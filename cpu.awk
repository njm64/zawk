
function cpu_init() {
    cpu_pc = hdr_initial_pc
    cpu_break = 0
}

function fetch_u8() {
    return mem_read_u8(cpu_pc++)
}

function fetch_u16(    n) {
    n = mem_read_u16(cpu_pc)
    cpu_pc += 2
    return n
}

function cpu_ret(val) {
    stack_pop_frame()
    cpu_pc = stack_pop()
    var_set(stack_pop(), val)
}

function cpu_branch(condition,    b, offset) {
    b = fetch_u8()

    # If bit 7 is clear, we invert the condition
    if(!test_bit(b, 7)) {
        condition = !condition
    }

    # Offset is normally an unsigned 6 bit number
    offset = b % 64

    # If bit 6 is set, fetch another byte. The offset becomes
    # a signed 14 bit number.
    if(test_bit(b, 6) == 0) {
        offset = (b % 64) * 256 + fetch_u8()
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

function cpu_call(routine, a1, a2, a3,   r, i, n, local) {
    r = fetch_u8()

    if(routine == 0) {
        var_set(ret_var, 0)
        return
    }

    stack_push(r)
    stack_push(cpu_pc)
    stack_push_frame()
    cpu_pc = routine * 2
    n = fetch_u8()

    for(i = 0; i < n; i++) {
        local = fetch_u16()
        if(i == 0 && a1 >= 0) {
            stack_push(a1)
        } else if(i == 1 && a2 >= 0) {
            stack_push(a2)
        } else if(i == 2 && a3 >= 0) {
            stack_push(a3)
        } else {
            stack_push(local)
        }
    }
}

