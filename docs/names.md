---
title: Author Names
---

Providing an author name is straight-forward: just set the `name`
attribute. However, sometimes fine-grained control over the name
is required.

## Name parts

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
