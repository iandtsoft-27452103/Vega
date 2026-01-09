import common;

// move format
// xxxxxxxx xxxxxxxx x1111111 : to
// xxxxxxxx xx111111 1xxxxxxx : from
// xxxxxxxx x1xxxxxx xxxxxxxx : is_promo
// xxxxx111 1xxxxxxx xxxxxxxx : pc
// x1111xxx xxxxxxxx xxxxxxxx : cap_pc

public int to(Move m)
{
    return m & 0x007f;
}

public int from(Move m)
{
    return (m >> 7) & 0x007f;
}

public int is_promo(Move m)
{
    return (m >> 14) & 1;
}

public int piece(Move m)
{
    return (m >> 15) & 0x000f;
}

public int cap_pc(Move m)
{
    return (m >> 19) & 0x000f;
}

public Move pack(int from, int to, int pc, int cap_pc, int flag_promo)
{
    return (cap_pc << 19) | (pc << 15) | (flag_promo << 14) | (from << 7) | to;
}

public Move null_move()
{
    return (1 << 23);
}