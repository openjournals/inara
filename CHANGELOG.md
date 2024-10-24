# Changelog

`Inara` uses [SemVer][] (semantic versioning).

## Inara v1.1.3

Released 2024-10-24.

All contributions by Juanjo Bazán.

- Fix CrossRef XML output. The affiliations element is moved
  before the ORCID element.

## Inara v1.1.2

Released 2024-10-23.

All contributions by Charles Taplev Hovt.

- Fix bug in the height of ROR logos.
  (https://github.com/openjournals/inara/pull/90)
- Fix bug in application of `prepare-affiliations.lua` filter.
- Fix a bug in the injection of `SOURCE_DATE_EPOCH` in tests.
  (https://github.com/openjournals/inara/pull/86)
- Fix test files. (https://github.com/openjournals/inara/pull/86,
  https://github.com/openjournals/inara/pull/85)
- Switch testing to work on tex instead of pdf.
  (https://github.com/openjournals/inara/pull/82)
- Refactor testing folders.
  (https://github.com/openjournals/inara/pull/84)

## Inara v1.1.1

Released 2024-09-05.

- Ignore failures around affiliations.

## Inara v1.1.0

Released 2024-09-04.

- Support for ROR identifiers (Charles Tapley Hoyt)
- Code cleanup

## Inara v1.0.0

Released 2024-06-10.

Initial release. May the program live long and prosper.

- *Pandoc*: 3.2.0
- *TeXLive*: 2024

[SemVer]: https://semver.org
