return {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
        local config = {
            -- Keep Eclipse metadata (.project, .classpath, .settings/, .factorypath)
            -- in jdtls's own workspace instead of every project module.
            cmd = {
                vim.fn.stdpath("data") .. "/mason/bin/jdtls",
                "--jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false",
            },
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
