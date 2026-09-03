local calendar_data = require("nepali-calendar.core.calendar_data")
local localization = require("nepali-calendar.core.localization")
local festivals = require("nepali-calendar.core.festivals")

local M = {}

M.min_year = calendar_data.min_year
M.max_year = calendar_data.max_year

--- Compute days in a BS month
--- @param year integer
--- @param month integer
--- @return integer
function M.days_in_month(year, month)
  if year < calendar_data.min_year or year > calendar_data.max_year or month < 1 or month > 12 then
    return 30
  end
  local months = calendar_data.days_in_months_by_year[year]
  return months and months[month] or 30
end

--- Compute total days in a BS year
--- @param year integer
--- @return integer
function M.days_in_year(year)
  local months = calendar_data.days_in_months_by_year[year]
  if not months then
    return 365
  end
  local sum = 0
  for _, d in ipairs(months) do
    sum = sum + d
  end
  return sum
end

--- Reference timestamp for 1918-04-13 00:00:00 UTC (in seconds)
-- UTC timestamp for 1918-04-13
-- os.time({year=1918, month=4, day=13, hour=0, isdst=false})
local REF_UTC_TIMESTAMP = os.time({ year = 1918, month = 4, day = 13, hour = 0, min = 0, sec = 0, isdst = false })

--- Convert AD date components into Bikram Sambat date table
--- @param ad_year integer
--- @param ad_month integer
--- @param ad_day integer
--- @return { year: integer, month: integer, day: integer }
function M.ad_to_bs(ad_year, ad_month, ad_day)
  local target_time = os.time({ year = ad_year, month = ad_month, day = ad_day, hour = 12, min = 0, sec = 0, isdst = false })
  local diff_seconds = os.difftime(target_time, REF_UTC_TIMESTAMP)
  local day_diff = math.floor(diff_seconds / 86400)

  if day_diff < 0 then
    return { year = calendar_data.min_year, month = 1, day = 1 }
  end

  local remaining_days = day_diff
  local curr_year = calendar_data.min_year

  while curr_year <= calendar_data.max_year do
    local y_days = M.days_in_year(curr_year)
    if remaining_days < y_days then
      break
    end
    remaining_days = remaining_days - y_days
    curr_year = curr_year + 1
  end

  if curr_year > calendar_data.max_year then
    curr_year = calendar_data.max_year
    remaining_days = 0
  end

  local months = calendar_data.days_in_months_by_year[curr_year] or { 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30 }
  local curr_month = 1
  for m = 1, 12 do
    local m_days = months[m]
    if remaining_days < m_days then
      break
    end
    remaining_days = remaining_days - m_days
    curr_month = curr_month + 1
  end

  local curr_day = remaining_days + 1
  return {
    year = curr_year,
    month = math.min(curr_month, 12),
    day = curr_day,
  }
end

--- Convert Bikram Sambat date table into AD date table
--- @param bs_year integer
--- @param bs_month integer
--- @param bs_day integer
--- @return { year: integer, month: integer, day: integer, wday: integer }|nil
function M.bs_to_ad(bs_year, bs_month, bs_day)
  if bs_year < calendar_data.min_year or bs_year > calendar_data.max_year or bs_month < 1 or bs_month > 12 then
    return nil
  end

  local total_days = 0
  for y = calendar_data.min_year, bs_year - 1 do
    total_days = total_days + M.days_in_year(y)
  end

  local months = calendar_data.days_in_months_by_year[bs_year]
  if months then
    for m = 1, bs_month - 1 do
      total_days = total_days + months[m]
    end
  end

  total_days = total_days + (bs_day - 1)

  local ad_timestamp = REF_UTC_TIMESTAMP + (total_days * 86400) + 43200 -- noon
  local ad_date = os.date("!*t", ad_timestamp)
  return {
    year = ad_date.year,
    month = ad_date.month,
    day = ad_date.day,
    wday = ad_date.wday, -- 1 = Sunday ... 7 = Saturday
  }
end

--- Returns weekday (1 = Sunday ... 7 = Saturday) for BS date
--- @param year integer
--- @param month integer
--- @param day integer
--- @return integer
function M.weekday_of(year, month, day)
  local ad = M.bs_to_ad(year, month, day)
  return ad and ad.wday or 1
end

--- Get today's Nepali date
--- @param use_nepal_time boolean|nil
--- @return { year: integer, month: integer, day: integer }
function M.today(use_nepal_time)
  local now = os.time()
  local date_t
  if use_nepal_time then
    -- Nepal is UTC + 5h45m (+20700 seconds)
    local nepal_time = now + 20700
    date_t = os.date("!*t", nepal_time)
  else
    date_t = os.date("*t", now)
  end
  return M.ad_to_bs(date_t.year, date_t.month, date_t.day)
end

--- Get full date info object including festival, tithi, and holiday
--- @param year integer
--- @param month integer
--- @param day integer
--- @return table
function M.date_info(year, month, day)
  local ev = festivals.get_event(year, month, day)
  local ad = M.bs_to_ad(year, month, day)
  local wday = ad and ad.wday or 1

  return {
    year = year,
    month = month,
    day = day,
    wday = wday,
    ad = ad,
    festival = ev and ev.festival or nil,
    tithi = ev and ev.tithi or nil,
    is_holiday = ev and ev.is_holiday or false,
    is_saturday = (wday == 7),
  }
end

--- Gregorian Span string for a BS month (e.g. "Aug 17 – Sep 16, 2026")
--- @param year integer
--- @param month integer
--- @return string
function M.gregorian_span(year, month)
  local first_ad = M.bs_to_ad(year, month, 1)
  local max_days = M.days_in_month(year, month)
  local last_ad = M.bs_to_ad(year, month, max_days)

  if not first_ad or not last_ad then
    return ""
  end

  local month_abbr = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }
  local start_str = string.format("%s %d", month_abbr[first_ad.month], first_ad.day)
  local end_str = string.format("%s %d, %d", month_abbr[last_ad.month], last_ad.day, last_ad.year)
  return string.format("%s – %s", start_str, end_str)
end

return M
