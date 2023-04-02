
# Decode the next instruction into the following global variables:
# op_pc:   Integer  Starting address of this instruction in memory
# op_type: String   ("0OP", "1OP", "2OP", or "VAR")
# op_code: Integer  opcode
# op_argc: Integer  number of operands
# op_arg:  Array    operands values   
#

# Might rename op_code and op_arg to:
# - OP
# - A0,A1,A2,A3
# With -1 for args that are not populated

function op_decode(    b, t) {
    op_pc = cpu_pc
    b = fetch_u8()
    
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
        b = fetch_u8()
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
        return fetch_u16();
    } else if(type == 1) {
        return fetch_u8();
    } else if(type == 2) {
        return var_get(fetch_u8());
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

function op_unknown(    i) {
    printf("Unknown opcode: ")
    op_print()
    cpu_break = 1
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
    if(op == 0) {
        # true
        cpu_ret(1)
    } else if(op == 1) {
        # false
        cpu_ret(0)
    } else if(op == 2) {
        # print
        printf("TODO: print\n")
    } else if(op == 3) {
        # print-ret
        printf("TODO: print-ret\n")
    } else if(op == 8) {
        # ret-popped
        cpu_ret(stack_pop())
    } else if(op == 9) {
        # pop
        stack_pop()
    } else if(op == 10) {
        # quit
        cpu_break = 1
    } else if(op == 11) {
        # new-line
        printf("\n")
    } else if(op == 13) {
        # verify
        cpu_branch(1)
    } else {
        op_unknown()
    }
}

function op_dispatch_1op(   r, t) {
    if(op_code == 0) {
        # jz
    } else if(op_code == 1) {
        # get_sibling
        r = fetch_u8()
        t = obj_sibling(op_arg[0])
        cpu_branch(t >= 0)
        var_set(r, t)
    } else if(op_code == 2) {
        # get_child
        r = fetch_u8()
        t = obj_child(op_arg[0])
        cpu_branch(t >= 0)
        var_set(r, t)
    } else if(op_code == 3) {
        # get_parent
        r = fetch_u8()
        t = obj_parent(op_arg[0])
        var_set(r, t)
    } else if(op_code == 4) {
        # get_prop_len
        r = fetch_u8()
        t = obj_prop_len(op_arg[0])
        var_set(r, t)
    } else if(op_code == 5) {
        # inc
        var_set(op_arg[0], var_get_signed(op_arg[0]) + 1)
    } else if(op_code == 6) {
        # dec
        var_set(op_arg[0], var_get_signed(op_arg[0]) - 1)
    } else if(op_code == 7) {
        # print_addr
        printf("TODO: print_addr\n")
    } else if(op_code == 9) {
        # remove_obj
        obj_remove(op_arg[0])
    } else if(op_code == 10) {
        # print_obj
        printf("TODO: print_obj\n")
    } else if(op_code == 11) {
        # ret
        cpu_ret(op_arg[0])
    } else if(op_code == 12) {
        # jump
        cpu_pc += (to_s16(op_arg[0]) - 2)
    } else if(op_code == 13) {
        # print_paddr
        printf("TODO: print_paddr\n")
    } else if(op_code == 14) {
        # load
        r = fetch_u8()
        if(op_arg[0] == 0) {
            stack_push(stack_top()) # 6.3.4
        }
        t = var_get(op_arg[0])
        var_set(r, t)
    } else if(op_code == 15) {
        r = fetch_u8()
        printf("TODO: not\n")
        var_set(r, op_arg[0])
    } else {
        op_unknown()
    }
}

function op_dispatch_2op(   t) {
    if(op_code == 1) {
        # je
        op_je()
    } else if(op_code == 2) {
        # jl
        cpu_branch(to_s16(op_arg[0]) < to_s16(op_arg[1]))
    } else if(op_code == 3) {
        # jg
        cpu_branch(to_s16(op_arg[0]) > to_s16(op_arg[1]))
    } else if(op_code == 4) {
        # dec-chk
        t = var_get_signed(op_arg[0]) - 1
        var_set(op_arg[0], t)
        cpu_branch(val < to_s16(op_arg[1]))
    } else if(op_code == 5) {
        # inc-chk
        t = var_get_signed(op_arg[0]) + 1
        var_set(op_arg[0], t)
        cpu_branch(val < to_s16(op_arg[1]))
    } else if(op_code == 6) {
        # jin
        cpu_branch(obj_parent(arg[0]) == arg[1])
    } else if(op_code == 7) {
        # test
        printf("TODO: test\n")
    } else if(op_code == 8) {
        # or
        var_set(fetch_u8(), logand(op_arg[0], op_arg[1]))
    } else if(op_code == 9) {
        # and
        var_set(fetch_u8(), logior(op_arg[0], op_arg[1]))
    } else if(op_code == 10) {
        # test_attr
        cpu_branch(obj_attr(op_arg[0], op_arg[1]))
    } else if(op_code == 11) {
        # set_attr
        obj_set_attr(op_arg[0], op_arg[1], 1)
    } else if(op_code == 12) {
        # clear_attr
        obj_clear_attr(op_arg[0], op_arg[1], 0)
    } else if(op_code == 13) {
        # store
        if(arg[0] == 0) {
            stack_pop() # 6.3.4
        }
        var_set(op_arg[0], op_arg[1])
    } else if(op_code == 14) {
        # insert_obj
        obj_insert(op_arg[0], op_arg[1])
    } else if(op_code == 15) {
        # loadw
        r = fetch_u8()
        t = mem_read_u16(op_arg[0] + 2 * op_arg[1])
        var_set(r, t)
    } else if(op_code == 16) {
        # loadb
        r = fetch_u8()
        t = mem_read_u8(op_arg[0] + op_arg[1])
        var_set(r, t)
    } else if(op_code == 17) {
        # get_prop
        r = fetch_u8()
        t = obj_prop(op_arg[0], op_arg[1])
        var_set(r, t)
    } else if(op_code == 18) {
        # get_prop_addr
        r = fetch_u8()
        t = obj_prop_addr(op_arg[0], op_arg[1])
        var_set(r, t)
    } else if(op_code == 19) {
        # get_next_prop
        r = fetch_u8()
        if(op_arg[1] == 0) {
            t = obj_first_prop(op_arg[0])
        } else {
            t = obj_next_prop(op_arg[0], op_arg[1])
        }
        var_set(r, t)
    } else if(op_code == 20) { 
        # add
        var_set(fetch_u8(), op_arg[0] + op_arg[1])
    } else if(op_code == 21) { 
        # sub
        var_set(fetch_u8(), op_arg[0] - op_arg[1])
    } else if(op_code == 22) { 
        # mul
        var_set(fetch_u8(), op_arg[0] * op_arg[1])
    } else if(op_code == 23) { 
        # div
        var_set(fetch_u8(), int(op_arg[0] / op_arg[1]))
    } else if(op_code == 24) { 
        # mod
        var_set(fetch_u8(), int(op_arg[0] % op_arg[1]))
    } else {
        op_unknown()
    }
}

function op_dispatch_var(    tmp) {
    if(op_code == 0) {
        # call
        op_call()
    } else if(op_code == 1) {
        # storew
        mem_write_u16(op_arg[0] + 2 * op_arg[1], op_arg[2])
    } else if(op_code == 2) {
        # storeb
        mem_write_u8(op_arg[0] + op_arg[1], op_arg[2])
    } else if(op_code == 3) {
        # put_prop
        obj_put_prop(op_arg[0], op_arg[1], op_arg[2])
    } else if(op_code == 4) {
        # read
        printf("TODO: read")
    } else if(op_code == 5) {
        # print_char
        printf("%c", op_arg[0])
    } else if(op_code == 6) {
        # print_num
        printf("%d", to_s16(op_arg[0]))
    } else if(op_code == 7) {
        # random
        printf("TODO: random")
    } else if(op_code == 8) {
        # push
        stack_push(op_arg[0])
    } else if(op_code == 9) {
        # pull
        tmp = stack_pop()
        if(arg[0] == 0) {
            stack_pop() # 6.3.3
        }
        var_set(arg[0], tmp)
    } else {
        op_unknown()
    }
}

function op_call(   ret_var, routine, num_locals, i, local) {
    ret_var = fetch_u8()
    routine = op_arg[0]
    if(routine == 0) {
        var_set(ret_var, 0)
    } else {
        stack_push(ret_var)
        stack_push(cpu_pc)
        stack_push_frame()
        cpu_pc = routine * 2
        num_locals = fetch_u8()
        for(i = 0; i < num_locals; i++) {
            local = fetch_u16()
            stack_push(i + 1 < op_argc ? op_arg[i + 1] : local)
        }
    }
}

function op_je(    i) {
    for(i = 1; i < op_argc; i++) {
        if(op_args[0] == op_args[i]) {
            cpu_branch(1)
            return
        }
    }
    cpu_branch(0)
}

