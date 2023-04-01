
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
    val = to_u16(val)
    if(i == 0) {
        cpu_stack_push(val)
    } else if(i < 16) {
        cpu_set_local(i - 1, val)
    } else if(i < 256) {
        cpu_set_global(i - 16, val)
    }
}

function cpu_ret(val) {
    cpu_stack_size = cpu_frame
    cpu_frame = cpu_stack_pop()
    cpu_pc = cpu_stack_pop()
    cpu_set_var(cpu_stack_pop(), val)
}

function cpu_branch(condition,    b, offset) {
    b = cpu_fetch_u8()

    # If bit 7 is clear, we invert the condition
    if(!test_bit(b, 7)) {
        condition = !condition
    }

    # Offset is normally an unsigned 6 bit number
    offset = b % 64

    # If bit 6 is set, fetch another byte. The offset becomes
    # a signed 14 bit number.
    if(test_bit(b, 6) == 0) {
        offset = (b % 64) * 256 + cpu_fetch_u8()
        if(offset >= 8192) {
            offset -= 16384
        }
    }

    if(condition) {
        if(offset == 0) {
            cpu_ret(0)
        } else if(offset == 1) {
            cpu_ret(1)
        } else {
            cpu_pc = cpu_pc + offset - 2
        }
    }
}


