return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && npm install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  ft = { "markdown" },
  config = function()
    -- プレビューオプションの設定
    vim.g.mkdp_preview_options = {
      mkit = {},
      katex = {},
      uml = {},
      maid = {},
      disable_sync_scroll = 0,
      sync_scroll_type = 'middle',
      hide_yaml_meta = 1,
      sequence_diagrams = {},
      flowchart_diagrams = {},
      content_editable = false,
      disable_filename = 0,
      toc = {}
    }

    -- カスタムテーマ設定 (ダークテーマ)
    vim.g.mkdp_theme = 'dark'

    -- プレビューページのタイトル設定
    vim.g.mkdp_page_title = '「${name}」'

    -- 認識するファイルタイプ
    vim.g.mkdp_filetypes = { 'markdown' }

    -- 自動でブラウザを開く
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1

    -- プレビュー更新の設定
    vim.g.mkdp_refresh_slow = 0

    -- ブラウザの指定（空の場合はデフォルトブラウザ）
    vim.g.mkdp_browser = ''

    -- キーマップの設定
    vim.keymap.set('n', '<C-s>', '<Plug>MarkdownPreview', { desc = 'Start Markdown Preview' })
    vim.keymap.set('n', '<M-s>', '<Plug>MarkdownPreviewStop', { desc = 'Stop Markdown Preview' })
    vim.keymap.set('n', '<C-m>', '<Plug>MarkdownPreviewToggle', { desc = 'Toggle Markdown Preview' })
  end,
}
