if vim.g.loaded_nepali_calendar then
  return
end
vim.g.loaded_nepali_calendar = true

-- User Commands
vim.api.nvim_create_user_command("NepaliCalendar", function()
  require("nepali-calendar").open()
end, { desc = "Open Nepali Calendar (नेपाली पात्रो) popup" })

vim.api.nvim_create_user_command("NepaliCalendarToggle", function()
  require("nepali-calendar").toggle()
end, { desc = "Toggle Nepali Calendar (नेपाली पात्रो) popup" })

vim.api.nvim_create_user_command("NepaliCalendarToday", function()
  local info = require("nepali-calendar").today()
  local str_np = require("nepali-calendar.core.format").format_full(info, "nepali")
  local loc = require("nepali-calendar.core.localization")
  local month_names = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
  local str_en = info.ad and string.format("🌐 AD: %s %d, %d (%s)", month_names[info.ad.month], info.ad.day, info.ad.year, loc.days_english_full[info.wday]) or ""
  local fest = (info.festival and info.festival ~= "") and ("\n✨ " .. info.festival) or ""
  local msg = string.format("🇳🇵 %s\n%s%s", str_np, str_en, fest)
  vim.notify(msg, vim.log.levels.INFO, { title = "Nepali Calendar (आज)" })
end, { desc = "Show today's Nepali & English date" })

vim.api.nvim_create_user_command("NepaliCalendarConvert", function()
  require("nepali-calendar.ui").open_converter_dialog()
end, { desc = "Open Nepali Date Converter / Age / Math tools" })

vim.api.nvim_create_user_command("NepaliCalendarSearch", function()
  require("nepali-calendar.ui").open_search_dialog()
end, { desc = "Search Nepali Festivals & Events" })

vim.api.nvim_create_user_command("NepaliCalendarUpdate", function()
  require("nepali-calendar").update_events()
end, { desc = "Fetch and update latest Nepali festivals & events from remote" })
