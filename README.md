# About Pull Request

This repository is read-only, so Pull Request is not accepted. Thank you for your understanding.

# Vega

Vega is a shogi engine framework, written by D.

Shogi is game like chess.

## Source Code Explanation

(1) atkop.d : Functions of piece attacks.

(2) bitop.d : Functions of bit operations.

(3) board.d : Functions of shogi board.

(4) common.d : Common constants and variables.

(5) csa.d : Functions of CSA format.

(6) genmoves.d : Functions for generating moves.

(7) hash.d : Functions of hash.

(8) init.d : Functions of initializing attack tables.

(9) io.d : Functions for reading records.

(10) mate1ply.d : Function for mate in one ply.

(11) move.d : Functions for moves.

(12) sfen.d : Functions for SFEN.

(13) sort.d : Functions for sorting moves.

(14) test.d : Functions for testing.

(15) Vega.d: The entry point of this software.

## Operating environment

OS: Windows 11 Pro

DMD: 2.111.0

## How to build

You move to current directory, and run the command below.

dmd Vega.d common.d board.d sfen.d test.d init.d bitop.d hash.d move.d csa.d atkop.d genmoves.d mate1ply.d sort.d io.d

## References

I developed this software referring to the softwares as below.

(1) Bonanza

(2) Apery

(3) YaneuraOu

(4) Gikou

(5) dlshogi

As far as I know, the source code for Bonanza and dlshogi is currently not publicly available.

## About the future

I think I'll add search functions and analyze records functions.
