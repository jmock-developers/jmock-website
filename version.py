#!/usr/bin/python

import sys
import os
import re
from xml.etree.ElementTree import parse as parse_xml, dump as dump_xml

class VersionFormatError(ValueError):
	pass

class Version:
	format = r"\A(?P<major>\d+)\.(?P<minor>\d+)\.(?P<patch>\d+)(?:-RC(?P<prerelease>\d+))?\Z"
	pattern = re.compile(format)
    
	def __init__(self, major, minor, patch, prerelease=None):
		self.major = major
		self.minor = minor
		self.patch = patch
		self.prerelease = prerelease
	
	@property
	def is_stable(self):
		return self.prerelease is None
	
	@property
	def is_unstable(self):
		return not self.is_stable
	
	def __str__(self):
		return ("%d.%d.%d"%(self.major, self.minor, self.patch)) + \
			   (("-RC%d"%self.prerelease) if self.is_unstable else "")
	
	def __eq__(self, other):
		return self.__class__ is other.__class__ and self.__dict__ == other.__dict__		
	
	def __cmp__(self, other):
		result = cmp(self.major, other.major)
		if result != 0:
			return result
		result = cmp(self.minor, other.minor)
		if result != 0:
			return result
		result = cmp(self.patch, other.patch)
		if result != 0:
			return result
		
		return cmp(sys.maxint if self.prerelease is None else self.prerelease,
			   sys.maxint if other.prerelease is None else other.prerelease)
	
		

	@classmethod
	def parse(type, str):
		if str is None:
			return None
		else:
			match = type.pattern.match(str)
			if match is None:
				raise VersionFormatError, '"%s" is not a valid version string'%str
			
			return type(**dict((name, None if value is None else int(value)) 
			                   for (name,value) in match.groupdict().items()))


def selftest():
	assert Version.parse('1.2.3-RC4') == Version(1,2,3,4)
	assert Version.parse('1.2.3') == Version(1,2,3)
	assert Version.parse('1.2.3-RC4') == Version.parse('1.2.3-RC4')
	assert str(Version(1,2,3,4)) == '1.2.3-RC4'
	assert cmp(Version(1,2,3,4), Version(1,2,3,4)) == 0
	assert cmp(Version(1,2,3,4), Version(1,2,3,5)) == -1
	assert cmp(Version(1,2,3,4), Version(1,2,3,5)) == -1
	assert cmp(Version(1,2,3), Version(1,2,3,4)) == 1


class VersionUpgradeError(ValueError):
	pass


def assert_upgrade(old, new):
	if old >= new:
		raise VersionUpgradeError, "new version %s does not follow current version %s"%(new,old)

def update_version_file(versions_file_name, new_version_str):
	new_version = Version.parse(new_version_str)
	
	doc = parse_xml(versions_file_name)
	branch, = (branch for branch in doc.findall('branch') if int(branch.get('id')) == new_version.major)
	
	old_stable_version = Version.parse(branch.get('stable'))
	old_unstable_version = Version.parse(branch.get('unstable'))
	
	assert_upgrade(old_stable_version, new_version)
		
	if new_version.is_stable:
		branch.attrib['stable'] = str(new_version)
		if old_unstable_version is not None and old_unstable_version < new_version:
			del branch.attrib['unstable']
	else:
		if old_unstable_version is not None:
			assert_upgrade(old_unstable_version, new_version)
				
		branch.attrib['unstable'] = str(new_version)
	
	doc.write(open(versions_file_name, "w"))
	
if __name__ == '__main__':
	if len(sys.argv) != 3:
		sys.stderr.write("usage: %s <versions-file> <new-version>\n"%sys.argv[0])
		sys.exit(1)
	
	try:
		update_version_file(*sys.argv[1:3])
	except Exception, m:
		sys.stderr.write("error: ")
		sys.stderr.write(str(m))
		sys.stderr.write("\n")
		sys.exit(1)
