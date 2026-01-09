//import std.int128;
//import std.stdio;
//import test;
import std.conv;
import std.array;
import std.algorithm;
import common;
import core.bitop;
import hash;
import bitop;
import move;

public BoardTree Init()
{
    BoardTree bt;
    int color = Color.Black;
    bt.BB_Piece[color][Piece.Pawn] = BitBoard(511L) << 18;
    bt.BB_Piece[color][Piece.Lance] = BitBoard(257L);
    bt.BB_Piece[color][Piece.Knight] = BitBoard(130L);
    bt.BB_Piece[color][Piece.Silver] = BitBoard(68L);
    bt.BB_Piece[color][Piece.Gold] = BitBoard(40L);
    bt.BB_Piece[color][Piece.Bishop] = BitBoard(65536L);
    bt.BB_Piece[color][Piece.Rook] = BitBoard(1024L);
    bt.BB_Piece[color][Piece.King] = BitBoard(16L);
    bt.BB_Occupied[color] = BitBoard((511L << 18) + (130L << 9) + 511L);
    color = Color.White;
    bt.BB_Piece[color][Piece.Pawn] = BitBoard(511L) << 54;
    bt.BB_Piece[color][Piece.Lance] = BitBoard(257L) << 72;
    bt.BB_Piece[color][Piece.Knight] = BitBoard(130L) << 72;
    bt.BB_Piece[color][Piece.Silver] = BitBoard(68L) << 72;
    bt.BB_Piece[color][Piece.Gold] = BitBoard(40L) << 72;
    bt.BB_Piece[color][Piece.Bishop] = BitBoard(1024L) << 54;
    bt.BB_Piece[color][Piece.Rook] = BitBoard(65536L) << 54;
    bt.BB_Piece[color][Piece.King] = BitBoard(16L) << 72;
    bt.BB_Occupied[color] = bt.BB_Occupied[color ^ 1] << 54;
    bt.BB_Empty = BB_Rank[1] | BB_Rank[3] | BB_Rank[4] | BB_Rank[5] | BB_Rank[7];
    bt.BB_Empty ^= (ABB_Mask[10] | ABB_Mask[16] | ABB_Mask[70] | ABB_Mask[64]);
    for (int i = 18; i < 27; i++)
    {
        bt.Board[i] = -Piece.Pawn;
    }
    bt.Board[0] = bt.Board[8] = -Piece.Lance;
    bt.Board[1] = bt.Board[7] = -Piece.Knight;
    bt.Board[2] = bt.Board[6] = -Piece.Silver;
    bt.Board[3] = bt.Board[5] = -Piece.Gold;
    bt.Board[16] = -Piece.Bishop;
    bt.Board[10] = -Piece.Rook;
    bt.Board[4] = -Piece.King;
    for (int i = 54; i < 63; i++)
    {
        bt.Board[i] = Piece.Pawn;
    }
    bt.Board[72] = bt.Board[80] = Piece.Lance;
    bt.Board[73] = bt.Board[79] = Piece.Knight;
    bt.Board[74] = bt.Board[78] = Piece.Silver;
    bt.Board[75] = bt.Board[77] = Piece.Gold;
    bt.Board[64] = Piece.Bishop;
    bt.Board[70] = Piece.Rook;
    bt.Board[76] = Piece.King;
    bt.Hand[0] = 0;
    bt.Hand[1] = 0;
    bt.CurrentHash = HashFunc(bt);
    bt.RootColor = Color.Black;
    bt.SQ_King[0] = 76;
    bt.SQ_King[1] = 4;
    bt.Ply = 1;
    bt.PrevHash = 0;
    bt.Hash[1] = bt.CurrentHash;
    bt.EvalArray[] = 0;
    return bt;
}

public void Clear(ref BoardTree bt)
{
    bt.BB_Occupied[0] = BitBoard(0L);
    bt.BB_Occupied[1] = BitBoard(0L);
    bt.BB_Empty = BitBoard(0L);
    for (int i = Color.Black; i < Color_NB; i++)
    {
        for (int j = Piece.Pawn; j < Piece_NB; j++)
        {
            bt.BB_Piece[i][j] = BitBoard(0L);
        }
    }
    bt.Hand[0] = bt.Hand[1] = 0;
    bt.CurrentHash = HashFunc(bt);
    bt.RootColor = Color.Black;
    bt.SQ_King[Color.Black] = 0;
    bt.SQ_King[Color.White] = 0;
    bt.Ply = 1;
    bt.PrevHash = 0;
    bt.EvalArray[] = 0;
}

