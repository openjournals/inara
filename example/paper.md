---
title: >-
    Article Writing with Markdown and the Open Journals publishing pipeline
authors:
  - name: Jane Roe
    affiliations: "1, 2"
    equal-contrib: true
    orcid: 0000-1234-5678-910X
  - name: John Q. Doe
    affiliations: 1
    equal-contrib: true
  - name: Kari Nordmann
    affiliations: 1
  - name: Juan Pérez
    affiliations: 2
    email: perez@example.edu
    corresponding: true
affiliations:
  - name: Starfleet Academy
    index: 1
  - name: Bajoran Institute of Science
    index: 2
bibliography: paper.bib
tags:
  - example
  - lorem ipsum
header-includes:
  - |
    ```{=context}
    \setupinteraction[state=start]
    ```
---

# Summary

This is an example article for [JOSS](https://joss.theoj.org), the
Journal of Open Source Software [@smith2018]. The publishing method is
similar to the model described by @krewinkel2017, in that Markdown is
used as the input that serves as the source for the generated publishing
artifacts. JOSS also relies on the idea of "chatops-driven publishing"
[@chatops].

The metadata section at the beginning of this article is formatted using
[YAML], a human-friendly data serialization language [@yaml_website].
Please include all of the fields in your paper.


Random fun fact: One of the most cited papers of all times is about protein
determination [@bradford1976]. This is mentioned here for no other reason than
to ensure that the reference section at the end of this paper lists one
additional item.

By the way, if you hit a writers block while replacing the below with your own
content, then maybe checkout the paper by @upper1974.

[YAML]: https://yaml.org


# Statement of Need

The journal publisher, in most cases where you'd be reading this, Open
Journals, maintains a detailed and helpful
[article](https://joss.readthedocs.io/en/latest/submitting.html) on the
requirements that articles must satisfy in order to be considered for
publication in that journal. However, submission requirements do not
help with the technical aspects of paper writing. The process for JOSS
and similar journals is different, in that the paper should be written
in the lightweight markup language *Markdown*.

This article explains the technical details and describes the publishing
system's capabilities. It can also be used as a test document, or serve
as a template that can be used as a starting point.

# Markdown primer

Markdown is based on email conventions. It was developed by John Gruber
and Aaron Swartz. This section provides a brief introduction to Markdown
syntax. Certain details or alternatives will be omitted, 

If you are already familiar with Markdown, then you may want to skip
this section and continue with the description of [article metadata].

## Inline markup

The markup in Markdown should be semantic, not presentations. The table
below gives a small example.

+-----------------+---------------------+-------------------+
| Markup          | Markdown example    | Rendered output   |
+:================+:===================:+:=================:+
| emphasis        | `*this*`            | *this*            |
+-----------------+---------------------+-------------------+
| strong emphasis | `**that**`          | **that**          |
+-----------------+---------------------+-------------------+
| subscript       | `H~2~O`             | H~2~O             |
+-----------------+---------------------+-------------------+
| superscript     | `Ca^2+^`            | Ca^2+^            |
+-----------------+---------------------+-------------------+
| underline       | `[underline]{.ul}`  | [underline]{.ul}  |
+-----------------+---------------------+-------------------+
| small caps      | `[Small Caps]{.sc}` | [Small Caps]{.sc} |
+-----------------+---------------------+-------------------+
| inline code     | `` `return 23` ``   | `return 23`       |
+-----------------+---------------------+-------------------+

: Basic inline markup and examples

### Links

Link syntax is `[link description](targetURL)`. E.g., this link to the
[Journal of Open Source Software](https://joss.theoj.org/) is written as \
`[Journal of Open Source Software](https://joss.theoj.org/)`.

Open Journal publications are not limited by the constraints of print
publications. We encourage authors to use hyperlinks for websites and
other external resources. However, the standard scientific practice of
citing the relevant publications should be followed regardless.

### Images

Markdown syntax for an image is that of a link, preceded by an
exclamation mark `!`.

The main use of images in papers is within figures. An image is treated
as a figure if

1. it has a non-empty description, which will be used as the figure
   label and
2. it is the only element in a paragraph, i.e., it must be surrounded by
   blank lines.
   
Images that are larger than the text area are scaled to fit the page. It
can sometimes be useful to give images an explicit height and/or width,
e.g. when adding an image as part of a paragraph. The Markdown `![Nyan
cat](nyan-cat.png){height="9pt"}` includes the image "nyan-cat.png"
![Nyan cat](nyan-cat.png){height="9pt"} while scaling it to a height of
9 pt.

### Citations

For a case study on writers block, see @upper1974.

```markdown
For a case study on writers block, see @Upper1974.
```

### Mathematical Formulæ

Equations and other math content has is marked by dollar signs (`$`). A
single dollar sign should be used for math that will appear directly
within the text, and `$$` should be used when the formula is to be
presented in "display" style, i.e., centered and on a separate line. The
formula itself must be given using TeX syntax.

To give some examples: When discussing a variable $x$ or a short formula
like $\sin \frac{\pi}{2}$, we would write `$x$` and `$\sin
\frac{\pi}{2}$`, respectively. However, for more complex formulæ,
display style is more appropriate. Writing `$$\int_{-\infty}^{+\infty}
e^{-x^2} \, dx = \sqrt{\pi}$$` will give us

$$\int_{-\infty}^{+\infty} e^{-x^2} \, dx = \sqrt{\pi}$$

### Footnotes

Footnotes [^1]

[^1]: like this


## Blocks

The larger components of a document are called "blocks". 

### Headings

Headings are added with `# Title`.

Please start headings on the first level. The maximum supported level is
5, but paper authors should try to limit themselves to headings of the
first two levels.

### Lists

# Article metadata

## Names

Providing an author name is straight-forward: just set the `name`
attribute. However, sometimes fine-grained control over the name
is required.

### Name parts

There are many ways to describe the parts of names; we support the
following:

- given names,
- surname,
- dropping particle,
- non-dropping particle,
- and suffix.

We use a heuristic to parse names into these components. This
parsing may produce the wrong result, in which case it is
necessary to provide the relevant parts explicitly.

The respective field names are

- `given-names` (aliases: `given`, `first`, `firstname`)
- `surname` (aliases: `family`)
- `suffix`

The full display name will be constructed from these parts, unless
the `name` attribute is given as well.

### Particles

It's usually enough to place particles like "van", "von", "della",
etc. at the end of the given name or at the beginning of the
surname, depending on the details of how the name is used.

- `dropping-particle`
- `non-dropping-particle`

### Literal names

The automatic construction of the full name from parts is geared
towards common Western names. It may therefore be necessary
sometimes to provide the display name explicitly. This is possible
by setting the `literal` field, e.g., `literal: 宮水 三葉`.

### Example

```yaml
authors:
  - name: John Doe
    affiliation: '1'

  - given-names: Ludwig
    dropping-particle: van
    surname: Beethoven
    affiliation: '3'

  # not recommended, but common aliases can be used for name parts.
  - given: Louis
    non-dropping-particle: de
    family: Broglie
    affiliation: '4'
```

The name parts can also be collected under the author's `name`:

``` yaml
authors:
  - name:
      given-names: Kari
      surname: Nordmann

  - name:
      literal: 立花 瀧
      given-names: 瀧
      surname: 立花
```

# Internal references

Markdown has no default mechanism to handle document internal
references, often called "cross-references". This conflicts with goal of
[Open Journals] is to provide authors with a seamless and pleasant
writing experience. This includes convenient cross-reference generation,
which is why a limited set of LaTeX commands are supported.

[Open Journals]: https://theoj.org

# Lorem ipsum

## Loqui subitisque adhuc

Hordea cum gaudia proles, erat harundo sic vetus sequitur? Thalamos
novos. Frontes sed quaerunt novae, Hectora; nec cumque, auditi vocali
furores modo!

> Cito Troianae ad huic, ore Bacchi os illum tremor, obstantis. Ostendit
> rettulit reditum ictus simulacra dederat; nec quoque mearum nympharum
> valent requiritur esse. Pectoraque formae durastis poenas [aut
> vellent] conbiberat crura est. Atri Cecropio nefas movet; unda spinae
> spectans abactas [tam partus].

Seque erat cum, orbe? In aestu, nec signa: caesorum plebe vicibus Cycnum,
*petenda*.


[aut vellent]: https://example.com/
[tam partus]: http://joss.theoj.org/

# Behind the scenes

Readers may wonder about the reasons behind some of the choices made for
paper writing. Most often, the decisions were driven by radical
pragmatism. For example, Markdown is not only nearly ubiquitous in the
realms of software, but it can also be converted into many different
output formats. The archiving standard for scientific articles is JATS,
and the most popular publishing format is PDF. Open Journals has built
its pipeline based on [pandoc](https://pandoc.org), a universal document
converter that can produce both of these publishing formats -- and many
more.

A common method for PDF generation is to go via LaTeX. However, support
for tagging -- a requirement for accessible PDFs -- is not readily
available for LaTeX. The current method used ConTeXt, to produce tagged
PDF/A-3, a format suited for archiving [@pdfa3].

