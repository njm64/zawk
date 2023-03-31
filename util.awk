function ord_init( i) {
    # Build a mapping table for converting input characters to integers.
    # The locale needs to be set to C for this to work correctly.
    # e.g. set LC_ALL=C in the environment
    for(i = 0; i < 256; i++) {
        ord[sprintf("%c", i)] = i
    }
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
