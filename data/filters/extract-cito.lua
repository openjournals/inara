-- Copyright © 2017–2021 Albert Krewinkel, Robert Winkler
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.

local _version = '1.0.0'
local properties_and_aliases = {
  agreesWith = {
    'agreeWith',
    'agree_with',
    'agrees_with',
  },
  citation = {
  },
  cites = {
  },
  citesAsAuthority = {
    'asAuthority',
    'cites_as_authority',
    'as_authority',
    'authority'
  },
  citesAsDataSource = {
    "asDataSource",
    "dataSource",
    'cites_as_data_source',
    "as_data_source",
    "data_source"
  },
  citesAsEvidence = {
    'asEvidence',
    'cites_as_evidence',
    'as_evidence',
    'evidence'
  },
  citesAsMetadataDocument = {
    'asMetadataDocument',
    'metadataDocument',
    'cites_as_metadata_document',
    'as_metadata_document',
    'metadata_document',
    'metadata'
  },
  citesAsPotentialSolution = {
    'cites_as_potential_solution',
    'potentialSolution',
    'potential_solution',
    'solution'
  },
  citesAsRecommendedReading = {
    'asRecommendedReading',
    'recommendedReading',
    'cites_as_recommended_reading',
    'as_recommended_reading',
    'recommended_reading'
  },
  citesAsRelated = {
    'cites_as_related',
    'related',
  },
  citesAsSourceDocument = {
    'cites_as_source_document',
    'sourceDocument',
    'source_document'
  },
  citesForInformation = {
    'cites_for_information',
    'information',
  },
  compiles = {
  },
  confirms = {
  },
  containsAssertionFrom = {
  },
  corrects = {
  },
  credits = {
  },
  critiques = {
  },
  derides = {
  },
  describes = {
  },
  disagreesWith = {
    'disagrees_with',
    'disagree',
    'disagrees'
  },
  discusses = {
  },
  disputes = {
  },
  documents = {
  },
  extends = {
  },
  includesExcerptFrom = {
    'excerptFrom',
    'excerpt',
    'excerpt_from',
    'includes_excerpt_from',
  },
  includesQuotationFrom = {
    'quotationFrom',
    'includes_quotation_from',
    'quotation',
    'quotation_from'
  },
  linksTo = {
    'links_to',
    'link'
  },
  obtainsBackgroundFrom = {
    'backgroundFrom',
    'obtains_background_from',
    'background',
    'background_from'
  },
  providesDataFor = {
  },
  obtainsSupportFrom = {
  },
  qualifies = {
  },
  parodies = {
  },
  refutes = {
  },
  repliesTo = {
    'replies_to',
  },
  retracts = {
  },
  reviews = {
  },
  ridicules = {
  },
  speculatesOn = {
  },
  supports = {
  },
  updates = {
  },
  usesConclusionsFrom = {
    'uses_conclusions_from'
  },
  usesDataFrom = {
    'dataFrom',
    'uses_data_from',
    'data',
    'data_from'
  },
  usesMethodIn = {
    'methodIn',
    'uses_method_in',
    'method',
    'method_in'
  },
}

local default_cito_property = 'citation'

--- Map from cito aliases to the actual cito property.
local properties_by_alias = {}
for property, aliases in pairs(properties_and_aliases) do
  -- every property is an alias for itself
  properties_by_alias[property] = property
  for _, alias in pairs(aliases) do
    properties_by_alias[alias] = property
  end
end

--- Split citation ID into cito property and the actual citation ID. If
--- the ID does not seem to contain a CiTO property, the
--- `default_cito_property` will be returned, together with the
--- unchanged input ID.
local function split_cito_from_id (citation_id)
  local split_citation_id = {}
  local cito_props = {}
  local id_started = false

  for part in citation_id:gmatch('[^:]+') do
    if not id_started and properties_by_alias[part] then
      table.insert(cito_props, properties_by_alias[part])
    else
      id_started = true
    end

    if id_started then
      table.insert(split_citation_id, 1, part)
    end
  end

  if next(split_citation_id) == nill then
    table.insert(split_citation_id, table.remove(cito_props))
  end

  return cito_props, table.concat(split_citation_id, ':')
end

--- CiTO properties by citation.
local function store_cito (cito_cites, prop, cite_id)
  if not prop then
    return
  end
  if not cito_cites[cite_id] then
    cito_cites[cite_id] = {}
  end
  table.insert(cito_cites[cite_id], prop)
end


--- Returns a Cite filter function which extracts CiTO information and
--- add it to the given collection table.
local function extract_cito (cito_cites)
  return function (cite)
    for k, citation in pairs(cite.citations) do
      local cito_props, cite_id = split_cito_from_id(citation.id)
      for l, cito_prop in pairs(cito_props) do
        store_cito(cito_cites, cito_prop, cite_id)
      end
      citation.id = cite_id
    end
    return cite
  end
end

--- Lists of citation IDs, indexed by CiTO properties.
local properties_by_citation = {}

return {
  {
    Cite = extract_cito(properties_by_citation)
  },
  {
    Meta = function (meta)
      meta.citation_properties = properties_by_citation
      meta.bibliography = meta.bibliography or
        meta.cito_bibliography or
        meta['cito-bibliography']
      return meta
    end
  }
}
