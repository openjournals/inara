# Testing

Testing in Inara works by checking both the _draft_ mode and
_production_ mode (i.e., compiled with `-p`) for the following artifacts
using the `diff` command:

1. JATS XML (`jats`)
2. Crossref XML (`crossref`)
3. Preprint LaTeX (`preprint`)
4. PDF (`pdf`), though note this is a binary comparison
