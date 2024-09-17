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

IMAGE = openjournals/inara:edge

MAKEFILE_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: all
all: cff pdf tex html jats crossref native preprint

.PHONY: cff pdf tex html jats crossref native preprint
cff: $(TARGET_FOLDER)/paper.cff
pdf: $(TARGET_FOLDER)/paper.pdf
tex: $(TARGET_FOLDER)/paper.tex
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
	docker build --tag $(IMAGE) .

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
	rm -rf $(TARGET_FOLDER)/paper.tex
	rm -rf $(TARGET_FOLDER)/paper.pdf
	rm -rf $(TARGET_FOLDER)/paper.preprint
	rm -rf $(TARGET_FOLDER)/paper.preprint.tex
	rm -rf example/jats
	rm -rf example/paper.cff
	rm -rf example/paper.crossref
	rm -rf example/paper.html
	rm -rf example/paper.jats
	rm -rf example/paper.native
	rm -rf example/paper.tex
	rm -rf example/paper.pdf
	rm -rf example/paper.preprint
	rm -rf example/paper.preprint.tex
	rm -rf test/JATS-Publishing-1-2-MathML2-XSD.zip
	rm -rf test/JATS-journalpublishing1-elements.xsd
	rm -rf test/JATS-journalpublishing1.xsd
	rm -rf test/standard-modules
	rm -rf /tmp/JATS-Publishing-1-2-MathML2-XSD


## Tests

# Note that SOURCE_DATE_EPOCH=1234567890 corresponds to 1234567890 seconds
# from the unix epoch (January 1, 1970), which is in 2009

# Command used to invoke Inara. Sets an environment variable that makes the
# program ignore the real date.
INARA_TEST_CMD = docker run --rm \
	--user $(shell id -u):$(shell id -g) \
	--env SOURCE_DATE_EPOCH=1234567890 \
	-v $${PWD}:/data $(IMAGE)

# Uncomment this if you want to run tests locally instead of inside docker,
# though note that there might be non-trivial differences that are hard to explain.
# You also have to run `cp -r resources/* .` to copy all of the resource files
# into the root directory, since this makefile relies on this directory structure
# which the dockerfile creates
# INARA_TEST_CMD = SOURCE_DATE_EPOCH=1234567890 JOURNAL=joss OPENJOURNALS_PATH=$(MAKEFILE_DIR) sh scripts/entrypoint.sh

.PHONY: test test-golden-draft test-golden-pub
test: test-golden-draft test-golden-pub
test-golden-draft: \
	test-draft-crossref \
	test-draft-jats \
	test-draft-tex \
	test-draft-preprint
test-golden-pub: \
	test-pub-crossref \
	test-pub-jats \
	test-pub-tex \
	test-pub-preprint

.PHONY: test-pub-jats test-pub-preprint test-pub-%
test-pub-jats:
	$(INARA_TEST_CMD) -m test/metadata.yaml -o jats example/paper.md -p
	diff test/expected-pub/paper.jats/paper.jats example/jats/paper.jats
test-pub-preprint: GOLDEN_FILE = paper.preprint.tex
test-pub-%:        GOLDEN_FILE = paper.$*
test-pub-%:
	$(INARA_TEST_CMD) -m test/metadata.yaml -o $* example/paper.md -p
	diff test/expected-pub/$(GOLDEN_FILE) example/$(GOLDEN_FILE)

.PHONY: test-draft-jats test-draft-preprint test-draft-%
test-draft-jats:
	$(INARA_TEST_CMD) -o jats example/paper.md
	diff test/expected-draft/paper.jats/paper.jats example/jats/paper.jats
test-draft-preprint: GOLDEN_FILE = paper.preprint.tex
test-draft-%:        GOLDEN_FILE = paper.$*
test-draft-%:
	$(INARA_TEST_CMD) -o $* example/paper.md
	diff test/expected-draft/$(GOLDEN_FILE) example/$(GOLDEN_FILE)

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
validate-jats: test/expected-draft/paper.jats/paper.jats \
		test/JATS-journalpublishing1.xsd
	xmllint --schema test/JATS-journalpublishing1.xsd $< --noout
