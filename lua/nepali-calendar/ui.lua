local converter = require("nepali-calendar.core.converter")
local localization = require("nepali-calendar.core.localization")
local panchanga = require("nepali-calendar.core.panchanga")
local calculator = require("nepali-calendar.core.calculator")
local format = require("nepali-calendar.core.format")
local config = require("nepali-calendar.config")

local M = {}

-- State
M.buf = nil
M.win = nil
M.current_year = nil
M.current_month = nil
M.selected_day = nil
M.today = nil
M.language = nil
M.visual_range_start = nil
M.visual_range_end = nil

-- Cell positions on screen: map of day -> { line: integer, col_start: integer, col_end: integer }
M.day_cell_map = {}

--- String visual width helper
local function str_width(s)
  return vim.fn.strdisplaywidth(s)
end

--- Pad a string with spaces to reach target visual width
local function pad_to(s, target_len, align_right)
  local w = str_width(s)
  if w >= target_len then
    return s
  end
  local pad = string.rep(" ", target_len - w)
  return align_right and (pad .. s) or (s .. pad)
end

--- Center string in given width
local function center_str(s, target_len)
  local w = str_width(s)
  if w >= target_len then
    return s
  end
  local left_pad = math.floor((target_len - w) / 2)
  local right_pad = target_len - w - left_pad
  return string.rep(" ", left_pad) .. s .. string.rep(" ", right_pad)
end

