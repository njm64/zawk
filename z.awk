

END {
    hdr_init()
    hdr_print()
    cpu_init()

    for(i = 0; i < 4; i++) {
        op_decode()
        op_dispatch()
    }
}

