return {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
        local config = {
            cmd = { vim.fn.stdpath("data") .. "/mason/bin/jdtls" },
            root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
        }

        -- Autocmd to start jdtls when opening a Java file
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = function()
                require("jdtls").start_or_attach(config)
            end,
        })
    end,
}
