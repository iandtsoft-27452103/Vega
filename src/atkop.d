import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.math;
import std.container.dlist;
import common;
import core.bitop;
import hash;
import bitop;
import move;
import board;

public BitBoard IsPinnedOnKing(BoardTree bt, int sq, int idirec, int color)
{
    BitBoard bb_attacks;
    BitBoard bb_occupied = bt.BB_Occupied[Color.Black] | bt.BB_Occupied[Color.White];
    switch (abs(idirec))
    {
    case Direction.Direc_File_U2d:
        bb_attacks = ABB_File_Attacks[sq][bb_occupied & ABB_File_Mask_Ex[sq]];
        if ((bb_attacks & ABB_Mask[bt.SQ_King[color]]) > BitBoard(0L))
            return bb_attacks & (bt.BB_Piece[color ^ 1][Piece.Rook] | bt.BB_Piece[color ^ 1][Piece.Dragon] | bt.BB_Piece[color ^ 1][Piece.Lance]);
        break;
    case Direction.Direc_Rank_L2r:
        bb_attacks = ABB_Rank_Attacks[sq][bb_occupied & ABB_Rank_Mask_Ex[sq]];
        if ((bb_attacks & ABB_Mask[bt.SQ_King[color]]) > BitBoard(0L))
            return bb_attacks & (bt.BB_Piece[color ^ 1][Piece.Rook] | bt.BB_Piece[color ^ 1][Piece.Dragon]);
        break;
    case Direction.Direc_Diag1_U2d:
        bb_attacks = ABB_Diag1_Attacks[sq][bb_occupied & ABB_Diag1_Mask_Ex[sq]];
        if ((bb_attacks & ABB_Mask[bt.SQ_King[color]]) > BitBoard(0L))
            return bb_attacks & (bt.BB_Piece[color ^ 1][Piece.Bishop] | bt.BB_Piece[color ^ 1][Piece.Horse]);
        break;
    case Direction.Direc_Diag2_U2d:
        bb_attacks = ABB_Diag2_Attacks[sq][bb_occupied & ABB_Diag2_Mask_Ex[sq]];
        if ((bb_attacks & ABB_Mask[bt.SQ_King[color]]) > BitBoard(0L))
            return bb_attacks & (bt.BB_Piece[color ^ 1][Piece.Bishop] | bt.BB_Piece[color ^ 1][Piece.Horse]);
        break;
    default:
        break;
    }
    return BitBoard(0L);
}

public bool IsMatePawnDrop(BoardTree bt, int sq_drop, int color)
{
    if (color == Color.White)
    {
        if ((sq_drop - 9) >= 0 && bt.Board[sq_drop - 9] != -Piece.King)
        {
            return false;
        }
    }
    else
    {
        if ((sq_drop + 9) < Square_NB && bt.Board[sq_drop + 9] != Piece.King)
        {
            return false;
        }
    }
    BitBoard bb_sum = bt.BB_Piece[color][Piece.Knight] & ABB_Piece_Attacks[color ^ 1][Piece.Knight][sq_drop];
    bb_sum |= bt.BB_Piece[color][Piece.Silver] & ABB_Piece_Attacks[color ^ 1][Piece.Silver][sq_drop];
    BitBoard bb_total_gold = bt.BB_Piece[color][Piece.Gold] | bt.BB_Piece[color][Piece.Pro_Pawn] | bt.BB_Piece[color][Piece.Pro_Lance] | bt.BB_Piece[color][Piece.Pro_Knight] | bt.BB_Piece[color][Piece.Pro_Silver];
    bb_sum |= bb_total_gold & ABB_Piece_Attacks[color ^ 1][Piece.Gold][sq_drop];
    BitBoard bb_occupied = bt.BB_Occupied[Color.Black] | bt.BB_Occupied[Color.White];
    BitBoard bb_bh = bt.BB_Piece[color][Piece.Bishop] | bt.BB_Piece[color][Piece.Horse];
    bb_sum |= bb_bh & ABB_Diagonal_Attacks[sq_drop][ABB_Diagonal_Mask_Ex[sq_drop] & bb_occupied];
    BitBoard bb_rd = bt.BB_Piece[color][Piece.Rook] | bt.BB_Piece[color][Piece.Dragon];
    bb_sum |= bb_rd & ABB_Cross_Attacks[sq_drop][ABB_Cross_Mask_Ex[sq_drop] & bb_occupied];
    BitBoard bb_hd = bt.BB_Piece[color][Piece.Horse] | bt.BB_Piece[color][Piece.Dragon];
    bb_sum |= bb_hd & ABB_Piece_Attacks[color][Piece.King][sq_drop];
    while (bb_sum > 0)
    {
        int ifrom = Square(bb_sum);
        bb_sum ^= ABB_Mask[ifrom];
        if (IsDiscoverKing(bt, ifrom, sq_drop, color))
        {
            continue;
        }
        return false;
    }
    int iking = bt.SQ_King[color];
    bool bret = true;
    bt.BB_Occupied[color ^ 1] ^= ABB_Mask[sq_drop];
    BitBoard bb_move = ABB_Piece_Attacks[color][Piece.King][iking] & bt.BB_Empty & BB_Full;
    //writeln(bb_move);
    //writeln(ABB_Piece_Attacks[color][Piece.King][iking]);
    while (bb_move > 0)
    {
        int ito = Square(bb_move);
        if (IsAttacked(bt, ito, color) == BitBoard(0L))
        {
            bret = false;
            //writeln("unagi");
            break;
        }
        bb_move ^= ABB_Mask[ito];
    }
    bt.BB_Occupied[color ^ 1] ^= ABB_Mask[sq_drop];
    //writeln("kabayaki");
    //writeln(bret);
    return bret;
}

