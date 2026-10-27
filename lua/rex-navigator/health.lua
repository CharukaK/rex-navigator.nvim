--- Health check module for rex-navigator.nvim (:checkhealth rex-navigator)
local utils = require("rex-navigator.utils")

local M = {}

function M.check()
  local health = vim.health or {}

  if health.start then
    health.start("rex-navigator")
  else
    vim.health.report_start("rex-navigator")
  end

  local report_ok = health.ok or vim.health.report_ok
  local report_warn = health.warn or vim.health.report_warn
  local report_error = health.error or vim.health.report_error
  local report_info = health.info or vim.health.report_info

  -- 1. Check if running inside Rex
  if utils.is_rex() then
    report_ok("Running inside a Rex terminal session")
  else
    report_warn("Not running inside a Rex terminal session (Rex fallback mode active)")
  end

  -- 2. Check Rex executable discovery
  local bin = utils.get_rex_bin()
  if bin then
    report_ok("Found Rex executable: " .. bin)
    local ok, ver = utils.run_rex_cmd({ "version" })
    if ok then
      report_ok("Rex version: " .. vim.trim(ver))
    else
      report_warn("Could not retrieve Rex version: " .. tostring(ver))
    end
  else
    report_error("Rex executable 'rex' not found in PATH or REX_BIN_DIR")
  end

  -- 3. Check environment variables
  if vim.env.REX_SESSION and vim.env.REX_SESSION ~= "" then
    report_ok("REX_SESSION: " .. vim.env.REX_SESSION)
  else
    report_info("REX_SESSION is not set")
  end

  if vim.env.REX_BLOCK and vim.env.REX_BLOCK ~= "" then
    report_ok("REX_BLOCK: " .. vim.env.REX_BLOCK)
  else
    report_info("REX_BLOCK is not set")
  end

  if vim.env.REX_SERVER and vim.env.REX_SERVER ~= "" then
    report_ok("REX_SERVER: " .. vim.env.REX_SERVER)
  else
    report_info("REX_SERVER is not set")
  end
end

return M
