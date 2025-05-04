module Pomodoro

using REPL.Terminals: TTYTerminal, raw!
using Dates: now, DateTime, Millisecond, Second, TimePeriod, canonicalize
using Markdown: @md_str, MD, Code

alert() = print("\a")
emoji_backspace() = print("\b\b")
hide_cursor() = print("\033[?25l")
show_cursor() = print("\033[?25h")

# From JuliaLang repo to avoid depending on internals
function default_terminal()
    term_type = get(ENV, "TERM", Sys.iswindows() ? "" : "dumb")
    return TTYTerminal(term_type, stdin, stdout, stderr)
end

function get_char()
    terminal = default_terminal()
    return try
        hide_cursor()
        raw!(terminal, true)
        read(stdin, Char)
    finally
        raw!(terminal, false)
        show_cursor()
    end
end

print_md(md::MD) = show(stdout, MIME"text/plain"(), md)

const times = [
    "🕛",
    "🕧",
    "🕐",
    "🕜",
    "🕑",
    "🕝",
    "🕒",
    "🕞",
    "🕓",
    "🕟",
    "🕔",
    "🕠",
    "🕕",
    "🕡",
    "🕖",
    "🕢",
    "🕗",
    "🕣",
    "🕘",
    "🕤",
    "🕙",
    "🕥",
    "🕚",
    "🕦",
]

mutable struct State{T}
    t0::DateTime
    dt::Millisecond
    ispaused::Bool
    isfirst::Bool
    const emojis::T
end

function State(t::TimePeriod)
    t0 = now()
    dt::Millisecond = t
    ispaused = false
    isfirst = true
    cycled = Iterators.cycle(times)
    emojis = Iterators.Stateful(cycled)
    return State(t0, dt, ispaused, isfirst, emojis)
end

function pause!(state::State)
    state.dt -= now() - state.t0
    state.ispaused = true
    return state
end

function resume!(state::State)
    state.t0 = now()
    state.ispaused = false
    return state
end

function start_timer(t::TimePeriod)
    state = State(t)
    timer = Timer(0; interval = 1) do _timer
        state.ispaused && return
        state.isfirst ? (state.isfirst = false) : emoji_backspace()
        if now() - state.t0 < state.dt
            emoji = popfirst!(state.emojis)
            print(emoji)
        else
            close(_timer)
            print("🍅")
            alert()
        end
    end
    return timer, state
end

function run_app(t::TimePeriod)
    time = canonicalize(t)

    msg = md"""
    __Instructions__

    The timer is set for $(time).\
    Press `Enter` to start writing a message.\
    When you are finished, press `Enter` again to start the clock.\
    Press `p` to pause / restart the clock. Press `q` to quit.
    """
    print_md(msg)

    state, timer = nothing, nothing

    while true
        ch = get_char()
        isrunning = !isnothing(timer) && isopen(timer)

        if ch == '\r'
            isrunning && continue

            println()
            println()
            print_md(md"__Task:__")
            print(" ")
            readline()

            print_md(md"__Status:__")
            print(" ")

            timer, state = start_timer(t)
        elseif lowercase(ch) == 'p'
            isrunning || continue
            state.ispaused ? resume!(state) : pause!(state)
        elseif lowercase(ch) == 'q'
            isrunning && close(timer)
            println()
            break
        end
    end
    return
end

function (@main)(ARGS)
    str = get(ARGS, 1, "25")
    nminutes = tryparse(Float64, str)
    if isnothing(nminutes)
        code = Code(str)
        msg = md"""
        Could not understand $(code) as number of minutes.
        """
        print_md(msg)
        println()
        return 1
    else
        nseconds = round(Int, 60 * nminutes)
        t = Second(nseconds)
        run_app(t)
        return 0
    end
end

end
