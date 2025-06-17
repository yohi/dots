local wezterm = require 'wezterm'
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- 設定の自動リロード
config.automatically_reload_config = true

-- IME使用
config.use_ime = true

-- 背景の透過
config.window_background_opacity = 1

config.enable_wayland = false


----------------------------------------------------
-- Font Configuration
----------------------------------------------------
config.font = wezterm.font('Cica Nerd Font', { weight = 'Regular' })
config.font_size = 11

----------------------------------------------------
-- Window Configuration
----------------------------------------------------
config.initial_cols = 120
config.initial_rows = 30

----------------------------------------------------
-- Character Encoding Configuration
----------------------------------------------------
-- UTF-8エンコーディングを明示的に設定
config.set_environment_variables = {
  LANG = 'ja_JP.UTF-8',
  LC_ALL = 'ja_JP.UTF-8',
}

----------------------------------------------------
-- Cursor Configuration
----------------------------------------------------
config.default_cursor_style = 'SteadyBar'

----------------------------------------------------
-- Tab Configuration
----------------------------------------------------
-- ウィンドウ枠を表示（タイトルバーとリサイズ境界を含む）
config.window_decorations = "TITLE | RESIZE"
-- config.window_decorations = "INTEGRATED_BUTTONS|NONE"
-- config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.integrated_title_button_style = "Windows"

-- タブバーの表示
config.show_tabs_in_tab_bar = true

-- タブが一つの時もタブバーを表示（タブ追加ボタンのため）
config.hide_tab_bar_if_only_one_tab = false

-- タブの追加ボタンを表示
config.show_new_tab_button_in_tab_bar = true

-- Cursorライクなタイトルバー設定
config.window_frame = {
  -- font = wezterm.font({ family = 'Cica Nerd Font', weight = 'Medium' }),
  -- font_size = 10.5,
  active_titlebar_bg = "#23272e",      -- VSCodeのアクティブタイトルバー色
  inactive_titlebar_bg = "#2c313a",    -- VSCodeの非アクティブタイトルバー色
  active_titlebar_fg = "#d4d4d4",      -- VSCodeのアクティブ文字色
  inactive_titlebar_fg = "#888888",    -- VSCodeの非アクティブ文字色
  active_titlebar_border_bottom = "#181a1f",
  inactive_titlebar_border_bottom = "#181a1f",
}

-- プロセス名とアイコン・色の対応テーブル
local process_icons = {
  docker = {
    color = "#1d63ed",
    icon = wezterm.nerdfonts.md_docker,
  },
  go = {
    color = "#79d4fd",
    icon = wezterm.nerdfonts.md_language_go,
  },
  nvim = {
    color = "#00b952",
    icon = wezterm.nerdfonts.custom_neovim,
  },
  zsh = {
    icon = wezterm.nerdfonts.dev_terminal,
  },
}

-- パスからファイル名部分だけを取り出す関数
local function trim_path(path)
  return string.gsub(path, "(.*[/\\])(.*)", "%2")
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local process_name = trim_path(pane.foreground_process_name or "")
  local icon_def = process_icons[process_name] or {}
  local icon = icon_def.icon or ""
  local icon_color = icon_def.color
  local cwd = pane.current_working_dir and trim_path(pane.current_working_dir.file_path) or ""
  local text_color = tab.is_active and "#c0c0c0" or "#808080"
  local zero_width_space = "\226\128\139"
  local title = pane.title or process_name

  return {
    { Foreground = { Color = text_color } },
    { Text = zero_width_space },
    { Foreground = { Color = icon_color or text_color } },
    { Text = icon ~= "" and icon or process_name },
    { Foreground = { Color = text_color } },
    { Text = " " .. title },
    { Text = " " .. cwd },
  }
end)

-- システム情報キャッシュ
local system_info_cache = {
  cpu_info = 'CPU:--',
  mem_info = 'MEM:--',
  last_cpu_stats = nil,
  last_update = 0,
  update_interval = 1000 -- 1秒間隔で更新
}

-- /proc/statから直接CPU統計を読み取る関数
local function read_cpu_stats()
  local success, file = pcall(io.open, "/proc/stat", "r")
  if not success or not file then
    return nil
  end

  local line = file:read("*line")
  file:close()

  if not line or not line:match("^cpu ") then
    return nil
  end

  local stats = {}
  for num in line:gmatch("%d+") do
    table.insert(stats, tonumber(num))
  end

  -- /proc/stat のフィールド: user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice
  if #stats >= 7 then
    local user = stats[1] or 0
    local nice = stats[2] or 0
    local system = stats[3] or 0
    local idle = stats[4] or 0
    local iowait = stats[5] or 0
    local irq = stats[6] or 0
    local softirq = stats[7] or 0
    local steal = stats[8] or 0
    local guest = stats[9] or 0
    local guest_nice = stats[10] or 0

    -- 総時間とアイドル時間を正確に計算
    local total = user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice
    local active = total - idle - iowait

    return {
      user = user,
      nice = nice,
      system = system,
      idle = idle,
      iowait = iowait,
      total = total,
      active = active
    }
  end

  return nil
end

-- /proc/meminfoから直接メモリ情報を読み取る関数
local function read_memory_info()
  local success, file = pcall(io.open, "/proc/meminfo", "r")
  if not success or not file then
    return nil
  end

  local mem_total, mem_available = nil, nil

  for line in file:lines() do
    if line:match("^MemTotal:") then
      mem_total = tonumber(line:match("(%d+)"))
    elseif line:match("^MemAvailable:") then
      mem_available = tonumber(line:match("(%d+)"))
    end

    if mem_total and mem_available then
      break
    end
  end

  file:close()

  if mem_total and mem_available then
    local mem_used = mem_total - mem_available
    local mem_percentage = math.floor((mem_used / mem_total) * 100)
    return mem_percentage
  end

  return nil
