using REPL: TerminalMenus, Terminals
using Dates: now, Second

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

function start_clock(t::Real; interval::Real = 1)
    t0 = now()
    isfirst = Ref(true)
    cycled = Iterators.cycle(times)
    emojis = Iterators.Stateful(cycled)
    return Timer(0; interval) do timer
        isfirst[] ? (isfirst[] = false) : (print('\b'); print('\b'))
        if (now() - t0) / Second(1) < t
            emoji = popfirst!(emojis)
            print(emoji)
        else
            close(timer)
            print('🍅')
            print('\a')
        end
    end
end

function run_app(t::Real; interval::Real = 1)
    println("Press `Space` to start the clock! Press `q` to quit.")

    open, timer = true, nothing

    while open
        ch = read(stdin, Char)
        isticking = !isnothing(timer) && isopen(timer)
        if isspace(ch)
            isticking || (timer = start_clock(t; interval))
        elseif lowercase(ch) == 'q'
            isticking && close(timer)
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
