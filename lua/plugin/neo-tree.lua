-- *NOTES: Default minimal setup
-- return {
--   "nvim-neo-tree/neo-tree.nvim",
--   branch = "v2.x",
--   requires = {
--     "nvim-lua/plenary.nvim",
--     "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
--     "MunifTanjim/nui.nvim",
--   }
-- }
return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    -- {
    --   "<leader>fe",
    --   function()
    --     require("neo-tree.command").execute({ toggle = true, dir = require("lazyvim.util").get_root() })
    --   end,
    --   desc = "Explorer NeoTree (root dir)",
    -- },
    {
      "<leader>e",
      -- "<leader>fE",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
      end,
      desc = "Explorer NeoTree (cwd)",
    },
    -- { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (root dir)", remap = true },
    -- { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },

  },
  deactivate = function()
    vim.cmd([[Neotree close]])
  end,
  init = function()
    vim.g.neo_tree_remove_legacy_commands = 1
    if vim.fn.argc() == 1 then
      local stat = vim.loop.fs_stat(vim.fn.argv(0))
      if stat and stat.type == "directory" then
        require("neo-tree")
      end
    end
  end,
  opts = {
    filesystem = {
      bind_to_cwd = false,
      follow_current_file = true,
      -- filtered_items = {
      --   visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
      --   hide_dotfiles = false,
      --   hide_gitignored = false,
      -- },
    },
    window = {
      mappings = {
        ["<space>"] = "none",
      },
    },
    default_component_configs = {
      indent = {
        with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
    },
    event_handlers = {
      { event = "file_opened",
        handler = function(file_path)
          --auto close
          require("neo-tree").close_all()
        end
      },
    },
  }
}
