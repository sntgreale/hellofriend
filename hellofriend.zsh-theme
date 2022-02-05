#!/bin/zsh

# HelloFriend ZSH Prompt

## Font types
BOLD=$'\e[1m'
ITALIC=$'\e[3m'
INVERT=$'\e[7m'
UNDERLINE=$'\e[4m'
FAINT=$'\e[2m'
RESET=$'\e[0m'

## Foreground and Background COLORS (Foreground -> F Background -> B )
F_BLACK=$'\e[30m'
B_BLACK=$'\e[40m'

F_WHITE=$'\e[37m'
B_WHITE=$'\e[47m'

F_RED=$'\e[31m'
B_RED=$'\e[41m'

F_GREEN=$'\e[32m'
B_GREEN=$'\e[42m'

F_BLUE=$'\e[34m'
B_BLUE=$'\e[44m'

F_CYAN=$'\e[36m'
B_CYAN=$'\e[46m'

F_YELLOW=$'\e[33m'
B_YELLOW=$'\e[43m'

F_MAGENTA=$'\e[35m'
B_MAGENTA=$'\e[45m'

F_GREY=$'\e[90m'
B_GREY=$'\e[100m'

F_BRIGHT_RED=$'\e[91m'
B_BRIGHT_RED=$'\e[101m'

F_BRIGHT_GREEN=$'\e[92m'
B_BRIGHT_GREEN=$'\e[102m'

F_BRIGHT_YELLOW=$'\e[93m'
B_BRIGHT_YELLOW=$'\e[103m'

F_BRIGHT_BLUE=$'\e[94m'
B_BRIGHT_BLUE=$'\e[104m'

F_BRIGHT_MAGENTA=$'\e[95m'
B_BRIGHT_MAGENTA=$'\e[105m'

F_BRIGHT_CYAN=$'\e[96m'
B_BRIGHT_CYAN=$'\e[106m'

F_BRIGHT_WHITE=$'\e[97m'
B_BRIGHT_WHITE=$'\e[107m'

# Flags
! [ -z "$SSH_TTY$SSH_CONNECTION$SSH_CLIENT" ]
IS_SSH=$?

# ------------------------------------------------
# Customization

# Options
HEADLINE_SHOW_LINE='true'
HEADLINE_SHOW_INTERSECTION='true'
HEADLINE_SINGLE_ACTIVE='true'
HEADLINE_DOUBLE_ACTIVE='false'

# Segments
HEADLINE_USER='true'
HEADLINE_HOST='true'
HEADLINE_PATH='true'
HEADLINE_GIT_BRANCH='true'
HEADLINE_GIT_STATUS='true'

# Promp Character
HEADLINE_PROMPT="%(#.#.%(!.!.$)) "

# Line drawing characters
# Representation of the drawing with single and double characters.
#
# Single:
# ┌─────┬─────┬─────────────────────────┬─────────────┬─────────────┐
# └ user┴host ┴ pathtotheuser'slocation ┴[ gitbranch ]┴[ gitstatus ]┘
#
# Double:
# ╔═════╦═════╦═════════════════════════╦═════════════╦═════════════╗
# ╚ user╩host ╩ pathtotheuser'slocation ╩[ gitbranch ]╩[ gitstatus ]╝
#
HEADLINE_SINGLE_HORIZONTAL_LINE='─'
HEADLINE_SINGLE_CORNER_TOP_LEFT='┌'
HEADLINE_SINGLE_CORNER_TOP_RIGHT='┐'
HEADLINE_SINGLE_CORNER_BOTTOM_LEFT='└'
HEADLINE_SINGLE_CORNER_BOTTOM_RIGHT='┘'
HEADLINE_SINGLE_TOP_INTERSECTION='┬'
HEADLINE_SINGLE_BOTTOM_INTERSECTION='┴'
#HEADLINE_SINGLE_LEFT_INTERSECTION='├'
#HEADLINE_SINGLE_RIGHT_INTERSECTION='┤'

HEADLINE_DOUBLE_HORIZONTAL_LINE='═'
HEADLINE_DOUBLE_CORNER_TOP_LEFT='╔'
HEADLINE_DOUBLE_CORNER_TOP_RIGHT='╗'
HEADLINE_DOUBLE_CORNER_BOTTOM_LEFT='╚'
HEADLINE_DOUBLE_CORNER_BOTTOM_RIGHT='╝'
HEADLINE_DOUBLE_TOP_INTERSECTION='╦'
HEADLINE_DOUBLE_BOTTOM_INTERSECTION='╩'
#HEADLINE_DOUBLE_LEFT_INTERSECTION='╠'
#HEADLINE_DOUBLE_RIGHT_INTERSECTION='╣'

# Constants
BRACKETS_OPEN='['
BRACKETS_CLOSE=']'
PARENTHESES_OPEN='('
PARENTHESES_CLOSE=')'

# Git status variables
GIT_HASH=':' # hash prefix to distinguish from branch
GIT_STATUS_STAGED='+'
GIT_STATUS_CHANGED='!'
GIT_STATUS_UNTRACKED='?'
GIT_STATUS_BEHIND='↓'
GIT_STATUS_AHEAD='↑'
GIT_STATUS_DIVERGED='↕'
GIT_STATUS_STASHED='*'
GIT_STATUS_CONFLICTS='✘' # Consider "%{$F_RED%}✘"
GIT_STATUS_CLEAN='✔' # Consider "%{$F_GREEN%}✔"

# ------------------------------------------------

# Calculate length of string, excluding formatting characters
# REF: https://old.reddit.com/r/zsh/comments/cgbm24/multiline_prompt_the_missing_ingredient/
headline_prompt_len() {
    emulate -L zsh
    local -i COLUMNS=${2:-COLUMNS}
    local -i x y=${#1} m
    if (( y )); then
        while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
            x=y
            (( y *= 2 ))
        done
        while (( y > x + 1 )); do
            (( m = x + (y - x) / 2 ))
            (( ${${(%):-$1%$m(l.x.y)}[-1]} = m ))
        done
    fi
    echo $x
}