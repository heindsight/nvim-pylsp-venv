.PHONY: clean coverage format lint spec test_setup

LUA_PATH:=$(LUA_PATH);fixtures/plugins/nvim-lspconfig/lua/?.lua


test_setup:
	scripts/test_setup.sh


lint:
	luacheck lua/ spec/
	selene lua/ spec/
	stylua --check lua/ spec/

spec:
	vusted $(ARGS)


format:
	stylua lua/ spec/

coverage: ARGS+=-c
coverage: spec
	@luacov-cobertura -o coverage.xml
	@rm luacov.stats.out
	@cat luacov.report.out


clean:
	@[ -z "$$(git status --short)" ] \
		&& git clean -ffd \
		|| printf "There are uncommitted changes. Not cleaning.\n" >&2
