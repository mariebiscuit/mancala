#lang forge


sig Board {
    // players: set Player,
    marbles: pfunc Pocket -> Int,

    turn: one Player,  
    hand: one Int,
    
    bnext : lone Board
}

sig Pocket{
    side : one Player,
    mancala : lone Player,
    next : one Pocket,
    opposite: lone Pocket
}

abstract sig Player{}


one sig Player1,Player2 extends Player{}


pred wellformed {
    all disj p1 : Player, p2 : Player | {
        -- Each player has the same number of pockets
        #{pock : Pocket | pock.side = p1} = #{pock : Pocket | pock.side = p2}

        -- Each player has exactly one mancala
        one pock1, pock2 : Pocket | {
            pock1.mancala = p1
            pock2.mancala = p2
        }
    }

    all b: Board | {
        -- It's someone's turn
        some b.turn

        all pock : Pocket | {
            -- No negative marbles
            b.marbles[pock] >= 0

            -- Set the right player sides and pocket opposites
            {pock.mancala = none} => { // if not a mancala
                {pock.next.mancala = none} => pock.opposite = pock.next.opposite.next else pock.opposite = pock.next.next
                pock.next.side = pock.side
                pock.opposite != pock
                pock.opposite.opposite = pock
            } else { // if a mancala
                no pock.opposite
                pock.mancala = pock.side
                pock.next.side != pock.side
            }

            -- Arrange all pockets in a cycle
            pock.next != pock
            all other_pock: Pocket | {
                reachable[other_pock, pock, next]
                reachable[pock, pock, next]
            }

        }
    }

}

pred init[b: Board] {
    -- Start with player 1
    one p : Player1 | {
        b.turn = p
    }
    -- Must have a next
    b.bnext != none

    -- Place marbles
    b.hand = 0
    all pock : Pocket | {
        pock.mancala = none => b.marbles[pock] = 1 else b.marbles[pock] = 0
    }
}

pred final[b: Board] {
    -- No next
    b.bnext = none

    -- No marbles left in hand
    b.hand = 0

    -- One player can no longer play
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
    -- Exists a first and last
    some disj first, last : Board | {
        init[first]
        final[last]
        reachable[last, first, bnext]
    }

    -- Each board is move-able to its next board
    all b:Board | {
        some b.bnext => move[b, b.bnext]
    }
}


run {
    wellformed
    // traces
} for exactly 2 Player, exactly 6 Pocket, exactly 3 Board for {bnext is linear}
