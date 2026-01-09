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

public Array!Record ReadRecords(string str_file_name)
{
    Array!Record records;
    auto f_data = std.stdio.File(str_file_name, "r");
    foreach (line; f_data.byLine()) {
        auto line2 = toUTF8(line);
        auto temp = line2.split(',');
        Record r;
        if (temp[0] == "B")
        {
            r.winner = 0;
        }
        else if (temp[0] == "W")
        {
            r.winner = 1;
        }
        else if (temp[0] == "D")
        {
            r.winner = 2;
        }
        auto limit = temp.length - 2;
        for (int i = 0; i < limit; i++)
        {
            r.str_moves ~= temp[i + 2];
        }
        records.insertBack(r);
        //writeln(temp);
        //writeln(limit);
    }
    return records;
}
