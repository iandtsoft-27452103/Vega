import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.algorithm.searching;
import std.container.array;
import common;
import core.bitop;
import hash;
import bitop;
import move;
import board;
import atkop;
import std.math;

public void GenDrop(ref BoardTree bt, int color, ref Array!Move moves)
{
    BitBoard bb_occupied = bt.BB_Occupied[Color.Black] | bt.BB_Occupied[Color.White];
    BitBoard[Piece.Rook + 1] bb_piece_can_drop;
    bb_piece_can_drop[] = BitBoard(0L);
    BitBoard bb_empty = bt.BB_Empty & BB_Full;
    if ((bt.Hand[color] & Hand_Mask[Piece.Pawn]) > 0)
    {
        for (int i = common.File.File1; i < NFile; i++)
        {
            BitBoard bb = BB_File[i] & bt.BB_Piece[color][Piece.Pawn];
            if (bb == BitBoard(0L))
            {
                //bb_piece_can_drop[Piece.Pawn] |= ~bt.BB_Piece[color][Piece.Pawn] & BB_Full & BB_Pawn_Lance_Can_Drop[color] & bb_empty & BB_File[i];
                //bb_piece_can_drop[Piece.Pawn] ^= bt.BB_Piece[color][Piece.Pawn];
                bb_piece_can_drop[Piece.Pawn] |= BB_Full & BB_Pawn_Lance_Can_Drop[color] & bb_empty & BB_File[i];
            }
            int sq = bt.SQ_King[color ^ 1] + Delta_Table[color ^ 1];
            bb = BitBoard(0L);
            if (sq >= 0 && sq < Square_NB)
            {
                bb = bb_piece_can_drop[Piece.Pawn] & ABB_Mask[sq];
                if (bt.Board[sq] == Piece.Empty && bb > BitBoard(0L))
                {
                    if (IsMatePawnDrop(bt, sq, color ^ 1))
                    {
                        //writeln("mmm");
                        bb_piece_can_drop[Piece.Pawn] ^= ABB_Mask[sq];
                    }
                }
            }
        }
    }
    bb_piece_can_drop[Piece.Lance] = BB_Pawn_Lance_Can_Drop[color] & bb_empty;
    bb_piece_can_drop[Piece.Knight] = BB_Knight_Can_Drop[color] & bb_empty;
    bb_piece_can_drop[Piece.Silver] = BB_Others_Can_Drop & bb_empty;
    bb_piece_can_drop[Piece.Gold] = bb_piece_can_drop[Piece.Bishop] = bb_piece_can_drop[Piece.Rook] = bb_piece_can_drop[Piece.Silver];
    for (int i = Piece.Pawn; i <= Piece.Rook; i++)
    {
        if ((bt.Hand[color] & Hand_Mask[i]) > 0)
        {
            BitBoard bb = bb_piece_can_drop[i];
            //writeln("aaa");
            //writeln(bb);
            while (bb > BitBoard(0L))
            {
                int ifrom = Square_NB + i - 1;
                int ito = Square(bb);
                bb ^= ABB_Mask[ito];
                Move m = pack(ifrom, ito, i, 0, 0);
                moves.insertBack(m);
            }
         }
     }
}

public void GenNoCap(BoardTree bt, int color, ref Array!Move moves)
{
    BitBoard bb_occupied = bt.BB_Occupied[Color.Black] | bt.BB_Occupied[Color.White];
    BitBoard bb_empty = bt.BB_Empty & BB_Full;
    BitBoard bb_from = bt.BB_Piece[color][Piece.Pawn];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Piece_Attacks[color][Piece.Pawn][ifrom] & bb_empty;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            int flag_promo = (BB_Rev_Color_Position[color] & ABB_Mask[ito]) > 0 ? 1 : 0;
            Move move = pack(ifrom, ito, Piece.Pawn, 0, flag_promo);
            moves.insertBack(move);
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Knight];
    while (bb_from > 0)
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Piece_Attacks[color][Piece.Knight][ifrom] & bb_empty;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            BitBoard bb_can_promote = BB_Rev_Color_Position[color] & ABB_Mask[ito];
            if (bb_can_promote > BitBoard(0L))
            {
                 Move move = pack(ifrom, ito, Piece.Knight, 0, 1);
                 moves.insertBack(move);
            }
            if ((BB_Knight_Must_Promote[color] & ABB_Mask[ito]) == BitBoard(0L))
            {
                 Move move = pack(ifrom, ito, Piece.Knight, 0, 0);
                 moves.insertBack(move);
            }
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Silver];
    while (bb_from > 0)
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Piece_Attacks[color][Piece.Silver][ifrom] & bb_empty;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            BitBoard bb_can_promote = BB_Rev_Color_Position[color] & (ABB_Mask[ifrom] | ABB_Mask[ito]);
            if (bb_can_promote > BitBoard(0L))
            {
                Move move = pack(ifrom, ito, Piece.Silver, 0, 1);
                moves.insertBack(move);
            }
            Move move = pack(ifrom, ito, Piece.Silver, 0, 0);
            moves.insertBack(move);
        }
    }
    immutable int[] piece_list= [ Piece.Gold, Piece.King, Piece.Pro_Pawn, Piece.Pro_Lance, Piece.Pro_Knight, Piece.Pro_Silver ];
    for (int i = 0; i < piece_list.length; i++)
    {
        bb_from = bt.BB_Piece[color][piece_list[i]];
        while (bb_from > BitBoard(0L))
        {
            int ifrom = Square(bb_from);
            bb_from ^= ABB_Mask[ifrom];
            BitBoard bb_to = ABB_Piece_Attacks[color][piece_list[i]][ifrom] & bb_empty;
            while (bb_to > BitBoard(0L))
            {
                int ito = Square(bb_to);
                bb_to ^= ABB_Mask[ito];
                Move move = pack(ifrom, ito, piece_list[i], 0, 0);
                moves.insertBack(move);
            }
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Lance];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Lance_Attacks[color][ifrom][ABB_Lance_Mask_Ex[color][ifrom] & bb_occupied] & bb_empty;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            BitBoard bb_can_promote = BB_Rev_Color_Position[color] & ABB_Mask[ito];
            if (bb_can_promote > BitBoard(0L))
            {
                Move move = pack(ifrom, ito, Piece.Lance, 0, 1);
                moves.insertBack(move);
            }
            if ((BB_Knight_Must_Promote[color] & ABB_Mask[ito]) == BitBoard(0L))
            {
                Move move = pack(ifrom, ito, Piece.Lance, 0, 0);
                moves.insertBack(move);
            }
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Bishop];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Diagonal_Attacks[ifrom][ABB_Diagonal_Mask_Ex[ifrom] & bb_occupied] & bb_empty;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            int flag_promo = (BB_Rev_Color_Position[color] & (ABB_Mask[ifrom] | ABB_Mask[ito])) > 0 ? 1 : 0;
            Move move = pack(ifrom, ito, Piece.Bishop, 0, flag_promo);
            moves.insertBack(move);
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Horse];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = (ABB_Diagonal_Attacks[ifrom][ABB_Diagonal_Mask_Ex[ifrom] & bb_occupied] | ABB_Piece_Attacks[color][Piece.King][ifrom]) & bb_empty;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(ifrom, ito, Piece.Horse, 0, 0);
            moves.insertBack(move);
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Rook];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Cross_Attacks[ifrom][ABB_Cross_Mask_Ex[ifrom] & bb_occupied] & bb_empty;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            int flag_promo = (BB_Rev_Color_Position[color] & (ABB_Mask[ifrom] | ABB_Mask[ito])) > 0 ? 1 : 0;
            Move move = pack(ifrom, ito, Piece.Rook, 0, flag_promo);
            moves.insertBack(move);
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Dragon];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = (ABB_Cross_Attacks[ifrom][ABB_Cross_Mask_Ex[ifrom] & bb_occupied] | ABB_Piece_Attacks[color][Piece.King][ifrom]) & bb_empty;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(ifrom, ito, Piece.Dragon, 0, 0);
            moves.insertBack(move);
        }
    }
}

