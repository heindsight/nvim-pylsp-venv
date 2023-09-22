local MODREV, SPECREV = 'scm', '-1'

rockspec_format = '3.0'
package = "nvim-pylsp-venv"
version = MODREV .. SPECREV

source = {
    url = "git://github.com/heindsight/nvim-pylsp-venv.git"
}

description = {
    summary = "Virtual environment auto-discovery for pylsp in neovim",
    detailed = [[
      A neovim plugin to configure pylsp (via nvim-lspconfig) to use per-project virtual environments.
   ]],
    homepage = "https://github.com/heindsight/nvim-pylsp-venv.git",
    license = "BSD-2-Clause",
    labels = { 'neovim', 'plugin', 'lsp', 'python', 'pylsp' },
}

dependencies = {
    'lua == 5.1',
}

build = {
    type = "builtin",
    copy_directories = {
        'plugin',
    }
}

test_dependencies = {
    'luacheck',
    'luacov',
    'luacov-cobertura',
    'luafilesystem',
    'nvim-lspconfig',
    'vusted',
}

test = {
    type = "command",
    command = "vusted",
}
