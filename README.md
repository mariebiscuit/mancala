
For this project, we ask that you submit a README that explains your implementation. At a minimum, you should address each of the following points:

What are you trying to model? Include a brief description that would give someone unfamiliar with the topic a basic understanding of your goal.
Give an overview of your model design choices, what checks or run statements you wrote, and what we should expect to see from an instance produced by the Sterling visualizer. How should we look at and interpret an instance created by your spec? Did you create a custom visualization, or did you use the default?
At a high level, what do each of your sigs and preds represent in the context of the model? Justify the purpose for their existence and how they fit together.
In addition to the README be sure to document your model and test files.

# Curiosity Modeling: Mancala
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
Our model also has the following `preds`:
- `wellformed`: Sets up th sensible physical stucture of the game 
    - All players have one mancala and have an equal number of pockets;
    - All pockets are connected to each other in a cycle;
    - A consecutive half of pockets belongs to one player and the other consecutive half belongs to another;
    - Pockets that are not mancalas have the correct opposites;
    - There are non-negative number of marbles in any holding structure (in hand or pockets);.
    - It is someone's turn in every game state.
- `init`: Sets up the starting state, with Integer parameter `n`
    - Player 1 starts first;
    - There are no marbles in hand or in any of the Mancalas;
    - All non-mancala pockets have the same `n` number of marbles.
- `final`: Sets up the endgame state
    - All marbles are in mancalas.
- `playerNoMarbles`: Helper predicate that for whether for a certain `Board` state, the player with the turn has no more marbles in pockets,
- `changeTurnKeepBoard`: Helper predicate for whether a given `pre` and `post` state have no difference except that the turn has changed.
- `otherPockUnchanged`: Helper predicate for whether, except for one specified `Pocket`, all other pockets are unchanged between `pre` and `post` Boards
- `move`: Predicate for a valid move between `pre` and `post` `Board` states. Most of our game logic lies in this predicate. It is a valid move if it is one of the events described above in the `bnext` field of the `Board` sig.
- `traces`: Predicate for a valid flow of game from start to end: that there is a starting state, ending state, and  every state in between is connected by a valid `move` to their next state. 
    - Takes an integer parameter `n` to pass into `init`


### Remarks on Design Choices
1. Events: We define each atomic event in our sequence of states as a change in some property of the game state, rather than using the start and end of player turns to define an event. 
    - We considered using the latter, but this would involve intermediately computing all the changes and making the accumulated updates to the Board. This was substantially more difficult since turns are of variable length and may involve multiple conditionals depending on the number of marbles the player picks up, and where they end. 
    - The former method allowed us to model the game succesfully state-to-state without requiring complex intermediate computations.
    - However, decoupling turns from 'events' means our model loses the ability to quickly answer some interesting questions about the game which are related to turns: for instance, count the minimum turns a player can take to win.
2. 'Do-Nothing' moves: Our `move` predicate consideres the change of turn without changing anything else on the board as a valid event. 
    - We need this to account for cases mid-game where one player runs out of marbles for their turn before the other player. The other player should be able to continue.
    - However, this also means that depending on the number of `Boards` indicated in the `run` statement, after both players run out of marbles Sterling will generate "padding" `Boards` where nothing happens except the `turn` changing, until the number of `Boards` are met.
    - For this reason, our model can investigae the lower bound of `Board`s required, but not the upper bound.

### Running The Model
This is an example to run a game where each pocket starts with 1 marble, there are 2 pockets and 2 Mancalas (= 4 `Pocket`), and 7 `Board`s are allowed as maximum. 

```
run {
    wellformed
    traces[1]
} for exactly 2 Player, exactly 4 Pocket, 7 Board for {bnext is linear}
```
- The `Int` parameter in `traces` indicates the number of marbles each pocket will start with.
- The number of `Pocket`s must be even to satisfy the constraint that each player has the same number of pockets. 
- `Board` must be sufficiently large relative to the number of pockets and number of marbles for there to be a final state (where both players run out of marbles). Since `traces` requires a final state, the model will return `unsat` if there are insufficient `Board`.

### Running The Model
We use the default Sterling visualizer. It is easiest to view by `Add Time Projection` > `Board`, and toggle between `Board`s to see where marbles are taken and transferred. One can trace the correct flow of marbles by toggling next/previous between Boards. 
- The visualizer does not show the `turn` and `hand` fields of `Board`, which can be accessed through the evaluator. It may be necessary to check these values to verify that it is the correct behavior.
- Generally, the pattern will be that one Pocket will be zero'd out and the next `n` successive pockets will be incremented by 1. In a case where a pocket out-of-order suddenly gains a lot of marbles, this pocket should be the mancala: this event means the next pocket was empty, so that opposite pocket and marble-in-hand are transfered to the player's mancala.