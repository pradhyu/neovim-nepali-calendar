# 🇳🇵 nepali-calendar.nvim

A comprehensive, fast, native Lua Nepali (Bikram Sambat / पात्रो) Calendar popup and date tool for Neovim.

Designed following the specifications of macOS Nepali Calendar: supporting 1975–2100 BS, 3,200+ festivals & tithis, Kathmandu Panchanga (Sunrise, Sunset, Rahu Kaal), live Nepal Time & office hours, AD ⟷ BS conversion, BS age calculation, date math, and statusline integration.

---

## ✨ Features

- 📅 **Bikram Sambat (1975 – 2100 BS)** month matrix grid with accurate month lengths and leap years.
- 🕉️ **Festivals, Tithis & Holidays**: 3,200+ event entries with holiday highlighting (`*`).
- 🧭 **Kathmandu Panchanga**: Astronomical Sunrise, Sunset, Day Length, Sun Rashi (राशि), and Rahu Kaal (राहु काल) calculations.
- 🇳🇵 **Nepal Clock & Office Status**: Live Kathmandu time (UTC+5:45) with local time difference and Nepal government office hours indicator.
- 🏖️ **Long Weekend Detector**: Automatic identification of consecutive holidays + Saturday streaks.
- 🔄 **AD ⟷ BS Converter, Age Calculator & Date Math**: Interactive picker tools to convert dates, calculate BS age, and add/subtract days.
- 📋 **Clipboard Copying**: Instant copy of formatted Nepali strings, Devanagari dates, and ISO dates (`YYYY-MM-DD`).
- 📊 **Statusline Integration**: Native helper for `lualine.nvim` or custom Neovim statuslines.

---

## 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "pradhyu/neovim-nepali-calendar",
  cmd = { "NepaliCalendar", "NepaliCalendarToggle", "NepaliCalendarToday", "NepaliCalendarConvert" },
  keys = {
    { "<leader>nc", "<cmd>NepaliCalendarToggle<cr>", desc = "Nepali Calendar (नेपाली पात्रो)" },
    { "<leader>nt", "<cmd>NepaliCalendarToday<cr>", desc = "Today's Nepali Date" },
  },
  opts = {
    language = "nepali", -- "nepali" or "english"
    border = "rounded",
    show_panchanga = true,
    show_nepal_clock = true,
    show_ad_date = true,
    show_long_weekends = false,
    show_month_progress = false,
  },
}
```

---

## ⌨️ Popup Keybindings

When the calendar popup is open:

| Key | Description |
|---|---|
| `h` / `[` / `<Left>` | Previous Month |
| `l` / `]` / `<Right>` | Next Month |
| `{` / `H` | Previous Year (-1) |
| `}` / `L` | Next Year (+1) |
| `j` / `<Down>` | Next Day (+1) |
| `k` / `<Up>` | Previous Day (-1) |
| `t` | Jump to Today |
| `<Tab>` | Toggle Language (`नेपाली` ↔ `English`) |
| `y` | Copy Full Nepali Date String to clipboard |
| `yi` | Copy ISO Date (`YYYY-MM-DD`) to clipboard |
| `c` | Open Converter / Age / Date Math Menu |
| `?` | Show Help Dialog |
| `q` / `<Esc>` | Close Calendar Popup |

---

## 💻 Commands

- `:NepaliCalendar` - Open Nepali Calendar popup.
- `:NepaliCalendarToggle` - Toggle popup open / close.
- `:NepaliCalendarToday` - Show today's Nepali date via notification.
- `:NepaliCalendarConvert` - Open interactive date conversion & age calculation dialog.

---

## 📊 Statusline Integration

For `lualine.nvim`:

```lua
require('lualine').setup({
  sections = {
    lualine_x = {
      {
        function()
          return require("nepali-calendar").statusline({ format = "short", lang = "nepali" })
        end,
      },
      "encoding",
      "fileformat",
      "filetype",
    },
  },
})
```

---

## ⚙️ Configuration

```lua
require("nepali-calendar").setup({
  language = "nepali",        -- "nepali" or "english"
  border = "rounded",         -- "rounded", "single", "double", "solid", "shadow"
  show_panchanga = true,      -- Kathmandu Panchanga (Sunrise, Sunset, Rahu Kaal)
  show_nepal_clock = true,    -- Live Nepal Time & Office status header
  show_ad_date = true,        -- Gregorian span in header
  show_long_weekends = true,  -- Highlight upcoming consecutive holidays
  show_month_progress = true, -- Visual month progress bar
})
```
# neovim-nepali-calendar
