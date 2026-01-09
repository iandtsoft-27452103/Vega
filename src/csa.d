//import std.int128;
import std.stdio;
import std.conv;
//import std.algorithm;
import std.math.algebraic;
import common;
import core.bitop;
import bitop;
import board;
import move;

public Move CSA2Move(BoardTree bt, string str_csa)
{
    Move move = 0;
    int ifrom = to!int(CSA_TO_SQ[str_csa[0..2]]);
    int ito = to!int(CSA_TO_SQ[str_csa[2..4]]);
    int ipiece;
    int flag_promo = 0;
    if (ifrom < Square_NB)
    {
        ipiece = abs(bt.Board[ifrom]);
    }
    else
    {
        ipiece = CSA_TO_PC[str_csa[4..6]];
        ifrom += ipiece - 1;
    }

    int icap_piece = abs(bt.Board[ito]);
    if (ipiece < Piece.King && CSA_TO_PC[str_csa[4..6]] > Piece.King)
    {
        flag_promo = 1;
    }
    move = pack(ifrom, ito, ipiece, icap_piece, flag_promo);
    return move;
}
public char[] Move2CSA(Move move)
{
    char[] str;
    str ~= Str_CSA[from(move)];
    str ~= Str_CSA[to(move)];
    if (is_promo(move) == 0)
    {
        str ~= Str_Piece[piece(move)];
    }
    else
    {
        str ~= Str_Piece[piece(move) + Promote];
    }
    return str;
}
