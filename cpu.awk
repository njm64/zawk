
function cpu_init() {
    cpu_pc = hdr_initial_pc
    cpu_stack_size = 0
    cpu_frame = 0
    cpu_break = 0
}

function cpu_fetch_u8() {
    return mem_read_u8(cpu_pc++)
}

function cpu_fetch_u16(    n) {
    n = mem_read_u16(cpu_pc)
    cpu_pc += 2
    return n
}

function cpu_stack_push(value) {
    cpu_stack[cpu_stack_size++] = value
}

function cpu_stack_pop() {
    return cpu_stack[--cpu_stack_size]
}

function cpu_stack_top() {
    return cpu_stack[cpu_stack_size - 1]
}

function cpu_get_local(i) {
    return cpu_stack[cpu_frame + i]
}

function cpu_set_local(i, val) {
    cpu_stack[cpu_frame + i] = val
}

function cpu_get_global(i) {
    return mem_read_u16(hdr_global_table_offset + i * 2)
}

function cpu_set_global(i, val) {
    mem_write_u16(hdr_global_table_offset + i * 2, val)
}

function cpu_get_var(i) {
    if(i == 0) {
        return cpu_stack_pop()
    } else if (i < 16) {
        return cpu_get_local(i - 1)
    } else if (i < 256) {
        return cpu_get_global(i - 16)
    } 
}

function cpu_set_var(i, val) {
    if(i == 0) {
        cpu_stack_push(to_u16(val))
    } else if(i < 16) {
        cpu_set_local(i - 1, to_u16(val))
    } else if(i < 256) {
        cpu_set_global(i - 16, to_u16(val))
    }
}

function cpu_ret(val) {
    cpu_stack_size = cpu_frame
    cpu_frame = cpu_stack_pop()
    cpu_pc = cpu_stack_pop()
    cpu_set_var(cpu_stack_pop(), val)
}

function cpu_branch(condition) {
    printf("branch %d\n", condition)
    # TODO
}


