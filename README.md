# Curiosity Modeling: Mancala
Final Project for CS1710
## About the Game
![](https://www.thesprucecrafts.com/thmb/yA6Lp0LcwqefQrJiQtNNVZTwIco=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/mancala-411837_hero_2888-8bef0fd76a324c86b61325556710d89f.jpg)

"Mancala" is a two-player game played on a board like above. Each player sits on one side of the board's length, so that each player has 6 number of 'pockets' on their side (the circular holes), and 1 Mancala on their right (the oblong hole). The game flow works as follows:

1. A player takes all the marbles from one of their pockets into their hand.
2. Going clockwise, the player drops one marble into each slot, where "slot" includes both pockets and Mancalas.
3. Depending on where the player drops their last marble, if the last marble...
    - Ends in their own mancala: The player keeps their turn and returns to step 1.
    - Ends in their own pocket that has no marbles: The player `steals' all the marbles in the opposite pocket and takes the just-added marble in this pocket, and adds all these marbles to their mancala. The next player takes their turn.
    - Otherwise: The next player takes their turn.
4. If it is a player's turn and none of their pockets have marbles left, they next player takes their turn.
5. The game ends when all pockets are empty. The player with more marbles in their Mancala wins.

## About Our Model
### Sigs and Fields
Our model has the following `sigs` and fields:
- `Pocket`: These track the static foundation on which the game is played, intended to represent the physical Mancala board. The run statement will indicate the specific number of `Pocket`s to build for the game.
    - `side`: Which player the `Pocket` belongs to.
    - `mancala`: Whether the `Pocket` is a Mancala: returns its belonging `Player` if it is, `none` if it is not. 
    - `next`: Which `Pocket` is next in the clockwise sequence. All the `Pocket`s form a cycle connected through `next`.
    - `opposite`: If it is not a Mancala, which `Pocket` is the corresponding opposite. This is needed for the `stealing' mechanic.
- `Board`: Represents a game state, encoding all changes that occur over the course of the game.
    - `marbles`: A `pfunc` that takes a pocket and returns the number of marbles in the pocket for this game state.
    - `turn`: Tracks which players' move it is for this game state. This field is necessary because it is not otherwise recoverable whose turn it is, since players' turn can span multiple events.
    - `hand`: An `Int` that tracks how many marbles are currently being held by the player-in-turn. 
    - `lastPocket`: A field with a `Pocket` that tracks which Pocket was last changed as 'memory', so that marbles can be dropped sequentially into the next pocket. This field is necessary as the player iit is not otherwise recoverable from looking at the wooden board which pocket was last changed.
    - `bnext`: The next game state in sequence; the `run` statement calls `for {bnext is linear}`. The transition between two adjacent `Boards` is one of the following events:
        - **A player forfeits their turn because they have no more marbles in their pockets**: A `turn` change with no other changes.
        - **A player finishes dropping their marbles in hand**: A decrement in `hand` and, depending on if they finished dropping the marble in...
            - **their own mancala**: an increment in `marbles` for that mancala, no `turn` change.
            - **their empty pocket**: a zero-ing of the opposite pocket, an increase in `marbles` for their mancala by the number of marbles in the opposite pocket and the 1 marble in-hand, and a change of `turn`
            - **otherwise**: an increment in `marbles` for the last-added pocket, and a change of `turn`.
        - **A player picks up marbles from a pocket**: A `hand` increase and zero-ing in `marbles` for one pocket on their side, update `lastPocket`.
        - **A player drops a marble in-hand**: A decrement in `hand` and increment in `marbles` for one pocket, no change of `turn`, update `lastPocket`.
- `Player`: An abstract sig that is either `Player1` or `Player2` to represent the two players in play.

### Preds
**Game-modeling Predicates**: Predicates that constrain the structure of the game
- `wellformedPockets`: Sets up the correct physical structure of the Mancala board
    - All players have one mancala and have an equal number of pockets;
    - All pockets are connected to each other in a cycle;
    - A consecutive half of pockets belongs to one player and the other consecutive half belongs to another;
    - Pockets that are not mancalas have the correct opposites;
- `wellformedBoards`: Defines physically sensible values for each Board state: mainly that all marbles counts are non-negative.
- `init`: Sets up the starting state, with Integer parameter `n`
    - Player 1 starts first;
    - There are no marbles in hand or in any of the Mancalas;
    - All non-mancala pockets have the same `n` number of marbles.
- `final`: Defines the endgame state as that all marbles are in mancalas.
- `move`: Predicate for a valid move between `pre` and `post` `Board` states. Most of our game logic lies in this predicate. It is a valid move if it is one of the events described above in the `bnext` field of the `Board` sig.
- `trace`: With some `init` board, the sequence of boards is connected by valid moves

#### **Investigative Predicates**: Predicates to use in TestExpects to test satisfiability of certain properties
- `reachableEnd` There exists some board that is a `final` board.
- `stealingHappened` At some transition between boards, a "stealing" event happened (i.e. a player landed in their own empty pocket and cleared out the opposite pocket into their mancala.

#### **Helper Predicates**
- `playerNoMarbles`: Helper predicate that for whether for a certain `Board` state, the player with the turn has no more marbles in pockets,
- `changeTurnKeepBoard`: Helper predicate for whether a given `pre` and `post` state have no difference except that the turn has changed.
- `otherPockUnchanged`: Helper predicate for whether, except for one specified `Pocket`, all other pockets are unchanged between `pre` and `post` Boards

#### **Convenience Predicates**
- `wellformed`: Combines `wellformedPockets` and `wellformedBoards`
- `fullGame[i]`: Combines `init[i]` and `reachableEnd` (i.e., a game start to end)


### Remarks on Design Choices
1. **Events**: We define each atomic event in our sequence of states as a change in some property of the game state, rather than using the start and end of player turns to define an event. 
    - We considered using the latter, but this would involve intermediately computing all the changes and making the accumulated updates to the Board. This was substantially more difficult since turns are of variable length and may involve multiple conditionals depending on the number of marbles the player picks up, and where they end. 
    - The former method allowed us to model the game succesfully state-to-state without requiring complex intermediate computations.
    - However, decoupling turns from 'events' means our model loses the ability to quickly answer some interesting questions about the game which are related to turns: for instance, count the minimum turns a player can take to win.
2. **'Do-Nothing' moves**: Our `move` predicate consideres the change of turn without changing anything else on the board as a valid event. 
    - We need this to account for cases mid-game where one player runs out of marbles for their turn before the other player. The other player should be able to continue.
    - However, this also means that depending on the number of `Boards` indicated in the `run` statement, after both players run out of marbles Sterling will generate "padding" `Boards` where nothing happens except the `turn` changing, until the number of `Boards` are met.
    - For this reason, our model can investigae the lower bound of `Board`s required, but not the upper bound.

### Running The Model
This is an example to run a game where each pocket starts with 1 marble, there are 2 pockets and 2 Mancalas (= 4 `Pocket`), and 7 `Board`s are allowed as maximum. 

```
run {
    wellformed
    fullGame[1]
} for exactly 2 Player, exactly 4 Pocket, 7 Board for {bnext is linear}
```
- The `Int` parameter in `traces` indicates the number of marbles each pocket will start with.
- The number of `Pocket`s must be even to satisfy the constraint that each player has the same number of pockets. 
- `Board` must be sufficiently large relative to the number of pockets and number of marbles for there to be a final state (where both players run out of marbles). Since `traces` requires a final state, the model will return `unsat` if there are not enough `Board`s.

### Understanding the Visualization
We use the default Sterling visualizer. It is easiest to view using `Add Time Projection` > `Board`. You should toggle between `Board`s to see where marbles are taken and transferred.
- Generally, the pattern will be that one Pocket containing `n` marbles will be zero'd out and the next `n` successive pockets will be incremented by 1. 
- In a case where a pocket out-of-order suddenly gains a lot of marbles, this pocket should be the mancala. This event means the next pocket in-sequence was empty, so that opposite pocket and marble-in-hand are transfered to the player's mancala.
- The visualizer does not show the `turn` and `hand` fields of `Board`, which can be accessed through the evaluator. It may be necessary to check these values to verify that it is the correct behavior.

### Testing
We do extensive unit-testing of our `init`, `move`, `wellformedPockets` and `wellformedBoard` predicates since they are most important in constraining the structure of the game. 

We tried doing induction testing using an additional board-specific `wellformed` predicate, like so:
```
pred wellformedBoard[b:Board] {
    some b.turn
    b.hand >= 0

    all pock : Pocket | {
        -- No negative marbles
        b.marbles[pock] >= 0
    }
}

test expect{}
    induction: {
        some b1, b2: Board{
            wellformedPockets
            wellformedBoard[b1]
            b2 = b1.bnext
            move[b1, b2]
            not wellformedBoard[b2]
        }
    } for exactly 2 Player, exactly 6 Pocket, 2 Board, 4 Int for {bnext is linear} is unsat
}
 ```
 However, this caused Forge to just give us cases that crossed the integer bitwidth. Since we require non-negative marbles for all pockets to be a wellformed Board, Forge generated cases where an increment to a pocket with 7 marbles in `b1` caused the pocket to have -8 marbles in `b2`.


For the rest, we do some `testExpects` to experiment with some properties of Mancala. As the game is completely deterministic based on the number of pockets, marbles and the choices of pockets, there are surely minimum and maximum bounds for the earliest and latest the game can end. For instance, we learn that:
- If you are committed to not triggering a 'stealing' event in your game, your game's maximum bound of number of increases by almost 100% (see `gameMustEndWithStealingMinBound` and `gameMustEndWithoutStealingMinBound`).
- If you play a game with just two pockets (and two mancalas), you can't **not** end the game by 6 Boards (see: `fourPocketGameMaxBound`).
