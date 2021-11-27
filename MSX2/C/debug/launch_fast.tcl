set throttle off
# SLTWRK = 0xfd09
# space per subslot = 4 * 2 = 8
# space per slot = 4 * 8 = 32
# offset for slot 1-0 = 32 = 0x20
# 0xfd29
debug set_watchpoint write_mem 0xfd29 {[debug read "memory" 0xfd29] == 0xed} {set throttle on}

