local M = {}

local rashi_nepali = {
  "मेष (Aries)",
  "वृष (Taurus)",
  "मिथुन (Gemini)",
  "कर्कट (Cancer)",
  "सिंह (Leo)",
  "कन्या (Virgo)",
  "तुला (Libra)",
  "वृश्चिक (Scorpio)",
  "धनु (Sagittarius)",
  "मकर (Capricorn)",
  "कुम्भ (Aquarius)",
  "मीन (Pisces)",
}

local rahu_kaal_windows = {
  "04:30 PM – 06:00 PM", -- Sunday (1)
  "07:30 AM – 09:00 AM", -- Monday (2)
  "03:00 PM – 04:30 PM", -- Tuesday (3)
  "12:00 PM – 01:30 PM", -- Wednesday (4)
  "01:30 PM – 03:00 PM", -- Thursday (5)
  "10:30 AM – 12:00 PM", -- Friday (6)
  "09:00 AM – 10:30 AM", -- Saturday (7)
}

--- Calculate Panchanga for a Nepali Date
--- @param date_info table { year: integer, month: integer, day: integer, wday: integer, tithi: string|nil }
--- @return table { sunrise: string, sunset: string, day_length: string, sun_rashi: string, rahu_kaal: string, tithi: string }
function M.calculate(date_info)
  local month = math.max(1, math.min(12, date_info.month))
  local sun_rashi = rashi_nepali[month]
  local wday = math.max(1, math.min(7, date_info.wday or 1))
  local rahu = rahu_kaal_windows[wday]

  -- Solar Sunrise & Sunset approximation for Kathmandu (27.7° N)
  local day_of_year = (month - 1) * 30 + date_info.day
  local rad = day_of_year * (2.0 * math.pi / 365.0)

  local declination = 0.409 * math.sin(rad - 1.39)
  local lat = 27.7172 * math.pi / 180.0

  local val = -math.tan(lat) * math.tan(declination)
  val = math.max(-1.0, math.min(1.0, val))
  local hour_angle = math.acos(val)
  local day_length_hours = (2.0 * hour_angle * 180.0 / math.pi) / 15.0

  local solar_noon_hours = 12.18 -- Kathmandu local mean time adjustment (85.32°E vs 86.25°E)
  local rise_hours = solar_noon_hours - (day_length_hours / 2.0)
  local set_hours = solar_noon_hours + (day_length_hours / 2.0)

  local rise_h = math.floor(rise_hours)
  local rise_m = math.floor((rise_hours - rise_h) * 60)
  local set_h = math.floor(set_hours)
  local set_m = math.floor((set_hours - set_h) * 60)
  local len_h = math.floor(day_length_hours)
  local len_m = math.floor((day_length_hours - len_h) * 60)

  local sunrise_str = string.format("%02d:%02d AM", rise_h, rise_m)
  local sunset_str = string.format("%02d:%02d PM", (set_h > 12 and (set_h - 12) or set_h), set_m)
  local length_str = string.format("%dh %dm", len_h, len_m)

  return {
    sunrise = sunrise_str,
    sunset = sunset_str,
    day_length = length_str,
    sun_rashi = sun_rashi,
    rahu_kaal = rahu,
    tithi = date_info.tithi or "सामान्य तिथि",
  }
end

return M
