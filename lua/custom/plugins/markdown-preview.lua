-- Markdown preview, opens a webbrowser on localhost to render and preview the current markdown
-- document if the preview is started.
-- can be started
-- :MarkdownPreview
--
-- and stopped with:
-- :MarkdownpreviewStop
return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  ft = { 'markdown' },
  build = function()
    require('lazy').load { plugins = { 'markdown-preview.nvim' } }
    vim.fn['mkdp#util#install']()
  end,
}
