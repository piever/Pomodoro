# Pomodoro

Simple pomodoro clock app.

## Setup

Install the [Julia](https://julialang.org/install/) programming language (minimum version 1.12, i.e., `juliaup add beta` at the moment).
You also need to manually make `~/.julia/bin` available on the PATH environment.

First start a Julia REPL. Then,

```julia-repl
julia> import Pkg # import package manager

julia> Pkg.Apps.add(url = "https://github.com/piever/Pomodoro.jl") # install app
```

Finally, exit the Julia REPL with `Ctrl + d`.

## Launching the app

To launch the app, run the following command in the terminal:

```
pomodoro 25
```

Replace `25` with the number of minutes you wish to run the pomodoro clock for (also accepts non-integer values, e.g., `2.5` would be two minutes and a half).
