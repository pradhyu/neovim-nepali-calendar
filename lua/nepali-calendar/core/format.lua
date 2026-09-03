local config = require("nepali-calendar.config")

local M = {}

--- Format a full Nepali date string
--- @param info table
--- @param lang string "nepali"|"english"
--- @return string
function M.format_full(info, lang)
  lang = lang or config.options.language
  local localization = require("nepali-calendar.core.localization")

  local m_name = (lang == "nepali") and localization.months_nepali[info.month] or localization.months_english[info.month]
  local d_str = (lang == "nepali") and localization.to_devanagari(info.day) or tostring(info.day)
  local y_str = (lang == "nepali") and localization.to_devanagari(info.year) or tostring(info.year)
  local w_str = (lang == "nepali") and localization.days_nepali_full[info.wday] or localization.days_english_full[info.wday]

  local str = string.format("%s %s %s, %s", d_str, m_name, y_str, w_str)
  if info.tithi and info.tithi ~= "" then
    str = str .. string.format(" (%s)", info.tithi)
  end
  return str
end

--- Format standard ISO format (e.g. 2083-05-14)
--- @param info table
--- @return string
function M.format_iso(info)
  return string.format("%04d-%02d-%02d", info.year, info.month, info.day)
end

--- Format short string (e.g. "भाद्र १४, २०८३")
--- @param info table
--- @param lang string
--- @return string
function M.format_short(info, lang)
  lang = lang or config.options.language
  local localization = require("nepali-calendar.core.localization")
  local m_name = (lang == "nepali") and localization.months_nepali[info.month] or localization.months_english[info.month]
  local d_str = (lang == "nepali") and localization.to_devanagari(info.day) or tostring(info.day)
  local y_str = (lang == "nepali") and localization.to_devanagari(info.year) or tostring(info.year)
  return string.format("%s %s, %s", m_name, d_str, y_str)
end

return M
