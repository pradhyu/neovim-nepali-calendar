local converter = require("nepali-calendar.core.converter")
local localization = require("nepali-calendar.core.localization")

local M = {}

--- Calculate precise age in Bikram Sambat
--- @param dob { year: integer, month: integer, day: integer }
--- @param as_of { year: integer, month: integer, day: integer }|nil
--- @return table|nil
function M.calculate_age(dob, as_of)
  as_of = as_of or converter.today()
  local dob_ad = converter.bs_to_ad(dob.year, dob.month, dob.day)
  local as_of_ad = converter.bs_to_ad(as_of.year, as_of.month, as_of.day)

  if not dob_ad or not as_of_ad then
    return nil
  end

  local y_diff = as_of.year - dob.year
  local m_diff = as_of.month - dob.month
  local d_diff = as_of.day - dob.day

  if d_diff < 0 then
    m_diff = m_diff - 1
    local prev_month = (as_of.month == 1) and 12 or (as_of.month - 1)
    local prev_year = (as_of.month == 1) and (as_of.year - 1) or as_of.year
    local days_in_prev = converter.days_in_month(prev_year, prev_month)
    d_diff = d_diff + days_in_prev
  end

  if m_diff < 0 then
    y_diff = y_diff - 1
    m_diff = m_diff + 12
  end

  if y_diff < 0 then
    return nil
  end

  local dob_time = os.time({ year = dob_ad.year, month = dob_ad.month, day = dob_ad.day, hour = 12 })
  local as_of_time = os.time({ year = as_of_ad.year, month = as_of_ad.month, day = as_of_ad.day, hour = 12 })
  local total_days = math.floor(os.difftime(as_of_time, dob_time) / 86400)

  -- Next birthday countdown
  local next_bday_year = as_of.year
  if dob.month < as_of.month or (dob.month == as_of.month and dob.day < as_of.day) then
    next_bday_year = next_bday_year + 1
  end

  local max_days_next = converter.days_in_month(next_bday_year, dob.month)
  local valid_day = math.min(dob.day, max_days_next)
  local next_bday_ad = converter.bs_to_ad(next_bday_year, dob.month, valid_day)
  local next_bday_in_days = 0
  if next_bday_ad then
    local next_bday_time = os.time({ year = next_bday_ad.year, month = next_bday_ad.month, day = next_bday_ad.day, hour = 12 })
    next_bday_in_days = math.max(0, math.floor(os.difftime(next_bday_time, as_of_time) / 86400))
  end

  local birth_wday = dob_ad.wday
  return {
    years = y_diff,
    months = m_diff,
    days = d_diff,
    total_days = total_days,
    birth_weekday_nepali = localization.days_nepali_full[birth_wday],
    birth_weekday_english = localization.days_english_full[birth_wday],
    next_birthday_in_days = next_bday_in_days,
  }
end

--- Shift Nepali date by N days (+/-)
--- @param date { year: integer, month: integer, day: integer }
--- @param days integer
--- @return { year: integer, month: integer, day: integer }|nil
function M.shift_days(date, days)
  local ad = converter.bs_to_ad(date.year, date.month, date.day)
  if not ad then
    return nil
  end

  local ad_time = os.time({ year = ad.year, month = ad.month, day = ad.day, hour = 12, min = 0, sec = 0 })
  local shifted_time = ad_time + (days * 86400)
  local shifted_ad = os.date("*t", shifted_time)
  return converter.ad_to_bs(shifted_ad.year, shifted_ad.month, shifted_ad.day)
end

--- Detect long weekend streaks in a month (streaks of holiday / saturday >= 2 days)
--- @param year integer
--- @param month integer
--- @return table[]
function M.detect_long_weekends(year, month)
  local max_days = converter.days_in_month(year, month)
  local streaks = {}
  local current_streak = {}

  for day = 1, max_days do
    local info = converter.date_info(year, month, day)
    local is_off = info.is_holiday or info.is_saturday
    if is_off then
      table.insert(current_streak, info)
    else
      if #current_streak >= 2 then
        table.insert(streaks, current_streak)
      end
      current_streak = {}
    end
  end

  if #current_streak >= 2 then
    table.insert(streaks, current_streak)
  end

  local results = {}
  for _, streak in ipairs(streaks) do
    local first = streak[1]
    local last = streak[#streak]
    local first_str = string.format("%s %s (%s)", localization.to_devanagari(first.day), localization.months_nepali[first.month], localization.days_nepali_short[first.wday])
    local last_str = string.format("%s %s (%s)", localization.to_devanagari(last.day), localization.months_nepali[last.month], localization.days_nepali_short[last.wday])

    local holiday_names = {}
    for _, item in ipairs(streak) do
      if item.festival and item.festival ~= "" then
        table.insert(holiday_names, item.festival)
      end
    end

    table.insert(results, {
      days_count = #streak,
      start_str = first_str,
      end_str = last_str,
      holiday_names = holiday_names,
    })
  end

  return results
end

--- Get Nepal Clock and Office Status
--- @return table
function M.get_nepal_clock_status()
  local now = os.time()
  local nepal_time_sec = now + 20700
  local nepal_t = os.date("!*t", nepal_time_sec)

  local hour = nepal_t.hour
  local min = nepal_t.min
  local sec = nepal_t.sec
  local ampm = hour >= 12 and "PM" or "AM"
  local display_hour = hour % 12
  if display_hour == 0 then
    display_hour = 12
  end
  local formatted_time = string.format("%02d:%02d:%02d %s", display_hour, min, sec, ampm)

  -- Time difference calculation
  local local_t = os.date("*t", now)
  local local_time_sec = os.time(local_t)
  local utc_t = os.date("!*t", now)
  local utc_time_sec = os.time(utc_t)
  local local_offset = os.difftime(local_time_sec, utc_time_sec)
  local diff_seconds = 20700 - local_offset
  local diff_hours = math.floor(diff_seconds / 3600)
  local diff_mins = math.abs(math.floor((diff_seconds % 3600) / 60))

  local diff_text
  if diff_seconds == 0 then
    diff_text = "Same as local time"
  elseif diff_seconds > 0 then
    diff_text = string.format("%dh %dm ahead of local", diff_hours, diff_mins)
  else
    diff_text = string.format("%dh %dm behind local", math.abs(diff_hours), diff_mins)
  end

  local today_bs = converter.ad_to_bs(nepal_t.year, nepal_t.month, nepal_t.day)
  local info = converter.date_info(today_bs.year, today_bs.month, today_bs.day)

  local office_status, color_type, is_open
  if info.wday == 7 then
    office_status = "बन्द (शनिबार / Saturday)"
    color_type = "red"
    is_open = false
  elseif info.is_holiday then
    local fest = info.festival or "सार्वजनिक बिदा"
    office_status = string.format("बन्द (%s)", fest)
    color_type = "red"
    is_open = false
  elseif hour >= 10 and hour < 17 then
    office_status = "खुला (Offices & Banks Open)"
    color_type = "green"
    is_open = true
  elseif hour < 10 then
    office_status = "बन्द (Opens at 10:00 AM)"
    color_type = "yellow"
    is_open = false
  else
    office_status = "बन्द (Closed for the day)"
    color_type = "yellow"
    is_open = false
  end

  return {
    nepal_time_formatted = formatted_time,
    time_difference_text = diff_text,
    office_status = office_status,
    color_type = color_type,
    is_open = is_open,
  }
end

return M
