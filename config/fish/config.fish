# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
#  FISH SHELL CONFIGURATION.
#
#  EVERY fish instance reads this file - including one started
#  non-interactively, e.g. via "fish -c something" or from a script.
#  Anything that prints output must therefore sit inside the
#  "status is-interactive" block, otherwise it ends up in other programs' pipes.
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

if status is-interactive
    # System info card when a terminal opens.
    #
    # MOVED FROM /etc/fish/config.fish, where it sat WITHOUT this condition.
    # The system file warns about it itself in a comment ("This file is run by all
    # fish instances"), and yet the call was bare - which made
    # fastfetch fire in non-interactive shells too.
    #
    # The symptom was easy to miss and misleading: a plain
    #     fish -c 'echo test'
    # printed the whole fastfetch graphic before the actual result.
    # In a script that reads such output, this ends with data
    # polluted by dozens of lines of ASCII art.
    #
    # Here the condition is present, so fastfetch shows up only when
    # you actually sit down at the terminal.
    if command -q fastfetch
        fastfetch
    end
end

# ----- PATHS -----
#
# fish_add_path instead of "export PATH=...:$PATH" - and this is not
# cosmetic. That form ADDS the directory on every fish start,
# and since shells are often nested, ~/.local/bin ended up
# in PATH four times. fish_add_path first checks whether the directory
# is already there.
#
# -g sets the variable globally for this session, but NOT permanently
# (that is what -U is for), so this file stays the single source of truth
# and leaves no state behind in fish's universal variables.
fish_add_path -g $HOME/.local/bin

# Flutter SDK (installed from a tarball, stable 3.47.2)
fish_add_path -g $HOME/flutter/bin
