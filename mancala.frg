#lang forge/bsl


sig Board {
    marbles: pfunc Pocket -> Int,

    turn: one Player,  
    hand: one Int,
    lastPocket: lone Pocket,

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
        b.hand >= 0

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

    -- no Prev
    no bo: Board | {
        bo.bnext = b
    }
    -- Must have a next
    b.bnext != none
    b.lastPocket = none

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
    all p : Player | {
        all pock : Pocket | {
            {pock.side = p and pock.mancala = none} => b.marbles[pock] = 0
        }
    }
}

pred playerNoMarbles[b: Board]{
    all pock: Pocket | {
            {pock.side = b.turn and pock.mancala = none} => b.marbles[pock] = 0
        }
}

pred changeTurnKeepBoard[pre: Board, post: Board]{
    post.turn != pre.turn
    post.hand = pre.hand
    -- No pockets change
    all p: Pocket | {
        pre.marbles[p] = post.marbles[p]
    }
}

pred otherPockUnchanged[p: Pocket, pre: Board, post:Board]{
    all otherP: Pocket | {
        p != otherP => pre.marbles[otherP] = post.marbles[otherP]
    }
}

pred noChange[pre: Board, post: Board]{
    post.turn = pre.turn
    post.hand = pre.hand
    -- No pockets change
    all p: Pocket | {
        pre.marbles[p] = post.marbles[p]
    }
}

pred move [pre: Board, post: Board] {

    {pre.hand = 0} => {
        playerNoMarbles[pre] => {
            changeTurnKeepBoard[pre, post]
        } else {
            some usedPock : Pocket | {
                -- GUARD
                usedPock.side = pre.turn // on player's side
                usedPock.mancala = none // not a mancala
                pre.marbles[usedPock] != 0
                
                -- ACTION
                post.marbles[usedPock] = 0 // all marbles removed
                post.hand = pre.marbles[usedPock] // marbles added to hand
                post.lastPocket = usedPock
                post.turn = pre.turn

                otherPockUnchanged[usedPock, pre, post]
            }
        } 
    } 
    else {
        post.hand = subtract[pre.hand, 1] // Changed from pre.hand - 1

        one pock: Pocket | {
            pock = pre.lastPocket.next

            {post.hand = 0} =>{ // have spent all marbles
                pock.mancala = none => { // finished in pocket
                    post.turn != pre.turn  // change turn
                    
                    {pre.marbles[pock] = 0 and pock.side=pre.turn} => { // finished in own side's empty pocket
                        post.marbles[pock.opposite] = 0
                        
                        one man: Pocket | {
                            man.mancala = pre.turn
                            post.marbles[man] = add[pre.marbles[man], pre.marbles[pock.opposite], 1]
                            
                            -- Other pocks unchanged, but two pocks change
                            all otherP: Pocket | {
                                {otherP != pock.opposite and otherP != man} => pre.marbles[otherP] = post.marbles[otherP]
                            }
                        }
                    } else { // finished in pocket with marbles
                        post.marbles[pock] = add[pre.marbles[pock], 1]
                        otherPockUnchanged[pock, pre, post]
                    }

                } 
                else { // finished in mancala
                    post.marbles[pock] = add[pre.marbles[pock], 1] // add to mancala
                    post.turn = pre.turn // keep turn
                    otherPockUnchanged[pock, pre, post]
                }
            } else { // still have marbles in hand
                post.marbles[pock] = add[pre.marbles[pock], 1]
                post.turn = pre.turn
                post.lastPocket = pock
                otherPockUnchanged[pock, pre, post]
        
            }
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
    traces
} for exactly 2 Player, exactly 6 Pocket, 7 Board for {bnext is linear}
