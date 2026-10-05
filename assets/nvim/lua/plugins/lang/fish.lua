vim.api.nvim_create_autocmd('FileType', {
  pattern = 'fish',
  callback = function()
    vim.bo.commentstring = '# %s'
  end,
})

return {}
