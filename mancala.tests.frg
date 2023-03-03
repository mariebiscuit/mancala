#lang forge/bsl


open "mancala.frg"

test suite for wellformedPockets {
    example mancalasOnly is wellformedPockets for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Pocket = `p1 + `p2
        side = `p1 -> `Player1 +
                `p2 -> `Player2 
        next = `p1 -> `p2 +
                `p2 -> `p1
        mancala = `p1 -> `Player1 + `p2 -> `Player2
        opposite = `p1 -> none +
                   `p2 -> none
    }
    example sixPockets is wellformedPockets for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Pocket = `p1 + `p2 + `p3 + `p4 + `p5 + `p6
        next = `p1 -> `p2 +
                `p2 -> `p3 +
                `p3 -> `p4 +
                `p4 -> `p5 +
                `p5 -> `p6 +
                `p6 -> `p1
        mancala = `p3 -> `Player1 +
                  `p6 -> `Player2
        opposite = `p1 -> `p5 + 
                   `p2 -> `p4 +
                   `p5 -> `p1 +
                   `p4 -> `p2
    }
    
    example playerWithTwoMancalas is not wellformedPockets for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Board = `board
        Pocket = `p1 + `p2
        mancala = `p1 -> `Player1 + `p2 -> `Player1
    }

    example mancalaInMiddleOfPockets is not wellformedPockets for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Pocket = `p1 + `p2 + `p3 + `p4 + `p5 + `p6
        next = `p1 -> `p2 +
                `p2 -> `p3 +
                `p3 -> `p4 +
                `p4 -> `p5 +
                `p5 -> `p6 +
                `p6 -> `p1
        mancala = `p3 -> `Player1 +
                  `p6 -> `Player2 
        side =  `p1 -> `Player2 +
                `p2 -> `Player1 +
                `p3 -> `Player1 +
                `p4 -> `Player1 +
                `p5 -> `Player2 +
                `p6 -> `Player2 
    }

    example wrongOpposites is not wellformedPockets for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Board = `board
        Pocket = `p1 + `p2 + `p3 + `p4 + `p5 + `p6
        next = `p1 -> `p2 +
                `p2 -> `p3 +
                `p3 -> `p4 +
                `p4 -> `p5 +
                `p5 -> `p6 +
                `p6 -> `p1
        mancala = `p3 -> `Player1 +
                  `p6 -> `Player2
        opposite = `p1 -> `p4 +
                   `p2 -> `p5 +
                   `p4 -> `p1 +
                   `p5 -> `p2
    }

    example oddPockets is not wellformedPockets for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Board = `board
        Pocket = `p1 + `p2 + `p3
    }

    example selfLoopPocket is not wellformedPockets for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Pocket = `p1 + `p2 
        next = `p1 -> `p1 +
                `p2 -> `p2
    }

}
test suite for wellformedBoards {

    example isWellformed is wellformedBoards for {
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

    example negativeMarblesPocket is not wellformedBoards for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Board = `board
        Pocket = `p1 + `p2
        marbles = 
            `board -> `p1 -> -1 +
            `board -> `p2 -> 1
    }

    example negativeMarblesHand is not wellformedBoards for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Board = `board
        hand = `board -> -1
    }
}

test suite for init{
    example initBoard is {some b: Board | init[b, 1]} for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Pocket = `p1 + `p2 + `p3 + `p4 
        mancala = `p2 -> `Player1 +
                  `p4 -> `Player2 +
                  `p1 -> none +
                  `p3 -> none
        Board = `board1 + `board2
        hand = `board1 -> 0 + `board2 -> 1
        turn = `board1 -> `Player1 + `board2 -> `Player1
        marbles = `board1 -> `p1 -> 1 +
                  `board1 -> `p2 -> 0 +
                  `board1 -> `p3 -> 1 +
                  `board1 -> `p4 -> 0 
        lastPocket = `board1 -> none
        bnext = `board1 -> `board2 + `board2 -> none
    }

    example nonEmptyHand is not {some b: Board | init[b, 1]} for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Pocket = `p1 + `p2 + `p3 + `p4 
        mancala = `p2 -> `Player1 +
                  `p4 -> `Player2 +
                  `p1 -> none +
                  `p3 -> none
        Board = `board1 + `board2
        hand = `board1 -> 1 + `board2 -> 1
        turn = `board1 -> `Player1 + `board2 -> `Player1
        marbles = `board1 -> `p1 -> 1 +
                  `board1 -> `p2 -> 0 +
                  `board1 -> `p3 -> 1 +
                  `board1 -> `p4 -> 0 
        lastPocket = `board1 -> none
        bnext = `board1 -> `board2 + `board2 -> none
    }
    
    example nonEmptyMancalas is not {some b: Board | init[b, 1]} for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Pocket = `p1 + `p2 + `p3 + `p4 
        mancala = `p2 -> `Player1 +
                  `p4 -> `Player2 +
                  `p1 -> none +
                  `p3 -> none
        Board = `board1 + `board2
        hand = `board1 -> 1 + `board2 -> 1
        turn = `board1 -> `Player1 + `board2 -> `Player1
        marbles = `board1 -> `p1 -> 1 +
                  `board1 -> `p2 -> 1 +
                  `board1 -> `p3 -> 1 +
                  `board1 -> `p4 -> 1 
        lastPocket = `board1 -> none
        bnext = `board1 -> `board2 + `board2 -> none
    }

        
    example unequalMarbles is not {some b: Board | init[b, 1]} for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Pocket = `p1 + `p2 + `p3 + `p4 
        mancala = `p2 -> `Player1 +
                  `p4 -> `Player2 +
                  `p1 -> none +
                  `p3 -> none
        Board = `board1 + `board2
        hand = `board1 -> 1 + `board2 -> 1
        turn = `board1 -> `Player1 + `board2 -> `Player1
        marbles = `board1 -> `p1 -> 1 +
                  `board1 -> `p2 -> 0 +
                  `board1 -> `p3 -> 2 +
                  `board1 -> `p4 -> 0 
        lastPocket = `board1 -> none
        bnext = `board1 -> `board2 + `board2 -> none
    }
}

test suite for move{

    example startTurn is {some pre, post: Board | move[pre, post]} for {
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
            `board2 -> `p1 -> 0 + // marbles were taken
            `board2 -> `p2 -> 1 +
            `board2 -> `p3 -> 0 +
            `board2 -> `p4 -> 1 +
            `board2 -> `p5 -> 1 +
            `board2 -> `p6 -> 0
        turn = `board1 -> `Player1 + 
               `board2 -> `Player1
        hand = `board1 -> 0 + `board2 -> 1
        lastPocket = `board2 -> `p1
        bnext = `board2 -> none + `board1 -> `board2
    }

    example keepTurn is {some pre, post: Board | move[pre, post]} for {
       Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Board = `board1 + `board2
        Pocket = `p1 + `p2 + `p3 + `p4
        side = `p1 -> `Player1 +
                `p2 -> `Player1 +
                `p3 -> `Player1 +
                `p4 -> `Player2 
        next = `p1 -> `p2 +
                `p2 -> `p3 +
                `p3 -> `p4 +
                `p4 -> `p1
        mancala = `p2 -> `Player1 + `p4 -> `Player2
        marbles = `board1 -> `p2 -> 0 +
                  `board2 -> `p2 -> 1  // marble ended in mancala
        turn = `board1 -> `Player1 + 
               `board2 -> `Player1 // player keeps turn
        hand = `board1 -> 1 + `board2 -> 0
        lastPocket = `board1 -> `p1
        bnext = `board2 -> none + `board1 -> `board2
    }
    
    example stealMarbles is {some pre, post: Board | move[pre, post]} for {
       Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Board = `board1 + `board2
        Pocket = `p1 + `p2 + `p3 + `p4
        side = `p1 -> `Player1 +
                `p2 -> `Player1 +
                `p3 -> `Player2 +
                `p4 -> `Player2 
        next = `p1 -> `p2 +
                `p2 -> `p3 +
                `p3 -> `p4 +
                `p4 -> `p1
        opposite = `p1 -> `p3 +
                   `p3 -> `p1 +
                   `p2 -> none +
                   `p4 -> none
        mancala = `p2 -> `Player1 + `p4 -> `Player2
        marbles = `board1 -> `p1 -> 0 +
                  `board1 -> `p3 -> 3 + // opposite pocket
                  `board1 -> `p2 -> 2 + // marbles in P1 mancala originally
                  `board2 -> `p1 -> 0 + // end in empty pocket
                  `board2 -> `p3 -> 0 + // opposite marbles stolen
                  `board2 -> `p2 -> 6  // marbles added to P1's mancala
        turn = `board1 -> `Player1 + 
               `board2 -> `Player2
        hand = `board1 -> 1 + `board2 -> 0
        lastPocket = `board1 -> `p4
        bnext = `board2 -> none + `board1 -> `board2
    }

     example forfeitTurn is {some pre, post: Board | move[pre, post]} for {
       Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Board = `board1 + `board2
        Pocket = `p1 + `p2 + `p3 + `p4
        side = `p1 -> `Player1 +
                `p2 -> `Player1 +
                `p3 -> `Player2 +
                `p4 -> `Player2 
        next = `p1 -> `p2 +
                `p2 -> `p3 +
                `p3 -> `p4 +
                `p4 -> `p1
        opposite = `p1 -> `p3 +
                   `p3 -> `p1 +
                   `p2 -> none +
                   `p4 -> none
        mancala = `p2 -> `Player1 + `p4 -> `Player2
        marbles = `board1 -> `p1 -> 0 + // P1's only pocket is empty
                  `board2 -> `p1 -> 0 +
                  `board1 -> `p2 -> 5 + // everything else stays the same
                  `board2 -> `p2 -> 5 +
                  `board1 -> `p3 -> 3 + 
                  `board2 -> `p3 -> 3 +
                  `board1 -> `p4 -> 2 + 
                  `board2 -> `p4 -> 2 
        turn = `board1 -> `Player1 + 
               `board2 -> `Player2
        hand = `board1 -> 0 + `board2 -> 0 // no marbles in hand
        bnext = `board2 -> none + `board1 -> `board2
    }
    
    example noStealMarbles is not {some pre, post: Board | move[pre, post]} for {
        Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Board = `board1 + `board2
        Pocket = `p1 + `p2 + `p3 + `p4
        side = `p1 -> `Player1 +
                `p2 -> `Player1 +
                `p3 -> `Player2 +
                `p4 -> `Player2 
        next = `p1 -> `p2 +
                `p2 -> `p3 +
                `p3 -> `p4 +
                `p4 -> `p1
        opposite = `p1 -> `p3 +
                   `p3 -> `p1 +
                   `p2 -> none +
                   `p4 -> none
        mancala = `p2 -> `Player1 + `p4 -> `Player2
        marbles = `board1 -> `p1 -> 0 + // empty pocket
                  `board1 -> `p3 -> 3 + // opposite pocket
                  `board1 -> `p2 -> 2 + // marbles in P1 mancala originally
                  `board2 -> `p1 -> 1 + // marble just ends in pocket
                  `board2 -> `p3 -> 3 + // opposite marbles same
                  `board2 -> `p2 -> 2  // P1 mancala same
        turn = `board1 -> `Player1 + 
               `board2 -> `Player2
        hand = `board1 -> 1 + `board2 -> 0
        lastPocket = `board1 -> `p4
        bnext = `board2 -> none + `board1 -> `board2
    }


    example turnOver is not {some pre, post: Board | move[pre, post]} for {
       Player = `Player1 + `Player2
        Player1 = `Player1
        Player2 = `Player2
        Board = `board1 + `board2
        Pocket = `p1 + `p2 + `p3 + `p4
        side = `p1 -> `Player1 +
                `p2 -> `Player1 +
                `p3 -> `Player1 +
                `p4 -> `Player2 
        next = `p1 -> `p2 +
                `p2 -> `p3 +
                `p3 -> `p4 +
                `p4 -> `p1
        mancala = `p2 -> `Player1 + `p4 -> `Player2
        marbles = `board1 -> `p2 -> 0 +
                  `board2 -> `p2 -> 1  // marble ended in mancala
        turn = `board1 -> `Player1 + 
               `board2 -> `Player2 // player does not keep turn
        hand = `board1 -> 1 + `board2 -> 0
        lastPocket = `board1 -> `p1
        bnext = `board2 -> none + `board1 -> `board2
    }
}


test expect {
    -- All test expects run with one marble
    eightPocketGameMinBound1: {
        wellformed
        trace[1]
        reachableEnd
    } for exactly 2 Player, exactly 8 Pocket, 9 Board for {bnext is linear} is sat

    eightPocketGameMinBound2: {
        wellformed
        trace[1]
        reachableEnd
    } for exactly 2 Player, exactly 8 Pocket, 8 Board for {bnext is linear} is unsat

    fourPocketGameMaxBound1: {
        wellformed
        trace[1]
        not reachableEnd
    } for exactly 2 Player, exactly 4 Pocket, 6 Board for {bnext is linear} is unsat

    fourPocketGameMaxBound2: {
        wellformed
        trace[1]
        not reachableEnd
    } for exactly 2 Player, exactly 4 Pocket, 5 Board for {bnext is linear} is sat


    fourPocketTwoMarbleGameMaxBound1: {
        wellformed
        trace[2]
        not reachableEnd
    } for exactly 2 Player, exactly 4 Pocket, 10 Board for {bnext is linear} is unsat

     fourPocketTwoMarbleGameMaxBound2: {
        wellformed
        trace[2]
        not reachableEnd
    } for exactly 2 Player, exactly 4 Pocket, 9 Board for {bnext is linear} is sat

    -- These take a while, so they're commented out
    // sixPocketGameMustEndMaxBound1: {
    //     wellformed
    //     trace[1]
    //     not reachableEnd
    // } for exactly 2 Player, exactly 6 Pocket, 23 Board for {bnext is linear} is unsat

    // sixPocketGameMustEndMaxBound2: {
    //     wellformed
    //     trace[1]
    //     not reachableEnd
    // } for exactly 2 Player, exactly 6 Pocket, 22 Board for {bnext is linear} is sat

    gameMustEndWithoutStealingMinBound1: {
        wellformed
        trace[1]
        not stealingHappened
        reachableEnd
    } for exactly 2 Player, exactly 6 Pocket, 11 Board for {bnext is linear} is unsat

    gameMustEndWithoutStealingMinBound2: {
        wellformed
        trace[1]
        not stealingHappened
        reachableEnd
    } for exactly 2 Player, exactly 6 Pocket, 12 Board for {bnext is linear} is sat

    gameMustEndWithStealingMinBound1: {
        wellformed
        trace[1]
        stealingHappened
        reachableEnd
    } for exactly 2 Player, exactly 6 Pocket, 6 Board for {bnext is linear} is unsat

    gameMustEndWithStealingMinBound2: {
        wellformed
        trace[1]
        stealingHappened
        reachableEnd
    } for exactly 2 Player, exactly 6 Pocket, 7 Board for {bnext is linear} is sat
}