local M = {}

function M.setup_highlights()
  local highlights = {
    NepaliCalHeader = { link = "Title", default = true },
    NepaliCalSubHeader = { link = "Comment", default = true },
    NepaliCalWeekday = { link = "Keyword", default = true },
    NepaliCalSaturday = { link = "DiagnosticError", default = true },
    NepaliCalToday = { link = "CursorLineNr", bold = true, reverse = true, default = true },
    NepaliCalSelected = { link = "Visual", bold = true, default = true },
    NepaliCalHoliday = { link = "ErrorMsg", bold = true, default = true },
    NepaliCalFestival = { link = "Special", default = true },
    NepaliCalTithi = { link = "Identifier", default = true },
    NepaliCalPanchanga = { link = "Function", default = true },
    NepaliCalBorder = { link = "FloatBorder", default = true },
    NepaliCalKey = { link = "SpecialKey", default = true },
    NepaliCalOpen = { link = "DiagnosticOk", default = true },
    NepaliCalClosed = { link = "DiagnosticWarn", default = true },
    NepaliCalEnglishSub = { link = "Comment", default = true },
    NepaliCalProgressBar = { link = "String", default = true },
    NepaliCalProgressFill = { link = "Function", bold = true, default = true },
  }

  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

return M
