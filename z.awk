

END {
#    debug = 1
    txt_init()
    hdr_init()
    cpu_init()
    stack_init()

    while(!cpu_break) {
        op_decode()
        op_dispatch()
    }


}

