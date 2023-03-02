#lang forge/bsl


open "mancala.frg"


test suite for wellformed {
    example isWellformed is wellformed for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Board = `board
        Pocket = `p1 + `p2 + `p3 + `p4 + `p5 + `p6
        side = `p1 -> `Player1 +
                `p2 -> `Player1 +
                `p3 -> `Player1 +
                `p4 -> `Player2 +
                `p5 -> `Player2 +
                `p6 -> `Player2
        next = `p1 -> `p2 +
                `p2 -> `p3 +
                `p3 -> `p4 +
                `p4 -> `p5 +
                `p5 -> `p6 +
                `p6 -> `p1
        mancala = `p3 -> `Player1 + `p6 -> `Player2
                  + `p1 -> none
                  + `p2 -> none
                  + `p4 -> none
                  + `p5 -> none
        opposite = `p1 -> `p5 + `p5 -> `p1
                 + `p2 -> `p4 + `p4 -> `p2
                 + `p3 -> none + `p6 -> none
        marbles = 
            `board -> `p1 -> 1 +
            `board -> `p2 -> 1 +
            `board -> `p3 -> 0 +
            `board -> `p4 -> 1 +
            `board -> `p5 -> 1 +
            `board -> `p6 -> 0
        turn = `board -> `Player1
        hand = `board -> 0
        lastPocket = `board -> `p1
        bnext = `board -> none
    }
    example negativeMarbles is not wellformed for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Board = `board
        Pocket = `p1 + `p2 + `p3 + `p4 + `p5 + `p6
        side = `p1 -> `Player1 +
                `p2 -> `Player1 +
                `p3 -> `Player1 +
                `p4 -> `Player2 +
                `p5 -> `Player2 +
                `p6 -> `Player2
        next = `p1 -> `p2 +
                `p2 -> `p3 +
                `p3 -> `p4 +
                `p4 -> `p5 +
                `p5 -> `p6 +
                `p6 -> `p1
        mancala = `p3 -> `Player1 + `p6 -> `Player2
                  + `p1 -> none
                  + `p2 -> none
                  + `p4 -> none
                  + `p5 -> none
        opposite = `p1 -> `p5 + `p5 -> `p1
                 + `p2 -> `p4 + `p4 -> `p2
                 + `p3 -> none + `p6 -> none
        marbles = 
            `board -> `p1 -> -1 +
            `board -> `p2 -> 1 +
            `board -> `p3 -> 0 +
            `board -> `p4 -> 1 +
            `board -> `p5 -> 1 +
            `board -> `p6 -> 0
        turn = `board -> `Player1
        hand = `board -> 0
        lastPocket = `board -> `p1
        bnext = `board -> none
    }
}

test suite for move{
    example validMove is {some pre, post: Board | move[pre, post]} for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Board = `board1 + `board2
        Pocket = `p1 + `p2 + `p3 + `p4 + `p5 + `p6
        side = `p1 -> `Player1 +
                `p2 -> `Player1 +
                `p3 -> `Player1 +
                `p4 -> `Player2 +
                `p5 -> `Player2 +
                `p6 -> `Player2
        next = `p1 -> `p2 +
                `p2 -> `p3 +
                `p3 -> `p4 +
                `p4 -> `p5 +
                `p5 -> `p6 +
                `p6 -> `p1
        mancala = `p3 -> `Player1 + `p6 -> `Player2
                  + `p1 -> none
                  + `p2 -> none
                  + `p4 -> none
                  + `p5 -> none
        opposite = `p1 -> `p5 + `p5 -> `p1
                 + `p2 -> `p4 + `p4 -> `p2
                 + `p3 -> none + `p6 -> none
        marbles = 
            `board1 -> `p1 -> 1 +
            `board1 -> `p2 -> 1 +
            `board1 -> `p3 -> 0 +
            `board1 -> `p4 -> 1 +
            `board1 -> `p5 -> 1 +
            `board1 -> `p6 -> 0 +
            `board2 -> `p1 -> 0 +
            `board2 -> `p2 -> 1 +
            `board2 -> `p3 -> 0 +
            `board2 -> `p4 -> 1 +
            `board2 -> `p5 -> 1 +
            `board2 -> `p6 -> 0
        turn = `board1 -> `Player1 + `board1 -> `Player1
        hand = `board1 -> 0 + `board2 -> 1
        lastPocket = `board2 -> `p1
        bnext = `board2 -> none + `board1 -> `board2
    }
    example endInOwnMancalaContinuesTurn is {some pre, post: Board | move[pre, post]} for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Board = `board1 + `board2
        Pocket = `p1 + `p2 + `p3 + `p4 + `p5 + `p6
        side = `p1 -> `Player1 +
                `p2 -> `Player1 +
                `p3 -> `Player1 +
                `p4 -> `Player2 +
                `p5 -> `Player2 +
                `p6 -> `Player2
        next = `p1 -> `p2 +
                `p2 -> `p3 +
                `p3 -> `p4 +
                `p4 -> `p5 +
                `p5 -> `p6 +
                `p6 -> `p1
        mancala = `p3 -> `Player1 + `p6 -> `Player2
                  + `p1 -> none
                  + `p2 -> none
                  + `p4 -> none
                  + `p5 -> none
        opposite = `p1 -> `p5 + `p5 -> `p1
                 + `p2 -> `p4 + `p4 -> `p2
                 + `p3 -> none + `p6 -> none
        marbles = 
            `board1 -> `p1 -> 1 +
            `board1 -> `p2 -> 0 +
            `board1 -> `p3 -> 0 +
            `board1 -> `p4 -> 1 +
            `board1 -> `p5 -> 1 +
            `board1 -> `p6 -> 0 +
            `board2 -> `p1 -> 1 +
            `board2 -> `p2 -> 0 +
            `board2 -> `p3 -> 1 +
            `board2 -> `p4 -> 1 +
            `board2 -> `p5 -> 1 +
            `board2 -> `p6 -> 0
        turn = `board1 -> `Player1 + `board1 -> `Player1
        hand = `board1 -> 1 + `board2 -> 0
        lastPocket = `board2 -> `p2
        bnext = `board2 -> none + `board1 -> `board2
    }
}