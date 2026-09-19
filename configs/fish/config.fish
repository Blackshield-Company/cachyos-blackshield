# Blackshield theme pack — fish config
# Minimal themed shell: fastfetch greeting + nvim defaults.
# Reference: install.sh configs phase (never clobbers your existing config without a backup).

source /usr/share/cachyos-fish-config/cachyos-config.fish

# Blackshield greeting — the mercenary checks the field before you do
function fish_greeting
    if status is-interactive
        fastfetch
    end
end

# Default editor
set -gx EDITOR nvim
set -gx VISUAL nvim