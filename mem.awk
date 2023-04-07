
function mem_init() {
    # Setup the FS split after every character (this is implementation
    # specific), and the RS to never split. Some implementations will
    # still start a new record when they encounter a nul character.
    FS=""
    RS="$a"
}

function mem_load_chunk(    i) {
    for(i = 1; i <= NF; i++) {
        mem[mem_size++] = ord[$i]
    }
    # Some versions of awk will terminate records on nul characters, 
    # so add an extra nul. We may end up with an extra nul at the end of 
    # the file, but this doesn't matter.
    mem[mem_size++] = 0 
}

function mem_read_u8(addr) {
    return mem[addr]
}

function mem_write_u8(addr, val) {
    mem[addr] = val
}

function mem_read_u16(addr) {
    return mem[addr] * 256 + mem[addr+1]
}

function mem_write_u16(addr, val) {
    mem[addr] = int(val / 256)
    mem[addr+1] = val % 256
}

function mem_write_string(addr, s,    i) {
    for(i = 0; i < length(s); i++) {
        mem_write_u8(addr + i + 1, ord[substr(s, i + 1, 1)])
    }
    mem_write_u8(addr + length(s) + 1, 0)
}

BEGIN { mem_init() }
{ mem_load_chunk() }

