import std.stdio;
import std.file;
import std.encoding;
import std.utf;
import std.array;
import std.algorithm;
import std.algorithm.searching;
import std.container.array;
import std.string;
import std.stdio;
import std.conv;
import common;
import bitop;
import board;
import csa;
import genmoves;
import hash;
import mate1ply;
import move;
import sfen;
import io;

public void TestGenDrop()
{
    auto f_data = std.stdio.File("test_data_drop.txt", "r");
    //Array!string data;
    int c = 0;
    foreach (line; f_data.byLine()) {
        //writeln("Line: ", line.idup);
        auto line2 = toUTF8(line);
        if (c == 1)
        {
            auto str_sfen = line2;
            Array!Move moves;
            BoardTree bt = ToBoard(str_sfen);
            //writeln(bt.BB_Empty);
            GenDrop(bt, bt.RootColor, moves);
            auto l = moves.length;
            string s = "moves_count" ~ to!string(l);
            char[] str_moves;
            for (int i = 0; i < l; i++)
            {
                auto str_move = Move2CSA(moves[i]);
                str_moves ~= str_move;
                str_moves ~= " ";
            }
            writeln(str_moves);
            writeln(s);
        }
        c ^= 1;
    }
}

public void TestGenNoCap()
{
    auto f_data = std.stdio.File("test_data_gennocap.txt", "r");
    //Array!string data;
    int c = 0;
    foreach (line; f_data.byLine()) {
        //writeln("Line: ", line.idup);
        auto line2 = toUTF8(line);
        if (c == 1)
        {
            auto str_sfen = line2;
            Array!Move moves;
            BoardTree bt = ToBoard(str_sfen);
            //writeln("aho");
            //writeln(bt.Board[29]);
            //writeln(bt.BB_Empty);
            GenNoCap(bt, bt.RootColor, moves);
            auto l = moves.length;
            string s = "moves_count" ~ to!string(l);
            char[] str_moves;
            for (int i = 0; i < l; i++)
            {
                auto str_move = Move2CSA(moves[i]);
                str_moves ~= str_move;
                str_moves ~= " ";
            }
            writeln(str_moves);
            writeln(s);
        }
        c ^= 1;
    }
}

public void TestGenCap()
{
    auto f_data = std.stdio.File("test_data_gencap.txt", "r");
    //Array!string data;
    int c = 0;
    foreach (line; f_data.byLine()) {
        //writeln("Line: ", line.idup);
        auto line2 = toUTF8(line);
        if (c == 1)
        {
            auto str_sfen = line2;
            Array!Move moves;
            BoardTree bt = ToBoard(str_sfen);
            //writeln("aho");
            //writeln(bt.Board[29]);
            //writeln(bt.BB_Empty);
            GenCap(bt, bt.RootColor, moves);
            auto l = moves.length;
            string s = "moves_count" ~ to!string(l);
            char[] str_moves;
            for (int i = 0; i < l; i++)
            {
                auto str_move = Move2CSA(moves[i]);
                str_moves ~= str_move;
                str_moves ~= " ";
            }
            writeln(str_moves);
            writeln(s);
        }
        c ^= 1;
    }
}

public void TestGenEvasion()
{
    auto f_data = std.stdio.File("test_data_evasion.txt", "r");
    //Array!string data;
    int c = 0;
    foreach (line; f_data.byLine()) {
        //writeln("Line: ", line.idup);
        auto line2 = toUTF8(line);
        if (c == 1)
        {
            auto str_sfen = line2;
            Array!Move moves;
            BoardTree bt = ToBoard(str_sfen);
            //writeln("aho");
            //writeln(bt.Board[29]);
            //writeln(bt.BB_Empty);
            GenEvasion(bt, bt.RootColor, moves);
            auto l = moves.length;
            string s = "moves_count" ~ to!string(l);
            char[] str_moves;
            for (int i = 0; i < l; i++)
            {
                auto str_move = Move2CSA(moves[i]);
                str_moves ~= str_move;
                str_moves ~= " ";
            }
            writeln(str_moves);
            writeln("\n");
            if (str_sfen == "4k4/9/9/9/9/9/3n5/2G6/4K4 b - 1")
            {
                //break;
            }
        }
        c ^= 1;
    }
}

