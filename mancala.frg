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


pred wellformedBoards {
    all b: Board | {
        -- Sig already constrains that it's someone's turn
        b.hand >= 0

        all pock : Pocket | {
            -- No negative marbles
            b.marbles[pock] >= 0
        }
    }
}

pred wellformedPockets {
    all disj p1 : Player, p2 : Player | {
        -- Each player has the same number of pockets
        #{pock : Pocket | pock.side = p1} = #{pock : Pocket | pock.side = p2}

        -- Each player has exactly one mancala
        one pock1, pock2 : Pocket | {
            pock1.mancala = p1
            pock2.mancala = p2
        }
    }

    all pock : Pocket | {
        -- Set the right player sides and pocket opposites
        {pock.mancala = none} => { // if not a mancala
            {pock.next.mancala = none} => pock.opposite = pock.next.opposite.next else pock.opposite = pock.next.next
            pock.next.side = pock.side
            pock.opposite != pock
            pock.opposite.opposite = pock
        } else { 
            -- If a mancala: 
            -- the pocket after the mancala should change sides
            no pock.opposite
            pock.mancala = pock.side
            pock.next.side != pock.side
        }

        -- All pockets arranged in a cycle
        pock.next != pock
        all other_pock: Pocket | {
            reachable[other_pock, pock, next]
            reachable[pock, pock, next]
        }

    }

}

pred wellformed{
    wellformedBoards
    wellformedPockets
}


pred init[b: Board, i: Int] {
    -- Start with player 1
    one p : Player1 | {
        b.turn = p
    }

    -- Board has no previous
    no bo: Board | {
        bo.bnext = b
    }
    -- Must have a next
    b.bnext != none
    b.lastPocket = none

    -- Place marbles: 0 in hand and same in pockets
    b.hand = 0
    all pock : Pocket | {
        pock.mancala = none => b.marbles[pock] = i else b.marbles[pock] = 0
    }
}

pred final[b: Board] {
    -- No next
    b.bnext = none

    -- No marbles left in hand
    b.hand = 0

    -- All players can no longer play
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
                    } else {
                         // finished in pocket with marbles
                        post.marbles[pock] = add[pre.marbles[pock], 1]
                        otherPockUnchanged[pock, pre, post]
                    }

                } 
                else { // finished in mancala
                    post.marbles[pock] = add[pre.marbles[pock], 1] // add to mancala
                    otherPockUnchanged[pock, pre, post]

                    pock.side = pre.turn => {
                        post.turn = pre.turn // keep turn if own mancala
                    } else {
                        post.turn != pre.turn // change turn if not
                    }
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

pred stealingHappened {
    some b1, b2: Board | {
        b1.bnext = b2
        some m : Pocket | {
            m.mancala != none
            subtract[b2.marbles[m], b1.marbles[m]] > 1
        }
    }
}

pred reachableEnd {
    one b: Board | {
        final[b]
    }
}

pred trace[i: Int] {
    -- Exists a first
    one first: Board | {
        init[first, i]
        all b: Board | {
            b != first => reachable[b, first, bnext]
        }
    }
    -- Each board is move-able to its next board
    all b:Board | {
        some b.bnext => move[b, b.bnext]
    }
}

pred fullGame[i: Int] {
    trace[i]
    reachableEnd
}


run {
    wellformed
    fullGame[1]
} for exactly 2 Player, exactly 4 Pocket, 7 Board for {bnext is linear}
