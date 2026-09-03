# 🇳🇵 nepali-calendar.nvim

A comprehensive, fast, native Lua Nepali (Bikram Sambat / पात्रो) Calendar popup and date tool for Neovim.

Designed following the specifications of [mac-nepali-calendar](https://github.com/pradhyu/mac-nepali-calendar): supporting 1975–2100 BS, 3,200+ festivals & tithis, Kathmandu Panchanga (Sunrise, Sunset, Rahu Kaal), live Nepal Time & office hours, AD ⟷ BS conversion, BS age calculation, date math, and statusline integration.

---

## 📸 Preview

```text
┌──────────────── 🇳🇵 Nepali Calendar (पात्रो) ────────────────┐
│      🇳🇵 काठमाडौँ: 10:45:12 AM  [खुला (Offices & Banks Open)]       │
│                 10h 45m ahead of local                         │
│────────────────────────────────────────────────────────────────│
│                          « भदौ २०८३ »                          │
│                    Aug 17 – Sep 16, 2026                       │
│────────────────────────────────────────────────────────────────│
│    आइत   सोम   मंगल   बुध   बिही   शुक्र   शनि                 │
│┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄│
│                 १     २     ३     ४     ५     ६*               │
│     ७     ८     ९    १०    ११    १२*   १३*                     │
│    १४    १५    १६   [१७]   १८    १९*   २०*                     │
│    २१    २२    २३    २४    २५    २६    २७*                     │
│    २८    २९    ३०    ३१                                        │
│────────────────────────────────────────────────────────────────│
│  📅 १७ भदौ २०८३, बुधबार (षष्ठी)                                  │
│  AD: Sep 2, 2026 (Wednesday)                                   │
│  🌅 05:28 AM   🌇 06:53 PM   ⌛ 13h 24m                        │
│  ☀️ राशि: सिंह (Leo)   ⏱ राहु काल: 12:00 PM – 01:30 PM         │
│────────────────────────────────────────────────────────────────│
│  [h/l] Month  [j/k] Day  [t] Today  [c] Convert                │
│  [y] Copy BS  [yi] ISO   [Tab] Lang [q] Close                  │
└────────────────────────────────────────────────────────────────┘
```

---

## ✨ Features

- 📅 **Bikram Sambat (1975 – 2100 BS)** month matrix grid with accurate month lengths and leap years.
- 🕉️ **Festivals, Tithis & Holidays**: 3,200+ event entries with holiday highlighting (`*`).
- 🧭 **Kathmandu Panchanga**: Astronomical calculations for Sunrise (सूर्योदय), Sunset (सूर्यास्त), Day Length, Sun Rashi (राशि), and Rahu Kaal (राहु काल).
- 🇳🇵 **Nepal Clock & Office Status**: Live Kathmandu time (UTC+5:45) with local time difference and Nepal government office hours indicator.
- 🏖️ **Long Weekend Detector**: Automatic identification of consecutive holidays + Saturday streaks.
- 🔄 **AD ⟷ BS Converter, Age Calculator & Date Math**: Interactive picker tools (`c`) to convert dates, calculate BS age, and add/subtract days.
- 📋 **Clipboard Copying**: Instant copy of formatted Nepali strings (`y`), Devanagari dates, and ISO dates (`yi` -> `YYYY-MM-DD`).
- 📊 **Statusline Integration**: Native helper for `lualine.nvim` or custom Neovim statuslines.
- ⌨️ **Vim Navigation**: Fluid navigation using standard keys (`h`/`j`/`k`/`l`, `{`/`}`, `t`, etc.).

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

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use({
  "pradhyu/neovim-nepali-calendar",
  config = function()
    require("nepali-calendar").setup()
  end,
})
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'pradhyu/neovim-nepali-calendar'
```

---

## ⌨️ Keybindings

### In the Calendar Popup:

| Key | Action |
|---|---|
| `h` / `[` / `<Left>` | Previous Month |
| `l` / `]` / `<Right>` | Next Month |
| `H` / `{` | Previous Year (-1) |
| `L` / `}` | Next Year (+1) |
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

- `:NepaliCalendar` — Open Nepali Calendar popup.
- `:NepaliCalendarToggle` — Toggle popup open / close.
- `:NepaliCalendarToday` — Show today's Nepali date via notification.
- `:NepaliCalendarConvert` — Open interactive date conversion & age calculation dialog.

---

## 📊 Statusline Integration

Add today's Nepali date to your `lualine.nvim` statusline:

```lua
require('lualine').setup({
  sections = {
    lualine_x = {
      {
        function()
          -- format: "short" ("भदौ १७, २०८३"), "full", or "iso" ("2083-05-17")
          -- lang: "nepali" or "english"
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

## 🛠️ Lua API

You can also use the Lua API directly in your custom scripts:

```lua
local nc = require("nepali-calendar")

-- Open / Toggle popup
nc.open()
nc.toggle()
nc.close()

-- Get today's Nepali date info
local today = nc.today()
print(today.year, today.month, today.day, today.festival, today.tithi)

-- Convert AD -> BS
local bs = nc.ad_to_bs(2026, 9, 2)
print(string.format("%04d-%02d-%02d", bs.year, bs.month, bs.day))

-- Convert BS -> AD
local ad = nc.bs_to_ad(2083, 5, 17)
print(string.format("%04d-%02d-%02d (%s)", ad.year, ad.month, ad.day, ad.wday))

-- Calculate Bikram Sambat Age
local age = nc.calculate_age({ year = 2055, month = 1, day = 1 })
print(age.years, age.months, age.days, age.next_birthday_in_days)
```

---

## ⚙️ Configuration Options

Default configuration settings:

```lua
require("nepali-calendar").setup({
  language = "nepali",        -- "nepali" or "english"
  border = "rounded",         -- "rounded", "single", "double", "solid", "shadow"
  show_panchanga = true,      -- Kathmandu Panchanga (Sunrise, Sunset, Rahu Kaal)
  show_nepal_clock = true,    -- Live Nepal Time & Office status header
  show_ad_date = true,        -- Gregorian span in header
  show_long_weekends = false, -- Highlight upcoming consecutive holidays
  show_month_progress = false,-- Visual month progress bar
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
})
```

---

## 📄 License

MIT License © [Pradhyumna Shrestha](https://github.com/pradhyu)
