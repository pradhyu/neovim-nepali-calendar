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

-- Backup file path: stdpath("data") .. "/nepali-calendar/festivals_backup.json"
local function get_backup_file()
  local data_dir = vim.fn.stdpath("data") .. "/nepali-calendar"
  if vim.fn.isdirectory(data_dir) == 0 then
    pcall(vim.fn.mkdir, data_dir, "p")
  end
  return data_dir .. "/festivals_backup.json"
end

--- Load any previously cached custom/updated festival data from disk with fallback to backup
function M.load_cached_events()
  local file = get_cache_file()
  local f = io.open(file, "r")
  if not f then
    -- Try backup file if primary cache is missing
    file = get_backup_file()
    f = io.open(file, "r")
  end

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
  local count = 0
  for line in text:gmatch("[^\r\n]+") do
    local date_k, fest, tithi, hol = line:match("^([%d%-]+)\t([^\t]*)\t([^\t]*)\t(%d+)")
    if date_k then
      events[date_k] = {
        festival = fest or "",
        tithi = tithi or "",
        is_holiday = (hol == "1"),
      }
      count = count + 1
    end
  end
  return events, count
end

--- Asynchronously fetch latest festival updates from GitHub/remote URL
--- Safely keeps existing data and creates backups; NEVER replaces on failure or empty responses.
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

  local function handle_success(stdout)
    if not stdout or #stdout < 200 then
      if force then
        vim.notify("Remote festival file is empty or unreachable. Keeping existing events.", vim.log.levels.WARN, { title = "Nepali Calendar" })
      end
      if callback then
        callback(false, 0)
      end
      return
    end

    local parsed, count = M.parse_tsv(stdout)
    -- Sanity check: must contain at least 100 valid events to prevent corrupt replacement
    if count < 100 then
      if force then
        vim.notify("Remote response invalid or corrupted. Keeping existing events.", vim.log.levels.WARN, { title = "Nepali Calendar" })
      end
      if callback then
        callback(false, 0)
      end
      return
    end

    -- 1. Create a backup of existing active cache before overwriting
    local cache_file = get_cache_file()
    local backup_file = get_backup_file()
    local old_cache = io.open(cache_file, "r")
    if old_cache then
      local old_content = old_cache:read("*a")
      old_cache:close()
      if old_content and #old_content > 0 then
        local b_file = io.open(backup_file, "w")
        if b_file then
          b_file:write(old_content)
          b_file:close()
        end
      end
    end

    -- 2. Safely merge new events into memory
    for k, v in pairs(parsed) do
      festivals_data.events[k] = v
    end

    -- 3. Write validated payload to disk
    local f = io.open(cache_file, "w")
    if f then
      local payload = vim.json.encode({
        updated_at = os.time(),
        events = parsed,
      })
      f:write(payload)
      f:close()
    end

    if force then
      vim.notify(string.format("Successfully updated and verified %d festivals from remote!", count), vim.log.levels.INFO, { title = "Nepali Calendar" })
    end
    if callback then
      callback(true, count)
    end
  end

  if vim.system then
    vim.system(cmd, { text = true }, function(out)
      vim.schedule(function()
        if out.code == 0 and out.stdout then
          handle_success(out.stdout)
        else
          if force then
            vim.notify("Network request failed. Keeping local events intact.", vim.log.levels.WARN, { title = "Nepali Calendar" })
          end
          if callback then
            callback(false, 0)
          end
        end
      end)
    end)
  else
    vim.fn.jobstart(cmd, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if data and #data > 1 then
          local full_text = table.concat(data, "\n")
          vim.schedule(function()
            handle_success(full_text)
          end)
        end
      end,
      on_exit = function(_, code)
        if code ~= 0 and force then
          vim.schedule(function()
            vim.notify("Failed to fetch remote updates. Kept existing local data.", vim.log.levels.WARN, { title = "Nepali Calendar" })
          end)
        end
      end,
    })
  end
end

return M
