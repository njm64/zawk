
function mem_init() {
    for(i = 1; i <= 65536; i++) {
        mem_rest[i] = mem[i]
    }
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

function mem_restore() {
    for(i = 1; i <= 65536; i++) {
        mem[i] = mem_rest[i]
    }
}
