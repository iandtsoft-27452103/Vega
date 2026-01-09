import common;
import std.int128;
import std.conv;
import std.stdio;
import std.string;
import core.stdc.stdint;

int[9] a = [Piece.Silver, Piece.Gold, Piece.Bishop, Piece.Pro_Pawn, Piece.Pro_Lance, Piece.Pro_Knight, Piece.Pro_Silver, Piece.Horse, Piece.Dragon];
int[11] b = [Piece.Pawn, Piece.Lance, Piece.Silver, Piece.Gold, Piece.Rook, Piece.Pro_Pawn, Piece.Pro_Lance, Piece.Pro_Knight, Piece.Pro_Silver, Piece.Horse, Piece.Dragon];
int[8] c = [Piece.Gold, Piece.Rook, Piece.Pro_Pawn, Piece.Pro_Lance, Piece.Pro_Knight, Piece.Pro_Silver, Piece.Horse, Piece.Dragon];
int[4] d = [Piece.Silver, Piece.Bishop, Piece.Horse, Piece.Dragon];

public void Init()
{
    Piece_Table[0][Direction.Direc_Diag2_U2d] = a;
    Piece_Table[0][Direction.Direc_File_U2d] = b;
    Piece_Table[0][Direction.Direc_Diag1_U2d] = a;
    Piece_Table[0][Direction.Direc_Rank_L2r] = c;
    Piece_Table[0][Direction.Direc_Rank_R2l] = c;
    Piece_Table[0][Direction.Direc_Diag1_D2u] = d;
    Piece_Table[0][Direction.Direc_File_D2u] = c;
    Piece_Table[0][Direction.Direc_Diag2_D2u] = d;
    Piece_Table[1][Direction.Direc_Diag2_U2d] = d;
    Piece_Table[1][Direction.Direc_File_U2d] = c;
    Piece_Table[1][Direction.Direc_Diag1_U2d] = d;
    Piece_Table[1][Direction.Direc_Rank_L2r] = c;
    Piece_Table[1][Direction.Direc_Rank_R2l] = c;
    Piece_Table[1][Direction.Direc_Diag1_D2u] = a;
    Piece_Table[1][Direction.Direc_File_D2u] = b;
    Piece_Table[1][Direction.Direc_Diag2_D2u] = a;
    //Piece_Table[1][0] = b;

    /*BitBoard bb = 0L;
    BitBoard bb0 = 131328L;
    BitBoard bb1 = 67240192L;
    BitBoard bb2 = 67240192L;
    bb0 = shr(bb, 54);
    bb0 = bb0 << 54;
    bb1 = bb1 << 27;
    bb = bb0 | bb1 | bb2;
    //writeln(bb);
    BitBoard bb100 = BitBoard(525314L) << 54;
    string s = "67240192";
    long aaa = to!ulong(s);
    BitBoard bb111 = BitBoard(aaa);*/

    auto file = std.stdio.File("abb_file_attacks_conv.txt", "r");
    foreach (line; file.byLine()) {
        auto result = split(line, ",");
        int sq = to!int(result[0]);
        sq = sq - 1;
        ulong h0 = to!ulong(result[1]);
        ulong h1 = to!ulong(result[2]);
        ulong h2 = to!ulong(result[3]);
        BitBoard h = BitBoard(h0) << 54 | BitBoard(h1) << 27 | BitBoard(h2);
        ulong v0 = to!ulong(result[4]);
        ulong v1 = to!ulong(result[5]);
        ulong v2 = to!ulong(result[6]);
        BitBoard v = BitBoard(v0) << 54 | BitBoard(v1) << 27 | BitBoard(v2);
        ABB_File_Attacks[sq][h] = v;
        /*writeln(h);
        writeln(h0);
        writeln(h1);
        writeln(h2);
        break;*/
    }

    //return;

    auto file2 = std.stdio.File("abb_file_mask_ex_conv.txt", "r");
    foreach (line; file2.byLine()) {
        auto result = split(line, ",");
        int sq = to!int(result[0]);
        sq = sq - 1;
        ulong v0 = to!ulong(result[1]);
        ulong v1 = to!ulong(result[2]);
        ulong v2 = to!ulong(result[3]);
        BitBoard v = BitBoard(v0) << 54 | BitBoard(v1) << 27 | BitBoard(v2);
        ABB_File_Mask_Ex[sq] = v;
        //writeln(h);
    }

    auto file3 = std.stdio.File("abb_rank_attacks_conv.txt", "r");
    foreach (line; file3.byLine()) {
        auto result = split(line, ",");
        int sq = to!int(result[0]);
        sq = sq - 1;
        ulong h0 = to!ulong(result[1]);
        ulong h1 = to!ulong(result[2]);
        ulong h2 = to!ulong(result[3]);
        BitBoard h = BitBoard(h0) << 54 | BitBoard(h1) << 27 | BitBoard(h2);
        ulong v0 = to!ulong(result[4]);
        ulong v1 = to!ulong(result[5]);
        ulong v2 = to!ulong(result[6]);
        BitBoard v = BitBoard(v0) << 54 | BitBoard(v1) << 27 | BitBoard(v2);
        ABB_Rank_Attacks[sq][h] = v;
        //writeln(h);
    }

    auto file4 = std.stdio.File("abb_rank_mask_ex_conv.txt", "r");
    foreach (line; file4.byLine()) {
        auto result = split(line, ",");
        int sq = to!int(result[0]);
        sq = sq - 1;
        ulong v0 = to!ulong(result[1]);
        ulong v1 = to!ulong(result[2]);
        ulong v2 = to!ulong(result[3]);
        BitBoard v = BitBoard(v0) << 54 | BitBoard(v1) << 27 | BitBoard(v2);
        ABB_Rank_Mask_Ex[sq] = v;
        //writeln(h);
    }

    auto file5 = std.stdio.File("abb_diag1_attacks_conv.txt", "r");
    foreach (line; file5.byLine()) {
        auto result = split(line, ",");
        int sq = to!int(result[0]);
        sq = sq - 1;
        ulong h0 = to!ulong(result[1]);
        ulong h1 = to!ulong(result[2]);
        ulong h2 = to!ulong(result[3]);
        BitBoard h = BitBoard(h0) << 54 | BitBoard(h1) << 27 | BitBoard(h2);
        ulong v0 = to!ulong(result[4]);
        ulong v1 = to!ulong(result[5]);
        ulong v2 = to!ulong(result[6]);
        BitBoard v = BitBoard(v0) << 54 | BitBoard(v1) << 27 | BitBoard(v2);
        ABB_Diag1_Attacks[sq][h] = v;
        //writeln(h);
    }

    auto file6 = std.stdio.File("abb_diag1_mask_ex_conv.txt", "r");
    foreach (line; file6.byLine()) {
        auto result = split(line, ",");
        int sq = to!int(result[0]);
        sq = sq - 1;
        ulong v0 = to!ulong(result[1]);
        ulong v1 = to!ulong(result[2]);
        ulong v2 = to!ulong(result[3]);
        BitBoard v = BitBoard(v0) << 54 | BitBoard(v1) << 27 | BitBoard(v2);
        ABB_Diag1_Mask_Ex[sq] = v;
        //writeln(h);
    }

    auto file7 = std.stdio.File("abb_diag2_attacks_conv.txt", "r");
    foreach (line; file7.byLine()) {
        auto result = split(line, ",");
        int sq = to!int(result[0]);
        sq = sq - 1;
        ulong h0 = to!ulong(result[1]);
        ulong h1 = to!ulong(result[2]);
        ulong h2 = to!ulong(result[3]);
        BitBoard h = BitBoard(h0) << 54 | BitBoard(h1) << 27 | BitBoard(h2);
        ulong v0 = to!ulong(result[4]);
        ulong v1 = to!ulong(result[5]);
        ulong v2 = to!ulong(result[6]);
        BitBoard v = BitBoard(v0) << 54 | BitBoard(v1) << 27 | BitBoard(v2);
        ABB_Diag2_Attacks[sq][h] = v;
        //writeln(h);
    }

    auto file8 = std.stdio.File("abb_diag2_mask_ex_conv.txt", "r");
    foreach (line; file8.byLine()) {
        auto result = split(line, ",");
        int sq = to!int(result[0]);
        sq = sq - 1;
        ulong v0 = to!ulong(result[1]);
        ulong v1 = to!ulong(result[2]);
        ulong v2 = to!ulong(result[3]);
        BitBoard v = BitBoard(v0) << 54 | BitBoard(v1) << 27 | BitBoard(v2);
        ABB_Diag2_Mask_Ex[sq] = v;
        //writeln(h);
    }

    auto file9 = std.stdio.File("abb_lance_attacks_conv.txt", "r");
    foreach (line; file9.byLine()) {
        auto result = split(line, ",");
        int co = to!int(result[0]);
        int sq = to!int(result[1]);
        co = co - 1;
        sq = sq - 1;
        ulong h0 = to!ulong(result[2]);
        ulong h1 = to!ulong(result[3]);
        ulong h2 = to!ulong(result[4]);
        BitBoard h = BitBoard(h0) << 54 | BitBoard(h1) << 27 | BitBoard(h2);
        ulong v0 = to!ulong(result[5]);
        ulong v1 = to!ulong(result[6]);
        ulong v2 = to!ulong(result[7]);
        BitBoard v = BitBoard(v0) << 54 | BitBoard(v1) << 27 | BitBoard(v2);
        ABB_Lance_Attacks[co][sq][h] = v;
        //writeln(h);
    }

    auto file10 = std.stdio.File("abb_lance_mask_ex_conv.txt", "r");
    foreach (line; file10.byLine()) {
        auto result = split(line, ",");
        int co = to!int(result[0]);
        int sq = to!int(result[1]);
        co = co - 1;
        sq = sq - 1;
        ulong v0 = to!ulong(result[2]);
        ulong v1 = to!ulong(result[3]);
        ulong v2 = to!ulong(result[4]);
        BitBoard v = BitBoard(v0) << 54 | BitBoard(v1) << 27 | BitBoard(v2);
        ABB_Lance_Mask_Ex[co][sq] = v;
        //writeln(h);
    }

    auto file11 = std.stdio.File("abb_obstacles_conv.txt", "r");
    foreach (line; file11.byLine()) {
        auto result = split(line, ",");
        int sq0 = to!int(result[0]);
        int sq1 = to!int(result[1]);
        sq0 = sq0 - 1;
        sq1 = sq1 - 1;
        ulong v0 = to!ulong(result[2]);
        ulong v1 = to!ulong(result[3]);
        ulong v2 = to!ulong(result[4]);
        BitBoard v = BitBoard(v0) << 54 | BitBoard(v1) << 27 | BitBoard(v2);
        ABB_Obstacles[sq0][sq1] = v;
        //writeln(h);
    }

    auto file12 = std.stdio.File("abb_cross_mask_ex_conv.txt", "r");
    foreach (line; file12.byLine()) {
        auto result = split(line, ",");
        int sq = to!int(result[0]);
        sq = sq - 1;
        ulong v0 = to!ulong(result[1]);
        ulong v1 = to!ulong(result[2]);
        ulong v2 = to!ulong(result[3]);
        BitBoard v = BitBoard(v0) << 54 | BitBoard(v1) << 27 | BitBoard(v2);
        ABB_Cross_Mask_Ex[sq] = v;
        //writeln(h);
    }

    auto file13 = std.stdio.File("abb_cross_attacks_conv.txt", "r");
    foreach (line; file13.byLine()) {
        auto result = split(line, ",");
        int sq = to!int(result[0]);
        sq = sq - 1;
        ulong h0 = to!ulong(result[1]);
        ulong h1 = to!ulong(result[2]);
        ulong h2 = to!ulong(result[3]);
        BitBoard h = BitBoard(h0) << 54 | BitBoard(h1) << 27 | BitBoard(h2);
        ulong v0 = to!ulong(result[4]);
        ulong v1 = to!ulong(result[5]);
        ulong v2 = to!ulong(result[6]);
        BitBoard v = BitBoard(v0) << 54 | BitBoard(v1) << 27 | BitBoard(v2);
        ABB_Cross_Attacks[sq][h] = v;
        //writeln(h);
    }

    auto file14 = std.stdio.File("abb_diagonal_mask_ex_conv.txt", "r");
    foreach (line; file14.byLine()) {
        auto result = split(line, ",");
        int sq = to!int(result[0]);
        sq = sq - 1;
        ulong v0 = to!ulong(result[1]);
        ulong v1 = to!ulong(result[2]);
        ulong v2 = to!ulong(result[3]);
        BitBoard v = BitBoard(v0) << 54 | BitBoard(v1) << 27 | BitBoard(v2);
        ABB_Diagonal_Mask_Ex[sq] = v;
        //writeln(h);
    }

    auto file15 = std.stdio.File("abb_diagonal_attacks_conv.txt", "r");
    foreach (line; file15.byLine()) {
        auto result = split(line, ",");
        int sq = to!int(result[0]);
        sq = sq - 1;
        ulong h0 = to!ulong(result[1]);
        ulong h1 = to!ulong(result[2]);
        ulong h2 = to!ulong(result[3]);
        BitBoard h = BitBoard(h0) << 54 | BitBoard(h1) << 27 | BitBoard(h2);
        ulong v0 = to!ulong(result[4]);
        ulong v1 = to!ulong(result[5]);
        ulong v2 = to!ulong(result[6]);
        BitBoard v = BitBoard(v0) << 54 | BitBoard(v1) << 27 | BitBoard(v2);
        ABB_Diagonal_Attacks[sq][h] = v;
        //writeln(h);
    }

    auto file16 = std.stdio.File("abb_piece_attacks_conv.txt", "r");
    foreach (line; file16.byLine()) {
        auto result = split(line, ",");
        int co = to!int(result[0]);
        int pc = to!int(result[1]);
        int sq = to!int(result[2]);
        //co = co - 1;
        ulong v0 = to!ulong(result[3]);
        ulong v1 = to!ulong(result[4]);
        ulong v2 = to!ulong(result[5]);
        BitBoard v = BitBoard(v0) << 54 | BitBoard(v1) << 27 | BitBoard(v2);
        //writeln(co);
        //writeln(sq);
        ABB_Piece_Attacks[co][pc][sq] = v;
        //writeln(h);
    }
}
