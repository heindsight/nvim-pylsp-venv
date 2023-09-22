-- vim: ft=lua

-- Rerun tests only if their modification time changed.
cache = true

ignore = {
  "122", -- Setting a read-only field of a global variable.
}

-- Global objects defined by the C code
read_globals = {
  "vim",
}

