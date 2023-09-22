.PHONY: clean cobertura coverage coverage-report format lint spec

export PATH := $(PWD)/lua_modules/bin:$(PATH)

lint:
	luacheck lua/ spec/
	selene lua/ spec/
	stylua --check lua/ spec/


format:
	@stylua lua/ spec/


spec:
	@luarocks --lua-version=5.1 test


coverage-report:
	@luacov
	@cat luacov.report.out


coverage: spec coverage-report


cobertura:
	@luacov-cobertura -o coverage.xml


clean:
	@rm -f luacov.*.out
	@rm -f coverage.xml
	@[ -z "$$(git status --short)" ] \
		&& git clean -ffd \
		|| printf "There are uncommitted changes. Not cleaning.\n" >&2
