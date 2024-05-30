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
all: cff pdf html jats crossref native preprint

.PHONY: cff pdf html jats crossref native preprint
cff: $(TARGET_FOLDER)/paper.cff
pdf: $(TARGET_FOLDER)/paper.pdf
html: $(TARGET_FOLDER)/paper.html
jats:	$(TARGET_FOLDER)/paper.jats
native:	$(TARGET_FOLDER)/paper.native
crossref:	$(TARGET_FOLDER)/paper.crossref
preprint:	$(TARGET_FOLDER)/paper.preprint

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
	rm -rf $(TARGET_FOLDER)/paper.preprint.tex
	rm -rf test/JATS-Publishing-1-2-MathML2-XSD.zip
	rm -rf test/JATS-journalpublishing1-elements.xsd
	rm -rf test/JATS-journalpublishing1.xsd
	rm -rf test/standard-modules
	rm -rf /tmp/JATS-Publishing-1-2-MathML2-XSD


## Tests

# Command used to invoke Inara. Sets an environment variable that makes the
# program ignore the real date.
INARA_TEST_CMD = docker run --rm -it \
	--env SOURCE_DATE_EPOCH=1234567890 \
	-v $${PWD}:/data openjournals/inara:latest

.PHONY: test golden-tests test-jats test-%
test: golden-tests

test-golden: test-crossref test-jats test-pdf test-preprint

test-jats:     GOLDEN_FILE = paper.jats/paper.jats
test-preprint: GOLDEN_FILE = paper.preprint.tex
test-%:        GOLDEN_FILE = paper.$*
test-%:
	$(INARA_TEST_CMD) -o $* example/paper.md
	diff example/$(GOLDEN_FILE) test/expected-$(GOLDEN_FILE)

NCBI_FTP = "ftp://ftp.ncbi.nih.gov/pub/jats/publishing/1.2/xsd/"
test/JATS-Publishing-1-2-MathML2-XSD.zip:
	curl --output $@ \
	  "$(NCBI_FTP)/JATS-Publishing-1-2-MathML2-XSD.zip"

test/JATS-journalpublishing1.xsd: \
		test/JATS-Publishing-1-2-MathML2-XSD.zip
	unzip -q -d /tmp $<
	cp -a /tmp/JATS-Publishing-1-2-MathML2-XSD/* test
	rm -rf /tmp/JATS-Publishing-1-2-MathML2-XSD

.PHONY: validate-jats
validate-jats: test/expected-paper.jats/paper.jats \
		test/JATS-journalpublishing1.xsd
	xmllint --schema test/JATS-journalpublishing1.xsd $< --noout
