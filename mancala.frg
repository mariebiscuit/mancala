#lang forge


one sig Board {
    // pockets: set Pocket,
    players: set Player,
    marbles: pfunc Pocket -> Int  
    hand: one Int
}

sig Pocket{
    side : one Player,
    mancala : lone Player,
    // marbles : one Int,
    next : one Pocket,
    opposite: lone Pocket
}

abstract sig Player{}


one sig Player1,Player2 extends Player{}


pred wellformed {
    all disj p1 : Player, p2 : Player | {
        #{pock : Pocket | pock.side = p1} = #{pock : Pocket | pock.side = p2}

        // Each player has exactly one mancala
        one pock : Pocket | {
            pock.mancala = p1
        }
        one pock : Pocket | {
            pock.mancala = p2
        }
        
        all b: Board | {
            all pock : Pocket | {
                // pock in b.pockets
                b.marbles[pock] >= 0
                // pock.marbles >= 0
                pock.next != pock

                p1 in b.players
                p2 in b.players

                {pock.mancala = none} => { // if it is not a mancala
                    {pock.next.mancala = none} => pock.opposite = pock.next.opposite.next else pock.opposite = pock.next.next
                    pock.next.side = pock.side
                    pock.opposite != pock
                    pock.opposite.opposite = pock
                } else { // if it is a mancala
                    no pock.opposite
                    pock.next.side != pock.side
                }

                all other_pock: Pocket | {
                    reachable[other_pock, pock, next]
                    reachable[pock, pock, next]
                }

            }
        }
    }

}

pred init {
    // all pock : Pocket | {
    //     pock.mancala = none => pock.marbles = 1 else pock.marbles = 0
    // }
    all b: Board | {
        b.hand = 0
        all pock : Pocket | {
            // pock.mancala = none => pock.marbles = 1 else pock.marbles = 0
            pock.mancala = none => b.marbles[pock] = 1 else b.marbles[pock] = 0
        }
    }
}

pred move [pre: Board, post: Board, p: Player] {

    one pock1: Pocket | {
        {pre.hand = 0} => { // chosen pocket
        // needs player-specific constraint
        // needs no other pocket changed constraint
            pre.marbles[pock1] != 0
            pock1.mancala = none
            post.marbles[pock1] = 0
            post.hand = pre.marbles[pock1]
            
        } else { // pocket gaining a marble
            post.marbles[pock1] = pre.marbles[pock1] + 1
            post.hand = pre.hand - 1
        // needs a mancala-checking constaint
        // needs no other pocket changed constraint
        }
    }
}


pred traces {
    
    some p: Pocket | {
        // track player?
        move[p, ]
    }

}


run{
    wellformed
    // init
} for exactly 2 Player, exactly 6 Pocket, exactly 1 Board
