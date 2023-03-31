END {
    hdr_init()
    hdr_print()
    cpu_init()

    cpu_stack_push(100)

    n = cpu_stack_pop()
    printf("Fetched %d\n", n)
}

