local festivals_data = require("nepali-calendar.core.festivals_data")
local config = require("nepali-calendar.config")

local M = {}

-- Cache path: stdpath("data") .. "/nepali-calendar/festivals_cache.json"
local function get_cache_file()
  local data_dir = vim.fn.stdpath("data") .. "/nepali-calendar"
  if vim.fn.isdirectory(data_dir) == 0 then
    pcall(vim.fn.mkdir, data_dir, "p")
  end
  return data_dir .. "/festivals_cache.json"
end

--- Load any previously cached custom/updated festival data from disk
function M.load_cached_events()
  local file = get_cache_file()
  local f = io.open(file, "r")
  if not f then
    return
  end
  local content = f:read("*a")
  f:close()

  if not content or content == "" then
    return
  end

  local ok, data = pcall(vim.json.decode, content)
  if ok and type(data) == "table" and data.events then
    for k, v in pairs(data.events) do
      festivals_data.events[k] = v
    end
  end
end

--- Parse TSV format into key-value map
function M.parse_tsv(text)
  local events = {}
  for line in text:gmatch("[^\r\n]+") do
    local date_k, fest, tithi, hol = line:match("^([%d%-]+)\t([^\t]*)\t([^\t]*)\t(%d+)")
    if date_k then
      events[date_k] = {
        festival = fest or "",
        tithi = tithi or "",
        is_holiday = (hol == "1"),
      }
    end
  end
  return events
end

--- Asynchronously fetch latest festival updates from GitHub/remote URL
--- @param force boolean|nil
--- @param callback function|nil
function M.check_and_update(force, callback)
  if not config.options.auto_update_festivals and not force then
    return
  end

  local url = config.options.festivals_url
  if not url or url == "" then
    return
  end

  -- Use vim.system or curl in background without blocking Neovim
  local cmd = { "curl", "-s", "--max-time", "10", url }

  if vim.system then
    vim.system(cmd, { text = true }, function(out)
      if out.code == 0 and out.stdout and #out.stdout > 100 then
        local parsed = M.parse_tsv(out.stdout)
        local count = 0
        for k, v in pairs(parsed) do
          festivals_data.events[k] = v
          count = count + 1
        end

        if count > 0 then
          -- Save cache to disk
          local cache_file = get_cache_file()
          local f = io.open(cache_file, "w")
          if f then
            local payload = vim.json.encode({
              updated_at = os.time(),
              events = parsed,
            })
            f:write(payload)
            f:close()
          end

          vim.schedule(function()
            if force then
              vim.notify(string.format("Updated %d Nepali festivals & events from remote!", count), vim.log.levels.INFO, { title = "Nepali Calendar" })
            end
            if callback then
              callback(true, count)
            end
          end)
          return
        end
      end

      if callback then
        vim.schedule(function()
          callback(false, 0)
        end)
      end
    end)
  else
    -- Fallback for older Neovim versions
    vim.fn.jobstart(cmd, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if data and #data > 1 then
          local full_text = table.concat(data, "\n")
          local parsed = M.parse_tsv(full_text)
          for k, v in pairs(parsed) do
            festivals_data.events[k] = v
          end
          local cache_file = get_cache_file()
          local f = io.open(cache_file, "w")
          if f then
            f:write(vim.json.encode({ updated_at = os.time(), events = parsed }))
            f:close()
          end
        end
      end,
    })
  end
end

return M
