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

ARTICLE_INFO_FILE = $(OPENJOURNALS_PATH)/default-article-info.yaml

.PHONY: all
all: cff pdf html jats crossref native preprint arxiv

.PHONY: cff pdf html jats crossref native preprint arxiv
cff: $(TARGET_FOLDER)/paper.cff
pdf: $(TARGET_FOLDER)/paper.pdf
html: $(TARGET_FOLDER)/paper.html
jats:	$(TARGET_FOLDER)/paper.jats
native:	$(TARGET_FOLDER)/paper.native
crossref:	$(TARGET_FOLDER)/paper.crossref
preprint:	$(TARGET_FOLDER)/paper.preprint
arxiv:	$(TARGET_FOLDER)/paper.arxiv.tex

$(TARGET_FOLDER)/paper.%: $(ARTICLE) \
		$(INARA_DATA_PATH)/defaults/%.yaml \
		$(OPENJOURNALS_PATH)/footer.csl \
		$(ARTICLE_INFO_FILE) \
		$(TARGET_FOLDER)
	INARA_ARTIFACTS_PATH=$(TARGET_FOLDER)/ $(PANDOC) \
	  --data-dir=$(INARA_DATA_PATH) \
	  --defaults=shared \
	  --defaults=$*.yaml \
	  --defaults=$(OPENJOURNALS_PATH)/$(JOURNAL)/defaults.yaml \
	  --resource-path=.:$(OPENJOURNALS_PATH):$(dir $(ARTICLE)) \
	  --metadata=article-info-file=$(ARTICLE_INFO_FILE) \
	  --variable=$(JOURNAL) \
	  --output=$@ \
	  $<

$(TARGET_FOLDER):
	mkdir -p $(TARGET_FOLDER)

.PHONY: docker-image
docker-image: Dockerfile
	docker build --tag openjournals/inara .

push-docker-image:
	docker push openjournals/inara

$(OPENJOURNALS_PATH)/footer.csl: $(OPENJOURNALS_PATH)/apa.csl
	sed -e 's/et-al-use-first="[0-9]*"/et-al-use-first="1"/g' \
	    -e 's/et-al-min="[0-9]*"/et-al-min="3"/g' \
	    -e 's/et-al-use-last="true"/et-al-use-last="false"/g' \
			$< > $@

.PHONY: clean
clean:
	rm -rf $(TARGET_FOLDER)/paper.cff
	rm -rf $(TARGET_FOLDER)/paper.crossref
	rm -rf $(TARGET_FOLDER)/paper.html
	rm -rf $(TARGET_FOLDER)/paper.jats
	rm -rf $(TARGET_FOLDER)/paper.native
	rm -rf $(TARGET_FOLDER)/paper.pdf
	rm -rf $(TARGET_FOLDER)/paper.preprint
	rm -rd $(TARGET_FOLDER)/paper.arxiv.tex
