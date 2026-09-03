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
  local str = require("nepali-calendar.core.format").format_full(info, "nepali")
  vim.notify("🇳🇵 आज: " .. str, vim.log.levels.INFO, { title = "Nepali Calendar" })
end, { desc = "Show today's Nepali date" })

vim.api.nvim_create_user_command("NepaliCalendarConvert", function()
  require("nepali-calendar.ui").open_converter_dialog()
end, { desc = "Open Nepali Date Converter / Age / Math tools" })

vim.api.nvim_create_user_command("NepaliCalendarSearch", function()
  require("nepali-calendar.ui").open_search_dialog()
end, { desc = "Search Nepali Festivals & Events" })
