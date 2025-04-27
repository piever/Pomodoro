using REPL: TerminalMenus, Terminals

function with_raw_terminal(f)
    terminal = TerminalMenus.terminal
    try
        Terminals.raw!(terminal, true)
        f()
    finally
        Terminals.raw!(terminal, false)
    end
end

const times = [
    '🕛',
    '🕧',
    '🕐',
    '🕜',
    '🕑',
    '🕝',
    '🕒',
    '🕞',
    '🕓',
    '🕟',
    '🕔',
    '🕠',
    '🕕',
    '🕡',
    '🕖',
    '🕢',
    '🕗',
    '🕣',
    '🕘',
    '🕤',
    '🕙',
    '🕥',
    '🕚',
    '🕦',
]

struct Clock
    start::Timer
    stop::Timer
end

function stop(c::Clock)
    close(c.stop)
    close(c.start)
    return
end

isticking(c::Clock) = isopen(c.start) || isopen(c.stop)
isticking(::Nothing) = false

mutable struct State
    index::Int
    isfirst::Bool
end
State() = State(1, true)

function update!(st::State)
    st.index %= length(times)
    st.index += 1
    st.isfirst = false
    return st
end

function backspace(n::Integer)
    for _ in 1:n
        print('\b')
    end
end

function start_clock(t::Real; interval::Real = 1)
    st = State()
    start = Timer(0; interval) do _
        st.isfirst || backspace(2)
        print(times[st.index])
        update!(st)
    end
    stop = Timer(t) do _
        close(start)
        backspace(2)
        print('🍅')
        print('\a')
    end
    return Clock(start, stop)
end

function run_app(t::Real; interval::Real = 1)
    println("Press `Space` to start the clock! Press `q` to quit.")

    open, clock = true, nothing

    while open
        ch = read(stdin, Char)
        if isspace(ch)
            isticking(clock) || (clock = start_clock(t; interval))
        elseif lowercase(ch) == 'q'
            isticking(clock) && stop(clock)
            print('\n')
            open = false
        end
    end
end

function (@main)(args)
    nminutes = parse(Float64, args[1])
    nseconds = 60 * nminutes

    with_raw_terminal() do
        run_app(nseconds)
    end

    return 0
end
