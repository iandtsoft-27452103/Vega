import common;
import std.int128;
//import std.stdio;
//import core.int128;
import core.bitop;
import bitop;

// This file derives from Bonanza's rand.c and hash.c .
// PRNG based on Mersenne Twister ( M.Matsumoto and T.Nishimura, 1998 ).

public struct RandWorkT
{
    int count;
    uint[2] cnst;
    uint[RandN] vec;
}

public Rand[Square_NB][Piece_NB][Color_NB] PieceRand;
public RandWorkT rand_work;

public void IniRand(uint u)
{
    rand_work.count = RandN;
    rand_work.cnst[0] = 0;
    rand_work.cnst[1] = 0x9908b0dfU;
    for (int i = 0; i < RandN; i++)
    {
        u = (uint)(i + 1812433253U * (u ^ (u >> 30)));
        u &= Mask32;
        rand_work.vec[i] = u;
    }
}

public uint Rand32()
{
    uint u = 0;
    uint u0 = 0;
    uint u1 = 0;
    uint u2 = 0;
    int i = 0;
    if (rand_work.count == RandN)
    {
        rand_work.count = 0;

        for (i = 0; i < RandN - RandM; i++)
        {
            u = rand_work.vec[i] & MaskU;
            u |= rand_work.vec[i + 1] & MaskL;

            u0 = rand_work.vec[i + RandM];
            u1 = u >> 1;
            u2 = rand_work.cnst[u & 1];
        }

        for (; i < RandN - 1; i++)
        {
            u = rand_work.vec[i] & MaskU;
            u |= rand_work.vec[i + 1] & MaskL;

            u0 = rand_work.vec[i + RandM - RandN];
            u1 = u >> 1;
            u2 = rand_work.cnst[u & 1];

            rand_work.vec[i] = u0 ^ u1 ^ u2;
        }

        u = rand_work.vec[RandN - 1] & MaskU;
        u |= rand_work.vec[0] & MaskL;

        u0 = rand_work.vec[RandM - 1];
        u1 = u >> 1;
        u2 = rand_work.cnst[u & 1];

        rand_work.vec[RandN - 1] = u0 ^ u1 ^ u2;
    }
    u = rand_work.vec[rand_work.count++];
    u ^= (u >> 11);
    u ^= (u << 7) & 0x9d2c5680U;
    u ^= (u << 15) & 0xefc60000U;
    u ^= (u >> 18);
    return u;
}

public ulong Rand64()
{
    ulong h = Rand32();
    ulong l = Rand32();

    return l | (h << 32);
}


public void IniRandomTable()
{
    for (int c = 0; c < Color_NB; c++)
    {
        for (int pc = 0; pc < Piece_NB; pc++)
        {
            for (int sq = 0; sq < Square_NB; sq++)
            {
                PieceRand[c][pc][sq] = Rand64();
            }
        }
    }
}

public Rand HashFunc(BoardTree bt)
{
    Rand key = 0;
    for (int c = 0; c < Color_NB; c++)
    {
        for (int pc = 1; pc < Piece_NB; pc++)
        {
            BitBoard bb = bt.BB_Piece[c][pc];
            while (bb > 0)
            {
                int sq = Square(bb);
                bb ^= ABB_Mask[sq];
                key ^= PieceRand[c][pc][sq];
            }
        }
    }
    return key;
}