// EvalArray is not implemented.
public BoardTree DeepCopy(BoardTree bt, bool flag)
{
    BoardTree bt_base;
    Clear(bt_base);
    for (int i = 0; i < Color_NB; i++)
    {
        bt_base.BB_Occupied[i] = bt.BB_Occupied[i];
        bt_base.SQ_King[i] = bt.SQ_King[i];
        for (int j = 0; j < Piece_NB; j++)
        {
            bt_base.BB_Piece[i][j] = bt.BB_Piece[i][j];
        }
        bt_base.Hand[0] = bt.Hand[0];
        bt_base.Hand[1] = bt.Hand[1];
    }
    bt_base.BB_Empty = bt.BB_Empty;

    bt_base.RootColor = bt.RootColor;
    bt_base.Ply = bt.Ply;
    bt_base.CurrentHash = bt.CurrentHash;
    bt_base.PrevHash = bt.PrevHash;

    for (int i = 0; i < Square_NB; i++)
    {
        bt_base.Board[i] = bt.Board[i];
    }

    for (int i = 0; i < Ply_Max; i++)
    {
        //if (i != 0 && bt.Hash[i] == 0) { break; }
        bt_base.Hash[i] = bt.Hash[i];
        bt_base.EvalArray[i] = bt.EvalArray[i];
    }

    if (flag)
    {
        bt_base.RootMoves[] = 0;
        for (int i = 0; i < Moves_Max; i++)
        {
            bt_base.RootMoves[i] = bt.RootMoves[i];
        }
    }
    return bt_base;
}

public void Do(ref BoardTree bt, uint m, int color)
{
    bt.PrevHash = bt.CurrentHash;
    int ifrom = from(m);
    int ito = to(m);
    int ipiece = piece(m);
    int is_promote = is_promo(m);
    if (ifrom >= Square_NB)
    {
        bt.BB_Piece[color][ipiece] ^= ABB_Mask[ito];
        bt.CurrentHash ^= PieceRand[color][ipiece][ito];
        bt.Hand[color] -= Hand_Hash[ipiece];
        bt.Board[ito] = -Sign_Table[color] * ipiece;
        bt.BB_Occupied[color] ^= ABB_Mask[ito];
        bt.BB_Empty ^= ABB_Mask[ito];
    }
    else
    {
        BitBoard bb_set_clear = ABB_Mask[ifrom] | ABB_Mask[ito];
        bt.BB_Occupied[color] ^= bb_set_clear;
        bt.Board[ifrom] = Piece.Empty;
        if (is_promote > 0)
        {
            bt.BB_Piece[color][ipiece] ^= ABB_Mask[ifrom];
            bt.BB_Piece[color][ipiece + Promote] ^= ABB_Mask[ito];
            bt.CurrentHash ^= PieceRand[color][ipiece][ifrom] ^ PieceRand[color][ipiece + Promote][ito];
            bt.Board[ito] = -Sign_Table[color] * (ipiece + Promote);
        }
        else
        {
            if (ipiece == Piece.King)
            {
                bt.SQ_King[color] = ito;
            }
            bt.BB_Piece[color][ipiece] ^= bb_set_clear;
            bt.CurrentHash ^= PieceRand[color][ipiece][ifrom] ^ PieceRand[color][ipiece][ito];
            bt.Board[ito] = -Sign_Table[color] * ipiece;
        }
        int icap_piece = cap_pc(m);
        int index = icap_piece;
        if (icap_piece > 0)
        {
            if (icap_piece > Piece.King)
            {
                index -= Promote;
            }
            bt.Hand[color] += Hand_Hash[index];
            bt.BB_Piece[color ^ 1][icap_piece] ^= ABB_Mask[ito];
            bt.CurrentHash ^= PieceRand[color ^ 1][icap_piece][ito];
            bt.BB_Occupied[color ^ 1] ^= ABB_Mask[ito];
            bt.BB_Empty ^= ABB_Mask[ifrom];
        }
        else
        {
            bt.BB_Empty ^= bb_set_clear;
        }
    }
    bt.Hash[bt.Ply] = bt.PrevHash;
    bt.Hash[bt.Ply + 1] = bt.CurrentHash;
    bt.Ply += 1;
}

