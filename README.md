
For this project, we ask that you submit a README that explains your implementation. At a minimum, you should address each of the following points:

What are you trying to model? Include a brief description that would give someone unfamiliar with the topic a basic understanding of your goal.
Give an overview of your model design choices, what checks or run statements you wrote, and what we should expect to see from an instance produced by the Sterling visualizer. How should we look at and interpret an instance created by your spec? Did you create a custom visualization, or did you use the default?
At a high level, what do each of your sigs and preds represent in the context of the model? Justify the purpose for their existence and how they fit together.
In addition to the README be sure to document your model and test files.

# Curiosity Modeling: Mancala
## About the Game
![](https://www.thesprucecrafts.com/thmb/yA6Lp0LcwqefQrJiQtNNVZTwIco=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/mancala-411837_hero_2888-8bef0fd76a324c86b61325556710d89f.jpg)

"Mancala"" is a two-player game played on a board like above. Each player sits on one side of the board's length, so that each player has 6 number of 'pockets' on their side (the circular holes), and 1 Mancala on their right (the oblong hole). The game flow works as follows:

1. A player takes all the marbles from one of their pockets into their hand.
2. Going clockwise, the player drops one marble into each slot, where "slot" includes both pockets and Mancalas.
3. Depending on where the player drops their last marble, if the last marble...
    - Ends in a pocket with marbles: The next player takes their turn.
    - Ends in their own mancala: