function ord_init(    i) {
    # Build a mapping table for converting input characters to integers.
    # The locale needs to be set to C for this to work correctly.
    # e.g. set LC_ALL=C in the environment
    for(i = 0; i < 256; i++) {
        ord[sprintf("%c", i)] = i
    }
}

function logand(a, b,    c, m) {
    for(m = 32768; m > 0; m = m / 2) {
        if(a >= m && b >= m) {
            c += m
        }
        a = a % m
        b = b % m
    }
    return c
}

function test_bit(a, n) {
    return int(a / (2 ^ n)) % 2
}

function to_s16(val) {
    return val > 32767 ? val - 65536 : val
}

function to_u16(val) {
    return val < 0 ? val + 65536 : val % 65536
}

function test_input() {
    FS=" "
    RS="\n"
    printf("getline")
    getline < "/dev/tty"
    printf("getline done: %d fields", NF)
}

BEGIN { 
    ord_init() 
}