public BitBoard AttacksToPiece(BoardTree bt, int sq, int color)
{
    BitBoard bb_occupied = bt.BB_Occupied[Color.Black] | bt.BB_Occupied[Color.White];
    BitBoard bb_ret = bt.BB_Piece[color][Piece.Pawn] & ABB_Piece_Attacks[color ^ 1][Piece.Pawn][sq];
    bb_ret |= bt.BB_Piece[color][Piece.Knight] & ABB_Piece_Attacks[color ^ 1][Piece.Knight][sq];
    bb_ret |= bt.BB_Piece[color][Piece.Silver] & ABB_Piece_Attacks[color ^ 1][Piece.Silver][sq];
    BitBoard bb_total_gold = bt.BB_Piece[color][Piece.Gold] | bt.BB_Piece[color][Piece.Pro_Pawn] | bt.BB_Piece[color][Piece.Pro_Lance] | bt.BB_Piece[color][Piece.Pro_Knight] | bt.BB_Piece[color][Piece.Pro_Silver];
    bb_ret |= bb_total_gold & ABB_Piece_Attacks[color ^ 1][Piece.Gold][sq];
    BitBoard bb_hdk = bt.BB_Piece[color][Piece.Horse] | bt.BB_Piece[color][Piece.Dragon] | bt.BB_Piece[color][Piece.King];
    bb_ret |= bb_hdk & ABB_Piece_Attacks[color ^ 1][Piece.King][sq];
    BitBoard bb_bh = bt.BB_Piece[color][Piece.Bishop] | bt.BB_Piece[color][Piece.Horse];
    bb_ret |= bb_bh & ABB_Diagonal_Attacks[sq][ABB_Diagonal_Mask_Ex[sq] & bb_occupied];
    bb_ret |= bb_bh & ABB_Diagonal_Attacks[sq][ABB_Diagonal_Mask_Ex[sq] & bb_occupied];
    BitBoard bb_rd = bt.BB_Piece[color][Piece.Rook] | bt.BB_Piece[color][Piece.Dragon];
    bb_ret |= bb_rd & ABB_Cross_Attacks[sq][ABB_Cross_Mask_Ex[sq] & bb_occupied];
    BitBoard bb_lance_attacks = ABB_Lance_Attacks[color ^ 1][sq][ABB_Lance_Mask_Ex[color ^ 1][sq] & bb_occupied];
    bb_ret |= bt.BB_Piece[color][Piece.Lance] & bb_lance_attacks;
    return bb_ret;
}

public BitBoard IsAttacked(BoardTree bt, int sq, int color)
{
    BitBoard bb_ret = BitBoard(0L);
    BitBoard bb_occupied = bt.BB_Occupied[Color.Black] | bt.BB_Occupied[Color.White];
    if ((sq + Delta_Table[color]) >= 0 && (sq + Delta_Table[color]) < Square_NB)
    {
        if (bt.Board[sq + Delta_Table[color]] == (Sign_Table[color] * Piece.Pawn))
        {
            bb_ret = ABB_Mask[sq + Delta_Table[color]];
        }
    }
    bb_ret |= bt.BB_Piece[color ^ 1][Piece.Knight] & ABB_Piece_Attacks[color][Piece.Knight][sq];
    bb_ret |= bt.BB_Piece[color ^ 1][Piece.Silver] & ABB_Piece_Attacks[color][Piece.Silver][sq];
    BitBoard bb_total_gold = bt.BB_Piece[color ^ 1][Piece.Gold] | bt.BB_Piece[color ^ 1][Piece.Pro_Pawn] | bt.BB_Piece[color ^ 1][Piece.Pro_Lance] | bt.BB_Piece[color ^ 1][Piece.Pro_Knight] | bt.BB_Piece[color ^ 1][Piece.Pro_Silver];
    bb_ret |= bb_total_gold & ABB_Piece_Attacks[color][Piece.Gold][sq];
    BitBoard bb_hdk = bt.BB_Piece[color ^ 1][Piece.Horse] | bt.BB_Piece[color ^ 1][Piece.Dragon] | bt.BB_Piece[color ^ 1][Piece.King];
    bb_ret |= bb_hdk & ABB_Piece_Attacks[color][Piece.King][sq];
    BitBoard bb_bh = bt.BB_Piece[color ^ 1][Piece.Bishop] | bt.BB_Piece[color ^ 1][Piece.Horse];
    bb_ret |= bb_bh & ABB_Diagonal_Attacks[sq][ABB_Diagonal_Mask_Ex[sq] & bb_occupied];
    BitBoard bb_rd = bt.BB_Piece[color ^ 1][Piece.Rook] | bt.BB_Piece[color ^ 1][Piece.Dragon];
    bb_ret |= bb_rd & ABB_Cross_Attacks[sq][ABB_Cross_Mask_Ex[sq] & bb_occupied];
    BitBoard bb_lance_attacks = ABB_Lance_Attacks[color][sq][ABB_Lance_Mask_Ex[color][sq] & bb_occupied];
    bb_ret |= bt.BB_Piece[color ^ 1][Piece.Lance] & bb_lance_attacks;
    return bb_ret;
}