public void UnDo(ref BoardTree bt, uint m, int color)
{
    bt.CurrentHash = bt.PrevHash;
    int ifrom = from(m);
    int ito = to(m);
    int ipiece = piece(m);
    int is_promote = is_promo(m);
    if (ifrom >= Square_NB)
    {
        bt.BB_Piece[color][ipiece] ^= ABB_Mask[ito];
        bt.Hand[color] += Hand_Hash[ipiece];
        bt.Board[ito] = Piece.Empty;
        bt.BB_Occupied[color] ^= ABB_Mask[ito];
        bt.BB_Empty ^= ABB_Mask[ito];
    }
    else
    {
        BitBoard bb_set_clear = ABB_Mask[ifrom] | ABB_Mask[ito];
        bt.BB_Occupied[color] ^= bb_set_clear;
        bt.Board[ifrom] = -Sign_Table[color] * ipiece;
        if (is_promote > 0)
        {
            bt.BB_Piece[color][ipiece] ^= ABB_Mask[ifrom];
            bt.BB_Piece[color][ipiece + Promote] ^= ABB_Mask[ito];
        }
        else
        {
            if (ipiece == Piece.King)
            {
                bt.SQ_King[color] = ifrom;
            }
            bt.BB_Piece[color][ipiece] ^= bb_set_clear;
        }
        int icap_piece = cap_pc(m);
        int index = icap_piece;
        if (icap_piece > 0)
        {
            if (icap_piece > Piece.King)
            {
                index -= Promote;
            }
            bt.Hand[color] -= Hand_Hash[index];
            bt.BB_Piece[color ^ 1][icap_piece] ^= ABB_Mask[ito];
            bt.BB_Occupied[color ^ 1] ^= ABB_Mask[ito];
            bt.Board[ito] = Sign_Table[color] * icap_piece;
            bt.BB_Empty ^= ABB_Mask[ifrom];
        }
        else
        {
            bt.Board[ito] = Piece.Empty;
            bt.BB_Empty ^= bb_set_clear;
        }
    }
    bt.PrevHash = bt.Hash[bt.Ply - 2];
    bt.Hash[bt.Ply] = 0;
    bt.Ply -= 1;
}

public void DoNull(ref BoardTree bt)
{
    bt.Hash[bt.Ply + 1] = bt.CurrentHash;
    bt.Ply += 1;
}

public void UnDoNull(ref BoardTree bt)
{
    bt.Hash[bt.Ply] = 0;
    bt.Ply -= 1;
}

