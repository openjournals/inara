---
title: Reviewer Credits
---

Reviewers can be credited for their work in the published paper by including their names and ORCIDs in the metadata.

**Important:** This reviewer information must be added to the paper's YAML frontmatter by the paper authors (or reviewers themselves) after the review process is complete but before the paper is published. The system does not automatically extract reviewer information from the review process.

**Note:** This feature displays reviewer credits in the published paper with ORCID badges (similar to authors) and links to ORCID profiles. However, we are not ORCID members (membership would nearly double our annual operating budget), so we cannot automatically update reviewers' ORCID records with their peer review activities. Reviewers who wish to add these reviews to their ORCID record must do so manually.

## Basic Usage

Add reviewers to your paper's YAML frontmatter:

```yaml
reviewers:
  - name: Jane Smith
    orcid: 0000-0001-2345-6789
  - name: John Doe
    orcid: 0000-0002-3456-7890
```

The `name` field is required. The `orcid` field is optional but recommended for proper academic credit.

## Name Formats

Reviewer names support the same flexible formats as author names:

### Simple Name

```yaml
reviewers:
  - name: Jane Smith
    orcid: 0000-0001-2345-6789
```

### Structured Name Parts

You can specify given names and surname separately, just like for authors:

```yaml
reviewers:
  - given-names: John
    surname: Doe
    orcid: 0000-0002-3456-7890
```

The following name field aliases are supported (same as for authors):

- **Given names**: `given-names`, `given`, `given_name`, `first`, `firstname`
- **Surname**: `surname`, `family`, `family_name`, `last`, `lastname`

### Name Only (No ORCID)

Reviewers can be listed without an ORCID. In this case, the name will appear as plain text without a link:

```yaml
reviewers:
  - name: Jane Smith
```

## ORCID Support

ORCIDs are validated using checksum verification. You can provide ORCIDs in either format:

- Full URL: `https://orcid.org/0000-0001-2345-6789`
- With dashes: `0000-0001-2345-6789`

Invalid ORCIDs will be silently ignored and not displayed in the output.

When a valid ORCID is provided:
- The reviewer's name becomes a hyperlink to their ORCID profile
- The ORCID badge (iD icon) appears next to their name
- Both the name and badge link to the same ORCID profile

## Complete Example

```yaml
---
title: My Research Paper
authors:
  - name: Research Author
    orcid: 0000-0002-9455-0796
reviewers:
  - name: Jane Smith
    orcid: 0000-0001-2345-6789
  - given-names: John
    surname: Doe
    orcid: 0000-0002-3456-7890
  - name: Anonymous Reviewer
---

# Summary

Your paper content here...
```

## Output

In the generated PDF, reviewers are displayed in the sidebar:

**With ORCID:**
```
Reviewers:
• Jane Smith iD
• John Doe iD
```
(Name and iD icon both link to ORCID profile)

**Without ORCID:**
```
Reviewers:
• Anonymous Reviewer
```
(Plain text, no link)

## Backward Compatibility

The existing workflow where reviewers are provided via external article-info metadata files continues to work without any changes. In this legacy mode, reviewers are specified as GitHub handles (e.g., `@reviewer1`) and link to GitHub profiles.

This enhanced format is only used when reviewers are explicitly added to the paper's YAML frontmatter.
