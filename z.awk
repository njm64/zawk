

END {
    hdr_init()
    hdr_print()
    cpu_init()

    while(!cpu_break) {
        op_decode()
        op_dispatch()
    }
}

