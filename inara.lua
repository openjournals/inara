#!/usr/bin/env pandoc-lua

PANDOC_VERSION:must_be_at_least {3,2}
local arg = arg or {[0] = 'inara.lua'}

-- Imports
local io = require 'io'
local pandoc = require 'pandoc'
local List = require 'pandoc.List'
local mediabag = require 'pandoc.mediabag'
local path = require 'pandoc.path'
local system = require 'pandoc.system'
local template = require 'pandoc.template'
local utils = require 'pandoc.utils'
-- Functions
local sha1 = utils.sha1
local run_lua_filter = utils.run_lua_filter
local read = pandoc.read

local usage = table.concat {
  'Usage: %s [OPTIONS] INPUT_FILE\n',
  'Options:\n',
  '\t-l: create log files for all formats\n',
  '\t-m: article info file; YAML file contains article metadata\n',
  '\t-o: comma-separated list of output format; defaults to jats,pdf\n',
  '\t-p: flag to force the production of a publishing PDF\n',
  '\t-r: flag to produce a retraction-notice publishing PDF\n',
  '\t-v: increase verbosity; can be given multiple times\n',
}

-- script options
local options = {
  verbosity = 0,
  outformats = {'jats','pdf'},
  retraction = false,
  log = false,
  article_info_file = nil,
  draft = true,
}
local positional_args = List{}

do
  local i = 1
  while i <= #arg do
    if arg[i] == '-l' then
      options.log = true
      i = i + 1
    elseif arg[i] == '-m' then
      options.article_info_file = arg[i+1]
      i = i + 2
    elseif arg[i] == '-o' then
      options.outformats = List{}
      for f in arg[i+1]:gmatch '[^,]+' do
        options.outformats:insert(f)
      end
      i = i + 2
    elseif arg[i] == '-r' then
      options.retraction = true
      i = i + 1
    elseif arg[i] == '-p' then
      options.draft = false
      i = i + 1
    elseif arg[i] == '-m' then
      options.verbosity = options.verbosity + 1
      i = i + 1
    elseif arg[i]:match '^%-' then
      io.stderr:write(usage)
    else
      positional_args:insert(arg[i])
      i = i + 1
    end
  end
end

local function ensure_absolute (filepath)
  return path.normalize(
    path.is_absolute(filepath)
    and filepath
    or path.join {system.get_working_directory(), filepath}
  )
end

local input_file = positional_args[1] or 'paper.md'

-- Base settings
local input_format = 'markdown'
local paper_directory = path.directory(input_file)
local output_directory = ensure_absolute(paper_directory)

local data_dir = path.join {
  os.getenv 'OPENJOURNALS_PATH' or ensure_absolute(path.directory(arg[0])),
  'data'
}

local resources_path = os.getenv 'OPENJOURNALS_PATH'
  or path.join {ensure_absolute(path.directory(arg[0])), 'resources'}

-- FIXME!!
local journal_metadata = {
  ['csl'] = 'apa.csl',
  ['joss'] = true,
  ['joss_resource_url'] = 'N/A',
  ['journal'] = {
    ['abbrev-title'] = 'JOSS',
    ['alias'] = 'joss',
    ['url'] = 'https://joss.theoj.org',
    ['doi'] = '10.21105/joss',
    ['title'] = 'Journal of Open Source Software',
    ['publisher-name'] = 'Open Journals',
    ['issn'] = '2475-9066',
    ['eissn'] = '2475-9066',
  },
  ['link-citations'] = true,
  ['copyright'] = {
    ['statement'] =
      "Authors of papers retain copyright and release the work under a " ..
      "Creative Commons Attribution 4.0 International License (CC BY 4.0)",
    ['holder'] = 'The article authors',
    ['year'] = '2024',
    ['type'] = 'open-access',
    ['link'] = 'https://creativecommons.org/licenses/by/4.0/',
    ['text'] =
      "Authors of papers retain copyright and release the work under a " ..
      "Creative Commons Attribution 4.0 International License (CC BY 4.0)"
  },
  ['aas_logo_path'] = path.join{resources_path, 'joss/aas-logo.png'},
  ['europar_logo_path'] = path.join{resources_path, 'joss/europar-logo.png'},
  ['logo_path'] = path.join{resources_path, 'joss/logo.png'},
}
--
-- File helpers
--

local function read_file (filename)
  local fh = assert(io.open(filename, 'r'), "Couldn't open " .. filename)
  local contents = fh:read 'a'
  fh:close()
  return contents
end

local function write_file (filename, contents)
  if options.verbosity >= 0 then
    io.stderr:write('Writing file ' .. filename .. '\n')
  end
  local fh = io.open(filename, 'wb')
  fh:write(contents)
  fh:close()
end


--- Map from old image filepaths to new names.
local updated_filepath = {}

local function unnest (filepath, contents)
  if updated_filepath[filepath] then
    return updated_filepath
  end

  local newpath = path.filename(filepath)
  if updated_filepath[newpath] then
    -- the filename is already in use. Prefix with sha1 hash.
    newpath = sha1(contents) .. '-' .. filepath
  end
  updated_filepath[filepath] = newpath
  return newpath
end

local function unnest_images (doc)
  local newpath
  for fp, mt, contents in mediabag.items() do
    -- Delete all mediabag items and re-insert them under their fixed
    -- name.
    newpath = unnest(fp, contents)
    mediabag.delete(fp)
    mediabag.insert(newpath, mt, contents)
  end
  return doc:walk {
    Image = function (img)
      img.src = updated_filepath[img.src] or img.src
      return img
    end
  }
end

