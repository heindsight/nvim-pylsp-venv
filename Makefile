.PHONY: clean coverage plugins rocks spec

rocks: .luarocks/lib/luarocks/rocks-5.1/vusted
rocks: .luarocks/lib/luarocks/rocks-5.1/luacov
rocks: .luarocks/lib/luarocks/rocks-5.1/luafilesystem


.luarocks/lib/luarocks/rocks-5.1/%:
	luarocks --tree .luarocks --lua-version=5.1 install $@


plugins: fixtures/plugins/nvim-lspconfig


fixtures/plugins/nvim-lspconfig:
	git clone https://github.com/neovim/nvim-lspconfig.git $@


spec: LUA_PATH:=$(LUA_PATH);fixtures/plugins/nvim-lspconfig/lua/?.lua
spec: rocks plugins
	vusted $(ARGS)


coverage: ARGS+=-c
coverage: spec
	@cat luacov.report.out


clean:
	@[ -z "$$(git status --short)" ] \
		&& git clean -xffd \
		|| printf "There are uncommitted changes. Not cleaning." >&2
