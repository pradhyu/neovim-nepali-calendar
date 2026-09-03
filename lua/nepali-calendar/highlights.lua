local M = {}

function M.setup_highlights()
  -- Theme-aware colors derived cleanly from standard groups or beautiful dark fallbacks
  local highlights = {
    NepaliCalHeader = { link = "Title", bold = true, default = true },
    NepaliCalSubHeader = { link = "Directory", default = true },
    NepaliCalWeekday = { link = "Special", bold = true, default = true },
    NepaliCalSaturday = { link = "DiagnosticError", bold = true, default = true },
    NepaliCalDay = { link = "Function", bold = true, default = true },
    NepaliCalToday = { link = "IncSearch", bold = true, default = true },
    NepaliCalSelected = { link = "Search", bold = true, default = true },
    NepaliCalHoliday = { link = "DiagnosticWarn", bold = true, default = true },
    NepaliCalFestival = { link = "DiagnosticOk", bold = true, default = true },
    NepaliCalTithi = { link = "String", default = true },
    NepaliCalEnglishDate = { link = "Title", bold = true, default = true },
    NepaliCalEnglishSub = { link = "Comment", default = true },
    NepaliCalPanchanga = { link = "Identifier", default = true },
    NepaliCalBorder = { link = "FloatBorder", default = true },
    NepaliCalKey = { link = "Comment", default = true },
    NepaliCalOpen = { link = "DiagnosticOk", bold = true, default = true },
    NepaliCalClosed = { link = "DiagnosticError", bold = true, default = true },
  }

  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

return M
