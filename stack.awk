
function stack_init() {
    stack_size = 0
    stack_frame = 0
}

function stack_push(value) {
    stack[stack_size++] = value
}

function stack_pop() {
    return stack[--stack_size]
}

function stack_top() {
    return stack[stack_size - 1]
}

function stack_pop_frame() {
    stack_size = stack_frame
    stack_frame = stack_pop()
}

function stack_push_frame() {
    stack_push(stack_frame)
    stack_frame = stack_size
}
