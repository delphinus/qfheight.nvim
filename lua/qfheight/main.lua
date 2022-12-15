---@class qfheight.main.Qfheight
---@field default_options qfheight.main.Options
---@field opts qfheight.main.Options
---@field augroup integer
local Qfheight = {}

---@return qfheight.main.Qfheight
Qfheight.new = function()
  return setmetatable(
    { augroup = vim.api.nvim_create_augroup("qfheight", {}), default_options = { max = 10, min = 3 }, opts = {} },
    { __index = Qfheight }
  )
end

---@class qfheight.main.Options
---@field max integer
---@field min integer

---@param opts qfheight.main.Options
---@return nil
function Qfheight:setup(opts)
  self.opts = vim.tbl_extend("force", self.default_options, opts)
  vim.validate {
    max = {
      self.opts.max,
      function(v)
        return type(v) == "number" and self.opts.max >= self.opts.min
      end,
      "number and max >= min",
    },
    min = {
      self.opts.min,
      function(v)
        return type(v) == "number" and self.opts.max >= self.opts.min
      end,
      "number and max >= min",
    },
  }
  self:enable()
end

---@return nil
function Qfheight:enable()
  self:disable()
  vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "VimResized" }, {
    group = self.augroup,
    ---@param args { event: string }
    callback = function(args)
      if args.event == "VimResized" then
        ---@type integer[]
        local quickfixes = vim.tbl_filter(function(winid)
          local bufnr = vim.api.nvim_win_get_buf(winid)
          return vim.api.nvim_buf_get_option(bufnr, "buftype") == "quickfix"
        end, vim.api.nvim_list_wins())
        for _, winid in ipairs(quickfixes) do
          self:set(winid)
        end
      elseif vim.opt.buftype:get() == "quickfix" then
        self:set(0)
      end
    end,
  })
end

---@return nil
function Qfheight:disable()
  vim.api.nvim_clear_autocmds { group = self.augroup }
end

---@param winid integer
---@return nil
function Qfheight:set(winid)
  local i = 0
  local count = 0
  local last = vim.fn.line("$", winid) - 1
  local winwidth = vim.fn.winwidth(winid)
  local bufnr = vim.api.nvim_win_get_buf(winid)
  while i <= last do
    local line = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)
    if #line == 0 then
      break
    end
    local width = vim.fn.strdisplaywidth(line[1])
    count = count + math.ceil(width / winwidth)
    if count >= self.opts.max then
      break
    end
    i = i + 1
  end
  local height = math.max(math.min(count, self.opts.max), self.opts.min)
  vim.api.nvim_win_set_height(winid, height)
end

---@param msg string
---@return nil
function Qfheight:warn(msg) --luacheck: ignore 212
  vim.notify("[qfh] " .. msg, vim.log.levels.WARN)
end

return Qfheight
