# Path to paper file
ARTICLE = paper.md
# The Journal under which the article is to be published.
# Currently either `joss` or `jose`.
JOURNAL = joss

# Path to OpenJournals resources like logos, csl style file, etc.
OPENJOURNALS_PATH = resources
# The pandoc executable
PANDOC = pandoc
# Folder in which the outputs will be placed
TARGET_FOLDER = publishing-artifacts

SHARED_OPTIONS = --data-dir=. \
  --defaults=$(OPENJOURNALS_PATH)/docker-defaults.yaml \
  --defaults=$(OPENJOURNALS_PATH)/$(JOURNAL)/defaults.yaml \
  --resource-path=.:$(OPENJOURNALS_PATH):$(dir $(ARTICLE)) \


.PHONY: all
all: \
		$(TARGET_FOLDER)/paper.pdf \
		$(TARGET_FOLDER)/paper.html

$(TARGET_FOLDER)/paper.pdf: $(ARTICLE) $(TARGET_FOLDER)
	mkdir -p $(TARGET_FOLDER)
	$(PANDOC) $(SHARED_OPTIONS)\
	  --output=$@ \
	  $<

$(TARGET_FOLDER)/paper.html: $(ARTICLE) $(TARGET_FOLDER)
	$(PANDOC) \
	  $(SHARED_OPTIONS) \
	  --extract-media=$(TARGET_FOLDER) \
	  --metadata=lang:en-US \
	  --to=html \
	  --output=$@ \
	  $<

$(TARGET_FOLDER):
	mkdir -p $(TARGET_FOLDER)

.PHONY: clean
clean:
	rm -rf $(TARGET_FOLDER)/paper.html
	rm -rf $(TARGET_FOLDER)/paper.pdf
