-- WezTerm Configuration - 極力シンプル版
local wezterm = require 'wezterm'

-- 設定テーブルを作成
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- 通常の設定
config.colors = {
  background = "#1e1e1e",  -- 通常の暗い背景色
}

config.color_scheme = "Tokyo Night"  -- カラースキームを設定

-- フォント設定
config.font = wezterm.font("Cica Nerd Font", {weight="Regular", stretch="Normal", style="Normal"})

-- カーソル設定
config.default_cursor_style = 'SteadyBar'  -- Iビーム（縦線）カーソル

-- IME設定
config.use_ime = true  -- IMEを有効にする
config.ime_preedit_rendering = 'Builtin'  -- IMEプリエディットの表示方法

-- ウィンドウ装飾設定
-- config.window_decorations = "TITLE | RESIZE"  -- タイトルバーとリサイズ可能な境界線を有効
config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"  -- 統合ボタンモード（タブバーにウィンドウ制御ボタンを配置）

-- Unity環境では"RESIZE"でもタイトルバーが表示されるため、統合ボタンモードを使用
-- 統合ボタンモードではタブバーにボタンが統合されてタイトルバーが非表示になる
-- config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"  -- タブバーにボタンを統合、タイトルバー非表示
-- config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"  -- タイトルバーを非表示にし、タブバーにウィンドウ制御ボタンを配置

-- Linux環境での追加設定
if wezterm.target_triple:find("linux") then
  -- X11/Wayland環境での設定
  config.enable_wayland = true  -- Waylandサポートを有効化
  config.window_background_opacity = 1.0  -- 透明度を無効化

  -- タブバーのドラッグ機能を確実に有効化するための追加設定
  config.adjust_window_size_when_changing_font_size = false  -- フォントサイズ変更時のウィンドウサイズ調整を無効化
end

-- 統合ボタンの設定（INTEGRATED_BUTTONS モード用）
config.integrated_title_button_style = "Windows"  -- Windows スタイル
config.integrated_title_buttons = { 'Hide', 'Maximize', 'Close' }  -- 表示するボタン
config.integrated_title_button_alignment = "Right"  -- ボタンの配置（Right推奨）

-- タブバー設定
config.enable_tab_bar = true
config.tab_bar_at_bottom = false  -- タブバーを上部に配置
-- config.use_fancy_tab_bar = false  -- レトロモードでカスタムボタンスタイルを有効化
config.tab_max_width = 16
config.show_tabs_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false  -- タブが1つでもタブバーを表示（ドラッグ用）

-- ウィンドウフレーム設定（タブバーの色とスタイル）
config.window_frame = {
  active_titlebar_bg = '#333333',
  inactive_titlebar_bg = '#2b2b2b',
  active_titlebar_fg = '#ffffff',
  inactive_titlebar_fg = '#cccccc',
  -- ボタンの色設定（RESIZE モードでは不要）
  -- button_fg = '#000000',        -- 黒文字
  -- button_bg = '#ffff00',        -- 黄色背景
  -- button_hover_fg = '#000000',  -- ホバー時も黒文字
  -- button_hover_bg = '#ffff80',  -- ホバー時薄い黄色
}

-- カスタムボタンスタイル（統合ボタン用）
config.tab_bar_style = {
  -- 最小化ボタン（より目立つデザイン）
  window_hide = wezterm.format {
    { Foreground = { Color = '#000000' } },
    { Background = { Color = '#ffa500' } },  -- オレンジ色の背景
    { Text = ' _ ' },  -- シンプルなアンダースコア
  },
  window_hide_hover = wezterm.format {
    { Foreground = { Color = '#000000' } },
    { Background = { Color = '#ffcc80' } },  -- 薄いオレンジ色
    { Text = ' _ ' },
  },
  -- 最大化ボタン
  window_maximize = wezterm.format {
    { Foreground = { Color = '#000000' } },
    { Background = { Color = '#4caf50' } },  -- 緑色の背景
    { Text = ' ◻ ' },  -- 四角いアイコン
  },
  window_maximize_hover = wezterm.format {
    { Foreground = { Color = '#000000' } },
    { Background = { Color = '#80c784' } },  -- 薄い緑色
    { Text = ' ◻ ' },
  },
  -- 閉じるボタン
  window_close = wezterm.format {
    { Foreground = { Color = '#ffffff' } },
    { Background = { Color = '#f44336' } },  -- 赤色の背景
    { Text = ' × ' },  -- X記号
  },
  window_close_hover = wezterm.format {
    { Foreground = { Color = '#ffffff' } },
    { Background = { Color = '#ff8a80' } },  -- 薄い赤色
    { Text = ' × ' },
  },
}

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

  -- タブバー領域でのドラッグ設定
  -- 注意: WezTermのデフォルトでは、タブバー領域での左ドラッグは自動的にウィンドウ移動になります
  -- しかし、Linux環境では明示的な設定が必要な場合があります

  -- 推奨：修飾キーありのドラッグ設定（テキスト選択との競合を避ける）
  -- Ctrl+Shift+左ドラッグでウィンドウ移動（Weztermデフォルト）
  {
    event = { Drag = { streak = 1, button = 'Left' } },
    mods = 'CTRL|SHIFT',
    action = wezterm.action.StartWindowDrag,
  },
  -- Alt+左ドラッグでもウィンドウ移動（推奨）
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
