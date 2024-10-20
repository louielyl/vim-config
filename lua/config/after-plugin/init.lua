-- print("after plugins")

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
        if desc then
            desc = "LSP: " .. desc
        end

        vim.keymap.set("n", keys, func, {
            buffer = bufnr,
            desc = desc,
        })
    end

    local telescope = require("telescope.builtin")
    nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

    -- nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap("gd", telescope.lsp_definitions, "[G]oto [D]efinition")
    nmap("gr", function()
        telescope.lsp_references({ include_declaration = false })
    end, "[G]oto [R]eferences")
    -- nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap("gI", telescope.lsp_implementations, "[G]oto [I]mplementation")
    nmap("<leader>ds", telescope.lsp_document_symbols, "[D]ocument [S]ymbols")
    nmap("<leader>ws", telescope.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

    -- See `:help K` for why this keymap
    nmap("K", vim.lsp.buf.hover, "Hover Documentation")
    -- nmap('<C-K>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
    nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
    nmap("<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "[W]orkspace [L]ist Folders")

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
        vim.lsp.buf.format()
    end, {
        desc = "Format current buffer with LSP",
    })
    nmap("<leader>f", vim.lsp.buf.format, "LSP [F]ormat")

    if client.server_capabilities.documentSymbolProvider then
        require("nvim-navic").attach(client, bufnr)
    end
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
    lua_ls = {
        Lua = {
            workspace = {
                checkThirdParty = false,
            },
            telemetry = {
                enable = false,
            },
        },
    },
}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local lspconfig = require("lspconfig")

-- Setup mason so it can manage external tooling
mason.setup()

-- Setup mason_lspconfig so it install all servers from Mason(?)
mason_lspconfig.setup({
    ensure_installed = vim.tbl_keys(servers),
})

-- Setup handlers using mason_lspconfig together with lspconfig
mason_lspconfig.setup_handlers({
    function(server_name)
        lspconfig[server_name].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
        })
    end,
})

-- nvim-cmp setup
local cmp = require("cmp")
local luasnip = require("luasnip")

luasnip.config.setup({})
require("luasnip.loaders.from_vscode").lazy_load()

vim.opt.completeopt = { "menu", "menuone", "noselect" }

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete({}),
        ["<CR>"] = cmp.mapping.confirm({
            select = true,
        }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item({ count = 2 })
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item({ count = 2 })
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
    },
})

-- treesitter
vim.treesitter.language.register("markdown", "mdx")

-- Plugin menus

-- Lazygit
vim.keymap.set("n", "<leader>lzg", "<CMD>LazyGit<CR>", { desc = "[L]a[Z]y [G]it" })
vim.keymap.set("n", "<leader>lzc", "<CMD>LazyGitConfig<CR>", { desc = "[L]a[Z]y Git [C]onfig" })

-- Spectre setup
vim.keymap.set("n", "<leader>sr", '<CMD>lua require("spectre").open()<CR>', { desc = "[S]earch & [R]eplace" })

-- Diffview setup
vim.keymap.set("n", "<leader>do", "<CMD>DiffviewOpen origin/HEAD..HEAD<CR>", { desc = "[D]iffview [O]pen" })
vim.keymap.set("n", "<leader>dh", "<CMD>DiffviewFileHistory %<CR>", { desc = "[D]iffview [H]istory" })
vim.keymap.set("n", "<leader>dc", "<CMD>DiffviewClose<CR>", { desc = "[D]iffview [C]lose" })
vim.keymap.set("n", "<leader>dt", "<CMD>DiffviewToggleFiles<CR>", { desc = "[D]iffview [T]oggle Files" })
vim.keymap.set("n", "<leader>df", "<CMD>DiffviewFocusFiles<CR>", { desc = "[D]iffview [F]ocus Files" })
vim.keymap.set("n", "<leader>dr", "<CMD>DiffviewRefresh<CR>", { desc = "[D]iffview [R]efresh" })
vim.keymap.set("v", "<leader>dr", "<Esc><CMD>'<,'>DiffviewFileHistory --follow<CR>", { desc = "[D]iffview [R]ange" })

-- Lazy vim
vim.keymap.set("n", "<leader>lv", "<CMD>:Lazy<CR>", { desc = "[L]azy [V]im" })

-- Mason
vim.keymap.set("n", "<leader>pm", "<CMD>Mason<CR>", { desc = "[M]ason" })

-- Alpha
vim.keymap.set("n", "<leader>pa", "<CMD>Alpha<CR>", { desc = "[A]lpha" })

-- NOTES: Plugin setup

-- vim-smoothie setup
-- vim.g.smoothie_update_interval = ??
vim.g.smoothie_base_speed = 2000

-- which-key setup
local wk = require("which-key")
wk.add({
    { "<leader>b", group = "+[B]uffer" },
    { "<leader>C", group = "+[C]ustom" },
    { "<leader>c", group = "+[C]ode action" },
    { "<leader>d", group = "+[D]ocument/ [D]iffvew" },
    { "<leader>r", group = "+[R]ename " },
    { "<leader>w", group = "+[W]orkspace" },
    { "<leader>x", group = "+Trouble [X]" },
    { "<leader>p", group = "+[P]lugin" },
    { "<leader>s", group = "+[S]earch" },
}, { mode = "n" })
wk.add({
    { "<leader>K", group = "+[C]hange Case" },
}, { mode = "v" })
