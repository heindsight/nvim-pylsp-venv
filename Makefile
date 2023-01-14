.PHONY: rocks plugins spec clean

rocks: .luarocks/bin/vusted


plugins: fixtures/plugins/nvim-lspconfig


.luarocks/bin/vusted:
	luarocks --tree .luarocks --lua-version=5.1 install vusted


fixtures/plugins/nvim-lspconfig:
	git clone https://github.com/neovim/nvim-lspconfig.git $@


spec: rocks plugins
	eval $$(luarocks --tree .luarocks --lua-version=5.1 path) \
		&& LUA_PATH="$${LUA_PATH};fixtures/nvim-lspconfig/lua/?.lua" \
		&& vusted


clean:
	@[ -z "$$(git status --short)" ] \
		&& git clean -xffd \
		|| echo "There are uncommitted changes. Not cleaning."
