
function tok_init(    i, n, entry_len) {
    cpu_pc = hdr_dictionary_offset
    tok_read_separators()
    tok_read_dictionary()
    tok_word_length = 6 # This varies by version
}

function tok_read_separators(   i, n, c) {
    n = fetch_u8()
    for(i = 0; i < n; i++) {
        c = chr[fetch_u8()]
        tok_separators[c] = 1
    }
    # Space is not technically a separator character, but we can treat
    # it like one, as long as we don't include it in the list of tokens
    # that are returned from read.
    tok_separators[" "] = 1
}

function tok_read_dictionary(   i, n, wsize) {
    wsize = fetch_u8()
    n = fetch_u16()
    for(i = 0; i < n; i++) {
        txt_decode(cpu_pc)
        tok_dict[txt_buf] = cpu_pc
        txt_clear()
        cpu_pc += wsize
    }
}

# Split the given string and store it in the globals tok_array/tok_count
# Separators are returned as tokens, and spaces are too (we need them
# to calculate offsets correctly)
function tok_split(s,   i, c, prev, prev_split) {
    prev_split = 1
    tok_count = 0
    for(i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        # Split points are before/after spaces & separator characters
        if(i > 0 && (c in tok_separators || prev in tok_separators)) {
           tok_array[tok_count++] = substr(s, prev_split, i - prev_split)
           prev_split = i
        }
        prev = c
    }
    tok_array[tok_count++] = substr(s, prev_split)
}

function tok_read_line() {
    FS=RS="\n"
    if(!getline < "/dev/tty") {
        cpu_break = 1
    }
    return $0
}

function tok_read(text_buf, parse_buf,    line, max_chars, max_tokens, i, tok, t, offset) {

    max_chars = mem_read_u8(text_buf) - 1
    max_tokens = mem_read_u8(parse_buf)

    # Read a line, convert to lower case, truncate if necessary,
    # then write into text_buf.
  
    line = tok_read_line()
    line = tolower(line)
    line = substr(line, 1, max_chars)
    mem_write_string(text_buf, line)

    # Split into tokens
 
    tok_split(line)

    # For each non-space token, write the address of the token in the 
    # dictionary, the length of the token in bytes, and the offset into 
    # the text_buf.

    for(i = 0; i < tok_count && n < max_tokens; i++) {
        tok = tok_array[i]
        if(tok != " ") {
            mem_write_u16(parse_buf + 2 + t * 4, tok_dict[substr(tok, 1, 6)]) 
            mem_write_u8(parse_buf + 4 + t * 4, length(tok))
            mem_write_u8(parse_buf + 5 + t * 4, offset + 1)
            t++
        }
        offset += length(tok)
    }
 
    # Write the total number of non-space tokens
 
    mem_write_u8(parse_buf + 1, t)
}

