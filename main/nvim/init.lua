local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end


vim.g.termguicolors=true

vim.opt.rtp:prepend(lazypath)

vim.wo.number = true

-- Example using a list of specs with the default options
vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

require("lazy").setup({
  -- "folke/which-key.nvim",
  -- { "folke/neoconf.nvim", cmd = "Neoconf" },
  -- "folke/neodev.nvim",
  -- Custom Parameters (with defaults)
  { "David-Kunz/gen.nvim" }, 
  { "nvim-lualine/lualine.nvim" },
  { "neoclide/coc.nvim", branch = "release" },
  { "nvim-treesitter/nvim-treesitter" },
  { "tpope/vim-fugitive" },
  { 'nvim-telescope/telescope.nvim', tag = '0.1.5', dependencies = { 'nvim-lua/plenary.nvim' } },
  { 'nvim-telescope/telescope-ui-select.nvim' },
  { 'embark-theme/vim', name = 'embark' },
  { 'nvimdev/dashboard-nvim', event = 'VimEnter', dependencies = { {'nvim-tree/nvim-web-devicons'}} }
})

require('lualine').setup  {
	options = {
    		theme = theme,
		component_separators = '',
  		--section_separators = { left = '', right = '' }, -- Commented out because gnome-terminal doesn't render them properly.
		section_separators = { left = '', right = '' }
	},
}

require('dashboard').setup {
    -- config
}

vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
	pattern = {"*.nim"}, 
	command = "set filetype=nim"
})

require('nvim-treesitter.configs').setup {
	ensure_installed = { "c", "yaml", "lua", "bash", "python", "nim" },
	auto_install = true,
  	highlight = {
    		enable = true,
	}
}

vim.opt.shiftwidth = 4
vim.cmd.colorscheme('embark')

require("telescope").load_extension("ui-select")