public void TestGenCheck()
{
    auto f_data = std.stdio.File("test_data_check.txt", "r");
    //Array!string data;
    int c = 0;
    foreach (line; f_data.byLine()) {
        //writeln("Line: ", line.idup);
        auto line2 = toUTF8(line);
        if (c == 1)
        {
            auto str_sfen = line2;
            Array!Move moves;
            BoardTree bt = ToBoard(str_sfen);
            //writeln("aho");
            //writeln(bt.Board[29]);
            //writeln(bt.BB_Empty);
            GenCheck(bt, bt.RootColor, moves);
            auto l = moves.length;
            string s = "moves_count" ~ to!string(l);
            char[] str_moves;
            for (int i = 0; i < l; i++)
            {
                auto str_move = Move2CSA(moves[i]);
                str_moves ~= str_move;
                str_moves ~= " ";
            }
            writeln(str_moves);
            writeln(s);
        }
        c ^= 1;
    }
}

public void TestGenCheck2()
{
    auto f_data = std.stdio.File("test_data_b_check_additional.txt", "r");
    //Array!string data;
    int c = 0;
    foreach (line; f_data.byLine()) {
        //writeln("Line: ", line.idup);
        auto line2 = toUTF8(line);
        if (c == 1)
        {
            auto str_sfen = line2;
            Array!Move moves;
            BoardTree bt = ToBoard(str_sfen);
            //writeln("aho");
            //writeln(bt.Board[29]);
            //writeln(bt.BB_Empty);
            GenCheck(bt, bt.RootColor, moves);
            auto l = moves.length;
            string s = "moves_count" ~ to!string(l);
            char[] str_moves;
            for (int i = 0; i < l; i++)
            {
                auto str_move = Move2CSA(moves[i]);
                str_moves ~= str_move;
                str_moves ~= " ";
            }
            writeln(str_moves);
            writeln(s);
        }
        c ^= 1;
    }
}

public void TestGenCheck3()
{
    auto f_data = std.stdio.File("test_data_w_check_additional.txt", "r");
    //Array!string data;
    int c = 0;
    foreach (line; f_data.byLine()) {
        //writeln("Line: ", line.idup);
        auto line2 = toUTF8(line);
        if (c == 1)
        {
            auto str_sfen = line2;
            Array!Move moves;
            BoardTree bt = ToBoard(str_sfen);
            //writeln("aho");
            //writeln(bt.Board[29]);
            //writeln(bt.BB_Empty);
            GenCheck(bt, bt.RootColor, moves);
            auto l = moves.length;
            string s = "moves_count" ~ to!string(l);
            char[] str_moves;
            for (int i = 0; i < l; i++)
            {
                auto str_move = Move2CSA(moves[i]);
                str_moves ~= str_move;
                str_moves ~= " ";
            }
            writeln(str_moves);
            writeln(s);
        }
        c ^= 1;
    }
}

public void TestMate1Ply()
{
    auto f_data = std.stdio.File("test_data_b_mate1ply.txt", "r");
    //Array!string data;
    int c = 0;
    int counter = 0;
    writeln(Piece_Table);
    foreach (line; f_data.byLine()) {
        //writeln("Line: ", line.idup);
        auto line2 = toUTF8(line);
        if (c == 1)
        {
            auto str_sfen = line2;
            BoardTree bt = ToBoard(str_sfen);
            //writeln("aho");
            //writeln(bt.Board[29]);
            //writeln(bt.BB_Empty);
            Move mate_move = MateIn1Ply(bt, bt.RootColor);
            if (mate_move != 0)
            {
                auto str_mate_move = Move2CSA(mate_move);
                writeln("Mate");
                writeln(str_mate_move);
            }
            else
            {
                writeln("No Mate");
            }
            writeln("");
        }
        c ^= 1;
        counter++;
        if (counter == 2)
        {
            //break;
        }
    }
}

public void TestMate1Ply2()
{
    auto f_data = std.stdio.File("test_data_w_mate1ply.txt", "r");
    //Array!string data;
    int c = 0;
    foreach (line; f_data.byLine()) {
        //writeln("Line: ", line.idup);
        auto line2 = toUTF8(line);
        if (c == 1)
        {
            auto str_sfen = line2;
            BoardTree bt = ToBoard(str_sfen);
            //writeln("aho");
            //writeln(bt.Board[29]);
            //writeln(bt.BB_Empty);
            Move mate_move = MateIn1Ply(bt, bt.RootColor);
            if (mate_move != 0)
            {
                auto str_mate_move = Move2CSA(mate_move);
                writeln("Mate");
                writeln(str_mate_move);
            }
            else
            {
                writeln("No Mate");
            }
            writeln("");
        }
        c ^= 1;
    }
}

