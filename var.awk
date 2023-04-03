
function var_get(i,    val) {
    if(i == 0) {
        val = stack_pop()
    } else if (i < 16) {
        val = stack[stack_frame + i - 1]
    } else if (i < 256) {
        val = mem_read_u16(hdr_global_table_offset + (i - 16) * 2)
    } 
    if(debug) {
        printf("Read var %d: %d\n", i, val)
    }
    return val
}

function var_get_signed(i) {
    return to_s16(var_get(i))
}

function var_set(i, val) {
    if(debug) {
        printf("Setting var %d to %d\n", i, val)
    }
    val = to_u16(val)
    if(i == 0) {
        stack_push(val)
    } else if(i < 16) {
        stack[stack_frame + i - 1] = val
    } else if(i < 256) {
        mem_write_u16(hdr_global_table_offset + (i - 16) * 2, val)
    }
}