--- Filters run for all formats
local shared_filters = List {
  'parse-latex.lua',
  'inline-cited-references.lua',
  utils.citeproc,
  'normalize-metadata.lua',
  'time.lua',
  'normalize-author-names.lua',
  'substitute-in-format.lua',
}

local formats = {
  crossref = {
    format = 'html5',
    filters = List {
      'doi-batch-id.lua',
      'flatten-references.lua',
    },
    template = 'templates/default.crossref'
  },
  jats = {
    format = 'jats_publishing',
    extensions = {element_citations = true},
    filters = List {
      'resolve-references.lua',
      'remove-references-heading.lua',
      'orcid-uri.lua',
      unnest_images,
    },
    outfile = function (_)
      return path.join{'jats', 'paper.jats'}
    end,
    write_output = function (jats, outfile)
      local outdir = outfile
      outfile = path.join{outdir, 'paper.jats'}
      system.make_directory(outdir, true)
      write_file(outfile, jats)
      pandoc.mediabag.write(outdir)
      mediabag.write(outdir)
    end
  },
  pdf = {
    format = 'latex',
    filters = List{
      'draft.lua',
      'self-citation.lua',
      'fix-bibentry-spacing.lua',
    },
    reference_links = true,
    template = 'templates/default.latex',
    variables = {
      -- styling options
      colorlinks = true,
      linkcolor = '[rgb]{0.0, 0.5, 1.0}',
      urlcolor = '[rgb]{0.0, 0.5, 1.0}',
    },
    write_output = function (tex, outfile)
      for _, key in ipairs{'logo_path', 'europar_logo_path', 'aas_logo_path'} do
        local filepath = journal_metadata[key]
        local content, mt = pandoc.mediabag.fetch(filepath)
        pandoc.mediabag.insert(path, content, mt)
      end
      system.with_temporary_directory(
        'inara-pdf',
        function (dirname)
          system.with_working_directory(dirname, function ()

            mediabag.write(dirname)
            local texfh = io.open(path.join{dirname, 'inara-paper.tex'}, 'w')
            texfh:write(tex)
            texfh:close()
            os.execute 'latexmk -lualatex inara-paper.tex'
            local pdffile = path.join{dirname, 'inara-paper.pdf'}
            local fh = io.open(outfile, 'w')
            fh:write(io.open(pdffile):read'a')
            fh:close()
          end)
        end
      )
    end
  },
}

local function get_template (conf)
  return conf.template
    and io.open(path.join{data_dir, conf.template}):read 'a'
    or template.default(conf.format)
end

local default_article_info = {
  ['archive_doi'] = '10.5281',
  ['citation_author'] = '¿citation_author?',
  ['doi_batch_id'] = 'N/A',
  ['draft'] = options.draft,
  ['editor'] = {
    name = 'Open Journals',
    url = 'https://joss.theoj.org',
    github_user = '@openjournals',
  },
  ['editor_name'] = 'Pending Editor',
  ['editor_url'] = 'https://example.com',
  ['formatted_doi'] = 'DOI unavailable',
  ['issue'] = '¿ISSUE?',
  ['page'] = '¿PAGE?',
  ['paper_url'] = 'NO PAPER URL',
  ['published_at'] = '1970-01-01',
  ['repository'] = 'NO_REPOSITORY',
  ['review_issue_url'] = 'N/A',
  ['reviewers'] = List{'openjournals'},
  ['software_repository_url'] = 'https://github.com/openjournals',
  ['software_review_url'] = 'https://github.com/openjournals',
  ['submitted_at'] = '1970-01-01',
  ['volume'] = '¿VOL?',
}

local doc = read(read_file(input_file), input_format)
doc = system.with_working_directory(
  paper_directory,
  function () return mediabag.fill(doc) end
)
for key, value in pairs(default_article_info) do
  doc.meta[key] = value
end
for key, value in pairs(journal_metadata) do
  doc.meta[key] = value
end
-- Set some specific metadata
doc.meta.lang = 'en-US'  -- articles must be written in American English
doc.meta['article-info-file'] = options.article_info_file and
  ensure_absolute(options.article_info_file)
doc.meta['footer-csl'] = path.join{resources_path, 'footer.csl'}
doc.meta['csl'] = path.join{resources_path, 'apa.csl'}

local doc_orig = doc:clone()
for _, format in ipairs(options.outformats) do
  io.stderr:write('Now converting to ' .. format .. '\n')
  doc = doc_orig:clone()
  local format_conf = assert(formats[format], 'Unsupported format: ' .. format)
  local output_format = format_conf.format
  FORMAT = output_format
  system.with_working_directory(
    paper_directory,
    function ()
      for _, filter in ipairs(shared_filters .. format_conf.filters) do
        if type(filter) == 'string' then
          local filter_path = path.join{data_dir, 'filters', filter}
          PANDOC_SCRIPT_FILE = filter_path
          doc = run_lua_filter(doc, filter_path)
        elseif type(filter) == 'function' then
          doc = filter(doc)
        else
          error("Cannot handle filter of type " .. type(filter))
        end
      end
    end
  )

  -- Writer options
  local wopts = {
    reference_links = format_conf.reference_links,
    template = get_template(format_conf),
    variables = format_conf.variables
  }
  local outstr = pandoc.write(doc, format_conf, wopts)
  format_conf.outfile = format_conf.outfile
    or function(_) return 'paper.' .. format end
  local outfile = path.join{output_directory, format_conf.outfile(doc)}
  if format_conf.write_output then
    format_conf.write_output(outstr, outfile)
  else
    write_file(outfile, outstr)
  end
end
