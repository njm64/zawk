
function cpu_init() {
    cpu_pc = hdr_initial_pc
    cpu_stack_size = 0
    cpu_frame = 0
    cpu_break = 0
}

function cpu_fetch_u8( n) {
    n = mem_read_u8(cpu_pc)
    cpu_pc++
    return n
}

function cpu_fetch_u16( n) {
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

function cpu_ret(val) {
    cpu_stack_size = cpu_frame
    cpu_frame = cpu_stack_pop()
    cpu_pc = cpu_stack_pop()
    # var_write(cpu_stack_pop(), val)
}

