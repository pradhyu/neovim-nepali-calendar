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

return M
