# Make sure you have installed the catalog files for XHTML on your local filesystem

GH_PAGES=../jmock-gh-pages
CONTENT=$(shell find content -not -name '*~' -and -not -path '*/.git*')
SKIN=$(shell find templates -not -name '*.xslt' -and -not -name '*~' -and -not -path '*/.git*')
ASSETS=$(shell find assets -not -name '*~' -and -not -path '*/.git*')
JAVADOCS=$(shell find javadoc -name '*.zip')

OUTDIR=skinned
OUTPUT=$(CONTENT:content/%=$(OUTDIR)/%) \
       $(SKIN:templates/%=$(OUTDIR)/%) \
       $(ASSETS:assets/%.svg=$(OUTDIR)/%.png) \
       $(JAVADOCS:javadoc/%-javadoc.zip=$(OUTDIR)/javadoc/%/index.html)

foo: $(OUTDIR)/javadoc/jmock-1.2.0/index.html

all: $(OUTPUT)

$(OUTDIR)/index.html: content/news-rss2.xml

$(OUTDIR)/%.html: content/%.html templates/skin.xslt data/versions.xml
	@mkdir -p $(dir $@)
	xsltproc \
	  --nodtdattr \
	  --nonet \
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

$(OUTDIR)/javadoc/%/index.html: javadoc/%-javadoc.zip
	@mkdir -p $(@D)
	@rm -r $(@D)
	@unzip -q -d $(dir $(@D)) $<

clean:
	rm -rf $(OUTDIR)/

again: clean all


SCANNED_FILES=content templates assets data Makefile javadoc

published: all
	rm -r $(GH_PAGES)/*
	cp -r $(OUTDIR)/* $(GH_PAGES)/
	@echo ">>>>>>>>>>> commit and push $(GH_PAGES) to github <<<<<<<<<<<<<<<<<"

    # rsync --recursive --checksum --delete --cvs-exclude --compress --stats --verbose --rsh=ssh $(OUTDIR)/* $(SITE)
