using Dates: now, Minute
using REPL: TerminalMenus, Terminals

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

function start_clock(nminutes)
    return @async begin
        i, t0 = 0, now()
        while (now() - t0) / Minute(1) ≤ nminutes
            i %= 24
            i += 1
            print(times[i])
            sleep(1)
            print('\b')
            print('\b')
        end
        print('🍅')
        print('\a')
    end
end

function get_char()
    t = TerminalMenus.terminal
    Terminals.raw!(t, true)
    char = read(stdin, Char)
    Terminals.raw!(t, false)
    return char
end

function (@main)(args)
    nminutes = parse(Float64, args[1])

    println("Press `Space` to start the clock! Press `q` to quit.")

    local tsk::Task

    while true
        ch = get_char()
        ticking = @isdefined(tsk) && !istaskdone(tsk)
        if ch == ' ' && !ticking
            tsk = start_clock(nminutes)
        elseif ch == 'q'
            print('\n')
            break
        else
            continue
        end
    end

    return 0
end
