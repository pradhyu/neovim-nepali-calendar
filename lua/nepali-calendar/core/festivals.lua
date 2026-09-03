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

-- Common English/Romanized festival keywords mapping to Nepali terms
local festival_synonyms = {
  dashain = { "दशैं", "दशमी", "विजया", "बिजया", "घटस्थापना", "फूलपाती", "फुलपाती", "महाअष्टमी", "महानवमी", "कोजाग्रत" },
  tihar = { "तिहार", "दिपावली", "दीपावली", "लक्ष्मी", "भाइटीका", "भाइ टीका", "काग तिहार", "कुकुर तिहार", "गोवर्धन", "म्ह" },
  deepawali = { "दिपावली", "दीपावली", "लक्ष्मी", "तिहार" },
  diwali = { "दिपावली", "दीपावली", "लक्ष्मी", "तिहार" },
  teej = { "तीज", "हरितालिका", "दरखाने", "ऋषिपञ्चमी", "ऋषि पञ्चमी" },
  holi = { "होली", "फागु", "चीरदाह" },
  chath = { "छठ", "छइठ" },
  chhath = { "छठ", "छइठ" },
  maghe = { "माघे", "माघ संक्रान्ति" },
  sankranti = { "संक्रान्ति", "संक्रान्ती" },
  saune = { "साउने", "साउन संक्रान्ती" },
  shivarathri = { "शिवरात्री", "महाशिवरात्री", "शिवरात्रि" },
  shivaratri = { "शिवरात्री", "महाशिवरात्री", "शिवरात्रि" },
  buddha = { "बुद्ध", "उभौली" },
  jayanti = { "जयन्ती", "जयन्ति" },
  lhosar = { "ल्होसार", "ल्होछार", "सोनाम", "ग्याल्पो", "तमु" },
  losar = { "ल्होसार", "ल्होछार", "सोनाम", "ग्याल्पो", "तमु" },
  janai = { "जनै", "रक्षाबन्धन", "ऋषितर्पणी" },
  purnima = { "पुर्णिमा", "पूर्णिमा", "पुन्ही" },
  aushi = { "औशी", "औँसी" },
  amavasya = { "औशी", "औँसी" },
  ekadashi = { "एकादशी" },
  krishna = { "श्रीकृष्ण", "जन्माष्टमी" },
  janmashtami = { "जन्माष्टमी", "श्रीकृष्ण" },
  ram = { "राम", "नवमी" },
  gaijatra = { "गाईजात्रा", "सापारू", "गाई जात्रा" },
  indrajatra = { "इन्द्रजात्रा", "इन्द्र जात्रा", "येँयाः" },
  ghodejatra = { "घोडेजात्रा", "घोडे जात्रा" },
  ratriyatri = { "रथयात्रा" },
  newyear = { "नव बर्ष", "नववर्ष", "नयाँ वर्ष" },
}

--- Search all festivals matching query string (supports Nepali, English & Romanized transliterations)
--- @param query string
--- @return table[] List of { date_key: string, year: integer, month: integer, day: integer, festival: string, tithi: string, is_holiday: boolean }
function M.search_events(query)
  if not query or query == "" then
    return {}
  end

  local q_lower = vim.trim(query):lower()
  local results = {}

  -- Expand Romanized query using synonyms
  local target_keywords = { q_lower }
  for term, synonyms in pairs(festival_synonyms) do
    if q_lower:find(term, 1, true) or term:find(q_lower, 1, true) then
      for _, syn in ipairs(synonyms) do
        table.insert(target_keywords, syn:lower())
      end
    end
  end

  for key, ev in pairs(festivals_data.events) do
    if ev.festival and ev.festival ~= "" then
      local fest_lower = ev.festival:lower()
      local tithi_lower = (ev.tithi or ""):lower()

      local matched = false
      for _, kw in ipairs(target_keywords) do
        if fest_lower:find(kw, 1, true) or tithi_lower:find(kw, 1, true) or key:find(kw, 1, true) then
          matched = true
          break
        end
      end

      if matched then
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