public BitBoard IsAttackedByLongPieces(BoardTree bt, int sq, int color)
{
    BitBoard bb_ret = BitBoard(0L);
    BitBoard bb_occupied = bt.BB_Occupied[Color.Black] | bt.BB_Occupied[Color.White];
    BitBoard bb_bh = bt.BB_Piece[color ^ 1][Piece.Bishop] | bt.BB_Piece[color ^ 1][Piece.Horse];
    bb_ret |= bb_bh & ABB_Diagonal_Attacks[sq][ABB_Diagonal_Mask_Ex[sq] & bb_occupied];
    BitBoard bb_rd = bt.BB_Piece[color ^ 1][Piece.Rook] | bt.BB_Piece[color ^ 1][Piece.Dragon];
    bb_ret |= bb_rd & ABB_Cross_Attacks[sq][ABB_Cross_Mask_Ex[sq] & bb_occupied];
    BitBoard bb_lance_attacks = ABB_Lance_Attacks[color][sq][ABB_Lance_Mask_Ex[color][sq] & bb_occupied];
    bb_ret |= bt.BB_Piece[color ^ 1][Piece.Lance] & bb_lance_attacks;
    return bb_ret;
}

public BitBoard AttacksToLongPiece(BoardTree bt, int sq, int color)
{
    BitBoard bb_ret = BitBoard(0L);
    BitBoard bb_occupied = bt.BB_Occupied[Color.Black] | bt.BB_Occupied[Color.White];
    BitBoard bb_bh = bt.BB_Piece[color][Piece.Bishop] | bt.BB_Piece[color][Piece.Horse];
    bb_ret = bb_bh & ABB_Diagonal_Attacks[sq][ABB_Diagonal_Mask_Ex[sq] & bb_occupied];
    BitBoard bb_rd = bt.BB_Piece[color][Piece.Rook] | bt.BB_Piece[color][Piece.Dragon];
    bb_ret |= bb_rd & ABB_Cross_Attacks[sq][ABB_Cross_Mask_Ex[sq] & bb_occupied];
    BitBoard bb_lance_attacks = ABB_Lance_Attacks[color ^ 1][sq][ABB_Lance_Mask_Ex[color ^ 1][sq] & bb_occupied];
    bb_ret |= bt.BB_Piece[color][Piece.Lance] & bb_lance_attacks;
    return bb_ret;
}

public bool IsDiscoverKing(BoardTree bt, int ifrom, int ito, int color)
{
    int idirec = Adirec[bt.SQ_King[color]][ifrom];
    if (idirec != Direction.Direc_Misc && idirec != Adirec[bt.SQ_King[color]][ito] && IsPinnedOnKing(bt, ifrom, idirec, color) != BitBoard(0L))
    {
        return true;
    }
    return false;
}

public bool IsDiscoverKing2(BoardTree bt, int ifrom, int ito, int color, int ipiece)
{
    int idirec = Adirec[bt.SQ_King[color]][ifrom];
    bt.BB_Piece[color][ipiece] ^= ABB_Mask[ifrom];
    bt.BB_Occupied[color] ^= ABB_Mask[ifrom];
    if (idirec != Direction.Direc_Misc && idirec != Adirec[bt.SQ_King[color]][ito] && IsPinnedOnKing(bt, ifrom, idirec, color) != BitBoard(0L))
    {
        bt.BB_Piece[color][ipiece] ^= ABB_Mask[ifrom];
        bt.BB_Occupied[color] ^= ABB_Mask[ifrom];
        return true;
    }
    bt.BB_Piece[color][ipiece] ^= ABB_Mask[ifrom];
    bt.BB_Occupied[color] ^= ABB_Mask[ifrom];
    return false;
}