public void GenCap(BoardTree bt, int color, ref Array!Move moves)
{
    BitBoard bb_occupied = bt.BB_Occupied[Color.Black] | bt.BB_Occupied[Color.White];
    BitBoard bb_can_cap = bt.BB_Occupied[color ^ 1];
    BitBoard bb_from = bt.BB_Piece[color][Piece.Pawn];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Piece_Attacks[color][Piece.Pawn][ifrom] & bb_can_cap;
        while(bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            int flag_promo = (BB_Rev_Color_Position[color] & ABB_Mask[ito]) > 0 ? 1 : 0;
            Move move = pack(ifrom, ito, Piece.Pawn, abs(bt.Board[ito]), flag_promo);
            moves.insertBack(move);
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Knight];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Piece_Attacks[color][Piece.Knight][ifrom] & bb_can_cap;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            BitBoard bb_can_promote = BB_Rev_Color_Position[color] & ABB_Mask[ito];
            if (bb_can_promote > BitBoard(0L))
            {
                Move move = pack(ifrom, ito, Piece.Knight, abs(bt.Board[ito]), 1);
                moves.insertBack(move);
            }
            if ((BB_Knight_Must_Promote[color] & ABB_Mask[ito]) == BitBoard(0L))
            {
                Move move = pack(ifrom, ito, Piece.Knight, abs(bt.Board[ito]), 0);
                moves.insertBack(move);
            }
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Silver];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Piece_Attacks[color][Piece.Silver][ifrom] & bb_can_cap;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            BitBoard bb_can_promote = BB_Rev_Color_Position[color] & ABB_Mask[ito];
            if (bb_can_promote > BitBoard(0L))
            {
                Move move = pack(ifrom, ito, Piece.Silver, abs(bt.Board[ito]), 1);
                moves.insertBack(move);
            }
            Move move = pack(ifrom, ito, Piece.Silver, abs(bt.Board[ito]), 0);
            moves.insertBack(move);
        }
    }
    int[] piece_list = [ Piece.Gold, Piece.King, Piece.Pro_Pawn, Piece.Pro_Lance, Piece.Pro_Knight, Piece.Pro_Silver ];
    for (int i = 0; i < piece_list.length; i++)
    {
        bb_from = bt.BB_Piece[color][piece_list[i]];
        while (bb_from > BitBoard(0L))
        {
            int ifrom = Square(bb_from);
            bb_from ^= ABB_Mask[ifrom];
            BitBoard bb_to = ABB_Piece_Attacks[color][piece_list[i]][ifrom] & bb_can_cap;
            while (bb_to > BitBoard(0L))
            {
                int ito = Square(bb_to);
                bb_to ^= ABB_Mask[ito];
                Move move = pack(ifrom, ito, piece_list[i], abs(bt.Board[ito]), 0);
                moves.insertBack(move);
            }
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Lance];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Lance_Attacks[color][ifrom][ABB_Lance_Mask_Ex[color][ifrom] & bb_occupied] & bb_can_cap;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            BitBoard bb_can_promote = BB_Rev_Color_Position[color] & ABB_Mask[ito];
            if (bb_can_promote > BitBoard(0L))
            {
                Move move = pack(ifrom, ito, Piece.Lance, abs(bt.Board[ito]), 1);
                moves.insertBack(move);
            }
            if ((BB_Knight_Must_Promote[color] & ABB_Mask[ito]) == BitBoard(0L))
            {
                Move move = pack(ifrom, ito, Piece.Lance, abs(bt.Board[ito]), 0);
                moves.insertBack(move);
            }
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Bishop];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Diagonal_Attacks[ifrom][ABB_Diagonal_Mask_Ex[ifrom] & bb_occupied] & bb_can_cap;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            int flag_promo = (BB_Rev_Color_Position[color] & (ABB_Mask[ifrom] | ABB_Mask[ito])) > 0 ? 1 : 0;
            Move move = pack(ifrom, ito, Piece.Bishop, abs(bt.Board[ito]), flag_promo);
            moves.insertBack(move);
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Horse];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = (ABB_Diagonal_Attacks[ifrom][ABB_Diagonal_Mask_Ex[ifrom] & bb_occupied] | ABB_Piece_Attacks[color][Piece.King][ifrom]) & bb_can_cap;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(ifrom, ito, Piece.Horse, abs(bt.Board[ito]), 0);
            moves.insertBack(move);
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Rook];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Cross_Attacks[ifrom][ABB_Cross_Mask_Ex[ifrom] & bb_occupied] & bb_can_cap;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            int flag_promo = (BB_Rev_Color_Position[color] & (ABB_Mask[ifrom] | ABB_Mask[ito])) > 0 ? 1 : 0;
            Move move = pack(ifrom, ito, Piece.Rook, abs(bt.Board[ito]), flag_promo);
            moves.insertBack(move);
        }
    }

    bb_from = bt.BB_Piece[color][Piece.Dragon];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = (ABB_Cross_Attacks[ifrom][ABB_Cross_Mask_Ex[ifrom] & bb_occupied] | ABB_Piece_Attacks[color][Piece.King][ifrom]) & bb_can_cap;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(ifrom, ito, Piece.Dragon, abs(bt.Board[ito]), 0);
            moves.insertBack(move);
        }
    }
}

