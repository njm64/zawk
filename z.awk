

END {
#    debug = 1
    mem_init()
    txt_init()
    hdr_init()
    tok_init()
    cpu_init()
    stack_init()

    while(!cpu_break) {
        op_decode()
        op_dispatch()
    }


}

