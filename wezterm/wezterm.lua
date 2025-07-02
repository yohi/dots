-- WezTerm Configuration - 極力シンプル版
local wezterm = require 'wezterm'

-- 設定テーブルを作成
local config = {}

-- 通常の設定
config.colors = {
  background = "#1e1e1e",  -- 通常の暗い背景色
}

-- フォント設定
config.font = wezterm.font("Cica Nerd Font", {weight="Regular", stretch="Normal", style="Normal"})

-- カーソル設定
config.default_cursor_style = 'SteadyBar'  -- Iビーム（縦線）カーソル

-- IME設定
config.use_ime = true  -- IMEを有効にする
config.ime_preedit_rendering = 'Builtin'  -- IMEプリエディットの表示方法

-- Neovimのモード変更に応じたIME制御
wezterm.on('user-var-changed', function(window, pane, name, value)
  local overrides = window:get_config_overrides() or {}
  if name == "NVIM_MODE" then
    if value == "n" then
      -- ノーマルモード: IMEを無効化
      overrides.use_ime = false
    elseif value == "i" or value == "c" then
      -- 挿入モードまたはコマンドモード: IMEを有効化
      overrides.use_ime = true
    end
    window:set_config_overrides(overrides)
  end
end)

-- 貼り付け用のキーバインド
config.keys = {
  {
    key = 'v',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
  -- Ctrl+Shift+K でターミナルリセット
  {
    key = 'K',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.Multiple {
      wezterm.action.ClearScrollback 'ScrollbackAndViewport',
      wezterm.action.SendKey { key = 'L', mods = 'CTRL' },
    },
  },
}

-- マウスバインディング
config.mouse_bindings = {
  -- 右クリック貼り付け
  {
    event = { Up = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
  -- Ctrl+Shift+左ドラッグでウィンドウ移動（Weztermデフォルト）
  {
    event = { Drag = { streak = 1, button = 'Left' } },
    mods = 'CTRL|SHIFT',
    action = wezterm.action.StartWindowDrag,
  },
  -- Alt+左ドラッグでもウィンドウ移動（代替手段）
  {
    event = { Drag = { streak = 1, button = 'Left' } },
    mods = 'ALT',
    action = wezterm.action.StartWindowDrag,
  },
  -- Super（Windowsキー/Commandキー）+左ドラッグでもウィンドウ移動
  {
    event = { Drag = { streak = 1, button = 'Left' } },
    mods = 'SUPER',
    action = wezterm.action.StartWindowDrag,
  },
}

return config
