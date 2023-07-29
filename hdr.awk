function hdr_init() {
    hdr_version = mem_read_u8(0)
    hdr_high_memory_offset = mem_read_u16(4)
    hdr_initial_pc = mem_read_u16(6)
    hdr_dictionary_offset = mem_read_u16(8)
    hdr_object_table_offset = mem_read_u16(10)
    hdr_global_table_offset = mem_read_u16(12)
    hdr_static_memory_offset = mem_read_u16(14)
    hdr_abbrev_table_offset = mem_read_u16(24)
}

function hdr_print() {
    printf("Version:              %d\n", hdr_version)
    printf("High memory offset:   %04X\n", hdr_high_memory_offset)
    printf("Initial PC:           %04X\n", hdr_initial_pc)
    printf("Dictionary offset:    %04X\n", hdr_dictionary_offset)
    printf("Object table offset:  %04X\n", hdr_object_table_offset)
    printf("Global table offset:  %04X\n", hdr_global_table_offset)
    printf("Static memory offset: %04X\n", hdr_static_memory_offset)
    printf("Abbrev table offset:  %04X\n", hdr_abbrev_table_offset)
}

function restart_game() {
    for(i = 1; i <= 65536; i++) {
        mem[i] = mem_rest[i]
    }
    cpu_init()
    stack_init()
}
