# Path to paper file
ARTICLE = paper.md
# The Journal under which the article is to be published.
# Currently either `joss` or `jose`.
JOURNAL = joss

DRAFT = true
# Path to OpenJournals resources like logos, csl style file, etc.
OPENJOURNALS_PATH = resources
# Data path, containing configs, filters.
INARA_DATA_PATH = data
# The pandoc executable
PANDOC = pandoc
# Folder in which the outputs will be placed
TARGET_FOLDER = publishing-artifacts

.PHONY: all
all: pdf html jats

.PHONY: pdf html jats
pdf: $(TARGET_FOLDER)/paper.pdf
html: $(TARGET_FOLDER)/paper.html
jats:	$(TARGET_FOLDER)/paper.jats

$(TARGET_FOLDER)/paper.%: $(ARTICLE) \
		$(INARA_DATA_PATH)/defaults/%.yaml \
		$(TARGET_FOLDER)
	mkdir -p $(TARGET_FOLDER)
	INARA_ARTIFACTS_PATH=$(TARGET_FOLDER)/ $(PANDOC) \
	  --data-dir=$(INARA_DATA_PATH) \
	  --defaults=shared \
	  --defaults=$*.yaml \
	  --defaults=$(OPENJOURNALS_PATH)/$(JOURNAL)/defaults.yaml \
	  --resource-path=.:$(OPENJOURNALS_PATH):$(dir $(ARTICLE)) \
	  --metadata=draft:$(DRAFT) \
	  --metadata-file=$(OPENJOURNALS_PATH)/$(JOURNAL)/journal-metadata.yaml \
	  --variable=$(JOURNAL) \
	  --output=$@ \
	  $<

$(TARGET_FOLDER):
	mkdir -p $(TARGET_FOLDER)

.PHONY: docker-image
docker-image: Dockerfile
	docker build --tag openjournals/inara .

.PHONY: clean
clean:
	rm -rf $(TARGET_FOLDER)/paper.html
	rm -rf $(TARGET_FOLDER)/paper.jats
	rm -rf $(TARGET_FOLDER)/paper.pdf