public void TestDeclarationWin()
{
    auto f_data = std.stdio.File("test_data_declaration_win.txt", "r");
    //Array!string data;
    //writeln("ikebukuro");
    int c = 0;
    foreach (line; f_data.byLine()) {
        //writeln("Line: ", line.idup);
        auto line2 = toUTF8(line);
        if (c == 1)
        {
            auto str_sfen = line2;
            BoardTree bt = ToBoard(str_sfen);
            auto iret = IsDeclarationWin(bt);
            writeln(iret);
            writeln("");
        }
        c ^= 1;
    }
}

public void TestRepetition()
{
    auto rs = ReadRecords("test_repetition.txt");
    auto limit = rs[0].str_moves.length;
    auto bt = board.Init();
    writeln(limit);
    TT tt;
    int color = 0;
    for (int i = 0; i < limit; i++)
    {
        auto str_move = rs[0].str_moves[i];
        auto move = CSA2Move(bt, str_move);
        //writeln(move);
        //return;
        Do(bt, move, color);
        tt.is_check[bt.CurrentHash] = false;
        //writeln(bt.CurrentHash);
        color ^= 1;
    }
    auto iret = IsRepetition(bt, tt);
    //writeln(bt.Hash);
    //writeln("iret");
    writeln(iret);
}

public void TestDo()
{
    auto rs = ReadRecords("20220403_nhk_hai.txt");
    auto limit = rs[0].str_moves.length;
    auto bt = board.Init();
    writeln(limit);
    int color = 0;
    //limit = 0;
    for (int i = 0; i < limit; i++)
    {
        auto str_move = rs[0].str_moves[i];
        writeln(str_move);
        auto move = CSA2Move(bt, str_move);
        Do(bt, move, color);
        color ^= 1;
    }
    OutBoard(bt);
}

public void TestUnDo()
{
    auto rs = ReadRecords("20220410_nhk_hai.txt");
    auto limit = rs[0].str_moves.length;
    auto bt = board.Init();
    writeln(limit);
    int color = 0;
    for (int i = 0; i < limit; i++)
    {
        auto str_move = rs[0].str_moves[i];
        writeln(str_move);
        auto move = CSA2Move(bt, str_move);
        auto bt_copy = DeepCopy(bt, false);
        if (i == 45) { writeln(bt.Ply);}
        Do(bt, move, color);
        if (i == 45) { writeln(bt.Ply);}
        UnDo(bt, move, color);
        if (i == 45) { writeln(bt.Ply);}
        writeln("baka");
        auto b = VerifyBoard(bt_copy, bt);
        if (b)
        {
            char[] s;
            s ~= "error in ply";
            s ~= to!string(i + 1);
            write(s);
            break;
        }
        Do(bt, move, color);
        color ^= 1;
    }
}

private bool VerifyBoard(BoardTree bt_before, BoardTree bt_after)
{
    for (int c = 0; c < Color_NB; c++)
    {
        for (int pc = Piece.Pawn; pc <= Piece.Dragon; pc++)
        {
            if (bt_before.BB_Piece[c][pc] != bt_after.BB_Piece[c][pc])
            {
                writeln("Error In BB_Piece");
                writeln("c=");
                writeln(c);
                writeln("pc=");
                writeln(pc);
                return true;
            }
        }
    }

    if (bt_before.BB_Empty != bt_after.BB_Empty)
    {
        writeln("Error In BB_Empty");
        return true;
    }

    for (int sq = 0; sq < Square_NB; sq++)
    {
        if (bt_before.Board[sq] != bt_after.Board[sq])
        {
            writeln("Error In Board");
            writeln("sq=");
            writeln(sq);
            return true;
        }
    }
    for (int c = 0; c < Color_NB; c++)
    {
        if (bt_before.Hand[c] != bt_after.Hand[c])
        {
            writeln("Error In Hand");
            writeln("c=");
            writeln(c);
            return true;
        }
    }

    if (bt_before.CurrentHash != bt_after.CurrentHash)
    {
        writeln("Error In CurrentHash");
        return true;
    }

    if (bt_before.RootColor != bt_after.RootColor)
    {
        writeln("Error In RootColor");
        return true;
    }

    for (int c = 0; c < Color_NB; c++)
    {
        if (bt_before.SQ_King[c] != bt_after.SQ_King[c])
        {
            writeln("Error In SQ_King");
            writeln("c=");
            writeln(c);
            return true;
        }
    }

    if (bt_before.PrevHash != bt_after.PrevHash)
    {
        writeln("Error In PrevHash");
        writeln(to!string(bt_before.PrevHash));
        writeln();
        writeln(to!string(bt_after.PrevHash));
        writeln();
        writeln(to!string(bt_before.Ply));
        writeln();
        writeln(to!string(bt_after.Ply));
        //writeln(bt_before.Hash);
        //writeln(bt_after.Hash);
        return true;
    }

    if (bt_before.Ply != bt_after.Ply)
    {
        writeln("Error In Ply");
        return true;
    }

    for (int ply = 0; ply < Ply_Max; ply++)
    {
        if (bt_before.Hash[ply] != bt_after.Hash[ply])
        {
            writeln("Error In Hash");
            writeln("ply=");
            writeln(ply);
            return true;
        }
    }

    return false;
}

