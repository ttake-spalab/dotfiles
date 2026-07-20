vim.opt.number = true
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = ""
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = false
vim.opt.termguicolors = true
vim.opt.autoread = true

vim.g.mapleader = " "

-- プラグインマネージャ (lazy.nvim) の自動セットアップ
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- カラーテーマ (Iceberg)
  { "cocopon/iceberg.vim", lazy = false, priority = 1000, config = function() vim.cmd[[colorscheme iceberg]] end },

  -- ファイルアイコン表示の共通基盤
  { "nvim-tree/nvim-web-devicons", config = function() require("nvim-web-devicons").setup({ default = true }) end },

  -- 括弧や引用符の自動閉じ機能
  { "windwp/nvim-autopairs", event = "InsertEnter", config = function() require("nvim-autopairs").setup({}) end },

  -- Gitの差分表示および変更箇所へのナビゲーション機能
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        on_attach = function(bufnr)
          local gitsigns = require('gitsigns')
          local function map(mode, l, r) vim.keymap.set(mode, l, r, { buffer = bufnr }) end
          -- Gitの差分がある箇所へのジャンプと変更前のプレビュー
          map('n', ']c', function() if vim.wo.diff then vim.cmd.normal({']c', bang = true}) else gitsigns.nav_hunk('next') end end)
          map('n', '[c', function() if vim.wo.diff then vim.cmd.normal({'[c', bang = true}) else gitsigns.nav_hunk('prev') end end)
          map('n', '<leader>hp', gitsigns.preview_hunk)
        end
      })
    end
  },

  -- 差分表示を強力にするプラグイン（gitgraphのコミット詳細表示で連動）
  { "sindrets/diffview.nvim", cmd = { "DiffviewOpen", "DiffviewFileHistory" } },

  -- Git GraphをNeovim内に描画するプラグイン
  {
    "isakbm/gitgraph.nvim",
    dependencies = { "sindrets/diffview.nvim" },
    keys = {
      -- スペース + g + g でGitグラフを描画
      {
        "<leader>gg",
        function()
          require("gitgraph").draw({}, { all = true, max_count = 5000 })
        end,
        desc = "GitGraph Show",
      },
    },
    opts = {
      symbols = {
        merge_commit = "M",
        commit = "*",
      },
      format = {
        timestamp = "%Y-%m-%d %H:%M:%S",
        fields = { "hash", "timestamp", "author", "branch_name", "tag" },
      },
      hooks = {
        -- グラフ上でEnterを押すと、そのコミットの差分をDiffviewで開く設定
        on_select_commit = function(commit)
          vim.cmd("DiffviewOpen " .. commit.hash .. "^!")
        end,
      },
    },
  },

  -- ファイルエクスプローラ (Gitステータス表示付き)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = false,
        filesystem = {
          follow_current_file = { enabled = true },
           use_libuv_file_watcher = true,
           -- 隠しファイルやGit Ignore対象の表示設定
          filtered_items = {
            visible = true, -- フィルターされたアイテムを完全に非表示にせず薄く表示する
            show_hidden_count = false,
            hide_dotfiles = false, -- 隠しファイル（ドットファイル）を非表示にしない
            hide_gitignored = false, -- .gitignore対象のファイルを非表示にしない
          },
        },
      })
    end
  },

  -- ステータスラインの導入
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "iceberg",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = { "neo-tree" },
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            {
              "filename",
              path = 1,
              symbols = {
                modified = "●", -- 未保存時に表示されるアイコン
                readonly = "[-]", -- 読み取り専用時に表示されるアイコン
                unnamed = "[No Name]",
                newfile = "[New]",
              },
            },
          },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end
  },

  -- 各言語（Python, Shell, Markdownなど）の高度な構文解析と色付け
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "python", "bash", "markdown", "markdown_inline", "lua" },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      local p_configs, ts_configs = pcall(require, "nvim-treesitter.configs")
      if p_configs then
        ts_configs.setup(opts)
      else
        local p_ts, ts = pcall(require, "nvim-treesitter")
        if p_ts and ts.setup then ts.setup(opts) end
      end
    end
  },

  -- LSP・リンター・型チェッカーの設定管理 (Ruff / Ty)
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({ ensure_installed = { "ruff" } })
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- Neovim 0.11以降のネイティブ方式とそれ未満の互換処理
      if vim.lsp.config then
        vim.lsp.config("*", { capabilities = capabilities })
        vim.lsp.enable("ruff")
        vim.lsp.config("ty", {
          settings = {
            ty = {
              -- 必要に応じてty固有のLanguage Server設定をここに記述
              diagnosticMode = 'workspace',
              completions = {
                autoImport = true,
                completeFunctionParentheses = true,
              },
            },
          },
        })
        vim.lsp.enable("ty")
      else
        local lspconfig = require("lspconfig")
        lspconfig.ruff.setup({ capabilities = capabilities })
        lspconfig.ty.setup({
          capabilities = capabilities,
          settings = {
            ty = {
              -- 必要に応じてty固有のLanguage Server設定をここに記述
              diagnosticMode = 'workspace',
              completions = {
                autoImport = true,
                completeFunctionParentheses = true,
              },
            },
          },
        })
      end
    end
  },

  -- 自作スニペット
  { "ttake-spalab/snippets" },

  -- コード補完エンジンおよび外部スニペットの統合
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip",
      "ttake-spalab/snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local types = require("cmp.types")

      -- VS Code形式のスニペットファイルを読み込み
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),              -- ドキュメントウィンドウ（関数の説明など）を上下スクロール
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-a>"] = cmp.mapping.complete(),                   -- 強制的に補完ウィンドウを開く
          ["<C-e>"] = cmp.mapping.abort(),                      -- 補完をキャンセルして閉じる
          ["<CR>"] = cmp.mapping.confirm({ select = true }),    -- 選択中の候補を確定
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({ { name = 'nvim_lsp' }, { name = 'luasnip' } }, { { name = 'buffer' }, { name = 'path' } }),
        sorting = {
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            -- スニペット候補を最上位にソートする処理
            function(entry1, entry2)
              local kind1 = entry1:get_kind()
              local kind2 = entry2:get_kind()
              local lsp_kind = types.lsp.CompletionItemKind
              if kind1 == lsp_kind.Snippet and kind2 ~= lsp_kind.Snippet then
                return true
              elseif kind2 == lsp_kind.Snippet and kind1 ~= lsp_kind.Snippet then
                return false
              end
              return nil
            end,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
      })
    end
  },

  -- PEP8準拠インデントプラグイン
  { "Vimjas/vim-python-pep8-indent", ft = "python" },

  -- トグルできるターミナル
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-j>]], -- Ctrl + j でターミナルを開閉
        direction = "horizontal",      -- "float" (浮遊), "horizontal" (下部分割), "vertical" (右側分割)
        float_opts = {
          border = "curved",      -- 角丸の枠線
          winblend = 3,           -- 少し背景を透過させる
        },
      })
    end
  },

  -- snacks.nvim (画像プレビュー機能の有効化)
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      image = {
        enabled = true,
        doc = {
          inline = true, -- Markdownファイル等の中でインライン表示する
        },
      },
    },
  }
})

-- キーバインド設定 (スペース+c+a でLSPのコードアクション/クイックフィックスを実行)
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)

-- neo-tree.nvim設定
-- Space + e でファイルエクスプローラを開閉
vim.keymap.set('n', '<leader>e', ':Neotree toggle left<CR>', opts)
-- Space + b で開いているバッファを展開
vim.keymap.set('n', '<leader>b', ':Neotree toggle buffers left<CR>', opts)

-- 警告（Diagnostics）関連のキーバインド定義
-- 現在の行の警告詳細をポップアップ（フローティングウィンドウ）で表示
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
-- 前後の警告箇所へジャンプ
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

-- Pythonファイルのみ80, 120列に縦ライン（カラーカラム）を表示
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.colorcolumn = "79,119"
  end,
})
