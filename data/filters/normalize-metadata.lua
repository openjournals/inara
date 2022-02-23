local path = pandoc.path
local List = pandoc.List
local stringify = pandoc.utils.stringify

local scriptdir = path.directory(PANDOC_SCRIPT_FILE)

local normalize_authors = dofile(
  path.join{scriptdir, 'normalize', 'authors.lua'}
)

local List = require 'pandoc.List'
local stringify = pandoc.utils.stringify

local defaults = {
  archive_doi = '10.5281',
  editor = {
    name = 'Open Journals',
    url = 'https://joss.theoj.org',
    github_user = '@openjournals',
  },
  citation_author = '¿citation_author?',
  issue = '¿ISSUE?',
  page = '¿PAGE?',
  paper_url = 'NO PAPER URL',
  reviewers = {'openjournals'},
  software_repository_url = 'https://github.com/openjournals',
  software_review_url = 'https://github.com/openjournals',
  volume = '¿VOL?',
}

local function read_metadata(filename)
  local fh = io.open(stringify(filename))
  local content = (fh:read 'a') .. '\n...\n' -- YAML separator required
  return pandoc.read(content, 'commonmark+yaml_metadata_block').meta
end


function Meta (meta)
  -- read values from metadata file; values from that file take precedence
  -- except for authors and title
  if meta['article-info-file'] then
    for k, v in pairs(read_metadata(meta['article-info-file'])) do
      if k ~= 'authors' and k ~= 'title' then
        meta[k] = v
      end
    end
  end

  -- set default values where no value is set
  for k, v in pairs(defaults) do
    meta[k] = meta[k] or v
  end

  -- Normalize authors and affiliations; also sets article author-notes
  -- to keep track of equal contributors and corresponding authors.
  meta = normalize_authors(meta)
  meta.affiliation = meta.affiliations

  -- ensure 'article' table is available
  meta.article = meta.article or {}
  -- We take the variable part of the doi as publisher id
  meta.article['publisher-id'] = meta.article['publisher-id'] or
    string.format("%0d", tonumber(stringify(meta.page or '')) or 0)

  -- move keys from base level to article
  local keys = {
    -- articlekey => basekey
    ['doi'] = 'doi',
    ['fpage'] = 'page',
    ['issue'] = 'issue',
    ['volume'] = 'volume',
    ['publisher-id'] = 'publisher-id'
  }
  for articlekey, basekey in pairs(keys) do
    meta.article[articlekey] = meta.article[articlekey]
      or meta[basekey]
      or 'N/A'
    -- unset base key
    meta[basekey] = nil
  end

  -- Remove leading '@' from reviewers
  for i, reviewer in ipairs(meta.reviewers) do
    meta.reviewers[i] = stringify(reviewer):gsub('^@', '')
  end

  -- Unset author notes unless it contains values: The existence of this
  -- value affects the JATS template, and the output becomes invalid if
  -- the `<author-notes>` element is present but empty.
  if not next(meta.article['author-notes']) then
    meta.article['author-notes'] = nil
  end

  -- especially for crossref
  meta['title-meta'] = stringify(meta.title)

  return meta
end
