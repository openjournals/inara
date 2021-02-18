# Path to paper file
ARTICLE = paper.md
# The Journal under which the article is to be published.
# Currently either `joss` or `jose`.
JOURNAL = joss

# Path to OpenJournals resources like logos, csl style file, etc.
OPENJOURNALS_PATH = resources
# Data path, containing configs, filters.
INARA_DATA_PATH = data
# The pandoc executable
PANDOC = pandoc
# Folder in which the outputs will be placed
TARGET_FOLDER = publishing-artifacts

SHARED_OPTIONS = --data-dir=$(INARA_DATA_PATH) \
  --defaults=$(INARA_DATA_PATH)/shared.yaml \
  --defaults=$(OPENJOURNALS_PATH)/$(JOURNAL)/defaults.yaml \
  --resource-path=.:$(OPENJOURNALS_PATH):$(dir $(ARTICLE)) \


.PHONY: all
all: \
		$(TARGET_FOLDER)/paper.pdf \
		$(TARGET_FOLDER)/paper.html

$(TARGET_FOLDER)/paper.%: $(ARTICLE) \
		$(INARA_DATA_PATH)/%.yaml \
		$(TARGET_FOLDER)
	mkdir -p $(TARGET_FOLDER)
	$(PANDOC) $(SHARED_OPTIONS)\
    --defaults=$(INARA_DATA_PATH)/$*.yaml \
	  --extract-media=$(TARGET_FOLDER) \
	  --output=$@ \
	  $<

$(TARGET_FOLDER):
	mkdir -p $(TARGET_FOLDER)

.PHONY: clean
clean:
	rm -rf $(TARGET_FOLDER)/paper.html
	rm -rf $(TARGET_FOLDER)/paper.pdf
