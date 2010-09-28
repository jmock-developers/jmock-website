# Make sure you have installed the catalog files for XHTML on your local filesystem

SITE=jmock@www.jmock.org:public_html


CONTENT=$(shell find content -not -name '*~' -and -not -path '*/.svn*')
SKIN=$(shell find templates -not -name '*.xslt' -and -not -name '*~' -and -not -path '*/.svn*')
ASSETS=$(shell find assets -not -name '*~' -and -not -path '*/.svn*')

OUTDIR=skinned
OUTPUT=$(CONTENT:content/%=$(OUTDIR)/%) \
       $(SKIN:templates/%=$(OUTDIR)/%) \
       $(ASSETS:assets/%.svg=$(OUTDIR)/%.png)

all: $(OUTPUT)

$(OUTDIR)/index.html: content/news-rss2.xml

$(OUTDIR)/%.html: content/%.html templates/skin.xslt data/versions.xml
	@mkdir -p $(dir $@)
	xsltproc \
	  --nodtdattr \
	  --stringparam path $*.html \
	  --stringparam rpath `echo $(dir $*) | sed 's|[^/.]\+|..|g'` \
	  --stringparam baseuri http://www.jmock.org \
	  --output $@ \
	  templates/skin.xslt $<

$(OUTDIR)/%: content/%
	@mkdir -p $(dir $@)
	cp $< $@

$(OUTDIR)/%: templates/%
	@mkdir -p $(dir $@)
	cp $< $@

$(OUTDIR)/logo.png: WIDTH=176
$(OUTDIR)/information.png: WIDTH=32
$(OUTDIR)/warning.png: WIDTH=40
$(OUTDIR)/get-it.png: WIDTH=40
$(OUTDIR)/get-started.png: WIDTH=40
$(OUTDIR)/get-training.png: WIDTH=40
$(OUTDIR)/icon.png: WIDTH=24
$(OUTDIR)/preferences.png: WIDTH=28
$(OUTDIR)/%.png: assets/%.svg Makefile
	inkscape --without-gui --export-png=$@ --export-area-drawing --export-area-snap --export-width=$(WIDTH) $<

clean:
	rm -rf $(OUTDIR)/

again: clean all


SCANNED_FILES=content templates assets data Makefile

continually: 
	@while true; do \
	  if make all; \
	  then \
	    condition clear "jMock Website Build"; \
	  else \
	    condition alert "jMock Website Build" "jMock Website Build Broken"; \
	  fi ; \
	  inotifywait -r -qq -e modify -e delete $(SCANNED_FILES); \
	done

published: all
	rsync --recursive --checksum --delete --cvs-exclude --compress --stats --verbose --rsh=ssh $(OUTDIR)/* $(SITE)
