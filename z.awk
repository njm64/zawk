

function z_main() {

    hdr_init()
    mem_init()

    if(hdr_version < 1 || hdr_version > 3) {
        printf ("ZAWK Z-Machine/Infocom Interactive fiction interpreter\n")
        printf ("Unsupported z-machine file version %d.\n", hdr_version)
        return
    }

    txt_init()
    tok_init()
    cpu_init()
    stack_init()

    while(!cpu_break) {
        op_decode()
        op_dispatch()
    }
}

END {
#    debug = 1
    z_main()
}