private void OutBoard(BoardTree bt)
{
    writeln("BitBoard");
    for (int c = 0; c < Color_NB; c++)
    {
        if (c == 0)
        {
            writeln("black");
        }
        else
        {
            writeln("white");
        }
        for (int pc = Piece.Pawn; pc <= Piece.Dragon; pc++)
        {
            if (pc == Piece.None)
            {
                continue;
            }
            auto bb = bt.BB_Piece[c][pc];
            char[] s;
            s ~= Str_Piece[pc];
            s ~= ": ";
            while (bb > BitBoard(0L))
            {
                int sq = Square(bb);
                s ~= to!string(sq);
                s ~= ",";
                bb ^= ABB_Mask[sq];
            }
            writeln(s);
        }
    }
    writeln("Board Array");
    for (int sq = 0; sq < Square_NB; sq++)
    {
        char[] s0;
        auto pc = bt.Board[sq];
        if (pc > 0)
        {
            s0 ~= to!string(sq);
            s0 ~= ": ";
            s0 ~= "black-";
            s0 ~= Str_Piece[pc];
        }
        else if (pc < 0)
        {
            s0 ~= to!string(sq);
            s0 ~= ": ";
            s0 ~= "white-";
            s0 ~= Str_Piece[-pc];
        }
        else
        {
            s0 ~= to!string(sq);
            s0 ~= ": ";
            s0 ~= "empty";
        }
        writeln(s0);
    }

    writeln("King's Position");
    writeln("Black King");
    writeln(to!string(bt.SQ_King[0]));
    writeln();
    writeln("White King");
    writeln(to!string(bt.SQ_King[1]));
    writeln();

    writeln("Empty Bitboard");
    auto bb_empty = bt.BB_Empty;
    char[] s1;
    while (bb_empty > BitBoard(0L))
    {
        int sq = Square(bb_empty);
        s1 ~= to!string(sq);
        s1 ~= "\n";
        bb_empty ^= ABB_Mask[sq];
    }
    writeln(s1);

    writeln("Black Occupied BitBoard");
    BitBoard bb_occupied = bt.BB_Occupied[0];
    char[] s2;
    while (bb_occupied > BitBoard(0L))
    {
        int sq = Square(bb_occupied);
        s2 ~= to!string(sq);
        s2 ~= "\n";
        bb_occupied ^= ABB_Mask[sq];
    }
    writeln(s2);

    writeln("White Occupied BitBoard");
    bb_occupied = bt.BB_Occupied[1];
    char[] s3;
    while (bb_occupied > BitBoard(0L))
    {
        int sq = Square(bb_occupied);
        s3 ~= to!string(sq);
        s3 ~= "\n";
        bb_occupied ^= ABB_Mask[sq];
    }
    writeln(s3);

    writeln("Black Hand");
    writeln();
    for (int pc = Piece.Pawn; pc <= Piece.Rook; pc++)
    {
        char[] s4;
        int n_hand = (bt.Hand[0] & Hand_Mask[pc]) >> Hand_Rev_Bit[pc];
        s4 ~= "black-";
        s4 ~= Str_Piece[pc];
        s4 ~= to!string(n_hand);
        s4 ~= "\n";
        writeln(s4);
    }

    writeln("White Hand");
    writeln();
    for (int pc = Piece.Pawn; pc <= Piece.Rook; pc++)
    {
        char[] s5;
        int n_hand = (bt.Hand[1] & Hand_Mask[pc]) >> Hand_Rev_Bit[pc];
        s5 ~= "white-";
        s5 ~= Str_Piece[pc];
        s5 ~= to!string(n_hand);
        s5 ~= "\n";
        writeln(s5);
    }
}
