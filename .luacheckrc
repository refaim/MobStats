std = "lua51"
max_line_length = false

ignore = {
    "1",       -- globals (setfenv pattern makes global analysis meaningless)
    "212/self", -- unused self in LuaUnit tests and constructors
}

exclude_files = {
    "types/",
}
