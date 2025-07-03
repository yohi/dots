-- WezTerm Configuration - 極力シンプル版
local wezterm = require 'wezterm'
local act = wezterm.action

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

-- ランチャー設定
config.launch_menu = {}  -- ランチャーメニューを空にする
config.show_tab_index_in_tab_bar = false  -- タブバーにインデックスを表示しない

-- ランチャーを完全に無効化
config.disable_default_key_bindings = false  -- デフォルトキーバインドは保持
config.automatically_reload_config = true  -- 設定の自動リロードを有効化

-- 新しいタブボタンの右クリックでLauncherが表示されないようにする追加設定
config.enable_tab_bar = true
config.show_new_tab_button_in_tab_bar = true  -- ボタンは表示するが、カスタムハンドラーで制御

-- ランチャー表示を完全に無効化
config.default_workspace = "main"  -- デフォルトワークスペースを設定
config.initial_cols = 80  -- 初期列数
config.initial_rows = 24  -- 初期行数

-- ペインのサイズと動作に関する設定
config.adjust_window_size_when_changing_font_size = false  -- フォントサイズ変更時のサイズ調整を無効化
config.pane_focus_follows_mouse = false  -- マウスフォーカスを無効化（安定性向上）
config.swallow_mouse_click_on_pane_focus = false  -- ペインフォーカス時のマウスクリックを処理
config.swallow_mouse_click_on_window_focus = false  -- ウィンドウフォーカス時のマウスクリックを処理

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

