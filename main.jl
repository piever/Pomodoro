using REPL: TerminalMenus, Terminals
using Dates: now, Second
using Markdown: @md_str, MD

alert() = print("\a")
emoji_backspace() = print("\b\b")
hide_cursor() = print("\033[?25l")
show_cursor() = print("\033[?25h")

function get_char()
    terminal = TerminalMenus.terminal
    try
        hide_cursor()
        Terminals.raw!(terminal, true)
        read(stdin, Char)
    finally
        Terminals.raw!(terminal, false)
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

function start_clock(t::Real; interval::Real = 1)
    t0 = now()
    isfirst = Ref(true)
    cycled = Iterators.cycle(times)
    emojis = Iterators.Stateful(cycled)
    return Timer(0; interval) do timer
        isfirst[] ? (isfirst[] = false) : emoji_backspace()
        if (now() - t0) / Second(1) < t
            emoji = popfirst!(emojis)
            print(emoji)
        else
            close(timer)
            print("🍅")
            alert()
        end
    end
end

function run_app(t::Real; interval::Real = 1)
    msg = md"""
    __Instructions__

    Press `Enter` to start writing a message.
    When you are finished, press `Enter` again to start the clock.
    Press `q` to quit.
    """
    print_md(msg)

    open, timer = true, nothing

    while open
        ch = get_char()
        isticking = !isnothing(timer) && isopen(timer)

        if !isticking && (ch == '\r')
            println()
            println()
            print_md(md"__Task:__")
            print(" ")
            readline()
            print_md(md"__Status:__")
            print(" ")
            timer = start_clock(t; interval)
        elseif lowercase(ch) == 'q'
            isticking && close(timer)
            println()
            open = false
        end
    end
end

function (@main)(args)
    nminutes = parse(Float64, args[1])
    nseconds = 60 * nminutes
    run_app(nseconds)
    return 0
end