// return value
// 0: This position is not the positon of declaration win.
// 1: The winner is black.
// 2: The winner is white.
public int IsDeclarationWin(BoardTree bt)
{
    int black_score = 0;
    int white_score = 0;
    int b_tekijin_piece_count = 0;
    int w_tekijin_piece_count = 0;
    int[Piece.Rook + 1] b_hand_piece_count = [0,0,0,0,0,0,0,0];
    int[Piece.Rook + 1] w_hand_piece_count = [0,0,0,0,0,0,0,0];
    int[Piece_NB] b_board_piece_count = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    int[Piece_NB] w_board_piece_count = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    BitBoard bb0 = bt.BB_Piece[Color.Black][Piece.King] & BB_White_Position;
    BitBoard bb1 = bt.BB_Piece[Color.White][Piece.King] & BB_Black_Position;
    if (bb0 == 0L && bb1 == 0L)
    {
        return 0;
    }
    if (bb0 > 0L)
    {
        for (int i = Piece.Pawn; i <= Piece.Rook; i++)
        {
            b_hand_piece_count[i] = (bt.Hand[Color.Black] & Hand_Mask[i]) >> Hand_Rev_Bit[i];
            if (i >= Piece.Bishop)
            {
                black_score += 5 * b_hand_piece_count[i];
            }
            else
            {
                black_score += b_hand_piece_count[i];
            }
        }
        for (int i = Piece.Pawn; i <= Piece.Dragon; i++)
        {
            if (i == Piece.None)
                continue;
            BitBoard bb_object = bt.BB_Piece[Color.Black][i] & BB_Rev_Color_Position[Color.Black];
            b_board_piece_count[i] = PopCount(bb_object);
            b_tekijin_piece_count += b_board_piece_count[i];
            BitBoard bb_temp = BB_DMZ | BB_Rev_Color_Position[Color.White];
            bb_object = bb_temp & bt.BB_Piece[Color.Black][i];
            b_board_piece_count[i] += PopCount(bb_object);
            if (i == Piece.King)
                continue;
            if (i == Piece.Bishop || i == Piece.Rook || i >= Piece.Horse)
            {
                black_score += 5 * b_board_piece_count[i];
            }
            else
            {
                black_score += b_board_piece_count[i];
            }
        }
    }
    if (bb1 > 0L)
    {
        for (int i = Piece.Pawn; i <= Piece.Rook; i++)
        {
            w_hand_piece_count[i] = (bt.Hand[Color.White] & Hand_Mask[i]) >> Hand_Rev_Bit[i];
            if (i >= Piece.Bishop)
            {
                white_score += 5 * w_hand_piece_count[i];
            }
            else
            {
                white_score += w_hand_piece_count[i];
            }
        }
        for (int i = Piece.Pawn; i <= Piece.Dragon; i++)
        {
            if (i == Piece.None)
                continue;
            BitBoard bb_object = bt.BB_Piece[Color.White][i] & BB_Rev_Color_Position[Color.White];
            w_board_piece_count[i] = PopCount(bb_object);
            w_tekijin_piece_count += w_board_piece_count[i];
            BitBoard bb_temp = BB_DMZ | BB_Rev_Color_Position[Color.Black];
            bb_object = bb_temp & bt.BB_Piece[Color.White][i];
            w_board_piece_count[i] += PopCount(bb_object);
            if (i == Piece.King)
                continue;
            if (i == Piece.Bishop || i == Piece.Rook || i >= Piece.Horse)
            {
                white_score += 5 * w_board_piece_count[i];
            }
            else
            {
                white_score += w_board_piece_count[i];
            }
        }
    }
    if (bb0 > 0L && black_score >= 28 && b_tekijin_piece_count >= 10)
        return 1;
    if (bb1 > 0L && white_score >= 27 && w_tekijin_piece_count >= 10)
        return 2;
    return 0;
}

public int IsRepetition(BoardTree bt, TT tt)
{
    int limit = bt.Ply - 12;
    if (limit < 1)
        return 0;
    int counter = 0;
    int i = bt.Ply;
    while (i >= limit)
    {
        if (bt.CurrentHash == bt.Hash[i])
            counter++;
        i--;
    }
    if (counter > 2)
    {
        if (bt.CurrentHash in tt.is_check)
        {
            bool b = tt.is_check[bt.CurrentHash];
            if (!b)
            {
                return 1;// normal repetition -> the game is draw.
            }
            else
            {
                return 2;// repetition with succession of check -> offence side is a loser.
            }
        }
    }
    return 0;
}