end

-- システム情報を非同期で更新する関数
local function update_system_info()
  -- WezTerm 0.17+ では wezterm.time() が高解像度の UNIX 時刻(float)を返す
  local current_time = wezterm.time() * 1000

  -- 更新間隔チェック
  if current_time - system_info_cache.last_update < system_info_cache.update_interval then
    return
  end

  -- CPU使用率計算
  local current_cpu_stats = read_cpu_stats()
  if current_cpu_stats then
    if system_info_cache.last_cpu_stats then
      -- 前回のデータが存在する場合のみ差分計算
      local prev_stats = system_info_cache.last_cpu_stats
      local total_diff = current_cpu_stats.total - prev_stats.total
      local active_diff = current_cpu_stats.active - prev_stats.active

      -- 差分が正の値で、かつ合理的な範囲内の場合のみ計算
      if total_diff > 0 and total_diff < 1000000 then -- 異常に大きな値を防ぐ
        local cpu_usage = math.max(0, math.min(100, math.floor((active_diff / total_diff) * 100)))
        system_info_cache.cpu_info = string.format("CPU:%d%%", cpu_usage)
      end
    else
      -- 初回はベースライン設定のみ、CPU使用率は表示しない
      system_info_cache.cpu_info = "CPU:--"
    end

    -- 現在の統計を保存（計算成功後に更新）
    system_info_cache.last_cpu_stats = current_cpu_stats
  end

  -- メモリ使用率計算
  local mem_percentage = read_memory_info()
  if mem_percentage then
    system_info_cache.mem_info = string.format("MEM:%d%%", mem_percentage)
  end

  system_info_cache.last_update = current_time
end

-- システム情報を取得する関数（キャッシュ版）
local function get_system_info()
  update_system_info()
  return system_info_cache.cpu_info, system_info_cache.mem_info
end

-- ステータスバー（フッター）イベントハンドラ
wezterm.on('update-status', function(window, pane)
  local date = os.date('%Y-%m-%d %H:%M:%S')
  local cpu_info, mem_info = 'CPU:--', 'MEM:--'
  local ok, c, m = pcall(get_system_info)
  if ok and c and m then
    cpu_info = c or 'CPU:--'
    mem_info = m or 'MEM:--'
  end

  -- IME状態
  local ime = 'IME:OFF'
  if window.ime_active ~= nil then
    local ok2, active = pcall(function() return window:ime_active() end)
    if ok2 and active then
      ime = 'IME:ON'
    end
  end

  -- アイコンはすべて絵文字で安全に
  local clock_icon = '🕒'
  local cpu_icon = '🖥️'
  local mem_icon = '💾'
  local ime_icon = '⌨️'

  window:set_right_status(wezterm.format({
    { Foreground = { Color = "#82aaff" } },
    { Text = clock_icon .. " " },
    { Foreground = { Color = "#c3e88d" } },
    { Text = date .. "  " },
    { Foreground = { Color = "#ffcb6b" } },
    { Text = cpu_icon .. " " },
    { Foreground = { Color = "#ffcb6b" } },
    { Attribute = { Intensity = "Bold" } },
    { Text = cpu_info .. "  " },
    { Foreground = { Color = "#f07178" } },
    { Text = mem_icon .. " " },
    { Foreground = { Color = "#f07178" } },
    { Attribute = { Underline = "Single" } },
    { Text = mem_info .. "  " },
    { Foreground = { Color = "#82aaff" } },
    { Text = ime_icon .. " " },
    { Foreground = { Color = ime == 'IME:ON' and "#c3e88d" or "#f07178" } },
    { Text = ime },
  }))
end)

-- マウスバインド設定
-- ・Ctrl+左クリック: 縦分割
-- ・Alt+左クリック: 横分割
-- ・右クリック: クリップボードから貼り付け
-- ・左クリック: 選択範囲をコピー
-- ・SUPER+左ドラッグ: ウィンドウ移動（Win/Commandキー）
-- ・Ctrl+Shift+左ドラッグ: ウィンドウ移動
config.mouse_bindings = {
  -- Ctrl+左クリックで縦分割
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  -- Alt+左クリックで横分割
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'ALT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  -- 右クリックでクリップボードから貼り付け
  {
    event = { Up = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
  -- 左クリックで選択範囲をコピー
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection',
  },
  -- SUPER（Win/Command）+左ドラッグでウィンドウ移動
  {
    event = { Drag = { streak = 1, button = 'Left' } },
    mods = 'SUPER',
    action = wezterm.action.StartWindowDrag,
  },
  -- Ctrl+Shift+左ドラッグでもウィンドウ移動
  {
    event = { Drag = { streak = 1, button = 'Left' } },
    mods = 'CTRL|SHIFT',
    action = wezterm.action.StartWindowDrag,
  },
}

-- キーバインドも追加（便利のため）
config.keys = {
  -- Ctrl+Shift+| で縦分割
  {
    key = '|',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  -- Ctrl+Shift+- で横分割
  {
    key = '_',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  -- より簡単なキーバインドも追加
  {
    key = 'v',
    mods = 'CTRL|ALT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'h',
    mods = 'CTRL|ALT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
}

-- Finally, return the configuration to wezterm
return config