--- Render the buffer contents
function M.render()
  if not M.buf or not vim.api.nvim_buf_is_valid(M.buf) then
    return
  end

  local lang = M.language or config.options.language
  local lines = {}
  local highlights = {} -- table of { group, line, col_start, col_end }
  M.day_cell_map = {}

  local function add_line(text)
    table.insert(lines, text)
  end

  local function add_hl(group, line_idx, col_start, col_end)
    table.insert(highlights, { group = group, line = line_idx - 1, col_start = col_start, col_end = col_end })
  end

  local total_inner_width = 77
  local col_width = 11
  local left_indent = ""

  -- 1. Live Nepal Clock Banner
  if config.options.show_nepal_clock then
    local clock_data = calculator.get_nepal_clock_status()
    local clock_str = string.format("🇳🇵 काठमाडौँ: %s  [%s]", clock_data.nepal_time_formatted, clock_data.office_status)
    add_line(center_str(clock_str, total_inner_width))
    local line_no = #lines
    local clock_hl = (clock_data.color_type == "green") and "NepaliCalOpen" or "NepaliCalClosed"
    add_hl(clock_hl, line_no, 0, -1)

    local diff_str = clock_data.time_difference_text
    add_line(center_str(diff_str, total_inner_width))
    add_hl("NepaliCalSubHeader", #lines, 0, -1)

    add_line(string.rep("─", total_inner_width))
    add_hl("NepaliCalBorder", #lines, 0, -1)
  end

  -- 2. Header: Month Year (Devanagari / English) + AD Date Span
  local month_title
  if lang == "nepali" then
    local m_name = localization.months_nepali[M.current_month]
    local y_str = localization.to_devanagari(M.current_year)
    month_title = string.format("« %s %s »", m_name, y_str)
  else
    local m_name = localization.months_english[M.current_month]
    month_title = string.format("« %s %d »", m_name, M.current_year)
  end

  add_line(center_str(month_title, total_inner_width))
  add_hl("NepaliCalHeader", #lines, 0, -1)

  if config.options.show_ad_date then
    local ad_span = converter.gregorian_span(M.current_year, M.current_month)
    add_line(center_str(ad_span, total_inner_width))
    add_hl("NepaliCalSubHeader", #lines, 0, -1)
  end

  -- 3. Month Progress Bar
  if config.options.show_month_progress then
    local max_days = converter.days_in_month(M.current_year, M.current_month)
    local is_curr_month = (M.current_year == M.today.year and M.current_month == M.today.month)
    local curr_d = is_curr_month and M.today.day or (M.selected_day or 1)
    local remaining = math.max(0, max_days - curr_d)
    local progress_ratio = math.min(1.0, curr_d / max_days)
    local bar_len = 24
    local filled_len = math.floor(progress_ratio * bar_len)
    local bar = string.rep("█", filled_len) .. string.rep("░", bar_len - filled_len)

    local rem_str
    if lang == "nepali" then
      rem_str = string.format("%s दिन बाँकी", localization.to_devanagari(remaining))
    else
      rem_str = string.format("%d days left", remaining)
    end

    local progress_line = string.format(" Progress: [%s] %s", bar, rem_str)
    add_line(center_str(progress_line, total_inner_width))
    add_hl("NepaliCalProgressBar", #lines, 0, -1)
  end

  -- 4. Long Weekend Notification (if any)
  if config.options.show_long_weekends then
    local lws = calculator.detect_long_weekends(M.current_year, M.current_month)
    if #lws > 0 then
      local lw = lws[1]
      local lw_str = string.format("🏖️  लामो बिदा (%s दिन): %s – %s", localization.to_devanagari(lw.days_count), lw.start_str, lw.end_str)
      add_line(center_str(lw_str, total_inner_width))
      add_hl("NepaliCalFestival", #lines, 0, -1)
    end
  end

  add_line(string.rep("─", total_inner_width))
  add_hl("NepaliCalBorder", #lines, 0, -1)

  -- 5. Weekday Headers (Sun to Sat)
  local wday_line_idx = #lines + 1
  local wday_line_buf = ""
  local wday_cols = {}

  for i = 1, 7 do
    local name = (lang == "nepali") and localization.days_nepali_short[i] or localization.days_english_short[i]
    local cell_str = center_str(name, col_width)
    local b_start = #wday_line_buf
    wday_line_buf = wday_line_buf .. cell_str
    local b_end = #wday_line_buf
    table.insert(wday_cols, { b_start = b_start, b_end = b_end, is_saturday = (i == 7) })
  end
  add_line(wday_line_buf)

  for _, wc in ipairs(wday_cols) do
    local hl_group = wc.is_saturday and "NepaliCalSaturday" or "NepaliCalWeekday"
    add_hl(hl_group, wday_line_idx, wc.b_start, wc.b_end)
  end

  add_line(string.rep("┄", total_inner_width))
  add_hl("NepaliCalBorder", #lines, 0, -1)

  -- 6. Days Grid Matrix
  local max_days = converter.days_in_month(M.current_year, M.current_month)
  local first_wday = converter.weekday_of(M.current_year, M.current_month, 1) -- 1 = Sunday ... 7 = Saturday
  local offset = first_wday - 1 -- number of empty cells before 1st

  local cell_idx = 0
  local current_row_cells = {}
  local row_days = {}

  local function flush_row()
    if #current_row_cells > 0 then
      while #current_row_cells < 7 do
        table.insert(current_row_cells, string.rep(" ", col_width))
        table.insert(row_days, false)
      end

      local r_line_idx = #lines + 1
      local r_line_buf = ""
      local cell_byte_spans = {}

      for col_i, cell_text in ipairs(current_row_cells) do
        local b_start = #r_line_buf
        r_line_buf = r_line_buf .. cell_text
        local b_end = #r_line_buf
        table.insert(cell_byte_spans, { b_start = b_start, b_end = b_end, day = row_days[col_i], col_i = col_i })
      end
      add_line(r_line_buf)

      for _, cspan in ipairs(cell_byte_spans) do
        local day_num = cspan.day
        if day_num then
          M.day_cell_map[day_num] = {
            line = r_line_idx,
            col_start = cspan.b_start,
            col_end = cspan.b_end,
          }

          local is_today = (M.current_year == M.today.year and M.current_month == M.today.month and day_num == M.today.day)
          local in_range = false
          if M.visual_range_start and M.visual_range_end then
            local r_min = math.min(M.visual_range_start, M.visual_range_end)
            local r_max = math.max(M.visual_range_start, M.visual_range_end)
            if day_num >= r_min and day_num <= r_max then
              in_range = true
            end
          end

          local is_selected = (day_num == M.selected_day) or in_range
          local d_info = converter.date_info(M.current_year, M.current_month, day_num)

          if in_range then
            add_hl("NepaliCalSelected", r_line_idx, cspan.b_start, cspan.b_end)
          elseif is_selected then
            add_hl("NepaliCalSelected", r_line_idx, cspan.b_start, cspan.b_end)
          elseif is_today then
            add_hl("NepaliCalToday", r_line_idx, cspan.b_start, cspan.b_end)
          elseif d_info.is_holiday then
            add_hl("NepaliCalHoliday", r_line_idx, cspan.b_start, cspan.b_end)
          elseif cspan.col_i == 7 then
            add_hl("NepaliCalSaturday", r_line_idx, cspan.b_start, cspan.b_end)
          else
            add_hl("NepaliCalDay", r_line_idx, cspan.b_start, cspan.b_end)
          end

          -- If not selected/today/holiday/range, highlight the secondary English "(day)" in subtle comment tone
          if not is_selected and not is_today and not d_info.is_holiday and cspan.col_i ~= 7 and not in_range then
            local cell_text = current_row_cells[cspan.col_i] or ""
            local paren_pos = cell_text:find("%(")
            if paren_pos then
              local paren_byte_start = cspan.b_start + (paren_pos - 1)
              add_hl("NepaliCalEnglishSub", r_line_idx, paren_byte_start, cspan.b_end)
            end
          end
        end
      end

      current_row_cells = {}
      row_days = {}
    end
  end

  -- Leading blanks
  for _ = 1, offset do
    table.insert(current_row_cells, string.rep(" ", col_width))
    table.insert(row_days, false)
    cell_idx = cell_idx + 1
  end

  for d = 1, max_days do
    local day_str
    if lang == "nepali" then
      day_str = localization.to_devanagari(d)
    else
      day_str = tostring(d)
    end

    local d_info = converter.date_info(M.current_year, M.current_month, d)
    if d_info.is_holiday then
      day_str = day_str .. "*"
    end

    if config.options.show_english_subscript and d_info.ad then
      day_str = string.format("%s (%d)", day_str, d_info.ad.day)
    end

    table.insert(current_row_cells, center_str(day_str, col_width))
    table.insert(row_days, d)
    cell_idx = cell_idx + 1

    if cell_idx % 7 == 0 then
      flush_row()
    end
  end
  flush_row()

  add_line(string.rep("─", total_inner_width))
  add_hl("NepaliCalBorder", #lines, 0, -1)

  -- 7. Selected Date / Visual Range Details Card
  if M.visual_range_start and M.visual_range_end then
    local r_min = math.min(M.visual_range_start, M.visual_range_end)
    local r_max = math.max(M.visual_range_start, M.visual_range_end)

    local start_info = converter.date_info(M.current_year, M.current_month, r_min)
    local end_info = converter.date_info(M.current_year, M.current_month, r_max)

    local m_name = (lang == "nepali") and localization.months_nepali[M.current_month] or localization.months_english[M.current_month]
    local y_str = (lang == "nepali") and localization.to_devanagari(M.current_year) or tostring(M.current_year)
    local start_d_str = (lang == "nepali") and localization.to_devanagari(r_min) or tostring(r_min)
    local end_d_str = (lang == "nepali") and localization.to_devanagari(r_max) or tostring(r_max)

    local range_title = string.format(" 🗓️  Range: %s – %s %s %s (%d days selected)", start_d_str, end_d_str, m_name, y_str, (r_max - r_min + 1))
    add_line(range_title)
    add_hl("NepaliCalHeader", #lines, 0, -1)

    if start_info.ad and end_info.ad then
      local month_names = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }
      local ad_range_str = string.format(" 🌐 AD: %s %d – %s %d, %d", month_names[start_info.ad.month], start_info.ad.day, month_names[end_info.ad.month], end_info.ad.day, end_info.ad.year)
      add_line(ad_range_str)
      add_hl("NepaliCalEnglishDate", #lines, 0, -1)
    end

    add_line(" 📋 Events in Range:")
    add_hl("NepaliCalSubHeader", #lines, 0, -1)

    local range_events_found = 0
    for day_i = r_min, r_max do
      local day_ev = converter.date_info(M.current_year, M.current_month, day_i)
      if (day_ev.festival and day_ev.festival ~= "") or day_ev.is_holiday or (day_ev.tithi and day_ev.tithi ~= "") then
        local d_label = (lang == "nepali") and localization.to_devanagari(day_i) or tostring(day_i)
        local w_label = (lang == "nepali") and localization.days_nepali_short[day_ev.wday] or localization.days_english_short[day_ev.wday]
        local hol_tag = day_ev.is_holiday and ((lang == "nepali") and " [सार्वजनिक बिदा]" or " [Public Holiday]") or ""

        local tithi_text = (lang == "nepali") and day_ev.tithi or localization.translate_tithi(day_ev.tithi)
        local tithi_tag = (tithi_text and tithi_text ~= "") and (" (" .. tithi_text .. ")") or ""

        local fest_text = (lang == "nepali") and day_ev.festival or localization.translate_festival(day_ev.festival)
        local fest_tag = (fest_text and fest_text ~= "") and (" - " .. fest_text) or ""

        local ev_line = string.format("   • %s %s%s%s%s", d_label, w_label, tithi_tag, fest_tag, hol_tag)
        add_line(ev_line)
        local ev_hl = day_ev.is_holiday and "NepaliCalHoliday" or "NepaliCalFestival"
        add_hl(ev_hl, #lines, 0, -1)
        range_events_found = range_events_found + 1
      end
    end

    if range_events_found == 0 then
      add_line("   (No special festivals or public holidays in this date range)")
      add_hl("NepaliCalKey", #lines, 0, -1)
    end
  else
    local sel_info = converter.date_info(M.current_year, M.current_month, M.selected_day)
    local full_date_str = format.format_full(sel_info, lang)
    if sel_info.is_holiday then
      full_date_str = full_date_str .. ((lang == "nepali") and "  [सार्वजनिक बिदा / Holiday]" or "  [Public Holiday]")
    end
    add_line(" 🇳🇵 " .. full_date_str)
    add_hl("NepaliCalHeader", #lines, 0, -1)

    if sel_info.ad then
      local month_names = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
      local ad_str = string.format(" 🌐 English (AD): %s %d, %d (%s)", month_names[sel_info.ad.month], sel_info.ad.day, sel_info.ad.year, localization.days_english_full[sel_info.wday])
      add_line(ad_str)
      add_hl("NepaliCalEnglishDate", #lines, 0, -1)
    end

    if sel_info.festival and sel_info.festival ~= "" then
      local fest_display = (lang == "nepali") and sel_info.festival or localization.translate_festival(sel_info.festival)
      add_line(" ✨ " .. fest_display)
      add_hl("NepaliCalFestival", #lines, 0, -1)
    end

    -- Panchanga Information
    if config.options.show_panchanga then
      local pan = panchanga.calculate(sel_info)
      local pan_line1 = string.format(" 🌅 %s   🌇 %s   ⌛ %s", pan.sunrise, pan.sunset, pan.day_length)
      add_line(pan_line1)
      add_hl("NepaliCalPanchanga", #lines, 0, -1)

      local rashi_label = (lang == "nepali") and "☀️ राशि:" or "☀️ Sun Sign:"
      local rahu_label = (lang == "nepali") and "⏱ राहु काल:" or "⏱ Rahu Kaal:"
      local pan_line2 = string.format(" %s %s   %s %s", rashi_label, pan.sun_rashi, rahu_label, pan.rahu_kaal)
      add_line(pan_line2)
      add_hl("NepaliCalPanchanga", #lines, 0, -1)
    end
  end

  add_line(string.rep("─", total_inner_width))
  add_hl("NepaliCalBorder", #lines, 0, -1)

  -- 8. Help / Navigation Footer
  add_line(" [h/l] Month  [j/k] Day  [v] Visual  [/] Search")
  add_hl("NepaliCalKey", #lines, 0, -1)
  add_line(" [y] Copy BS  [yi] ISO   [Tab] Lang  [q] Close")
  add_hl("NepaliCalKey", #lines, 0, -1)

  -- Write lines to buffer (unlock & lock)
  vim.bo[M.buf].modifiable = true
  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, lines)
  vim.bo[M.buf].modifiable = false

  -- Apply highlight namespaces
  local ns = vim.api.nvim_create_namespace("nepali_calendar_hl")
  vim.api.nvim_buf_clear_namespace(M.buf, ns, 0, -1)

  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(M.buf, ns, hl.group, hl.line, hl.col_start, hl.col_end)
  end

  -- Dynamically adjust window height to fit exact content
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    local new_height = math.min(#lines, vim.o.lines - 4)
    local screen_h = vim.o.lines
    local new_row = math.max(1, math.floor((screen_h - new_height) / 2))
    pcall(vim.api.nvim_win_set_config, M.win, { height = new_height, row = new_row })
  end

  -- Position cursor on the selected day cell if possible
  if M.day_cell_map[M.selected_day] and M.win and vim.api.nvim_win_is_valid(M.win) then
    local cell = M.day_cell_map[M.selected_day]
    pcall(vim.api.nvim_win_set_cursor, M.win, { cell.line, cell.col_start + 2 })
  end
end

--- Move month by delta (+1 or -1)
function M.change_month(delta)
  local m = M.current_month + delta
  local y = M.current_year
  if m > 12 then
    m = 1
    y = y + 1
  elseif m < 1 then
    m = 12
    y = y - 1
  end

  local min_y = converter.min_year or 1975
  local max_y = converter.max_year or 2100

  if y < min_y then
    y = min_y
    m = 1
  elseif y > max_y then
    y = max_y
    m = 12
  end

  M.current_year = y
  M.current_month = m
  local max_days = converter.days_in_month(y, m)
  if M.selected_day > max_days then
    M.selected_day = max_days
  end
  M.render()
end

--- Move year by delta (+1 or -1)
function M.change_year(delta)
  local min_y = converter.min_year or 1975
  local max_y = converter.max_year or 2100
  local y = math.max(min_y, math.min(max_y, M.current_year + delta))
  M.current_year = y
  local max_days = converter.days_in_month(y, M.current_month)
  if M.selected_day > max_days then
    M.selected_day = max_days
  end
  M.render()
end

--- Toggle visual range selection mode (v)
function M.toggle_visual_mode()
  if M.visual_range_start then
    -- Exit visual mode
    M.visual_range_start = nil
    M.visual_range_end = nil
    vim.notify("Exited Visual Selection Mode", vim.log.levels.INFO, { title = "Nepali Calendar" })
  else
    -- Enter visual mode starting at current day
    M.visual_range_start = M.selected_day
    M.visual_range_end = M.selected_day
    vim.notify("Entered Visual Mode: use h/l/j/k to select day range (press v or Esc to exit)", vim.log.levels.INFO, { title = "Nepali Calendar" })
  end
  M.render()
end

--- Select entire current week (V / Shift-V)
function M.select_whole_week()
  local sel_info = converter.date_info(M.current_year, M.current_month, M.selected_day)
  local max_days = converter.days_in_month(M.current_year, M.current_month)

  -- wday: 1 = Sunday, 2 = Monday, ..., 7 = Saturday
  local days_to_sunday = sel_info.wday - 1
  local days_to_saturday = 7 - sel_info.wday

  local week_start = math.max(1, M.selected_day - days_to_sunday)
  local week_end = math.min(max_days, M.selected_day + days_to_saturday)

  M.visual_range_start = week_start
  M.visual_range_end = week_end
  M.selected_day = week_end

  vim.notify(string.format("Selected Week (%d to %d)", week_start, week_end), vim.log.levels.INFO, { title = "Nepali Calendar" })
  M.render()
end

--- Clear visual selection mode
function M.clear_visual_mode()
  if M.visual_range_start or M.visual_range_end then
    M.visual_range_start = nil
    M.visual_range_end = nil
    M.render()
    return true
  end
  return false
end

--- Move day by delta (+1, -1, +7, -7)
function M.change_day(delta)
  local max_days = converter.days_in_month(M.current_year, M.current_month)
  local new_day = M.selected_day + delta

  if new_day < 1 then
    M.change_month(-1)
    local prev_max = converter.days_in_month(M.current_year, M.current_month)
    M.selected_day = math.max(1, prev_max + new_day)
    if M.visual_range_start then
      M.visual_range_start = M.selected_day
      M.visual_range_end = M.selected_day
    end
  elseif new_day > max_days then
    local overflow = new_day - max_days
    M.change_month(1)
    M.selected_day = math.min(overflow, converter.days_in_month(M.current_year, M.current_month))
    if M.visual_range_start then
      M.visual_range_start = M.selected_day
      M.visual_range_end = M.selected_day
    end
  else
    M.selected_day = new_day
    if M.visual_range_start then
      M.visual_range_end = new_day
    end
  end
  M.render()
end

--- Go to today
function M.goto_today()
  M.visual_range_start = nil
  M.visual_range_end = nil
  M.today = converter.today()
  M.current_year = M.today.year
  M.current_month = M.today.month
  M.selected_day = M.today.day
  M.render()
end

--- Toggle display language
function M.toggle_language()
  M.language = (M.language == "nepali") and "english" or "nepali"
  M.render()
end

--- Copy selected date or date range to clipboard
function M.copy_selected_date()
  if M.visual_range_start and M.visual_range_end then
    local r_min = math.min(M.visual_range_start, M.visual_range_end)
    local r_max = math.max(M.visual_range_start, M.visual_range_end)
    local start_info = converter.date_info(M.current_year, M.current_month, r_min)
    local end_info = converter.date_info(M.current_year, M.current_month, r_max)

    local lines_to_copy = {}
    table.insert(lines_to_copy, string.format("Nepali Date Range: %s to %s", format.format_full(start_info, M.language), format.format_full(end_info, M.language)))
    for day_i = r_min, r_max do
      local day_ev = converter.date_info(M.current_year, M.current_month, day_i)
      if (day_ev.festival and day_ev.festival ~= "") or day_ev.is_holiday then
        local hol_tag = day_ev.is_holiday and " [Holiday]" or ""
        table.insert(lines_to_copy, string.format("• %s: %s%s", format.format_short(day_ev, M.language), day_ev.festival, hol_tag))
      end
    end
    local str = table.concat(lines_to_copy, "\n")
    vim.fn.setreg("+", str)
    vim.fn.setreg('"', str)
    vim.notify("Copied date range and events to clipboard!", vim.log.levels.INFO, { title = "Nepali Calendar" })
  else
    local info = converter.date_info(M.current_year, M.current_month, M.selected_day)
    local str = format.format_full(info, M.language)
    vim.fn.setreg("+", str)
    vim.fn.setreg('"', str)
    vim.notify("Copied to clipboard: " .. str, vim.log.levels.INFO, { title = "Nepali Calendar" })
  end
end

--- Copy selected date or date range in ISO format (YYYY-MM-DD)
function M.copy_iso_date()
  if M.visual_range_start and M.visual_range_end then
    local r_min = math.min(M.visual_range_start, M.visual_range_end)
    local r_max = math.max(M.visual_range_start, M.visual_range_end)
    local start_info = converter.date_info(M.current_year, M.current_month, r_min)
    local end_info = converter.date_info(M.current_year, M.current_month, r_max)
    local str = string.format("%s to %s", format.format_iso(start_info), format.format_iso(end_info))
    vim.fn.setreg("+", str)
    vim.fn.setreg('"', str)
    vim.notify("Copied ISO date range to clipboard: " .. str, vim.log.levels.INFO, { title = "Nepali Calendar" })
  else
    local info = converter.date_info(M.current_year, M.current_month, M.selected_day)
    local str = format.format_iso(info)
    vim.fn.setreg("+", str)
    vim.fn.setreg('"', str)
    vim.notify("Copied to clipboard: " .. str, vim.log.levels.INFO, { title = "Nepali Calendar" })
  end
end

--- Open interactive date converter prompt
function M.open_converter_dialog()
  vim.ui.select({ "1. AD to BS (Gregorian to Nepali)", "2. BS to AD (Nepali to Gregorian)", "3. Age Calculator (Bikram Sambat)", "4. Date Math (Add/Subtract Days)" }, {
    prompt = "Nepali Calendar Tools:",
  }, function(choice)
    if not choice then
      return
    end

    if choice:match("^1") then
      vim.ui.input({ prompt = "Enter Gregorian Date (YYYY-MM-DD) [Default: Today]: " }, function(input)
        local y, m, d
        if not input or input == "" then
          local now_t = os.date("*t")
          y, m, d = now_t.year, now_t.month, now_t.day
        else
          y, m, d = input:match("(%d%d%d%d)[-%/](%d%d?)[-%/](%d%d?)")
          y, m, d = tonumber(y), tonumber(m), tonumber(d)
        end
        if y and m and d then
          local bs = converter.ad_to_bs(y, m, d)
          local info = converter.date_info(bs.year, bs.month, bs.day)
          local res = string.format("AD: %04d-%02d-%02d => BS: %s (%s)", y, m, d, format.format_full(info, "nepali"), format.format_iso(info))
          vim.fn.setreg("+", format.format_iso(info))
          vim.notify(res .. "\n(Copied BS ISO to clipboard)", vim.log.levels.INFO, { title = "AD ➔ BS Converter" })
        else
          vim.notify("Invalid AD date format. Use YYYY-MM-DD", vim.log.levels.ERROR)
        end
      end)
    elseif choice:match("^2") then
      vim.ui.input({ prompt = "Enter Nepali BS Date (YYYY-MM-DD) [e.g. 2083-05-14]: " }, function(input)
        if not input or input == "" then
          return
        end
        local y, m, d = input:match("(%d%d%d%d)[-%/](%d%d?)[-%/](%d%d?)")
        y, m, d = tonumber(y), tonumber(m), tonumber(d)
        if y and m and d then
          local ad = converter.bs_to_ad(y, m, d)
          if ad then
            local res = string.format("BS: %04d-%02d-%02d => AD: %04d-%02d-%02d (%s)", y, m, d, ad.year, ad.month, ad.day, localization.days_english_full[ad.wday])
            vim.fn.setreg("+", string.format("%04d-%02d-%02d", ad.year, ad.month, ad.day))
            vim.notify(res .. "\n(Copied AD ISO to clipboard)", vim.log.levels.INFO, { title = "BS ➔ AD Converter" })
          else
            vim.notify("BS Date out of supported range (1975-2100 BS)", vim.log.levels.ERROR)
          end
        else
          vim.notify("Invalid BS date format. Use YYYY-MM-DD", vim.log.levels.ERROR)
        end
      end)
    elseif choice:match("^3") then
      vim.ui.input({ prompt = "Enter Date of Birth in BS (YYYY-MM-DD): " }, function(input)
        if not input or input == "" then
          return
        end
        local y, m, d = input:match("(%d%d%d%d)[-%/](%d%d?)[-%/](%d%d?)")
        y, m, d = tonumber(y), tonumber(m), tonumber(d)
        if y and m and d then
          local age = calculator.calculate_age({ year = y, month = m, day = d }, M.today)
          if age then
            local res = string.format(
              "🎂 Age: %s वर्ष, %s महिना, %s दिन (%d years, %d months, %d days)\nBirth Day: %s (%s)\nTotal Days: %d days | Next Birthday: %d days left",
              localization.to_devanagari(age.years),
              localization.to_devanagari(age.months),
              localization.to_devanagari(age.days),
              age.years,
              age.months,
              age.days,
              age.birth_weekday_nepali,
              age.birth_weekday_english,
              age.total_days,
              age.next_birthday_in_days
            )
            vim.notify(res, vim.log.levels.INFO, { title = "BS Age Calculator" })
          else
            vim.notify("Invalid birth date or future date entered", vim.log.levels.ERROR)
          end
        end
      end)
    elseif choice:match("^4") then
      vim.ui.input({ prompt = "Enter Days to add (+) or subtract (-) [e.g. +30 or -15]: " }, function(input)
        if not input or input == "" then
          return
        end
        local days = tonumber(input)
        if days then
          local shifted = calculator.shift_days({ year = M.current_year, month = M.current_month, day = M.selected_day }, days)
          if shifted then
            local info = converter.date_info(shifted.year, shifted.month, shifted.day)
            local res = string.format("Shifted (%+d days): %s", days, format.format_full(info, M.language))
            vim.notify(res, vim.log.levels.INFO, { title = "Date Math Result" })
            M.current_year = shifted.year
            M.current_month = shifted.month
            M.selected_day = shifted.day
            M.render()
          end
        end
      end)
    end
  end)
end

--- Search festivals and jump to selected date
function M.open_search_dialog()
  local festivals = require("nepali-calendar.core.festivals")
  local lang = M.language or config.options.language

  local input_prompt = (lang == "nepali") and "🔍 Search Nepali Festivals & Events (नेपाली चाडपर्व): " or "🔍 Search Nepali Festivals & Events: "
  vim.ui.input({ prompt = input_prompt }, function(query)
    if not query or vim.trim(query) == "" then
      return
    end

    local matches = festivals.search_events(query, M.current_year, M.current_month, M.selected_day)
    if #matches == 0 then
      vim.notify("No festivals found matching: " .. query, vim.log.levels.WARN, { title = "Festival Search" })
      return
    end

    local items = {}
    for _, m in ipairs(matches) do
      local hol_tag = m.is_holiday and ((lang == "nepali") and " [सार्वजनिक बिदा]" or " [Public Holiday]") or ""

      local tithi_text = (lang == "nepali") and m.tithi or localization.translate_tithi(m.tithi)
      local tithi_tag = (tithi_text and tithi_text ~= "") and (" (" .. tithi_text .. ")") or ""

      local fest_text = (lang == "nepali") and m.festival or localization.translate_festival(m.festival)

      local ad_info = converter.bs_to_ad(m.year, m.month, m.day)
      local month_abbr = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }
      local ad_str = ad_info and string.format("(%s %d, %d)", month_abbr[ad_info.month], ad_info.day, ad_info.year) or ""

      local date_label
      if lang == "nepali" then
        local m_np = localization.months_nepali[m.month] or tostring(m.month)
        date_label = string.format("%s %s %s %s", localization.to_devanagari(m.day), m_np, localization.to_devanagari(m.year), ad_str)
      else
        local m_en = localization.months_english[m.month] or tostring(m.month)
        date_label = string.format("%d %s %d %s", m.day, m_en, m.year, ad_str)
      end

      local label = string.format("%s: %s%s%s", date_label, fest_text, tithi_tag, hol_tag)
      table.insert(items, { label = label, match = m })
    end

    local select_prompt = (lang == "nepali") and string.format("खोज नतिजा '%s' (%d भेटियो):", query, #items) or string.format("Search Results for '%s' (%d found):", query, #items)

    vim.ui.select(items, {
      prompt = select_prompt,
      format_item = function(item)
        return item.label
      end,
    }, function(choice)
      if choice and choice.match then
        M.current_year = choice.match.year
        M.current_month = choice.match.month
        M.selected_day = choice.match.day
        M.render()
      end
    end)
  end)
end

--- Show popup keymaps / help dialog
function M.show_help()
  local help_text = [[
Nepali Calendar (नेपाली पात्रो) Shortcuts:
─────────────────────────────────────────────
  h / [ / Left      : Previous Month
  l / ] / Right     : Next Month
  { / H             : Previous Year
  } / L             : Next Year
  j / Down          : Next Day (+1)
  k / Up            : Previous Day (-1)
  v                 : Toggle Visual Selection Range (Show all events)
  V (Shift-V)       : Select Entire Week (Sun–Sat) & Show Events
  t                 : Jump to Today
  / / s             : Search Festivals & Events (3200+)
  <Tab>             : Toggle Nepali / English
  y                 : Copy Selected Date / Range
  yi                : Copy ISO Date / Range (YYYY-MM-DD)
  c                 : Date Tools (AD<->BS, Age, Math)
  ?                 : Show This Help
  q / <Esc>         : Close / Exit Visual Mode
]]
  vim.notify(help_text, vim.log.levels.INFO, { title = "Nepali Calendar Help" })
end

--- Close calendar window
function M.close()
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    vim.api.nvim_win_close(M.win, true)
  end
  M.win = nil
  M.buf = nil
end

--- Toggle or open popup window
function M.open()
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    M.close()
    return
  end

  require("nepali-calendar.highlights").setup_highlights()

  M.today = converter.today()
  M.current_year = M.today.year
  M.current_month = M.today.month
  M.selected_day = M.today.day
  M.language = config.options.language

  -- Create scratch buffer
  M.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[M.buf].buftype = "nofile"
  vim.bo[M.buf].bufhidden = "wipe"
  vim.bo[M.buf].swapfile = false
  vim.bo[M.buf].filetype = "nepali_calendar"

  -- Calculate floating window dimensions
  local width = 79
  local height = 24
  local screen_w = vim.o.columns
  local screen_h = vim.o.lines
  local row = math.max(1, math.floor((screen_h - height) / 2))
  local col = math.max(1, math.floor((screen_w - width) / 2))

  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = config.options.border,
    title = " 🇳🇵 Nepali Calendar (पात्रो) ",
    title_pos = "center",
  }

  M.win = vim.api.nvim_open_win(M.buf, true, win_opts)
  vim.wo[M.win].cursorline = false
  vim.wo[M.win].wrap = false

  -- Bind keymaps
  local function map(keys, callback)
    for _, k in ipairs(keys) do
      vim.keymap.set("n", k, callback, { buffer = M.buf, nowait = true, silent = true })
    end
  end

  local km = config.options.keymaps
  map(km.close, function()
    if not M.clear_visual_mode() then
      M.close()
    end
  end)
  map(km.visual_mode, M.toggle_visual_mode)
  map(km.visual_line, M.select_whole_week)
  map(km.next_month, function()
    M.change_month(1)
  end)
  map(km.prev_month, function()
    M.change_month(-1)
  end)
  map(km.next_year, function()
    M.change_year(1)
  end)
  map(km.prev_year, function()
    M.change_year(-1)
  end)
  map(km.next_day, function()
    M.change_day(1)
  end)
  map(km.prev_day, function()
    M.change_day(-1)
  end)
  map(km.today, M.goto_today)
  map(km.toggle_lang, M.toggle_language)
  map(km.copy_date, M.copy_selected_date)
  map(km.copy_iso, M.copy_iso_date)
  map(km.search, M.open_search_dialog)
  map(km.converter, M.open_converter_dialog)
  map(km.help, M.show_help)

  -- Render UI
  M.render()
end

return M
