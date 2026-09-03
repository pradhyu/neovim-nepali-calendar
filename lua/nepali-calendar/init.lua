local config = require("nepali-calendar.config")
local ui = require("nepali-calendar.ui")
local converter = require("nepali-calendar.core.converter")
local calculator = require("nepali-calendar.core.calculator")
local format = require("nepali-calendar.core.format")

local M = {}

--- Setup user options
--- @param opts table|nil
function M.setup(opts)
  config.setup(opts)
end

--- Open or toggle the floating Nepali Calendar popup
function M.toggle()
  ui.open()
end

--- Open the floating Nepali Calendar popup
function M.open()
  ui.open()
end

--- Close the floating Nepali Calendar popup
function M.close()
  ui.close()
end

--- Get today's Nepali date info table
--- @param use_nepal_time boolean|nil
--- @return table
function M.today(use_nepal_time)
  local t = converter.today(use_nepal_time)
  return converter.date_info(t.year, t.month, t.day)
end

--- Statusline component helper (e.g. for lualine or custom statusline)
--- @param opts table|nil { lang = "nepali"|"english", show_icon = true, format = "short"|"full"|"iso" }
--- @return string
function M.statusline(opts)
  opts = opts or {}
  local lang = opts.lang or config.options.language
  local t = converter.today(true)
  local info = converter.date_info(t.year, t.month, t.day)
  local icon = (opts.show_icon ~= false) and "🇳🇵 " or ""

  if opts.format == "iso" then
    return icon .. format.format_iso(info)
  elseif opts.format == "full" then
    return icon .. format.format_full(info, lang)
  else
    return icon .. format.format_short(info, lang)
  end
end

--- Convert AD date to BS
--- @param y integer
--- @param m integer
--- @param d integer
--- @return table
function M.ad_to_bs(y, m, d)
  local bs = converter.ad_to_bs(y, m, d)
  return converter.date_info(bs.year, bs.month, bs.day)
end

--- Convert BS date to AD
--- @param y integer
--- @param m integer
--- @param d integer
--- @return table|nil
function M.bs_to_ad(y, m, d)
  return converter.bs_to_ad(y, m, d)
end

--- Calculate age in Bikram Sambat
--- @param dob { year: integer, month: integer, day: integer }
--- @return table|nil
function M.calculate_age(dob)
  return calculator.calculate_age(dob)
end

--- Open interactive festival search
function M.search()
  ui.open_search_dialog()
end

--- Search festivals programmatically
--- @param query string
--- @return table[]
function M.search_events(query)
  return require("nepali-calendar.core.festivals").search_events(query)
end

return M
