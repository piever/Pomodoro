# Pomodoro

Simple pomodoro clock app.

## Setup

Install the [Julia](https://julialang.org/install/) programming language (minimum version 1.11).

Navigate to the top level of the repository and install all the dependencies as follows.

First start a Julia REPL. Then,

```julia-repl
julia> ] # open Pkg mode

(@v1.11) pkg> activate . # activate the environment

(Pomodoro) pkg> instantiate # install dependencies
```

Finally, exit the Julia REPL with `Ctrl + d`.

## Launcing the app

To launch the app, run the following command in the terminal:

```
julia --project main.jl 25
```

Replace `25` with the number of minutes you wish to run the pomodo clock for (also accepts non-integer values, e.g., `2.5` would be two minutes and a half).


