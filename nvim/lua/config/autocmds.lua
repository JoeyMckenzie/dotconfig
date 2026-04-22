-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- PHP file scaffolding: auto-fill namespace, class, strict types on new files
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
  pattern = "*.php",
  callback = function()
    -- Only scaffold if the buffer is empty
    local line_count = vim.api.nvim_buf_line_count(0)
    local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
    if line_count > 1 or first_line ~= "" then
      return
    end

    local filepath = vim.fn.expand("%:p")
    local dir = vim.fn.expand("%:p:h")
    local classname = vim.fn.expand("%:t:r")

    -- Walk up to find composer.json and read PSR-4 autoload mappings
    local namespace = nil
    local root = vim.fn.findfile("composer.json", dir .. ";")
    if root ~= "" then
      local root_dir = vim.fn.fnamemodify(root, ":p:h")
      local ok, content = pcall(vim.fn.readfile, root)
      if ok then
        local json = vim.json.decode(table.concat(content, "\n"))
        local autoload = (json.autoload and json.autoload["psr-4"]) or {}
        local autoload_dev = (json["autoload-dev"] and json["autoload-dev"]["psr-4"]) or {}

        -- Merge both autoload tables, preferring non-dev
        local mappings = {}
        for ns, path in pairs(autoload_dev) do
          mappings[ns] = path
        end
        for ns, path in pairs(autoload) do
          mappings[ns] = path
        end

        -- Find the best matching PSR-4 prefix
        local rel = filepath:sub(#root_dir + 2) -- relative path from project root
        local best_ns, best_len = nil, 0
        for ns, path in pairs(mappings) do
          -- Normalize: strip trailing slashes
          path = path:gsub("/+$", "")
          if rel:sub(1, #path) == path and #path > best_len then
            best_ns = ns
            best_len = #path
          end
        end

        if best_ns then
          -- Build namespace from PSR-4 prefix + remaining directory structure
          local remainder = rel:sub(best_len + 2) -- skip the mapped dir + separator
          local ns_suffix = vim.fn.fnamemodify(remainder, ":h")
          if ns_suffix == "." then
            namespace = best_ns:gsub("\\+$", "")
          else
            namespace = best_ns:gsub("\\+$", "") .. "\\" .. ns_suffix:gsub("/", "\\")
          end
        end
      end
    end

    local lines = { "<?php", "", "declare(strict_types=1);", "" }
    if namespace then
      table.insert(lines, "namespace " .. namespace .. ";")
      table.insert(lines, "")
    end
    table.insert(lines, "final readonly class " .. classname)
    table.insert(lines, "{")
    table.insert(lines, "}")

    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    -- Place cursor inside the class body
    vim.api.nvim_win_set_cursor(0, { #lines - 1, 0 })
  end,
})

-- Astro filetype detection
vim.filetype.add({
  extension = {
    astro = "astro",
  },
})
