function obj_property_default (property) {
    return mem_read_u16(hdr_object_table_offset + 2 * (property - 1))
}

function obj_address(obj) {
    return hdr_object_table_offset + 62 + (obj - 1) * 9
}

function obj_attr_address(obj, attr) {
    return obj_address(obj) + int(attr / 8)
}

function obj_attr(obj, attr) {
    return test_bit(mem_read_u8(obj_attr_address(obj, attr)), 7 - (attr % 8))
}

function obj_set_attr(obj, attr,    b, addr, bit) {
    addr = obj_attr_address(obj, attr)
    bit = 7 - attr % 8
    b = mem_read_u8(addr)
    if(!test_bit(b, bit)) {
        mem_write_u8(b + (2 ^ bit))
    } 
}

function obj_clear_attr(obj, attr,    b, addr, bit) {
    addr = obj_attr_address(obj, attr)
    bit = 7 - attr % 8
    b = mem_read_u8(addr)
    if(test_bit(b, bit)) {
        mem_write_u8(b - (2 ^ bit))
    } 
}

function obj_parent(obj) {
    return mem_read_u8(obj_address(obj) + 4)
}

function obj_set_parent(obj, parent) {
    mem_write_u8(obj_address(obj) + 4, parent)
}

function obj_sibling(obj) {
    return mem_read_u8(obj_address(obj) + 5)
}

function obj_set_sibling(obj, sibling) {
    mem_write_u8(obj_address(obj) + 5, parent)
}

function obj_child(obj) {
    return mem_read_u8(obj_address(obj) + 6)
}

function obj_set_child(obj, child) {
    mem_write_u8(obj_address(obj) + 6, parent)
}

function obj_prev_sibling(obj,  p, prev) {
    p = obj_parent(obj)
    if(p == 0) {
        return 0
    }

    for(p = obj_child(p); p; p = obj_sibling(p)) {
        if(p == obj) {
            return prev
        }
        prev = p
    }

    return 0
}

function obj_name_addr(obj) {
    return mem_read_u16(obj_address(obj) + 8)
}

function obj_name_byte_len(obj) {
    return mem_read_u8(obj_name_addr(obj) - 1) * 2
}

function obj_properties_addr(obj) {
    return obj_name_addr(obj) + obj_name_byte_len(obj)
}

function obj_property_list(obj) {
    printf("TODO: obj_property_list\n")
}

function obj_first_prop(obj) {
    printf("TODO: obj_first_prop\n")
}

function obj_next_prop(obj, prop) {
    printf("TODO: obj_next_prop\n")
}

function obj_prop_addr(obj, prop) {
    printf("TODO: obj_prop_addr\n")
}

function obj_prop_len(prop_addr) {
    printf("TODO: obj_prop_len\n")
}

function obj_prop(obj, prop) {
    printf("TODO: obj_prop\n")
}

function obj_set_prop(obj, prop, val) {
    printf("TODO: obj_set_prop\n")
}

function obj_remove(obj) {
    if(obj_parent(obj)) {
        if(obj_prev_sibling(obj)) {
            obj_set_sibling(obj_prev_sibling(obj), obj_sibling(obj))
        } else {
            obj_set_child(obj_parent(obj), obj_sibling(obj))
        }
        obj_set_sibling(obj, 0)
        obj_set_parent(obj, 0)
    }
}

function obj_insert(obj, dst) {
    obj_remove(obj)
    obj_set_sibling(obj, obj_child(dst))
    obj_set_child(dst, obj)
    obj_set_parent(obj, dst)
}

