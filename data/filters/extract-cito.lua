-- Copyright © 2017–2021 Albert Krewinkel, Robert Winkler
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--
-- Extracts CiTO (Citation Typing Ontology) properties from citations
-- such as `[@usesMethodIn:smith2018]`, so that citeproc sees the plain
-- citation key `smith2018`. The properties are stored in the metadata
-- field `citation_properties`, a map from citation key to the list of
-- CiTO property names used for that key.
--
-- Ported from BioHackrXiv (bhxiv-gen-pdf). Unlike the original, a
-- prefix is only stripped if what remains is a known reference, so keys
-- that contain colons (e.g., `DBLP:journals/corr/abs-1234`, `data:2019`)
-- are left untouched.

local properties_and_aliases = {
  agreesWith = { 'agreeWith', 'agree_with', 'agrees_with' },
  citation = {},
  cites = {},
  citesAsAuthority = {
    'asAuthority', 'cites_as_authority', 'as_authority', 'authority'
  },
  citesAsDataSource = {
    'asDataSource', 'dataSource', 'cites_as_data_source', 'as_data_source',
    'data_source'
  },
  citesAsEvidence = {
    'asEvidence', 'cites_as_evidence', 'as_evidence', 'evidence'
  },
  citesAsMetadataDocument = {
    'asMetadataDocument', 'metadataDocument', 'cites_as_metadata_document',
    'as_metadata_document', 'metadata_document', 'metadata'
  },
  citesAsPotentialSolution = {
    'cites_as_potential_solution', 'potentialSolution', 'potential_solution',
    'solution'
  },
  citesAsRecommendedReading = {
    'asRecommendedReading', 'recommendedReading',
    'cites_as_recommended_reading', 'as_recommended_reading',
    'recommended_reading'
  },
  citesAsRelated = { 'cites_as_related', 'related' },
  citesAsSourceDocument = {
    'cites_as_source_document', 'sourceDocument', 'source_document'
  },
  citesForInformation = { 'cites_for_information', 'information' },
  compiles = {},
  confirms = {},
  containsAssertionFrom = {},
  corrects = {},
  credits = {},
  critiques = {},
  derides = {},
  describes = {},
  disagreesWith = { 'disagrees_with', 'disagree', 'disagrees' },
  discusses = {},
  disputes = {},
  documents = {},
  extends = {},
  includesExcerptFrom = {
    'excerptFrom', 'excerpt', 'excerpt_from', 'includes_excerpt_from'
  },
  includesQuotationFrom = {
    'quotationFrom', 'includes_quotation_from', 'quotation', 'quotation_from'
  },
  linksTo = { 'links_to', 'link' },
  obtainsBackgroundFrom = {
    'backgroundFrom', 'obtains_background_from', 'background',
    'background_from'
  },
  obtainsSupportFrom = {},
  parodies = {},
  providesDataFor = {},
  qualifies = {},
  refutes = {},
  repliesTo = { 'replies_to' },
  retracts = {},
  reviews = {},
  ridicules = {},
  speculatesOn = {},
  supports = {},
  updates = {},
  usesConclusionsFrom = { 'uses_conclusions_from' },
  usesDataFrom = { 'dataFrom', 'uses_data_from', 'data', 'data_from' },
  usesMethodIn = { 'methodIn', 'uses_method_in', 'method', 'method_in' },
}

--- Map from CiTO aliases (and property names) to the CiTO property.
local properties_by_alias = {}
for property, aliases in pairs(properties_and_aliases) do
  properties_by_alias[property] = property
  for _, alias in ipairs(aliases) do
    properties_by_alias[alias] = property
  end
end

--- Splits a citation ID into a list of CiTO properties and the citation
--- key. Leading `property:` segments are removed only if the remaining
--- string is a known citation key; otherwise the ID is returned
--- unchanged, without properties.
local function split_cito_from_id (citation_id, is_known)
  if is_known(citation_id) then
    return {}, citation_id
  end
  local props = {}
  local rest = citation_id
  while true do
    local prefix, remainder = rest:match '^([^:]+):(.+)$'
    local prop = prefix and properties_by_alias[prefix]
    if not prop then
      return {}, citation_id
    end
    table.insert(props, prop)
    if is_known(remainder) then
      return props, remainder
    end
    rest = remainder
  end
end

function Pandoc (doc)
  -- Support the BioHackrXiv field name for the bibliography.
  doc.meta.bibliography = doc.meta.bibliography
    or doc.meta.cito_bibliography
    or doc.meta['cito-bibliography']

  -- `pandoc.utils.references` only returns cited references, but keys
  -- are cited with their CiTO prefix at this point. Use `nocite: @*` on
  -- a metadata-only copy to get all references.
  local allmeta = {}
  for k, v in pairs(doc.meta) do allmeta[k] = v end
  allmeta.nocite = pandoc.MetaInlines{
    pandoc.Cite({}, {pandoc.Citation('*', 'NormalCitation')})
  }
  local known = {}
  for _, ref in ipairs(pandoc.utils.references(pandoc.Pandoc({}, allmeta))) do
    known[ref.id] = true
  end
  local function is_known (id) return known[id] == true end

  -- CiTO properties per citation key, in order of first use.
  local properties = {}
  local seen = {}
  local function store (key, prop)
    properties[key] = properties[key] or pandoc.List()
    seen[key] = seen[key] or {}
    if not seen[key][prop] then
      seen[key][prop] = true
      properties[key]:insert(prop)
    end
  end

  doc = doc:walk {
    Cite = function (cite)
      for _, citation in ipairs(cite.citations) do
        local props, key = split_cito_from_id(citation.id, is_known)
        for _, prop in ipairs(props) do
          store(key, prop)
        end
        citation.id = key
      end
      return cite
    end
  }

  if next(properties) then
    doc.meta.citation_properties = properties
  end
  return doc
end
