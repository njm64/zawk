# Include this file to load binary data formatted as decimal with od,
# with the following options:
#     od -v -t u1 <input.z3> 

{
    for(i = 2; i <= NF; i++) {
        mem[mem_size++] = $i+0
    }
}
