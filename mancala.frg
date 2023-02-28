#lang forge


one sig Board {
    // pockets: set Pocket,
    players: set Player,
    marbles: pfunc Pocket -> Int,
    turn: one Player,  
    hand: one Int,
    bnext : lone Board
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

pred init[b: Board] {
    // all pock : Pocket | {
    //     pock.mancala = none => pock.marbles = 1 else pock.marbles = 0
    // }

    // Starts with player1
    one p : Player1 | {
        b.turn = p
    }

    b.bnext != none
    b.hand = 0
    all pock : Pocket | {
        // pock.mancala = none => pock.marbles = 1 else pock.marbles = 0
        pock.mancala = none => b.marbles[pock] = 1 else b.marbles[pock] = 0
    }
}

pred final[b: Board] {
    b.bnext = none
    b.hand = 0
    one p : Player | {
        all pock : Pocket | {
            pock.side = p => {pock.mancala = none => b.marbles[pock] = 0}
        }
    }
}

pred move [pre: Board, post: Board] {

    -- GUARD: Ensure pockets are changed in sequence
    one pock : Pocket | {
        pre.marbles[pock.next] != post.marbles[pock.next]
    } or {
        pock.next.mancala = none
        pre.marbles[pock.next.opposite] != post.marbles[pock.next.opposite]
    }
    
    one pock1: Pocket | {
        {pre.hand = 0} => { // chosen pocket
            -- GUARD (what needs to hold about the pre-state?)
            pre.marbles[pock1] != 0 // has marbles
            pock1.side = pre.turn // on player's side
            pock1.mancala = none // not a mancala

             -- ACTION (what does the post-state then look like?)
            post.marbles[pock1] = 0 // all marbles removed
            post.hand = pre.marbles[pock1] // marbles added to hand
            
        } else { // pocket gaining a marble
            post.hand = pre.hand - 1
            {post.hand = 0} =>{ // have spent all marbles
                pock1.mancala = none => { // finished in pocket
                    post.turn != pre.turn  // change turn
                    
                    pre.marbles[pock1] = 0 => { // finished in empty pocket
                        post.marbles[pock1] = 0
                        post.marbles[pock1.opposite] = 0

                        one man: Pocket | {
                            man.mancala = pre.turn
                            post.marbles[man] = pre.marbles[man] + pre.marbles[pock1.opposite] + 1
                        }
                    } else { // finished in pocket with marbles
                        post.marbles[pock1] = pre.marbles[pock1] + 1
                    }
                } else post.turn = pre.turn // finished in mancala, keep turn

            } else { // still have marbles in hand
                post.marbles[pock1] = pre.marbles[pock1] + 1
                post.turn = pre.turn
            }
        }
        
        // no other pocket changed constraint
        all other_pock: Pocket | {
                pock1 != other_pock => pre.marbles[other_pock] = post.marbles[other_pock]
            }
    }
}


pred traces {

    some disj first, last : Board | {
        init[first]
        final[last]
        reachable[last, first, bnext]
    }

    all b:Board | {
        some b.bnext => move[b, b.bnext]
    }
}


run {
    wellformed
    // traces
} for exactly 2 Player, exactly 6 Pocket, exactly 2 Board// for {bnext is linear}