public void GenEvasion(BoardTree bt, int color, ref Array!Move moves)
{
    int ito, idirec, ipiece;
    bool flag;
    BitBoard bb_occupied = bt.BB_Occupied[Color.Black] | bt.BB_Occupied[Color.White];
    BitBoard[Piece.Rook + 1] bb_piece_can_drop;
    bb_piece_can_drop[] = BitBoard(0L);
    int sq_king = bt.SQ_King[color];
    int ifrom = sq_king;
    bt.BB_Occupied[color] ^= ABB_Mask[ifrom];
    BitBoard bb_not_color = ~bt.BB_Occupied[color] & BB_Full;
    BitBoard bb_to = ABB_Piece_Attacks[color][Piece.King][sq_king] & bb_not_color;
    while (bb_to > BitBoard(0L))
    {
        ito = Square(bb_to);
        if (IsAttacked(bt, ito, color) == BitBoard(0L))
        {
            Move move = pack(ifrom, ito, Piece.King, abs(bt.Board[ito]), 0);
            moves.insertBack(move);
        }
        bb_to ^= ABB_Mask[ito];
    }
    bt.BB_Occupied[color] ^= ABB_Mask[ifrom];
    BitBoard bb_checker = AttacksToPiece(bt, sq_king, color ^ 1);
    int checker_num = PopCount(bb_checker);
    if (checker_num == 2)
    {
        return;
    }
    int sq_checker = Square(bb_checker);
    BitBoard bb_cap_checker = AttacksToPiece(bt, sq_checker, color);
    ito = sq_checker;
    while (bb_cap_checker > BitBoard(0L))
    {
        ifrom = Square(bb_cap_checker);
        bb_cap_checker ^= ABB_Mask[ifrom];
        if (ifrom == sq_king)
        {
            continue;
        }
        ipiece = abs(bt.Board[ifrom]);
        idirec = Adirec[ifrom][ito];
        flag = false;
        if (IsPinnedOnKing(bt, ifrom, idirec, color) == BitBoard(0L))
        {
            if (Set_Piece_Can_Promote0.canFind(ipiece) && (ABB_Piece_Attacks[color][ipiece][ifrom] & ABB_Mask[sq_checker]) > BitBoard(0L) && (ABB_Piece_Attacks[color][ipiece][ifrom] & BB_Rev_Color_Position[color]) > BitBoard(0L))
            {
                Move move = pack(ifrom, ito, ipiece, abs(bt.Board[ito]), 1);
                Do(bt, move, color);
                if (IsAttacked(bt, sq_king, color) == BitBoard(0L))
                {
                    moves.insertBack(move);
                }
                UnDo(bt, move, color);
                if (ipiece == Piece.Pawn)
                {
                    flag = true;
                }
            }
            if (Set_Piece_Can_Promote1.canFind(ipiece))
            {
                if ((BB_Rev_Color_Position[color] & ABB_Mask[ifrom]) > BitBoard(0L) || (BB_Rev_Color_Position[color] & ABB_Mask[ito]) > BitBoard(0L))
                {
                    Move move = pack(ifrom, ito, ipiece, abs(bt.Board[ito]), 1);
                    Do(bt, move, color);
                    if (IsAttacked(bt, sq_king, color) == BitBoard(0L))
                    {
                        moves.insertBack(move);
                    }
                    UnDo(bt, move, color);
                    if (ipiece != Piece.Silver)
                    {
                        flag = true;
                    }
                }
            }
            if (!flag)
            {
                Move move = pack(ifrom, ito, ipiece, abs(bt.Board[ito]), 0);
                Do(bt, move, color);
                if (IsAttacked(bt, sq_king, color) == BitBoard(0L))
                {
                    moves.insertBack(move);
                }
                UnDo(bt, move, color);
            }
        }
    }
    int checker = abs(bt.Board[sq_checker]);
    if (!Set_Long_Attack_Pieces.canFind(checker))
    {
        return;
    }
    if ((bb_checker & ABB_Piece_Attacks[color][Piece.King][sq_king]) > BitBoard(0L))
    {
        return;
    }
    else
    {
        if ((Set_Long_Attack_Pieces.canFind(checker)))
        {
            BitBoard bb_inter = ABB_Obstacles[sq_king][sq_checker];
            while (bb_inter > BitBoard(0L))
            {
                ito = Square(bb_inter);
                bb_inter ^= ABB_Mask[ito];
                BitBoard bb_defender = AttacksToPiece(bt, ito, color);
                while (bb_defender > BitBoard(0L))
                {
                    ifrom = Square(bb_defender);
                    bb_defender ^= ABB_Mask[ifrom];
                    if (ifrom == sq_king)
                    {
                         continue;
                    }
                    ipiece = abs(bt.Board[ifrom]);
                    idirec = Adirec[sq_king][ifrom];
                    flag = false;
                    if (idirec == Direction.Direc_Misc || IsPinnedOnKing(bt, ifrom, idirec, color) == BitBoard(0L))
                    {
                        if (Set_Piece_Can_Promote0.canFind(ipiece))
                        {
                            if (ipiece != Piece.Lance && (ABB_Piece_Attacks[color][ipiece][ifrom] & BB_Rev_Color_Position[color]) > BitBoard(0L))
                            {
                                Move move = pack(ifrom, ito, ipiece, abs(bt.Board[ito]), 1);
                                moves.insertBack(move);
                                if (ipiece == Piece.Pawn)
                                {
                                    flag = true;
                                }
                            }
                            else if (ipiece == Piece.Lance)
                            {
                                bb_occupied = bt.BB_Occupied[Color.Black] | bt.BB_Occupied[Color.White];
                                if ((ABB_Lance_Attacks[color][ifrom][ABB_Lance_Mask_Ex[color][ifrom] & bb_occupied]) > BitBoard(0L) && (BB_Rev_Color_Position[color] & ABB_Mask[ito]) > BitBoard(0L))
                                {
                                    Move move = pack(ifrom, ito, ipiece, abs(bt.Board[ito]), 1);
                                    moves.insertBack(move);
                                }
                            }
                        }
                        if (Set_Piece_Can_Promote1.canFind(ipiece))
                        {
                            if ((BB_Rev_Color_Position[color] & ABB_Mask[ifrom]) > BitBoard(0L) || (BB_Rev_Color_Position[color] & ABB_Mask[ito]) > BitBoard(0L))
                            {
                                Move move = pack(ifrom, ito, ipiece, abs(bt.Board[ito]), 1);
                                moves.insertBack(move);
                                if (ipiece != Piece.Silver)
                                {
                                    flag = true;
                                }
                            }
                        }
                        if (!flag)
                        {
                            if ((ipiece == Piece.Knight || ipiece == Piece.Lance) && (BB_Knight_Must_Promote[color] & ABB_Mask[ito]) > BitBoard(0L))
                            {
                                continue;
                            }
                            Move move = pack(ifrom, ito, ipiece, abs(bt.Board[ito]), 0);
                            moves.insertBack(move);
                        }
                    }
                }
            }
        }
        BitBoard bb_empty = ABB_Obstacles[sq_king][sq_checker];
        bb_piece_can_drop[Piece.Pawn] = BitBoard(0L);
        if ((bt.Hand[color] & Hand_Mask[Piece.Pawn]) > 0)
        {
            for (int i = common.File.File1; i < NFile; i++)
            {
                if ((BB_File[i] & bt.BB_Piece[color][Piece.Pawn]) == BitBoard(0L))
                {
                    BitBoard bb = (~bt.BB_Piece[color][Piece.Pawn] & BB_Full) & BB_Pawn_Lance_Can_Drop[color] & bb_empty & BB_File[i];
                    bb_piece_can_drop[Piece.Pawn] = bb_piece_can_drop[Piece.Pawn] | bb;
                }
            }
            int sq = bt.SQ_King[color] + Delta_Table[color];
            if ((sq >= 0 && sq < Square_NB) && bt.Board[sq] == Piece.Empty && (bb_piece_can_drop[Piece.Pawn] & ABB_Mask[sq]) == BitBoard(0L))
            {
                if (IsMatePawnDrop(bt, sq, color))
                {
                    bb_piece_can_drop[Piece.Pawn] ^= ABB_Mask[sq];
                }
            }
        }
        bb_piece_can_drop[Piece.Lance] = BB_Pawn_Lance_Can_Drop[color] & bb_empty;
        bb_piece_can_drop[Piece.Knight] = BB_Knight_Can_Drop[color] & bb_empty;
        bb_piece_can_drop[Piece.Silver] = BB_Others_Can_Drop & bb_empty;
        bb_piece_can_drop[Piece.Gold] = bb_piece_can_drop[Piece.Bishop] = bb_piece_can_drop[Piece.Rook] = bb_piece_can_drop[Piece.Silver];
        for (int i = Piece.Pawn; i <= Piece.Rook; i++)
        {
            if ((bt.Hand[color] & Hand_Mask[i]) > 0)
            {
                BitBoard bb_object = bb_piece_can_drop[i];
                while (bb_object > BitBoard(0L))
                {
                    ifrom = Square_NB + i - 1;
                    ito = Square(bb_object);
                    bb_object ^= ABB_Mask[ito];
                    Move move = pack(ifrom, ito, i, 0, 0);
                    moves.insertBack(move);
                }
            }
        }
    }
}

