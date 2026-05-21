-- 1. SET LEADER FIRST
vim.g.mapleader = " "

-- 2. Setup lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- 3. Plugins
require("lazy").setup({
  { "neovim/nvim-lspconfig" },
  
  -- Cyberdream Theme Setup
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup({
        transparent = true,
        italic_comments = true,
        hide_fillchars = true,
        borderless_pickers = true,
        terminal_colors = true,
      })
      vim.cmd("colorscheme cyberdream") -- Set the theme here
    end,
  },

  { "nvim-lualine/lualine.nvim" },
  
  -- Telescope (Fuzzy Finder)
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fz', builtin.current_buffer_fuzzy_find, {}) -- ADDED: Text search current file and jump
    end
  }, 
  
  { "nvim-tree/nvim-tree.lua", dependencies = "nvim-tree/nvim-web-devicons" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
  
  -- Completion Engine
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
        })
      })
    end
  },
})

-- 4. General Settings
vim.opt.number = true
vim.opt.relativenumber = true 
vim.opt.termguicolors = true

-- 5. Plugin Setup
require('lualine').setup({
  options = { theme = 'auto' }
})
require("nvim-tree").setup()
require("nvim-autopairs").setup{}

-- LSP Setup
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig.clangd.setup({ capabilities = capabilities })
lspconfig.pyright.setup({ capabilities = capabilities }) 

-- Treesitter
local status, ts = pcall(require, "nvim-treesitter.configs")
if status then
    ts.setup {
      ensure_installed = { "cpp", "lua", "vim", "vimdoc", "python" },
      highlight = { enable = true },
    }
end

-- 6. KEYBINDINGS
-- Sidebar & Documentation
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>') 
vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover)
vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help)

-- Space + r: SMART RUN
vim.keymap.set('n', '<leader>r', function()
    local file = vim.fn.expand("%")
    local ext = vim.fn.expand("%:e")

    if ext == "py" then
        vim.cmd("!python3 " .. vim.fn.shellescape(file))
    elseif ext == "cpp" then
        vim.cmd("!clang++ " .. vim.fn.shellescape(file) .. " -o out && ./out")
    else
        print("No runner for ." .. ext)
    end
end, { desc = "Run script" })

-- Quick exit from Insert Mode
vim.keymap.set('i', 'jk', '<Esc>', { desc = "Exit insert mode" }) -- FIXED: Cleaned up trailing text
