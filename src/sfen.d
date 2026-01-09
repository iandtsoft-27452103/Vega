//import std.int128;
import board;
import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import common;
//import core.bitop;
//import bitop;
//import move;
import hash;

public string ToSFEN(BoardTree bt, int color)
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
    //BoardTree bt = board.Init();
    BoardTree bt;
    board.Clear(bt);
    Clear(bt);
    int int_pc = 0;
    string[] str_temp = str_sfen.split(' ');
    string str_board = str_temp[0];
    int limit = cast(int)str_board.length;
    int sq = 0;
    flag = false;
    for (int j = 0; j < limit; j++)
    {
        //char c = str_board[j];
        string s = str_board[j..j+1];
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
                    bt.BB_Empty ^= ABB_Mask[sq];
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
}
