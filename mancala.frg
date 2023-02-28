#lang forge/bsl


// one sig Board {

// }



sig Pocket{
    side : one Player,
    mancala : lone Player,
    marbles : one Int,
    next : one Pocket
}

abstract sig Player{}


one sig Player1,Player2 extends Player{}


pred wellformed {
    all disj p1 : Player, p2 : Player | {
        #{pock : Pocket | pock.side = p1} = #{pock : Pocket | pock.side = p2}
        one pock : Pocket | {
            pock.mancala = p1
        }
        one pock : Pocket | {
            pock.mancala = p2
        }
        all pock : Pocket | {
            {pock.mancala = none} => pock.next.side = pock.side else pock.next.side != pock.side
            reachable[pock, pock, next]
            pock.next != pock
            pock.marbles >= 0
        }
    }

}

pred init {
    all pock : Pocket | {
        pock.mancala = none => pock.marbles = 1 else pock.marbles = 0
    }
}




run{
    wellformed
    init
} for exactly 2 Player, exactly 4 Pocket
