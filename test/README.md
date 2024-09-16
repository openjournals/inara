# Testing

Testing in Inara works by checking both the _draft_ mode and
_production_ mode (i.e., compiled with `-p`) for the following artifacts
using the `diff` command:

1. JATS XML (`jats`)
2. Crossref XML (`crossref`)
3. Preprint LaTeX (`preprint`)
4. PDF (`pdf`), though note this is a binary comparison

The _draft_ golden standard files are in the [expected-draft](expected-draft) folder while
the _production_ golden standard files are in the [expected-pub](expected-pub) folder.

## Maintaining the Golden Standard Files

If you make updates to the underlying [paper.md](../example/paper.md) file in the `/examples`
folder, you'll need to update at minimum the preprint and PDF. If you update the metadata
in the `paper.md` or make changes to the templates, you might also have to update the JATS
and Crossref XML files.

**How to update the golden standard files** - TBA
