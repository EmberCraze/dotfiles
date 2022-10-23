-- Requires
local lspkind = require('lspkind')

local cmp_tabnine_status_ok, tabnine = pcall(require, 'cmp_tabnine.config')
if not cmp_tabnine_status_ok then
  return
end

local cmp_status_ok, cmp = pcall(require, 'cmp')
if not cmp_status_ok then
  return
end

local snip_status_ok, luasnip = pcall(require, 'luasnip')
if not snip_status_ok then
  return
end

require('luasnip/loaders/from_vscode').lazy_load()

-- Utils
local types = require('cmp.types')

local check_backspace = function()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s')
end

local deprioritize_snippet = function(entry1, entry2)
  if entry1:get_kind() == types.lsp.CompletionItemKind.Snippet then
    return false
  end
  if entry2:get_kind() == types.lsp.CompletionItemKind.Snippet then
    return true
  end
end

lspkind.init({
  symbol_map = {
    Text = '',
    Method = 'ƒ',
    Function = 'ﬦ',
    Constructor = '',
    Variable = '',
    Class = '',
    Interface = 'ﰮ',
    Module = '',
    Property = '',
    Unit = '',
    Value = '',
    Enum = '了',
    Keyword = '',
    Snippet = '﬌',
    Color = '',
    File = '',
    Folder = '',
    EnumMember = '',
    Constant = '',
    Struct = '',
  },
})
-- Setup
local source_mapping = {
  npm = NvimConfig.icons.terminal .. '[NPM]',
  cmp_tabnine = NvimConfig.icons.light,
  nvim_lsp = NvimConfig.icons.paragraph .. '[LSP]',
  buffer = NvimConfig.icons.buffer .. '[BUF]',
  nvim_lua = NvimConfig.icons.bomb,
  luasnip = NvimConfig.icons.snippet .. '[SNP]',
  calc = NvimConfig.icons.calculator,
  path = NvimConfig.icons.folderOpen2,
  treesitter = NvimConfig.icons.tree,
  zsh = NvimConfig.icons.terminal .. '[ZSH]',
}

local buffer_option = {
  -- Complete from all visible buffers (splits)
  get_bufnrs = function()
    local bufs = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      bufs[vim.api.nvim_win_get_buf(win)] = true
    end
    return vim.tbl_keys(bufs)
  end,
}

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  -- You must set mapping if you want.
  mapping = {
    ['<C-j>'] = cmp.mapping.select_next_item({
      behavior = cmp.SelectBehavior.Insert,
    }),
    ['<C-k>'] = cmp.mapping.select_prev_item({
      behavior = cmp.SelectBehavior.Insert,
    }),
    ['<Down>'] = cmp.mapping.select_next_item({
      behavior = cmp.SelectBehavior.Select,
    }),
    ['<Up>'] = cmp.mapping.select_prev_item({
      behavior = cmp.SelectBehavior.Select,
    }),
    ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-2), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(2), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = NvimConfig.plugins.completion.select_first_on_enter,
    }),
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expandable() then
        luasnip.expand()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif check_backspace() then
        fallback()
      else
        fallback()
      end
    end, {
      'i',
      's',
    }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {
      'i',
      's',
    }),
  },

  formatting = {
    format = function(entry, vim_item)
      vim_item.kind = lspkind.symbolic(vim_item.kind, { with_text = true })

      -- set a name for each source
      local menu = source_mapping[entry.source.name]
      local maxwidth = 60

      if entry.source.name == 'cmp_tabnine' then
        if
          entry.completion_item.data ~= nil
          and entry.completion_item.data.detail ~= nil
        then
          menu = menu .. entry.completion_item.data.detail
        else
          menu = menu .. 'TBN'
        end
      end

      vim_item.menu = menu
      if #vim_item.abbr > maxwidth then
        vim_item.abbr = vim_item.abbr:sub(1, maxwidth) .. '...'
      end

      return vim_item
    end,
  },

  -- You should specify your *installed* sources.
  sources = {
    { name = 'nvim_lsp', priority = 9 },
    { name = 'nvim_lsp_signature_help', priority = 9 },
    { name = 'npm', priority = 9 },
    { name = 'cmp_tabnine', priority = 8, max_num_results = 3 },
    {
      name = 'buffer',
      priority = 7,
      keyword_length = 5,
      option = buffer_option,
      max_item_count = 8,
    },
    { name = 'luasnip', priority = 7, max_item_count = 8 },
    { name = 'nvim_lua', priority = 5 },
    { name = 'path', priority = 4 },
    { name = 'calc', priority = 3 },
  },

  sorting = {
    comparators = {
      deprioritize_snippet,
      cmp.config.compare.exact,
      cmp.config.compare.locality,
      cmp.config.compare.recently_used,
      cmp.config.compare.score,
      cmp.config.compare.offset,
      cmp.config.compare.sort_text,
      cmp.config.compare.order,
    },
  },

  confirm_opts = {
    behavior = cmp.ConfirmBehavior.Replace,
    select = false,
  },

  window = {
    completion = cmp.config.window.bordered({
      winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
      border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
    }),
    documentation = cmp.config.window.bordered({
      winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
      border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
    }),
  },

  experimental = {
    native_menu = false,
    ghost_text = true,
  },
})

-- ╭──────────────────────────────────────────────────────────╮
-- │ Cmdline                                                  │
-- ╰──────────────────────────────────────────────────────────╯

-- `/` cmdline setup.
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' },
  },
})
-- `:` cmdline setup.
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline' },
  }),
})

-- ╭──────────────────────────────────────────────────────────╮
-- │ tabnine                                                  │
-- ╰──────────────────────────────────────────────────────────╯

tabnine:setup({
  max_lines = 1000,
  max_num_results = 3,
  sort = true,
  show_prediction_strength = true,
  run_on_every_keystroke = true,
  snipper_placeholder = '..',
  ignored_file_types = {},
})