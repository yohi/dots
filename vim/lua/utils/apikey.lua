-- utils/apikey.lua
-- APIキー管理ユーティリティ
-- 要件5.1: 環境変数からAPIキーを取得
-- 要件5.2: 未設定時に警告を表示

local M = {}

---@class ApiKeyResult
---@field key string? APIキー（未設定時はnil）
---@field valid boolean キーが有効か

--- 環境変数からAPIキーを取得する
---
--- キーが存在する場合はその値を返し、未設定またはエラーの場合は
--- vim.notify で警告を表示して valid = false を返す。
---
---@param env_var string 環境変数名
---@param plugin_name string プラグイン名（警告表示用）
---@return ApiKeyResult
function M.get_api_key(env_var, plugin_name)
  local key = vim.env[env_var]
  if not key or key == "" then
    vim.notify(
      string.format("[%s] APIキーが未設定です。環境変数 %s を設定してください。", plugin_name, env_var),
      vim.log.levels.WARN
    )
    return { key = nil, valid = false }
  end
  return { key = key, valid = true }
end

--- APIキーが有効かどうかのみをチェックする
---
--- 警告は表示せず、キーの有無のみを確認する。
---
---@param env_var string 環境変数名
---@return boolean
function M.has_api_key(env_var)
  local key = vim.env[env_var]
  return key ~= nil and key ~= ""
end

--- APIキーを必要とするプラグインの enabled フラグを返す
---
--- キーが未設定の場合は false を返し、プラグインを無効化する。
--- 警告は表示しない（プラグイン有効化時の判断用）。
---
---@param env_var string 環境変数名
---@return boolean
function M.is_plugin_enabled(env_var)
  return M.has_api_key(env_var)
end

return M
