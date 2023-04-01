
# Decode the next instruction into the following global variables:
# op_pc:   Integer  Starting address of this instruction in memory
# op_type: String   ("0OP", "1OP", "2OP", or "VAR")
# op_code: Integer  opcode
# op_argc: Integer  number of operands
# op_arg:  Array    operands values   
function op_decode(    b, t) {
    op_pc = cpu_pc
    b = cpu_fetch_u8()
    
    if(b == 190 && hdr_version == 5) {
        # Extended instruction (v5)
    } else if(!test_bit(b, 7)) {
        # Long instruction (2OP)
        op_type = "2OP"
        op_code = b % 32
        op_argc = 2
        op_arg[0] = op_decode_arg(test_bit(b, 6) + 1)
        op_arg[1] = op_decode_arg(test_bit(b, 5) + 1)
    } else if(test_bit(b, 6)) {
        # Variable instruction (2OP or VAR arity)
        op_type = test_bit(b, 5) ? "VAR" : "2OP"
        op_code = b % 32
        op_argc = 0
        b = cpu_fetch_u8()
        if((t = int(b / 64)) != 3) {
            op_arg[op_argc++] = op_decode_arg(t)
            if((t = int(b / 16) % 4) != 3) {
                op_arg[op_argc++] = op_decode_arg(t)
                if((t = int(b / 4) % 4) != 3) {
                    op_arg[op_argc++] = op_decode_arg(t)
                    if((t = int(b % 4)) != 3) {
                        op_arg[op_argc++] = op_decode_arg(t)
                    }
                }
            }
        }
    } else {
        # Short instruction (0OP or 1OP)
        op_code = b % 16 
        t = (b / 16) % 4
        if(t == 3) {
            op_type = "0OP"
            op_argc = 0
        } else {
            op_type = "1OP"
            op_argc = 1
            op_arg[0] = op_decode_arg(t)
        }
    }
}

function op_decode_arg(type) {
    if(type == 0) {
        return cpu_fetch_u16();
    } else if(type == 1) {
        return cpu_fetch_u8();
    } else if(type == 2) {
        return cpu_get_var(cpu_fetch_u8());
    } else {
        return 0;
    }
}

function op_dispatch() {
    op_print()
    if(op_type == "0OP") {
        op_dispatch_0op()
    } else if(op_type == "1OP") {
        op_dispatch_1op() 
    } else if(op_type == "2OP") {
        op_dispatch_2op()
    } else if(op_type == "VAR") {
        op_dispatch_var()
    }
}

function op_unknown(arity,    i) {
    printf("Unknown opcode: ")
    op_print()
}

function op_print(    i) {
    printf("%04X: %s %d (", op_pc, op_type, op_code)
    for(i = 0; i < op_argc; i++) {
        if(i > 0) {
            printf(" ")
        }
        printf("%s", op_arg[i])
    }
    printf(")\n")
}

function op_dispatch_0op() {
    op_unknown()
}

function op_dispatch_1op() {
    op_unknown()
}

function op_dispatch_2op() {
    if(op_code == 20) {
    } else {
        op_unknown()
    }
}

function op_dispatch_var() {
    if(op_code == 0) { # call
        op_call()
    } else if(op_code == 2) { # storeb
        mem_write_u8(op_arg[0] + op_arg[1], op_arg[2])
    } else {
        op_unknown()
    }
}

function op_call(   ret_var, routine, num_locals, i, local) {
    ret_var = cpu_fetch_u8()
    routine = op_arg[0]
    if(routine == 0) {
        var_set(ret_var, 0)
    } else {
        cpu_stack_push(ret_var)
        cpu_stack_push(cpu_pc)
        cpu_stack_push(cpu_frame)
        cpu_frame = cpu_stack_size
        cpu_pc = routine * 2
        num_locals = cpu_fetch_u8()
        for(i = 0; i < num_locals; i++) {
            local = cpu_fetch_u16()
            cpu_stack_push(i + 1 < op_argc ? op_arg[i + 1] : local)
        }
    }
}

