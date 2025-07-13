globals = {
    "turtle",
    "term", 
    "os",
    "read",
    "tonumber",
    "print",
    "io"
}

ignore = {
    "212",  -- Unused argument
    "213",  -- Unused loop variable
}

std = "lua54"

files["spec/"] = {
    globals = {
        "describe",
        "it", 
        "before_each",
        "after_each",
        "setup",
        "teardown",
        "assert",
        "spy",
        "stub",
        "mock"
    }
}