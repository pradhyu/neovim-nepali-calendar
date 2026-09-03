local M = {}

M.defaults = {
  language = "nepali", -- "nepali" or "english"
  border = "rounded", -- "rounded", "single", "double", "solid", "shadow"
  show_panchanga = true,
  show_nepal_clock = true,
  show_ad_date = true,
  show_english_subscript = true,
  show_long_weekends = false,
  show_month_progress = false,
  keymaps = {
    close = { "q", "<Esc>" },
    next_month = { "l", "<Right>", "]" },
    prev_month = { "h", "<Left>", "[" },
    next_year = { "}", "L" },
    prev_year = { "{", "H" },
    next_day = { "j", "<Down>" },
    prev_day = { "k", "<Up>" },
    today = { "t", "T" },
    toggle_lang = { "<Tab>" },
    copy_date = { "yy", "y" },
    copy_iso = { "yi" },
    converter = { "c", "C" },
    help = { "?" },
  },
}

M.options = vim.deepcopy(M.defaults)

function M.setup(user_opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, user_opts or {})
end

return M
