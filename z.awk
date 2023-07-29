

END {
#    debug = 1
    txt_init()
    hdr_init()
    tok_init()
    cpu_init()
    stack_init()

    if (mem[0] == 3) {
        while(!cpu_break) {
            op_decode()
            op_dispatch()
        }
    } else {
        printf ("ZAWK Z-Machine/Infocom Interactive fiction interpreter\n")
        printf ("Unsupported z-machine file version %d.\n",mem[0])
    }

}

