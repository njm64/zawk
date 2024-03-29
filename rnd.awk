
function rnd_set_seed(n) {
    rnd_seed = n
    rnd_next = 0
}
    
function rnd_get(n) {
    if(rnd_seed) {
        # Predictable
        return 1 + ((rnd_next++ % rnd_seed) % n)
    } else {
        # Random
        return int(rand() * n) + 1
    }
}

