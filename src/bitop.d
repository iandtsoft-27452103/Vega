import common;
import std.int128;
import core.bitop;

public int Square(BitBoard bb)
{
    BitBoard bb0 = bb >> 64;
    ulong ul = cast(ulong)bb0;
    if (ul > 0) 
    {
        return Square_NB - 1 - (bsf(ul) + 64);
    }
    ul = cast(ulong)bb;
    return Square_NB - 1 - (bsf(ul));
}

// created by Copilot and changed by me.
public int PopCount(BitBoard bb)
{
    ulong l  = cast(ulong)(bb & ulong.max);
    ulong h = cast(ulong)(bb >> 64);
    return _popcnt(l) + _popcnt(h);
}
