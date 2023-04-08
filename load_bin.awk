# Include this file to load binary data directly, without piping it through
# od. This approach works with awk and gawk, but not with mawk. The problem
# with mawk is that it buffers stdin/stdout by default, and if we disable 
# buffering with the -Winteractive option, it breaks on newlines, and 
# ignores RS.

# Setup the FS split after every character (this is implementation
# specific), and the RS to never split. Some implementations will
# still start a new record when they encounter a nul character.
BEGIN {
    FS=""
    RS="$a"
}

# Read the next binary chunk.
# Some versions of awk will terminate records on nul characters, 
# so add an extra nul. We may end up with an extra nul at the end of 
# the file, but this doesn't matter.
function load_chunk(    i) {
    for(i = 1; i <= NF; i++) {
        mem[mem_size++] = ord[$i]
    }
    mem[mem_size++] = 0 
}

{ load_chunk() }

