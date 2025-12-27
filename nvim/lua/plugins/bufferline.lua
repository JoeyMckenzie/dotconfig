return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        name_formatter = function(buf)
          return vim.fn.fnamemodify(buf.path, ":.")
        end,
      },
    },
  },
}