// This function generates moves which make own king discovered check.
public void GenCheck(BoardTree bt, int color, ref Array!Move moves)
{
    int opponent_color = color ^ 1;
    int sq_opponent_king = bt.SQ_King[opponent_color];
    int sq_object = sq_opponent_king + Delta_Table[opponent_color];
    int sq_pawn = sq_opponent_king + (2 * Delta_Table[opponent_color]);
    // normal pawn move
    BitBoard bb_occupied = bt.BB_Occupied[Color.Black] | bt.BB_Occupied[Color.White];
    BitBoard bb_empty = ~bb_occupied & BB_Full;
    BitBoard bb_move_to = (bt.BB_Occupied[color ^ 1] | bb_empty) & BB_Full;
    // generate no promote pawn move
    if (sq_pawn >= 0 && sq_pawn < Square_NB && (bt.Board[sq_pawn] == Sign_Table[opponent_color] * Piece.Pawn) && ((ABB_Mask[sq_pawn] & BB_Pawn_Mask[color]) > BitBoard(0L)) && (ABB_Mask[sq_object] & bb_move_to) > BitBoard(0L))
    {
        Move move = pack(sq_pawn, sq_object, Piece.Pawn, abs(bt.Board[sq_object]), 0);
        moves.insertBack(move);
    }
    // generate pawn promote move
    BitBoard bb_from = bt.BB_Piece[color][Piece.Pawn];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = BB_Rev_Color_Position[color] & ABB_Piece_Attacks[color][Piece.Pawn][ifrom] & ABB_Piece_Attacks[opponent_color][Piece.King][sq_opponent_king] & bb_move_to;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(ifrom, ito, Piece.Pawn, abs(bt.Board[ito]), 1);
            moves.insertBack(move);
        }
    }
    // generate discovered check, using rook or dragon attacks.
    bb_from = ABB_Rank_Attacks[sq_opponent_king][BitBoard(0L)] & bt.BB_Piece[color][Piece.Pawn];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_rd = bt.BB_Piece[color][Piece.Rook] | bt.BB_Piece[color][Piece.Dragon];
        BitBoard bb_temp = ABB_Rank_Attacks[ifrom][BitBoard(0L)] & bb_rd;
        BitBoard bb_temp2 = ABB_Piece_Attacks[color][Piece.Pawn][ifrom] & bb_move_to;
        if (((bt.BB_Piece[color][Piece.Rook] | bt.BB_Piece[color][Piece.Dragon]) & ABB_Rank_Attacks[ifrom][BitBoard(0L)]) > BitBoard(0L) && (ABB_Piece_Attacks[color][Piece.Pawn][ifrom] & bb_move_to) > BitBoard(0L))
        {
            int flag_promo = 0;
            if ((BB_Rev_Color_Position[color] & ABB_Piece_Attacks[color][Piece.Pawn][ifrom]) != BitBoard(0L))
            {
                flag_promo = 1;
            }
            int ito = ifrom + Delta_Table[color];
            Move move = pack(ifrom, ito, Piece.Pawn, abs(bt.Board[ito]), flag_promo);
            moves.insertBack(move);
        }
    }
    // generate discovered check, using bishop or horse attacks.
    bb_from = ABB_Diag1_Attacks[sq_opponent_king][BitBoard(0L)] & bt.BB_Piece[color][Piece.Pawn];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_bh = bt.BB_Piece[color][Piece.Bishop] | bt.BB_Piece[color][Piece.Horse];
        BitBoard bb_temp = ABB_Diag1_Attacks[ifrom][BitBoard(0L)] & (bt.BB_Piece[color][Piece.Bishop] | bt.BB_Piece[color][Piece.Horse]);
        BitBoard bb_temp2 = ABB_Piece_Attacks[color][Piece.Pawn][ifrom] & bb_move_to;
        if ((ABB_Diag1_Attacks[ifrom][BitBoard(0L)] & (bt.BB_Piece[color][Piece.Bishop] | bt.BB_Piece[color][Piece.Horse])) > BitBoard(0L) && ((ABB_Piece_Attacks[color][Piece.Pawn][ifrom] & bb_move_to)) > BitBoard(0L))
        {
            int flag_promo = 0;
            if ((BB_Rev_Color_Position[color] & ABB_Piece_Attacks[color][Piece.Pawn][ifrom]) != BitBoard(0L))
            {
                 flag_promo = 1;
            }
            int ito = ifrom + Delta_Table[color];
            Move move = pack(ifrom, ito, Piece.Pawn, abs(bt.Board[ito]), flag_promo);
            moves.insertBack(move);
        }
    }
    bb_from = ABB_Diag2_Attacks[sq_opponent_king][BitBoard(0L)] & bt.BB_Piece[color][Piece.Pawn];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_bh = bt.BB_Piece[color][Piece.Bishop] | bt.BB_Piece[color][Piece.Horse];
        BitBoard bb_temp = ABB_Diag2_Attacks[ifrom][BitBoard(0L)] & (bt.BB_Piece[color][Piece.Bishop] | bt.BB_Piece[color][Piece.Horse]);
        BitBoard bb_temp2 = ABB_Piece_Attacks[color][Piece.Pawn][ifrom] & bb_move_to;
        if ((ABB_Diag2_Attacks[ifrom][BitBoard(0L)] & (bt.BB_Piece[color][Piece.Bishop] | bt.BB_Piece[color][Piece.Horse])) > BitBoard(0L) && ((ABB_Piece_Attacks[color][Piece.Pawn][ifrom] & bb_move_to)) > BitBoard(0L))
        {
             int flag_promo = 0;
             if ((BB_Rev_Color_Position[color] & ABB_Piece_Attacks[color][Piece.Pawn][ifrom]) != BitBoard(0L))
             {
                 flag_promo = 1;
             }
             int ito = ifrom + Delta_Table[color];
             Move move = pack(ifrom, ito, Piece.Pawn, abs(bt.Board[ito]), flag_promo);
             moves.insertBack(move);
        }
    }
    BitBoard bb_temp3 = BitBoard(0L);
    // generate pawn drop move
    if (sq_object >= 0 && sq_object < Square_NB)
    {
        bb_temp3 = BB_File[FileTable[sq_object]] & bt.BB_Piece[color][Piece.Pawn];
    }
    if (bb_temp3 == BitBoard(0L) && (sq_object >= 0 && sq_object < Square_NB) && (bt.Hand[color] & Hand_Mask[Piece.Pawn]) > 0 && bt.Board[sq_object] == Piece.Empty && !IsMatePawnDrop(bt, sq_object, color ^ 1))
    {
        Move move = pack(Square_NB + Piece.Pawn - 1, sq_object, Piece.Pawn, 0, 0);
        moves.insertBack(move);
    }
    // generate no promote silver move
    bb_from = bt.BB_Piece[color][Piece.Silver];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        int idirec = Adirec[sq_opponent_king][ifrom];
        BitBoard bb_to = ABB_Piece_Attacks[color][Piece.Silver][ifrom] & ABB_Piece_Attacks[opponent_color][Piece.Silver][sq_opponent_king] & bb_move_to;
        if (idirec != Direction.Direc_Misc && IsPinnedOnKing(bt, ifrom, idirec, opponent_color) > BitBoard(0L))
        {
            BitBoard bb_temp = BitBoard(0L);
            bb_to |= AddBehindAttacks(bb_temp, idirec, sq_opponent_king) & ABB_Piece_Attacks[color][Piece.Silver][ifrom] & bb_move_to;
        }
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(ifrom, ito, Piece.Silver, abs(bt.Board[ito]), 0);
            moves.insertBack(move);
        }
    }
    // generate silver promote move
    bb_from = bt.BB_Piece[color][Piece.Silver];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        int idirec = Adirec[sq_opponent_king][ifrom];
        BitBoard bb_to = ABB_Piece_Attacks[color][Piece.Silver][ifrom] & ABB_Piece_Attacks[opponent_color][Piece.Gold][sq_opponent_king] & bb_move_to;
        if (idirec != Direction.Direc_Misc && IsPinnedOnKing(bt, ifrom, idirec, opponent_color) > BitBoard(0L))
        {
            BitBoard bb_temp = BitBoard(0L);
            bb_to |= AddBehindAttacks(bb_temp, idirec, sq_opponent_king) & ABB_Piece_Attacks[color][Piece.Silver][ifrom] & bb_move_to;
        }
        while (bb_to > BitBoard(0L))
        {
            int ito =Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            if ((BB_Rev_Color_Position[color] & ABB_Mask[ifrom]) > BitBoard(0L) || (BB_Rev_Color_Position[color] & ABB_Mask[ito]) > BitBoard(0L))
            {
                Move move = pack(ifrom, ito, Piece.Silver, abs(bt.Board[ito]), 1);
                moves.insertBack(move);
            }
        }
    }
    // generate silver drop move
    if ((bt.Hand[color] & Hand_Mask[Piece.Silver]) > 0)
    {
        BitBoard bb_to = ABB_Piece_Attacks[opponent_color][Piece.Silver][sq_opponent_king] & bb_empty;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(Square_NB + Piece.Silver - 1, ito, Piece.Silver, 0, 0);
            moves.insertBack(move);
        }
    }
    // generate gold move
    bb_from = bt.BB_Piece[color][Piece.Gold] | bt.BB_Piece[color][Piece.Pro_Pawn] | bt.BB_Piece[color][Piece.Pro_Lance] | bt.BB_Piece[color][Piece.Pro_Knight] | bt.BB_Piece[color][Piece.Pro_Silver];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        int idirec = Adirec[sq_opponent_king][ifrom];
        BitBoard bb_to = ABB_Piece_Attacks[color][Piece.Gold][ifrom] & ABB_Piece_Attacks[opponent_color][Piece.Gold][sq_opponent_king] & bb_move_to;
        if (idirec != Direction.Direc_Misc && IsPinnedOnKing(bt, ifrom, idirec, opponent_color) > BitBoard(0L))
        {
            BitBoard bb_temp = BitBoard(0L);
            bb_to |= AddBehindAttacks(bb_temp, idirec, sq_opponent_king) & ABB_Piece_Attacks[color][Piece.Gold][ifrom] & bb_move_to;
        }
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(ifrom, ito, abs(bt.Board[ifrom]), abs(bt.Board[ito]), 0);
            moves.insertBack(move);
        }
    }
    // generate gold drop move
    if ((bt.Hand[color] & Hand_Mask[Piece.Gold]) > BitBoard(0L))
    {
        BitBoard bb_to = ABB_Piece_Attacks[opponent_color][Piece.Gold][sq_opponent_king] & bb_empty;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(Square_NB + Piece.Gold - 1, ito, Piece.Gold, 0, 0);
            moves.insertBack(move);
        }
    }
    // generate no promote knight move
    bb_from = bt.BB_Piece[color][Piece.Knight];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        int idirec = Adirec[sq_opponent_king][ifrom];
        BitBoard bb_to = ABB_Piece_Attacks[color][Piece.Knight][ifrom] & ABB_Piece_Attacks[opponent_color][Piece.Knight][sq_opponent_king] & bb_move_to;
        if (idirec != Direction.Direc_Misc && IsPinnedOnKing(bt, ifrom, idirec, opponent_color) > BitBoard(0L))
        {
            BitBoard bb_temp = BitBoard(0L);
            bb_to |= AddBehindAttacks(bb_temp, idirec, sq_opponent_king) & ABB_Piece_Attacks[color][Piece.Knight][ifrom] & bb_move_to;
        }
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(ifrom, ito, Piece.Knight, abs(bt.Board[ito]), 0);
            moves.insertBack(move);
        }
    }
    // generate knight promote move
    bb_from = bt.BB_Piece[color][Piece.Knight];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        int idirec = Adirec[sq_opponent_king][ifrom];
        BitBoard bb_to = ABB_Piece_Attacks[color][Piece.Knight][ifrom] & ABB_Piece_Attacks[opponent_color][Piece.Gold][sq_opponent_king] & bb_move_to;
        if (idirec != Direction.Direc_Misc && IsPinnedOnKing(bt, ifrom, idirec, opponent_color) > BitBoard(0L))
        {
            BitBoard bb_temp = BitBoard(0L);
            bb_to |= AddBehindAttacks(bb_temp, idirec, sq_opponent_king) & ABB_Piece_Attacks[color][Piece.Knight][ifrom] & bb_move_to;
        }
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            if ((BB_Rev_Color_Position[color] & ABB_Mask[ifrom]) > BitBoard(0L) || (BB_Rev_Color_Position[color] & ABB_Mask[ito]) > BitBoard(0L))
            {
                Move move = pack(ifrom, ito, Piece.Knight, abs(bt.Board[ito]), 1);
                moves.insertBack(move);
            }
        }
    }
    // generate knight drop move
    if ((bt.Hand[color] & Hand_Mask[Piece.Knight]) > BitBoard(0L))
    {
        BitBoard bb_to = ABB_Piece_Attacks[opponent_color][Piece.Knight][sq_opponent_king] & bb_empty;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(Square_NB + Piece.Knight - 1, ito, Piece.Knight, 0, 0);
            moves.insertBack(move);
        }
    }
    // generate king move
    // this moves are discovered check
    int ifrom_king = bt.SQ_King[color];
    int idirec_king = Adirec[sq_opponent_king][ifrom_king];
    if ((idirec_king != Direction.Direc_Misc) && IsPinnedOnKing(bt, ifrom_king, idirec_king, opponent_color) > BitBoard(0L))
    {
        BitBoard bb_temp = BitBoard(0L);
        BitBoard bb_to = AddBehindAttacks(bb_temp, idirec_king, sq_opponent_king) & ABB_Piece_Attacks[color][Piece.King][ifrom_king] & bb_move_to;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(ifrom_king, ito, Piece.King, abs(bt.Board[ito]), 0);
            moves.insertBack(move);
        }
    }
    // generate no promote lance move => it must be capture move.
    bb_from = bt.BB_Piece[color][Piece.Lance];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Lance_Attacks[color][ifrom][ABB_Lance_Mask_Ex[color][ifrom] & bb_occupied] & (~BB_Knight_Must_Promote[color] & BB_Full & bt.BB_Occupied[opponent_color] & bb_move_to);
        BitBoard bb_attacks = bb_to;
        bb_to &= ABB_Lance_Attacks[color ^ 1][sq_opponent_king][ABB_Lance_Mask_Ex[color ^ 1][sq_opponent_king] & bb_occupied];
        int idirec = Adirec[sq_opponent_king][ifrom];
        if ((idirec != Direction.Direc_Misc) && IsPinnedOnKing(bt, ifrom, idirec, opponent_color) > BitBoard(0L))
        {
            BitBoard bb_temp = BitBoard(0L);
            bb_temp = bb_attacks & AddBehindAttacks(bb_temp, idirec, sq_opponent_king);
            bb_to |= bb_temp;
            bb_to &= (color == Color.Black) ? (BB_File[FileTable[ifrom]] & (BB_Rank[2] | BB_Rank[3])) : (BB_File[FileTable[ifrom]] & (BB_Rank[6] | BB_Rank[5]));
        }
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(ifrom, ito, Piece.Lance, abs(bt.Board[ito]), 0);
            moves.insertBack(move);
        }
    }
    // generate no promote lance move => it must be discovered check.
    bb_from = bt.BB_Piece[color][Piece.Lance];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Lance_Attacks[color][ifrom][ABB_Lance_Mask_Ex[color][ifrom] & bb_occupied] & (~BB_Knight_Must_Promote[color] & BB_Full & bb_move_to);
        BitBoard bb_attacks = bb_to;
        bb_to &= ABB_Lance_Attacks[color ^ 1][sq_opponent_king][ABB_Lance_Mask_Ex[color ^ 1][sq_opponent_king] & bb_occupied];
        int idirec = Adirec[sq_opponent_king][ifrom];
        if ((idirec != Direction.Direc_Misc) && IsPinnedOnKing(bt, ifrom, idirec, opponent_color) > BitBoard(0L))
        {
            BitBoard bb_temp = BitBoard(0L);
            bb_temp = bb_attacks & AddBehindAttacks(bb_temp, idirec, sq_opponent_king);
            bb_to |= bb_temp;
            bb_to &= (color == Color.Black) ? (BB_File[FileTable[ifrom]] & (BB_Rank[2] | BB_Rank[3])) : (BB_File[FileTable[ifrom]] & (BB_Rank[6] | BB_Rank[5]));
        }
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(ifrom, ito, Piece.Lance, abs(bt.Board[ito]), 0);
            moves.insertBack(move);
        }
    }
    // generate lance promote move
    bb_from = bt.BB_Piece[color][Piece.Lance];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Lance_Attacks[color][ifrom][ABB_Lance_Mask_Ex[color][ifrom] & bb_occupied];
        BitBoard bb_attacks = bb_to;
        bb_to &= BB_Rev_Color_Position[color] & BB_Full & ABB_Piece_Attacks[opponent_color][Piece.Gold][sq_opponent_king] & bb_move_to;
        bb_to &= ABB_Lance_Attacks[color ^ 1][sq_opponent_king][ABB_Lance_Mask_Ex[color ^ 1][sq_opponent_king] & bb_occupied];
        int idirec = Adirec[sq_opponent_king][ifrom];
        if ((idirec != Direction.Direc_Misc) && IsPinnedOnKing(bt, ifrom, idirec, opponent_color) > BitBoard(0L))
        {
            BitBoard bb_temp = BitBoard(0L);
            bb_temp = bb_attacks & AddBehindAttacks(bb_temp, idirec, sq_opponent_king);
            bb_to |= bb_temp;
            bb_to &= BB_Color_Position[Color.Black] | BB_Color_Position[Color.White];
        }
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(ifrom, ito, Piece.Lance, abs(bt.Board[ito]), 1);
            moves.insertBack(move);
        }
    }
    // generate lance drop move
    if ((bt.Hand[color] & Hand_Mask[Piece.Lance]) > BitBoard(0L))
    {
        BitBoard bb_to = ABB_Lance_Attacks[color ^ 1][sq_opponent_king][ABB_Lance_Mask_Ex[color ^ 1][sq_opponent_king] & bb_occupied] & bb_empty;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(Square_NB + Piece.Lance - 1, ito, Piece.Lance, 0, 0);
            moves.insertBack(move);
        }
    }
    // generate no promote rook move
    bb_from = bt.BB_Piece[color][Piece.Rook] & (BB_Color_Position[color] | BB_DMZ);
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Cross_Attacks[ifrom][ABB_Cross_Mask_Ex[ifrom] & bb_occupied];
        BitBoard bb_attacks = bb_to;
        bb_to &= bb_move_to;
        int idirec = Adirec[sq_opponent_king][ifrom];
        bb_to &= ABB_Cross_Attacks[sq_opponent_king][ABB_Cross_Mask_Ex[sq_opponent_king] & bb_occupied];
        bb_to &= BB_Color_Position[color] | BB_DMZ;
        if ((idirec != Direction.Direc_Misc) && IsPinnedOnKing(bt, ifrom, idirec, opponent_color) > BitBoard(0L))
        {
            BitBoard bb_temp = BitBoard(0L);
            bb_temp = bb_attacks & AddBehindAttacks(bb_temp, idirec, sq_opponent_king);
            bb_to |= bb_temp;
            bb_to &= BB_Color_Position[color] | BB_DMZ;
        }
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(ifrom, ito, Piece.Rook, abs(bt.Board[ito]), 0);
            moves.insertBack(move);
        }
    }
    // generate rook promote move
    bb_from = bt.BB_Piece[color][Piece.Rook];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Cross_Attacks[ifrom][ABB_Cross_Mask_Ex[ifrom] & bb_occupied];
        BitBoard bb_attacks = bb_to;
        bb_to &= bb_move_to;
        int idirec = Adirec[sq_opponent_king][ifrom];
        bb_to &= (ABB_Cross_Attacks[sq_opponent_king][ABB_Cross_Mask_Ex[sq_opponent_king] & bb_occupied]) | ABB_Piece_Attacks[opponent_color][Piece.King][sq_opponent_king];
        if ((idirec != Direction.Direc_Misc) && IsPinnedOnKing(bt, ifrom, idirec, opponent_color) > BitBoard(0L))
        {
            BitBoard bb_temp = BitBoard(0L);
            bb_temp = bb_attacks & AddBehindAttacks(bb_temp, idirec, sq_opponent_king);
            bb_to |= bb_temp;
        }
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            if ((ABB_Mask[ifrom] & BB_Rev_Color_Position[color]) > BitBoard(0L) || (ABB_Mask[ito] & BB_Rev_Color_Position[color]) > BitBoard(0L))
            {
                Move move = pack(ifrom, ito, Piece.Rook, abs(bt.Board[ito]), 1);
                moves.insertBack(move);
            }
        }
    }
    // generate rook drop move
    if ((bt.Hand[color] & Hand_Mask[Piece.Rook]) > 0)
    {
        BitBoard bb_to = ABB_Cross_Attacks[sq_opponent_king][ABB_Cross_Mask_Ex[sq_opponent_king] & bb_occupied] & bb_empty;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(Square_NB + Piece.Rook - 1, ito, Piece.Rook, 0, 0);
            moves.insertBack(move);
        }
    }
    // generate no promote bishop move
    bb_from = bt.BB_Piece[color][Piece.Bishop] & (BB_Color_Position[color] | BB_DMZ);
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Diagonal_Attacks[ifrom][ABB_Diagonal_Mask_Ex[ifrom] & bb_occupied];
        BitBoard bb_attacks = bb_to;
        bb_to &= bb_move_to;
        int idirec = Adirec[sq_opponent_king][ifrom];
        bb_to &= ABB_Diagonal_Attacks[sq_opponent_king][ABB_Diagonal_Mask_Ex[sq_opponent_king] & bb_occupied];
        bb_to &= BB_Color_Position[color] | BB_DMZ;
        if ((idirec != Direction.Direc_Misc) && IsPinnedOnKing(bt, ifrom, idirec, opponent_color) > BitBoard(0L))
        {
            BitBoard bb_temp = BitBoard(0L);
            bb_to |= bb_attacks & AddBehindAttacks(bb_temp, idirec, sq_opponent_king);
            bb_to &= BB_Color_Position[color] | BB_DMZ;
        }
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(ifrom, ito, Piece.Bishop, abs(bt.Board[ito]), 0);
            moves.insertBack(move);
        }
    }
    // generate bishop promote move
    bb_from = bt.BB_Piece[color][Piece.Bishop];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Diagonal_Attacks[ifrom][ABB_Diagonal_Mask_Ex[ifrom] & bb_occupied];
        BitBoard bb_attacks = bb_to;
        bb_to &= bb_move_to;
        int idirec = Adirec[sq_opponent_king][ifrom];
        bb_to &= (ABB_Diagonal_Attacks[sq_opponent_king][ABB_Diagonal_Mask_Ex[sq_opponent_king] & bb_occupied]) | (ABB_Piece_Attacks[opponent_color][Piece.King][sq_opponent_king]);
        if ((idirec != Direction.Direc_Misc) && IsPinnedOnKing(bt, ifrom, idirec, opponent_color) > BitBoard(0L))
        {
            BitBoard bb_temp = BitBoard(0L);
            bb_to |= bb_attacks & AddBehindAttacks(bb_temp, idirec, sq_opponent_king);
        }
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            if ((ABB_Mask[ifrom] & BB_Rev_Color_Position[color]) > BitBoard(0L) || (ABB_Mask[ito] & BB_Rev_Color_Position[color]) > BitBoard(0L))
            {
                Move move = pack(ifrom, ito, Piece.Bishop, abs(bt.Board[ito]), 1);
                moves.insertBack(move);
            }
        }
    }
    // generate bishop drop move
    if ((bt.Hand[color] & Hand_Mask[Piece.Bishop]) > 0)
    {
        BitBoard bb_to = ABB_Diagonal_Attacks[sq_opponent_king][ABB_Diagonal_Mask_Ex[sq_opponent_king] & bb_occupied] & bb_empty;
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(Square_NB + Piece.Bishop - 1, ito, Piece.Bishop, 0, 0);
            moves.insertBack(move);
        }
    }
    // generate dragon move
    bb_from = bt.BB_Piece[color][Piece.Dragon];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Cross_Attacks[ifrom][ABB_Cross_Mask_Ex[ifrom] & bb_occupied] | ABB_Piece_Attacks[color][Piece.King][ifrom];
        BitBoard bb_attacks = bb_to;
        bb_to &= bb_move_to;
        int idirec = Adirec[sq_opponent_king][ifrom];
        bb_to &= ABB_Cross_Attacks[sq_opponent_king][ABB_Cross_Mask_Ex[sq_opponent_king] & bb_occupied] | ABB_Piece_Attacks[color][Piece.King][sq_opponent_king];
        if ((idirec != Direction.Direc_Misc) && IsPinnedOnKing(bt, ifrom, idirec, opponent_color) > BitBoard(0L))
        {
            BitBoard bb_temp = BitBoard(0L);
            bb_to |= bb_attacks & AddBehindAttacks(bb_temp, idirec, sq_opponent_king);
        }
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(ifrom, ito, Piece.Dragon, abs(bt.Board[ito]), 0);
            moves.insertBack(move);
        }
    }
    // generate horse move
    bb_from = bt.BB_Piece[color][Piece.Horse];
    while (bb_from > BitBoard(0L))
    {
        int ifrom = Square(bb_from);
        bb_from ^= ABB_Mask[ifrom];
        BitBoard bb_to = ABB_Diagonal_Attacks[ifrom][ABB_Diagonal_Mask_Ex[ifrom] & bb_occupied] | ABB_Piece_Attacks[color][Piece.King][ifrom];
        BitBoard bb_attacks = bb_to;
        bb_to &= bb_move_to;
        int idirec = Adirec[sq_opponent_king][ifrom];
        BitBoard bb_temp = ABB_Diagonal_Attacks[sq_opponent_king][ABB_Diagonal_Mask_Ex[sq_opponent_king] & bb_occupied] | ABB_Piece_Attacks[color][Piece.King][sq_opponent_king];
        bb_to &= ABB_Diagonal_Attacks[sq_opponent_king][ABB_Diagonal_Mask_Ex[sq_opponent_king] & bb_occupied] | ABB_Piece_Attacks[color][Piece.King][sq_opponent_king];
        if ((idirec != Direction.Direc_Misc) && IsPinnedOnKing(bt, ifrom, idirec, opponent_color) > BitBoard(0L))
        {
            bb_temp = BitBoard(0L);
            bb_to |= bb_attacks & AddBehindAttacks(bb_temp, idirec, sq_opponent_king);
        }
        while (bb_to > BitBoard(0L))
        {
            int ito = Square(bb_to);
            bb_to ^= ABB_Mask[ito];
            Move move = pack(ifrom, ito, Piece.Horse, abs(bt.Board[ito]), 0);
            moves.insertBack(move);
        }
    }
}

public BitBoard AddBehindAttacks(BitBoard bb, int idirec, int ik)
{
    BitBoard bb_tmp = BitBoard(0L);
    switch (abs(idirec))
    {
    case Direction.Direc_Diag1_U2d:
        bb_tmp = ABB_Diag1_Attacks[ik][BitBoard(0L)];
        break;
    case Direction.Direc_Diag2_U2d:
        bb_tmp = ABB_Diag2_Attacks[ik][BitBoard(0L)];
        break;
    case Direction.Direc_File_U2d:
        bb_tmp = ABB_File_Attacks[ik][BitBoard(0L)];
        break;
    case Direction.Direc_Rank_L2r:
        bb_tmp = ABB_Rank_Attacks[ik][BitBoard(0L)];
        break;
    default:
        break;
    }
    bb_tmp = BB_Full & ~bb_tmp;
    return bb_tmp |= bb;
}