-- コマンドパレットにカスタムエントリを追加
wezterm.on('augment-command-palette', function(window, pane)
  return {
    {
      brief = 'Split Vertical (縦分割)',
      icon = 'md_border_vertical',
      action = act.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    {
      brief = 'Split Horizontal (横分割)',
      icon = 'md_border_horizontal',
      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
      brief = 'Close Current Pane (ペインを閉じる)',
      icon = 'md_close',
      action = act.CloseCurrentPane { confirm = true },
    },
  }
end)

-- 新しいタブボタンをクリックしたときのイベント処理
wezterm.on('new-tab-button-click', function(window, pane, button, default_action)
  wezterm.log_info('new-tab-button-click', button)  -- デバッグ用ログ
  if button == 'Left' then
    -- 左クリック：通常の新しいタブを作成
    window:perform_action(act.SpawnTab 'CurrentPaneDomain', pane)
  elseif button == 'Right' then
    -- 右クリック：縦分割（上下分割）でペインを作成 - SplitHorizontalを使用
    -- 複数のアクションを順番に実行して、レイアウトを適切に調整
    window:perform_action(act.Multiple {
      act.SplitHorizontal { domain = 'CurrentPaneDomain' },
      -- 新しいペインにフォーカスを移動
      act.ActivatePaneDirection 'Next',
      -- 少し待機してから全体のレイアウトを調整
      act.EmitEvent 'refresh-layout',
    }, pane)
  elseif button == 'Middle' then
    -- 中クリック：横分割（左右分割）でペインを作成 - SplitVerticalを使用
    window:perform_action(act.Multiple {
      act.SplitVertical { domain = 'CurrentPaneDomain' },
      -- 新しいペインにフォーカスを移動
      act.ActivatePaneDirection 'Next',
      -- 少し待機してから全体のレイアウトを調整
      act.EmitEvent 'refresh-layout',
    }, pane)
  end
  -- デフォルトアクション（Launcherの表示など）を防ぐ
  return false
end)

-- ステータスバーの更新（操作ヒントを表示）
wezterm.on('update-status', function(window, pane)
  local left_status = ''
  local right_status = ''

  -- アクティブなペインの数を取得
  local tab = window:active_tab()
  if tab then
    local panes = tab:panes()
    if #panes > 1 then
      left_status = string.format('Panes: %d', #panes)
    end
  end

  -- 右側のヒントを非表示にする
  right_status = ''

  window:set_left_status(wezterm.format {
    { Foreground = { Color = '#888888' } },
    { Text = left_status },
  })

  window:set_right_status(wezterm.format {
    { Foreground = { Color = '#888888' } },
    { Text = right_status },
  })
end)

-- レイアウト調整用のイベントハンドラー
wezterm.on('refresh-layout', function(window, pane)
  -- 分割後のレイアウトを調整
  local tab = window:active_tab()
  if tab then
    local panes = tab:panes()
    if #panes > 1 then
      -- 複数のペインがある場合、レイアウトを調整
      wezterm.log_info('Refreshing layout for', #panes, 'panes')

      -- 少し待機してからレイアウトを強制的に更新
      wezterm.sleep_ms(50)

      -- 現在のペインのサイズを取得して調整
      local current_pane = tab:active_pane()
      if current_pane then
        -- アクティブなペインに再フォーカス
        window:perform_action(act.ActivatePane { index = current_pane:pane_id() }, current_pane)

        -- 分割後のペインサイズを均等に調整
        -- 縦分割（上下分割）の場合、上下のペインを均等に調整
        local dims = current_pane:get_dimensions()
        if dims and dims.rows then
          -- 上下分割の場合、各ペインを均等に調整
          window:perform_action(act.Multiple {
            act.AdjustPaneSize { 'Up', math.floor(dims.rows / #panes) },
            act.AdjustPaneSize { 'Down', math.floor(dims.rows / #panes) },
          }, current_pane)
        end
      end
    end
  end
end)

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

-- ランチャーの表示を防ぐ（もし表示されそうになった場合）
wezterm.on('window-config-reloaded', function(window, pane)
  -- 設定リロード時にランチャーが表示されないようにする
  local tab = window:active_tab()
  if tab then
    local active_pane = tab:active_pane()
    if active_pane then
      -- アクティブなペインにフォーカスを戻す
      window:perform_action(act.ActivatePane { index = 0 }, active_pane)
    end
  end
end)

-- 貼り付け用のキーバインド
config.keys = {
  {
    key = 'v',
    mods = 'CTRL|SHIFT',
    action = act.PasteFrom 'Clipboard',
  },
  -- Ctrl+Shift+K でターミナルリセット
  {
    key = 'K',
    mods = 'CTRL|SHIFT',
    action = act.Multiple {
      act.ClearScrollback 'ScrollbackAndViewport',
      act.SendKey { key = 'L', mods = 'CTRL' },
    },
  },

  -- ペイン分割のキーバインド
  {
    key = 'Enter',
    mods = 'CTRL|SHIFT',
    action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '\\',
    mods = 'CTRL|SHIFT',
    action = act.SplitVertical { domain = 'CurrentPaneDomain' },
  },

  -- 追加の分割ショートカット
  {
    key = 'h',
    mods = 'CTRL|ALT',
    action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'v',
    mods = 'CTRL|ALT',
    action = act.SplitVertical { domain = 'CurrentPaneDomain' },
  },

  -- ペイン間の移動
  {
    key = 'LeftArrow',
    mods = 'CTRL|SHIFT',
    action = act.ActivatePaneDirection 'Left',
  },
  {
    key = 'RightArrow',
    mods = 'CTRL|SHIFT',
    action = act.ActivatePaneDirection 'Right',
  },
  {
    key = 'UpArrow',
    mods = 'CTRL|SHIFT',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = 'DownArrow',
    mods = 'CTRL|SHIFT',
    action = act.ActivatePaneDirection 'Down',
  },

  -- ペインのクローズ
  {
    key = 'w',
    mods = 'CTRL|SHIFT',
    action = act.CloseCurrentPane { confirm = true },
  },

  -- ペインのリサイズ
  {
    key = 'h',
    mods = 'CTRL|SHIFT|ALT',
    action = act.AdjustPaneSize { 'Left', 5 },
  },
  {
    key = 'l',
    mods = 'CTRL|SHIFT|ALT',
    action = act.AdjustPaneSize { 'Right', 5 },
  },
  {
    key = 'k',
    mods = 'CTRL|SHIFT|ALT',
    action = act.AdjustPaneSize { 'Up', 5 },
  },
  {
    key = 'j',
    mods = 'CTRL|SHIFT|ALT',
    action = act.AdjustPaneSize { 'Down', 5 },
  },

  -- コマンドパレット
  {
    key = 'p',
    mods = 'CTRL|SHIFT',
    action = act.ActivateCommandPalette,
  },

  -- ランチャーのキーバインドを無効化
  {
    key = 'l',
    mods = 'CTRL|SHIFT',
    action = act.DisableDefaultAssignment,
  },
  {
    key = 'L',
    mods = 'CTRL|SHIFT',
    action = act.DisableDefaultAssignment,
  },
}

-- マウスバインディング（シンプル版）
config.mouse_bindings = {
  -- 右クリック貼り付け
  {
    event = { Up = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act.PasteFrom 'Clipboard',
  },

  -- タブバー領域でのドラッグ設定
  -- 注意: WezTermのデフォルトでは、タブバー領域での左ドラッグは自動的にウィンドウ移動になります
  -- しかし、Linux環境では明示的な設定が必要な場合があります

  -- 推奨：修飾キーありのドラッグ設定（テキスト選択との競合を避ける）
  -- Ctrl+Shift+左ドラッグでウィンドウ移動（Weztermデフォルト）
  {
    event = { Drag = { streak = 1, button = 'Left' } },
    mods = 'CTRL|SHIFT',
    action = act.StartWindowDrag,
  },
  -- Alt+左ドラッグでもウィンドウ移動（推奨）
  {
    event = { Drag = { streak = 1, button = 'Left' } },
    mods = 'ALT',
    action = act.StartWindowDrag,
  },
  -- Super（Windowsキー/Commandキー）+左ドラッグでもウィンドウ移動
  {
    event = { Drag = { streak = 1, button = 'Left' } },
    mods = 'SUPER',
    action = act.StartWindowDrag,
  },
}

return config
