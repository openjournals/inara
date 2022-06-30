-- Bail if we are converting to LaTeX.
if FORMAT:match('latex') then
  return {}
end

local ntables = 0
local nfigures = 0
local nequations = 0

local table_labels = {}
local figure_labels = {}
local equation_labels = {}
local labels = {}

local function collect_table_labels (tbl)
  ntables = ntables + 1
  return pandoc.walk_block(tbl, {
    Span = function (span)
      if span.attributes.label then
        table_labels[span.attributes.label] = tostring(ntables)
        labels[span.attributes.label] = {
          pandoc.Str('Table ' .. tostring(ntables))
        }
        span.content = {}
        return span
      end
    end
  })
end

local function collect_figure_labels (para)
  -- ensure that we are looking at an implicit figure
  if #para.content ~= 1 or para.content[1].t ~= 'Image' then
    return nil
  end
  local image = para.content[1]
  nfigures = nfigures + 1
  return pandoc.Para{
    pandoc.walk_inline(image, {
        Span = function (span)
          if span.attributes.label then
            figure_labels[span.attributes.label] = tostring(nfigures)
            labels[span.attributes.label] = {
              pandoc.Str('Figure ' .. tostring(nfigures))
            }
            span.content = {}
            return span
          end
        end
      })
  }
end

local function collect_equation_tags (span)
  local eq = span.content[1]
  if #span.content == 1 and eq.t == 'Math' and span.attributes.label then
    nequations = nequations + 1
    equation_labels[span.attributes.label] = tostring(nequations)
    labels[span.attributes.label] = {
      pandoc.Str('Equation ' .. tostring(nequations))
    }
  end
end

local function find_label (txt)
  local before, label, after = txt:match '(.*)\\label%{(.-)%}(.*)'
  return label, label and before .. after
end

local function parse_equation (txt)
  local is_equation = txt:match '^\\begin%{equation%}'
    or txt:match '^\\begin%{align%}'
  if is_equation then
    local para = pandoc.read(txt, 'latex').blocks[1]
    if not para.t == 'Para' then
      -- something weird happened. bail out!
      return nil
    end
    local label = find_label(txt)
    if label then
      local attr = pandoc.Attr(label, {'equation'}, {label=label})
      return {pandoc.Span(para.content, attr)}
    end
    return para.content
  end
  return nil
end

return {
  {
    RawInline = function (raw)
      if not raw.format == 'tex' then
        return nil
      end
      local is_ref_or_label = raw.text:match '^\\ref%{'
        or raw.text:match '^\\autoref'
        or raw.text:match '^\\label%{.*%}$'
      if is_ref_or_label then
        local first = pandoc.read(raw.text, 'latex').blocks[1]
        return first and first.content or nil
      end

      return parse_equation(raw.text)
    end,
    RawBlock = function (raw)
      if raw.format == 'tex' then
        local eq = parse_equation(raw.text)
        return eq and pandoc.Para(eq) or nil
      end
    end,
    Math = function (m)
      if m.mathtype == pandoc.DisplayMath then
        local label, stripped = find_label(m.text)
        if label then
          local attr = pandoc.Attr(label, {'equation'}, {label=label})
          m.text = stripped
          return pandoc.Span({m}, attr)
        end
      end
    end
  }, {
    Table = collect_table_labels,
    Para = collect_figure_labels,
    Span = collect_equation_tags,
  }, {
    Link = function (link)
      local ref = link.attributes.reference
      if not ref then
        return nil
      end
      local ref_target = link.attributes['reference-type'] == 'autoref'
        and labels[ref]
        or (table_labels[ref] or figure_labels[ref] or equation_labels[ref])
      if ref_target then
        link.content = ref_target
      end
      return link
    end
  }
}
