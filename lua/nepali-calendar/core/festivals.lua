local festivals_data = require("nepali-calendar.core.festivals_data")

local M = {}

-- Fixed annual festivals fallback
M.fixed_annual_events = {
  ["01-01"] = { festival = "नववर्ष आरम्भ (New Year)", tithi = "", is_holiday = true },
  ["03-15"] = { festival = "राष्ट्रिय धान दिवस (Dhan Diwas)", tithi = "", is_holiday = false },
  ["04-01"] = { festival = "साउने संक्रान्ति (Saune Sankranti)", tithi = "", is_holiday = false },
  ["04-15"] = { festival = "खीर खाने दिन", tithi = "", is_holiday = false },
  ["06-03"] = { festival = "संविधान दिवस (Constitution Day)", tithi = "", is_holiday = true },
  ["10-01"] = { festival = "माघे संक्रान्ति (Maghe Sankranti)", tithi = "", is_holiday = true },
  ["10-16"] = { festival = "शहीद दिवस (Martyrs Day)", tithi = "", is_holiday = false },
  ["11-07"] = { festival = "राष्ट्रिय प्रजातन्त्र दिवस (Democracy Day)", tithi = "", is_holiday = true },
  ["11-24"] = { festival = "अन्तर्राष्ट्रिय महिला दिवस (Women's Day)", tithi = "", is_holiday = true },
  ["12-01"] = { festival = "चैते दशैं / घोडेजात्रा", tithi = "", is_holiday = false },
}

--- Lookup festival/tithi for a given Bikram Sambat date
--- @param year integer
--- @param month integer
--- @param day integer
--- @return { festival: string, tithi: string, is_holiday: boolean }|nil
function M.get_event(year, month, day)
  local key = string.format("%04d-%02d-%02d", year, month, day)
  if festivals_data.events[key] then
    return festivals_data.events[key]
  end

  local month_day_key = string.format("%02d-%02d", month, day)
  if M.fixed_annual_events[month_day_key] then
    return M.fixed_annual_events[month_day_key]
  end

  return nil
end

--- Search all festivals matching query string
--- @param query string
--- @return table[] List of { date_key: string, year: integer, month: integer, day: integer, festival: string, tithi: string, is_holiday: boolean }
function M.search_events(query)
  if not query or query == "" then
    return {}
  end

  local q_lower = vim.trim(query):lower()
  local results = {}

  for key, ev in pairs(festivals_data.events) do
    if ev.festival and ev.festival ~= "" then
      local fest_lower = ev.festival:lower()
      local tithi_lower = (ev.tithi or ""):lower()
      if fest_lower:find(q_lower, 1, true) or tithi_lower:find(q_lower, 1, true) or key:find(q_lower, 1, true) then
        local y, m, d = key:match("(%d%d%d%d)-(%d%d)-(%d%d)")
        table.insert(results, {
          date_key = key,
          year = tonumber(y),
          month = tonumber(m),
          day = tonumber(d),
          festival = ev.festival,
          tithi = ev.tithi or "",
          is_holiday = ev.is_holiday or false,
        })
      end
    end
  end

  -- Sort chronologically
  table.sort(results, function(a, b)
    return a.date_key < b.date_key
  end)

  return results
end

return M