/*public string ToSFEN(BoardTree bt, int color)
{
    char[] str_sfen;
    bool flag = false;
    int i = 0;
    int empty_count = 0;

    while (i < Square_NB)
    {
        string str_piece = Str_SFEN_Pc[bt.Board[i]];
        if (str_piece == "")
        {
            empty_count++;
            flag = true;
        }
        else
        {
            if (flag == true)
            {
                flag = false;
                str_sfen ~= to!string(empty_count);
                empty_count = 0;
            }
            str_sfen ~= str_piece;
        }
        if (i != (Square_NB - 1) && FileTable[i] == common.File.File9)
        {
            if (empty_count > 0)
            {
                flag = false;
                str_sfen ~= to!string(empty_count);
                empty_count = 0;
            }
            str_sfen ~= "/";
        }
        i++;
    }

    str_sfen ~= " ";
    str_sfen ~= Str_Color[color];
    str_sfen ~= " ";

    int k = 0;
    if (bt.Hand[Color.Black] == 0 && bt.Hand[Color.White] == 0)
    {
        str_sfen ~= "-";
    }
    else
    {
        for (i = Color.Black; i < Color_NB; i++)
        {
            for (int j = Piece.Rook; j >= Piece.Pawn; j--)
            {
                int num = (bt.Hand[i] & Hand_Mask[j]) >> Hand_Rev_Bit[j];
                if (num == 0)
                    continue;
                if (num > 0)
                {
                    if (num == 1)
                    {
                        k = -Sign_Table[i] * j;
                        str_sfen ~= Str_SFEN_Pc[k];
                    }
                    else if (num > 1)
                    {
                        k = -Sign_Table[i] * j;
                        str_sfen ~= to!string(num) ~ Str_SFEN_Pc[k];
                    }
                }
            }
        }
    }

    str_sfen ~= " 1";
    return str_sfen.idup;
}

public BoardTree ToBoard(string str_sfen)
{
    bool flag;
    BoardTree bt = board.Init();
    Clear(bt);
    int int_pc = 0;
    string[] str_temp = str_sfen.split(' ');
    string str_board = str_temp[0];
    int limit = cast(int)str_board.length;
    int sq = 0;
    for (int j = 0; j < limit; j++)
    {
        //char c = str_board[j];
        string s = str_board[j..j+1];
        flag = false;
        if (s == "+")
        {
            flag = true;
        }
        else if (s == "/")
        {
            continue;
        }
        else
        {
            if (Set_Empty_Num.canFind(s))
            {
                int empty_num = Int_Empty_Num[s];
                int k = 0;
                while (k < empty_num)
                {
                    bt.Board[sq] = Piece.Empty;
                    sq++;
                    k++;
                }
            }
            else
            {
                int_pc = Int_Pc[s];
                if (int_pc > 0)
                {
                    if (flag == true)
                    {
                        int_pc += Promote;
                        flag = false;
                    }
                    bt.BB_Piece[Color.Black][int_pc] |= ABB_Mask[sq];
                    bt.BB_Occupied[Color.Black] |= ABB_Mask[sq];
                    if (int_pc == Piece.King)
                    {
                        bt.SQ_King[Color.Black] = sq;
                    }
                }
                else
                {
                    if (flag == true)
                    {
                        int_pc -= Promote;
                        flag = false;
                    }
                    bt.BB_Piece[Color.White][-int_pc] |= ABB_Mask[sq];
                    bt.BB_Occupied[Color.White] |= ABB_Mask[sq];
                    if (int_pc == -Piece.King)
                    {
                        bt.SQ_King[Color.White] = sq;
                    }
                }
                bt.Board[sq] = int_pc;
                sq += 1;
            }
        }
    }
    string str_color = str_temp[1];
    bt.RootColor = Num_Color[str_color];
    string str_hand = str_temp[2];
    limit = cast(int)str_hand.length;
    flag = false;
    int num = 1;
    int color = 0;
    for (int j = 0; j < limit; j++)
    {
        string s = str_hand[j..j+1];
        if (s == "-")
            break;
        if (s == "1" && !flag)
        {
            flag = true;
        }
        else
        {
            if (flag)
            {
                num = 10 + Int_Hand_Num[s];
                flag = false;
            }
            else
            {
                if (Set_Hand_Num.canFind(s))
                {
                    num = Int_Hand_Num[s];
                }
                else
                {
                    int_pc = Int_Pc[s];
                    if (int_pc > 0)
                    {
                        color = Color.Black;
                    }
                    else
                    {
                        color = Color.White;
                        int_pc = -int_pc;
                    }
                    int k = 0;
                    while (k < num)
                    {
                        bt.Hand[color] += Hand_Hash[int_pc];
                        k++;
                    }
                    num = 1;
                }
            }
        }
    }
    bt.CurrentHash = HashFunc(bt);
    bt.Hash[0] = bt.PrevHash;
    bt.Hash[1] = bt.CurrentHash;
    bt.Ply = 1;
    return bt;
}*/
