import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.algorithm.searching;
import std.container.array;
import common;
import core.bitop;
//import hash;
import bitop;
import board;
import csa;
import move;
import board;
import atkop;
//import genmoves;
import std.math;

public Move MateIn1Ply(BoardTree bt, int color)
{
    int i, j, k, index, cnt_d, cnt_m, cnt_e, sq, sq_object, pos, myside_attacks_count, attacks_count, cnt_pos, cnt_pc, pc, idirec, flag_promo;
    BitBoard bb_myside_attacks, bb_enemy_attacks, bb;
    Move mate_move = 0;
    Move null_move = 0;
    int[] sq_can_check_by_drop = [0,0,0,0,0,0,0,0];
    int[] sq_can_check_by_move = [0,0,0,0,0,0,0,0];
    int[] pos_array = [0,0,0,0,0,0,0,0,0,0];
    int[] pc_array = [0,0,0,0,0,0,0,0,0,0];
    int[] sq_can_escape = [0,0,0,0,0,0,0,0];
    bool flag = false;
    uint hand = 0;
    cnt_d = cnt_m = cnt_e = 0;
    int opponent_color = color ^ 1;
    int sq_opponent_king = bt.SQ_King[opponent_color];
    BitBoard bb_can_escape = BB_Full & ~bt.BB_Occupied[opponent_color];
    hand = bt.Hand[color];
    BitBoard bb_opp_king_attacks = ABB_Piece_Attacks[opponent_color][Piece.King][sq_opponent_king];
    while (bb_opp_king_attacks > BitBoard(0L))
    {
        sq = Square(bb_opp_king_attacks);
        bb_opp_king_attacks ^= ABB_Mask[sq];
        bb_myside_attacks = AttacksToPiece(bt, sq, opponent_color);
        myside_attacks_count = PopCount(bb_myside_attacks);
        flag = false;
        if (myside_attacks_count >= 2 && bt.Board[sq] == Piece.Empty)
        {
            //If there are attacks from opponent pieces except king, opponents can capture the checker.
            flag = true;
        }
        if ((bb_can_escape & ABB_Mask[sq]) > BitBoard(0L))
        {
            // If there are attacks from your pieces, you maybe generate escape move.
            if (IsAttacked(bt, sq, opponent_color) == BitBoard(0L))
            {
                sq_can_escape[cnt_e++] = sq;
            }
        }
        if (bt.Board[sq] == Piece.Empty && flag == false)
        {
            sq_can_check_by_drop[cnt_d++] = sq;
        }
        bb_enemy_attacks = IsAttacked(bt, sq, color ^ 1);
        if (bt.Board[sq] != Piece.Empty && (bt.BB_Occupied[opponent_color] & ABB_Mask[sq]) > BitBoard(0L) && bb_enemy_attacks > BitBoard(0L))
        {
            sq_can_check_by_move[cnt_m++] = sq;
        }
        if (myside_attacks_count < 2 && bt.Board[sq] == Piece.Empty && bb_enemy_attacks > BitBoard(0L))
        {
            sq_can_check_by_move[cnt_m++] = sq;
        }
    }
    //writeln("JBL");
    //writeln(cnt_d);
    for (i = 0; i < cnt_d; i++)
    {
        sq = sq_can_check_by_drop[i];
        //writeln("sq_0");
        //writeln(sq);
        idirec = Adirec[sq][sq_opponent_king];
        auto pt = Piece_Table[opponent_color];
        //writeln("pt");
        //writeln(common.Piece_Table);
        bb = AttacksToPiece(bt, sq, opponent_color);
        cnt_pos = 0;
        cnt_pc = 0;
        while (bb > 0)
        {
            pos = Square(bb);
            bb ^= ABB_Mask[pos];
            pos_array[cnt_pos++] = pos;
            pc_array[cnt_pc++] = bt.Board[pos];
        }
        auto pcs = pt[idirec];
        if (hand > 0)
        {
            for (j = 0; j  < pcs.length; j++)
            {
                pc = pcs[j];
                //writeln("piece");
                //writeln(pc);
                if (pc > Piece.Rook)
                {
                    break;
                }
                if ((pc != Piece.Pawn) && (hand & Hand_Mask[pc]) > 0)
                {
                    if (cnt_e == 0)
                    {
                        mate_move = pack(Square_NB + pc - 1, sq, pc, 0, 0);
                        return mate_move;
                    }
                    int counter = 0;
                    bool mate_flag = true;
                    for (k = 0; k < cnt_e; k++)
                    {
                        sq_object = sq_can_escape[k];
                        //writeln("sq_object");
                        //writeln(sq_object);
                        if (sq == sq_object)
                        {
                            counter++;
                        }
                        //writeln("sq");
                        //writeln(sq);
                        //writeln("IsCanEscape");
                        //writeln(IsCanEscape(bt, color, sq, pc, sq_opponent_king, sq_object, false));
                        //writeln("IsCanCapture");
                        //writeln(IsCanCapture(bt, color, opponent_color, sq, true, -1, pc));
                        if (!IsCanEscape(bt, color, sq, pc, sq_opponent_king, sq_object, false) && !IsCanCapture(bt, color, opponent_color, sq, true, -1, pc))
                        {
                            counter++;
                        }
                        else
                        {
                            //writeln("saitama");
                            mate_flag = false;
                        }
                    }
                    if (counter == cnt_e && mate_flag)
                    {
                        mate_move = pack(Square_NB + pc - 1, sq, pc, 0, 0);
                        return mate_move;
                    }
                }
             }
             //writeln("ichinojo");
        }
    }
    for (i = 0; i < cnt_m; i++)
    {
        sq = sq_can_check_by_move[i];
        idirec = Adirec[sq][sq_opponent_king];
        auto pt = Piece_Table[opponent_color];
        bb = AttacksToPiece(bt, sq, color);
        attacks_count = PopCount(bb);
        if (attacks_count < 2 && bb > BitBoard(0L))
        {
            pos = Square(bb);
            BitBoard bb2 = AttacksToLongPiece(bt, pos, color);
            while (bb2 > BitBoard(0L))
            {
                int sq2 = Square(bb2);
                bb2 ^= ABB_Mask[sq2];
                int idirec2 = Adirec[sq2][sq_opponent_king];
                if (idirec == idirec2)
                {
                    if (cnt_e == 0)
                    {
                        if (!IsCanCapture(bt, color, opponent_color, sq, false, pos, abs(bt.Board[pos])))
                        {
                            mate_move = pack(pos, sq, abs(bt.Board[pos]), abs(bt.Board[sq]), 0);
                            return mate_move;
                        }
                    }
                    else if (cnt_e == 1)
                    {
                        int sq3 = sq_can_escape[0];
                        int idirec3 = Adirec[sq3][sq_opponent_king];
                        if (!IsCanCapture(bt, color, opponent_color, sq, false, pos, abs(bt.Board[pos])))
                        {
                            if (abs(idirec) == abs(idirec3))
                            {
                                switch (abs(idirec))
                                {
                                case Direction.Direc_File_U2d:
                                    if (abs(bt.Board[pos]) == Piece.Lance || abs(bt.Board[pos]) == Piece.Rook || abs(bt.Board[pos]) == Piece.Dragon)
                                    {
                                        mate_move = pack(pos, sq, abs(bt.Board[pos]), abs(bt.Board[sq]), 0);
                                        return mate_move;
                                    }
                                    break;
                                case Direction.Direc_Rank_L2r:
                                    if (abs(bt.Board[pos]) == Piece.Rook || abs(bt.Board[pos]) == Piece.Dragon)
                                    {
                                        mate_move = pack(pos, sq, abs(bt.Board[pos]), abs(bt.Board[sq]), 0);
                                        return mate_move;
                                    }
                                    break;
                                case Direction.Direc_Diag1_U2d:
                                case Direction.Direc_Diag2_U2d:
                                    if (abs(bt.Board[pos]) == Piece.Bishop || abs(bt.Board[pos]) == Piece.Horse)
                                    {
                                        mate_move = pack(pos, sq, abs(bt.Board[pos]), abs(bt.Board[sq]), 0);
                                        return mate_move;
                                    }
                                    break;
                                default:
                                    break;
                                }
                            }
                        }
                    }
                }
                else
                {
                    if (cnt_e == 0 && (ABB_Piece_Attacks[color][Piece.Gold][sq] & ABB_Piece_Attacks[opponent_color][Piece.King][sq_opponent_king]) > BitBoard(0L) && (ABB_Mask[sq] & BB_Color_Position[opponent_color]) > BitBoard(0L))
                    {
                        bb_myside_attacks = AttacksToPiece(bt, sq, opponent_color);
                        myside_attacks_count = PopCount(bb_myside_attacks);
                        int idirec3 = Adirec[pos][bt.SQ_King[color]];
                        bt.BB_Occupied[color] ^= ABB_Mask[pos];
                        bb = IsPinnedOnKing(bt, pos, idirec3, color);
                        bt.BB_Occupied[color] ^= ABB_Mask[pos];
                        if (myside_attacks_count < 2 && bb == BitBoard(0L))
                        {
                            mate_move = pack(pos, sq, abs(bt.Board[pos]), abs(bt.Board[sq]), 1);
                            return mate_move;
                        }
                    }
                }
            }
            continue;
        }
        cnt_pos = cnt_pc = 0;
        while (bb > BitBoard(0L))
        {
            pos = Square(bb);
            bb ^= ABB_Mask[pos];
            pos_array[cnt_pos++] = pos;
            pc_array[cnt_pc++] = bt.Board[pos];
        }
        auto pcs = pt[idirec];
        if (cnt_pos == 0)// This maybe not make sense.
        {
            continue;
        }
        index = 0;
        while (index < cnt_pos)
        {
            pos = pos_array[index];
            pc = abs(pc_array[index]);
            if (pc == Piece.King)
            {
                index++;
                continue;
            }
            idirec = Adirec[pos][sq_opponent_king];
            if (IsDiscoverKing2(bt, pos, sq, color, pc))
            {
                index++;
                continue;
            }
            if (pcs.canFind(pc))
            {
                if (LongPieces2.canFind(pc))
                {
                    if (cnt_e == 0)
                    {
                        if (LongPieces.canFind(pc) && !IsCanCapture(bt, color, opponent_color, sq, false, pos, pc))
                        {
                            if ((ABB_Mask[sq] & BB_Color_Position[opponent_color]) > BitBoard(0L))
                            {
                                flag_promo = 1;
                            }
                            else
                            {
                                flag_promo = 0;
                            }
                            mate_move = pack(pos, sq, pc, abs(bt.Board[sq]), flag_promo);
                            return mate_move;
                        }
                    }
                    flag = false;
                    for (j = 0; j < cnt_e; j++)
                    {
                        sq_object = sq_can_escape[j];
                        if (sq == sq_object)
                        {
                            continue;
                        }
                        if (!IsCanEscape(bt, color, sq, pc, sq_opponent_king, sq_object, false) && !IsCanCapture(bt, color, opponent_color, sq, false, pos, pc))
                        {
                            if ((ABB_Mask[pos] & BB_Color_Position[opponent_color]) > BitBoard(0L) || (ABB_Mask[sq] & BB_Color_Position[opponent_color]) > BitBoard(0L))
                            {
                                flag_promo = 1;
                            }
                            else
                            {
                                flag_promo = 0;
                            }
                            mate_move = pack(pos, sq, pc, abs(bt.Board[sq]), flag_promo);
                            flag = true;
                        }
                        else
                        {
                            flag = false;
                            mate_move = 0;
                            break;
                        }
                    }
                    if (flag && mate_move != 0)
                    {
                        return mate_move;
                    }
                }
                else if (pc == Piece.Dragon || pc == Piece.Horse)
                {
                    if (cnt_e == 0)
                    {
                        if (!IsCanCapture(bt, color, opponent_color, sq, false, pos, pc))
                        {
                            mate_move = pack(pos, sq, pc, abs(bt.Board[sq]), 0);
                            return mate_move;
                        }
                    }
                    flag = false;
                    for (j = 0; j < cnt_e; j++)
                    {
                        sq_object = sq_can_escape[j];
                        if (sq == sq_object)
                        {
                            continue;
                        }
                        if (!IsCanEscape(bt, color, sq, pc, sq_opponent_king, sq_object, false) && !IsCanCapture(bt, color, opponent_color, sq, false, pos, pc))
                        {
                            mate_move = pack(pos, sq, pc, abs(bt.Board[sq]), 0);
                            flag = true;
                        }
                        else
                        {
                            flag = false;
                            mate_move = 0;
                            break;
                        }
                    }
                    if (flag && mate_move != 0)
                    {
                        return mate_move;
                    }
                }
                else
                {
                    switch (pc)
                    {
                    case Piece.Gold:
                    case Piece.Pro_Pawn:
                    case Piece.Pro_Lance:
                    case Piece.Pro_Knight:
                    case Piece.Pro_Silver:
                    case Piece.Silver:
                        if (cnt_e == 0)
                        {
                            if (!IsCanCapture(bt, color, opponent_color, sq, false, pos, pc))
                            {
                                mate_move = pack(pos, sq, pc, abs(bt.Board[sq]), 0);
                                return mate_move;
                            }
                        }
                        flag = false;
                        for (j = 0; j < cnt_e; j++)
                        {
                            sq_object = sq_can_escape[j];
                            if (sq == sq_object)
                            {
                                continue;
                            }
                            if (!IsCanEscape(bt, color, sq, pc, sq_opponent_king, sq_object, false) && !IsCanCapture(bt, color, opponent_color, sq, false, pos, pc))
                            {
                                mate_move = pack(pos, sq, pc, abs(bt.Board[sq]), 0);
                            }
                            else
                            {
                                flag = false;
                                mate_move = 0;
                                break;
                            }
                        }
                        if (flag && mate_move != 0)
                        {
                            return mate_move;
                        }
                        break;
                    default:
                        break;
                    }
                }
                // If mate by lance or pawn move, it is not promoted. Strictry speaking lance or pawn
                // promote move is better than no promote move, but not judging promotion is a few faster.
            }
            if (pc > Piece.Rook)
            {
                index++;
                continue;
            }
            int pc_promote = pc + Promote;
            // knight promote move
            // Knight cannnot mate opponent king from neighbour 8 Square.
            if ((pcs.canFind(pc_promote) && pc == Piece.Knight && (BB_Rev_Color_Position[color] & ABB_Mask[sq]) > BitBoard(0L)))
            {
                if (cnt_e == 0)
                {
                    if (!IsCanCapture(bt, color, opponent_color, sq, false, pos, pc) && (ABB_Piece_Attacks[color][Piece.Gold][sq] & ABB_Mask[sq_opponent_king]) > BitBoard(0L))
                    {
                        mate_move = pack(pos, sq, pc, abs(bt.Board[sq]), 1);
                        return mate_move;
                    }
                }
                flag = false;
                for (j = 0; j < cnt_e; j++)
                {
                    sq_object = sq_can_escape[j];
                    if (sq == sq_object)
                    {
                        continue;
                    }
                    if (!IsCanEscape(bt, color, sq, pc, sq_opponent_king, sq_object, true) && !IsCanCapture(bt, color, opponent_color, sq, false, pos, pc))
                    {
                        flag = true;
                        mate_move = pack(pos, sq, pc, abs(bt.Board[sq]), 1);
                    }
                    else
                    {
                        flag = false;
                        mate_move = 0;
                        break;
                    }
                }
                if (flag && mate_move != 0)
                {
                    return mate_move;
                }
            }
            // lance promote move or pawn promote move
            if (pcs.canFind(pc_promote) && ShortPieces.canFind(pc) && (BB_Rev_Color_Position[color] & ABB_Mask[sq]) > BitBoard(0L))
            {
                if (cnt_e == 0)
                {
                    if (!IsCanCapture(bt, color, opponent_color, sq, false, pos, pc) && (ABB_Piece_Attacks[color][Piece.Gold][sq] & ABB_Mask[sq_opponent_king]) > BitBoard(0L))
                    {
                        mate_move = pack(pos, sq, pc, abs(bt.Board[sq]), 1);
                        return mate_move;
                    }
                }
                flag = false;
                for (j = 0; j < cnt_e; j++)
                {
                    sq_object = sq_can_escape[j];
                    if (sq == sq_object)
                    {
                        continue;
                    }
                    if (!IsCanEscape(bt, color, sq, pc, sq_opponent_king, sq_object, true) && !IsCanCapture(bt, color, opponent_color, sq, false, pos, pc))
                    {
                        flag = true;
                        mate_move = pack(pos, sq, pc, abs(bt.Board[sq]), 1);
                    }
                    else
                    {
                        flag = false;
                        mate_move = 0;
                        break;
                    }
                }
                if (flag && mate_move != 0)
                {
                    mate_move = pack(pos, sq, pc, abs(bt.Board[sq]), 1);
                    return mate_move;
                }
            }
            // silver promote move
            if (pc == Piece.Silver)
            {
                if (pcs.canFind(pc_promote) && (BB_Rev_Color_Position[color] & ABB_Mask[sq]) > BitBoard(0L) || (BB_Rev_Color_Position[color] & ABB_Mask[pos]) > BitBoard(0L))
                {
                    if (cnt_e == 0)
                    {
                        if (!IsCanCapture(bt, color, opponent_color, sq, false, pos, pc) && (ABB_Piece_Attacks[color][Piece.Gold][sq] & ABB_Mask[sq_opponent_king]) > BitBoard(0L))
                        {
                            mate_move = pack(pos, sq, pc, abs(bt.Board[sq]), 1);
                            return mate_move;
                        }
                    }
                    flag = false;
                    for (j = 0; j < cnt_e; j++)
                    {
                        sq_object = sq_can_escape[j];
                        if (sq == sq_object)
                        {
                            continue;
                        }
                        if (!IsCanEscape(bt, color, sq, pc, sq_opponent_king, sq_object, true) && !IsCanCapture(bt, color, opponent_color, sq, false, pos, pc))
                        {
                            mate_move = pack(pos, sq, pc, abs(bt.Board[sq]), 1);
                            flag = true;
                        }
                        else
                        {
                            flag = false;
                            mate_move = 0;
                            break;
                        }
                    }
                    if (flag && mate_move != 0)
                    {
                        return mate_move;
                    }
                }
            }
            if (pc < Piece.Bishop)
            {
                index++;
                continue;
            }
            // rook promote move or bishop promote move
            if (pcs.canFind(pc_promote) && LongPieces.canFind(pc) && (BB_Rev_Color_Position[color] & ABB_Mask[sq]) > BitBoard(0L) || (BB_Rev_Color_Position[color] & ABB_Mask[pos]) > BitBoard(0L))
            {
                if (cnt_e == 0)
                {
                    if (!IsCanCapture(bt, color, opponent_color, sq, false, pos, pc) && (ABB_Piece_Attacks[color][Piece.King][sq] & ABB_Mask[sq_opponent_king]) > BitBoard(0L))
                    {
                        if ((ABB_Mask[pos] & BB_Color_Position[opponent_color]) > 0 || (ABB_Mask[pos] & BB_Color_Position[opponent_color]) > 0)
                        {
                            flag_promo = 1;
                        }
                        else
                        {
                            flag_promo = 0;
                        }
                        mate_move = pack(pos, sq, pc, abs(bt.Board[sq]), flag_promo);
                        return mate_move;
                    }
                }
                flag = false;
                for (j = 0; j < cnt_e; j++)
                {
                    sq_object = sq_can_escape[j];
                    if (sq == sq_object)
                    {
                        continue;
                    }
                    if (!IsCanEscape(bt, color, sq, pc, sq_opponent_king, sq_object, true) && !IsCanCapture(bt, color, opponent_color, sq, false, pos, pc))
                    {
                        if ((ABB_Mask[pos] & BB_Color_Position[opponent_color]) > BitBoard(0L) || (ABB_Mask[sq] & BB_Color_Position[opponent_color]) > BitBoard(0L) )
                        {
                            flag_promo = 1;
                        }
                        else
                        {
                            flag_promo = 0;
                        }
                        mate_move = pack(pos, sq, pc, abs(bt.Board[sq]), flag_promo);
                        flag = true;
                    }
                    else
                    {
                        flag = false;
                        mate_move = 0;
                        break;
                    }
                }
                if (flag && mate_move != 0)
                {
                    return mate_move;
                }
            }
            index++;
        }
    }
    // You cannot mate opponnent king from neighbour 8 square.
    // You maybe mate opponnent move using knight.
    pc = Piece.Knight;
    BitBoard bb_occupied, bb_opponent_attacks_to_sq, bb_my_knight_attacks;
    bb_occupied = bt.BB_Occupied[Color.Black] | bt.BB_Occupied[Color.White];
    bb = ABB_Piece_Attacks[opponent_color][pc][sq_opponent_king] & ((~bb_occupied & BB_Full) | bt.BB_Occupied[opponent_color]);
    while (bb > BitBoard(0L))
    {
        sq = Square(bb);
        bb ^= ABB_Mask[sq];
        bb_opponent_attacks_to_sq = AttacksToPiece(bt, sq, opponent_color);
        if ((hand & Hand_Mask[pc]) > 0 && bt.Board[sq] == Piece.Empty && cnt_e == 0 && bb_opponent_attacks_to_sq == BitBoard(0L))
        {
            // drop knight
            mate_move = pack(Square_NB + pc - 1, sq, pc, 0, 0);
            return mate_move;
        }
        bb_my_knight_attacks = ABB_Piece_Attacks[opponent_color][pc][sq] & bt.BB_Piece[color][Piece.Knight];
        if (bb_my_knight_attacks > BitBoard(0L) && cnt_e == 0 && bb_opponent_attacks_to_sq == BitBoard(0L))
        {
            pos = Square(bb_my_knight_attacks);
            bb_my_knight_attacks ^= ABB_Mask[pos];
            if (IsDiscoverKing2(bt, pos, sq, color, pc))
            {
                continue;
            }
            mate_move = pack(pos, sq, pc, abs(bt.Board[sq]), 0);
        }
    }
    if (mate_move != 0)
        return mate_move;
    return null_move;
}
public bool IsCanEscape(BoardTree bt, int color, int sq_checker, int pc_checker, int sq_opponent_king, int sq_object, bool is_promo)
{
    BitBoard bb_occupied = bt.BB_Occupied[Color.Black] | bt.BB_Occupied[Color.White];
    bb_occupied ^= (ABB_Mask[sq_opponent_king] | ABB_Mask[sq_object]);
    BitBoard bb_attacks = BitBoard(0L);
    switch (pc_checker)
    {
    case Piece.Rook:
        bb_attacks = ABB_Cross_Attacks[sq_checker][ABB_Cross_Mask_Ex[sq_checker] & bb_occupied];
        break;
    case Piece.Dragon:
        bb_attacks = ABB_Cross_Attacks[sq_checker][ABB_Cross_Mask_Ex[sq_checker] & bb_occupied];
        bb_attacks |= ABB_Piece_Attacks[color][Piece.King][sq_checker];
        break;
    case Piece.Bishop:
        bb_attacks = ABB_Diagonal_Attacks[sq_checker][ABB_Diagonal_Mask_Ex[sq_checker] & bb_occupied];
        break;
    case Piece.Horse:
        bb_attacks = ABB_Diagonal_Attacks[sq_checker][ABB_Diagonal_Mask_Ex[sq_checker] & bb_occupied];
        bb_attacks |= ABB_Piece_Attacks[color][Piece.King][sq_checker];
        break;
    case Piece.Pawn:
    case Piece.Knight:
    case Piece.Silver:
        if (is_promo)
        {
            bb_attacks = ABB_Piece_Attacks[color][Piece.Gold][sq_checker];
        }
        else
        {
            bb_attacks = ABB_Piece_Attacks[color][pc_checker][sq_checker];
        }
        break;
    case Piece.Lance:
        if (is_promo)
        {
            bb_attacks = ABB_Piece_Attacks[color][Piece.Gold][sq_checker];
        }
        else
        {
            bb_attacks = ABB_Lance_Attacks[color][sq_checker][ABB_Lance_Mask_Ex[color][sq_checker] & bb_occupied];
        }
        break;
    default:
        bb_attacks = ABB_Piece_Attacks[color][pc_checker][sq_checker];
        break;
    }
    bb_attacks &= ABB_Mask[sq_object];
    if (bb_attacks > BitBoard(0L))
    {
        return false;
    }
    return true;
}
public bool IsCanCapture(BoardTree bt, int color, int opponent_color, int sq_object, bool is_drop, int ifrom, int ipiece)
{
    BitBoard bb, bb2, bb3;
    int idirec;
    BitBoard bb_myside_attacks = AttacksToPiece(bt, sq_object, color);
    int myside_attacks_count = PopCount(bb_myside_attacks);
    BitBoard bb_opp_attacks = AttacksToPiece(bt, sq_object, opponent_color);
    int opp_attacks_count = PopCount(bb_opp_attacks);
    if (opp_attacks_count > 1)
        return true;
    if ((opp_attacks_count == 1) && (myside_attacks_count == 0))
    {
        // There is only one attack from opponent_king to objective square, but there is no attack from my side.
        return true;
    }
    if (opp_attacks_count >= myside_attacks_count)
    {
        if ((opp_attacks_count == myside_attacks_count) && is_drop)
        {
            // There is only one attack from opponent_king to objective square and there is one  attack from my side, but this move is drop move.
            return false;
        }
        if (is_drop)
            return true;
        bt.BB_Occupied[color] ^= ABB_Mask[ifrom];
        bt.BB_Piece[color][ipiece] ^= ABB_Mask[ifrom];
        bb = IsAttacked(bt, bt.SQ_King[opponent_color], color);
        bb2 = IsAttacked(bt, bt.SQ_King[color], color);
        bb3 = BitBoard(0L);
        switch (ipiece)
        {
        case Piece.Pawn:
        case Piece.Lance:
        case Piece.Rook:
        case Piece.Dragon:
            idirec = Adirec[ifrom][sq_object];
            if (abs(idirec) == Direction.Direc_File_U2d)
            {
                bb3 = IsAttacked(bt, sq_object, color);
            }
            break;
        default:
            break;
        }
        bt.BB_Occupied[color] ^= ABB_Mask[ifrom];
        bt.BB_Piece[color][ipiece] ^= ABB_Mask[ifrom];
        if (bb2 > BitBoard(0L))
            return true;
        if (bb > BitBoard(0L) || bb3 > BitBoard(0L))
            return false;
        return true;
    }

    return false;
}
