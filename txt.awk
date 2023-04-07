
function txt_init() {
    cs0 = "abcdefghijklmnopqrstuvwxyz"
    cs1 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    cs2 = " \n0123456789.,!?_#'\"/\\-:()"
}

function abbrev_addr (table_index, i) {
    return mem_read_u16(hdr_abbrev_table_offset + table_index * 64 + i * 2) * 2
}

function txt_clear() {
    txt_buf = ""
}

function txt_decode(addr,    cs, w, i, abbrev, esc, esc_code) {
    cs = cs0
    abbrev = -1
    esc = -1

    while(i >= 0) {

        # Read 16 bits at a time into w. Each 16 bit word contains
        # three 5 bit characters. Keep track of the next character 
        # index in i. When i reaches zero, we need to read another 
        # 16 bit word. If the high bit of w is set, that means end 
        # of string, and we set i to a negative value to break out 
        # of the outer loop.

        if(i == 0) {
            w = mem_read_u16(addr)
            addr += 2
            i = 1
            c = int(w / 1024) % 32
        } else if(i == 1) {
            c = int(w / 32) % 32
            i = 2
        } else if(i == 2) {
            c = w % 32
            i = test_bit(w, 15) ? -1 : 0
        }

        if(esc == 0) {
            # First part of an escape code
            esc_code = c * 32
            esc++
        } else if(esc == 1) {
            # Second part of an escape code
            esc_code += c
            txt_buf = txt_buf chr[esc_code]
            esc = -1
        } else if(abbrev >= 0) {
            # Abbreviation
            txt_decode(abbrev_addr(abbrev, c))
            abbrev = -1
        } else if(c == 0) {
            txt_buf = txt_buf " "
        } else if(c == 1) {
            abbrev = 0
        } else if(c == 2) {
            abbrev = 1
        } else if(c == 3) {
            abbrev = 2
        } else if(c == 4) {
            cs = cs1
        } else if(c == 5) {
            cs = cs2
        } else if(c == 6 && cs == cs2) {
            cs = cs0
            esc = 0
        } else {
            txt_buf = txt_buf substr(cs, c - 5, 1)
            cs = cs0
        }
    }

    return addr
}

function txt_print(addr) {
    addr = txt_decode(addr)
    printf("%s", txt_buf)
    txt_buf = ""
    return addr
}

