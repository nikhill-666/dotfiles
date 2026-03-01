return {
    {
        "bjarneo/aether.nvim",
        branch = "v2",
        name = "aether",
        priority = 1000,
        opts = {
            transparent = false,
            colors = {
                -- Background colors
                bg = "#0D151D",
                bg_dark = "#0D151D",
                bg_highlight = "#71889e",

                -- Foreground colors
                -- fg: Object properties, builtin types, builtin variables, member access, default text
                fg = "#dbdbdb",
                -- fg_dark: Inactive elements, statusline, secondary text
                fg_dark = "#C0F6F9",
                -- comment: Line highlight, gutter elements, disabled states
                comment = "#71889e",

                -- Accent colors
                -- red: Errors, diagnostics, tags, deletions, breakpoints
                red = "#7BABC5",
                -- orange: Constants, numbers, current line number, git modifications
                orange = "#b9d4e3",
                -- yellow: Types, classes, constructors, warnings, numbers, booleans
                yellow = "#95C8D4",
                -- green: Comments, strings, success states, git additions
                green = "#A3D7E4",
                -- cyan: Parameters, regex, preprocessor, hints, properties
                cyan = "#84AEBA",
                -- blue: Functions, keywords, directories, links, info diagnostics
                blue = "#93b1c2",
                -- purple: Storage keywords, special keywords, identifiers, namespaces
                purple = "#a2b7c3",
                -- magenta: Function declarations, exception handling, tags
                magenta = "#d9e2e8",
            },
        },
        config = function(_, opts)
            require("aether").setup(opts)
            vim.cmd.colorscheme("aether")

            -- Enable hot reload
            require("aether.hotreload").setup()
        end,
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "aether",
        },
    },
}
