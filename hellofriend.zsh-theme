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
HEADLINE_LINE_MODE='auto' # on|auto|off (whether to print the line above the prompt)
HEADLINE_INFO_MODE='prompt' # precmd|prompt (whether info line is in $PROMPT or printed by precmd)
  # use "precmd" for window resize to work properly (but Ctrl+L doesn't show info line)
  # use "prompt" for Ctrl+L to clear properly (but window resize eats previous output)

# Options
HEADLINE_SHOW_LINE='true'
HEADLINE_SHOW_INTERSECTION='true'
#HEADLINE_SINGLE_ACTIVE='true'
#HEADLINE_DOUBLE_ACTIVE='false'

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
EMPTY=''
SPACE=' '
BRACKETS_OPEN='['
BRACKETS_CLOSE=']'
PARENTHESES_OPEN='('
PARENTHESES_CLOSE=')'

# Info styles (ANSI SGR codes)
HEADLINE_STYLE_DEFAULT='' # style applied to entire info line
HEADLINE_STYLE_JOINT=$F_GREY
if [ $IS_SSH = 0 ]; then
  HEADLINE_STYLE_USER=$F_MAGENTA
else
  HEADLINE_STYLE_USER=$F_RED
fi
HEADLINE_STYLE_HOST=$F_YELLOW
HEADLINE_STYLE_PATH=$F_BLUE
HEADLINE_STYLE_BRANCH=$F_CYAN
HEADLINE_STYLE_STATUS=$F_MAGENTA

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

GIT_STATUS_COUNTS='true'
GIT_STATUS_OMIT_ONE='false'

# Constants for zsh
setopt PROMPT_SP # always start prompt on new line
setopt PROMPT_SUBST # substitutions
autoload -U add-zsh-hook

# Local variables
_HEADLINE_LINE_OUTPUT='' # separator line
_HEADLINE_INFO_OUTPUT='' # text line
_HEADLINE_DO_SEP='false' # whether to show divider this time
if [ $IS_SSH = 0 ]; then
  _HEADLINE_DO_SEP='true' # assume it's not a fresh window
fi

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


# Git command wrapper
headline_git() {
    GIT_OPTIONAL_LOCKS=0 command git "$@"
}

# Git branch (or hash)
headline_git_branch() {
    local ref
    ref=$(headline_git symbolic-ref --quiet HEAD 2> /dev/null)
    local ret=$?
    if [[ $ret == 0 ]]; then
        echo ${ref#refs/heads/} # remove "refs/heads/" to get branch
    else # not on a branch
        [[ $ret == 128 ]] && return  # not a git repo
        ref=$(headline_git rev-parse --short HEAD 2> /dev/null) || return
        echo "$GIT_HASH$ref" # hash prefixed to distingush from branch
    fi
}

# Git status
headline_git_status() {
  # Data structures
  local order=('STAGED' 'CHANGED' 'UNTRACKED' 'BEHIND' 'AHEAD' 'DIVERGED' 'STASHED' 'CONFLICTS')
  local -A totals
  for key in $order; do
    totals+=($key 0)
  done

  # Retrieve status
  # REF: https://git-scm.com/docs/git-status
  local raw lines
  raw="$(headline_git status --porcelain -b 2> /dev/null)"
  if [[ $? == 128 ]]; then
    return 1 # catastrophic failure, abort
  fi
  lines=(${(@f)raw})

  # Process tracking line
  if [[ ${lines[1]} =~ '^## [^ ]+ \[(.*)\]' ]]; then
    local items=("${(@s/,/)match}")
    for item in $items; do
      if [[ $item =~ '(behind|ahead|diverged) ([0-9]+)?' ]]; then
        case $match[1] in
          'behind') totals[BEHIND]=$match[2];;
          'ahead') totals[AHEAD]=$match[2];;
          'diverged') totals[DIVERGED]=$match[2];;
        esac
      fi
    done
  fi

  # Process status lines
  for line in $lines; do
    if [[ $line =~ '^##|^!!' ]]; then
      continue
    elif [[ $line =~ '^U[AD]|^[AD]U|^AA|^DD' ]]; then
      totals[CONFLICTS]=$(( ${totals[CONFLICTS]} + 1 ))
    elif [[ $line =~ '^\?\?' ]]; then
      totals[UNTRACKED]=$(( ${totals[UNTRACKED]} + 1 ))
    elif [[ $line =~ '^[MTADRC] ' ]]; then
      totals[STAGED]=$(( ${totals[STAGED]} + 1 ))
    elif [[ $line =~ '^[MTARC][MTD]' ]]; then
      totals[STAGED]=$(( ${totals[STAGED]} + 1 ))
      totals[CHANGED]=$(( ${totals[CHANGED]} + 1 ))
    elif [[ $line =~ '^ [MTADRC]' ]]; then
      totals[CHANGED]=$(( ${totals[CHANGED]} + 1 ))
    fi
  done

  # Check for stashes
  if $(headline_git rev-parse --verify refs/stash &> /dev/null); then
    totals[STASHED]=$(headline_git rev-list --walk-reflogs --count refs/stash 2> /dev/null)
  fi

  # Build string
  local prefix status_str
  status_str=''
  for key in $order; do
    if (( ${totals[$key]} > 0 )); then
      if (( ${#status_str} )); then # not first iteration
        local style_joint="$RESET$HEADLINE_STYLE_DEFAULT$HEADLINE_STYLE_JOINT"
        local style_status="$RESET$HEADLINE_STYLE_DEFAULT$HEADLINE_STYLE_STATUS"
        status_str="$status_str%{$style_joint%}$EMPTY%{$style_status%}"
      fi
      eval prefix="\$GIT_STATUS_${key}"
      if [[ $GIT_STATUS_COUNTS == 'true' ]]; then
        if [[ $GIT_STATUS_OMIT_ONE == 'true' && (( ${totals[$key]} == 1 )) ]]; then
          status_str="$status_str$prefix"
        else
          status_str="$status_str${totals[$key]}$prefix"
        fi
      else
        status_str="$status_str$prefix"
      fi
    fi
  done

  # Return
  if (( ${#status_str} )); then
    echo $status_str
  else
    echo $GIT_STATUS_CLEAN
  fi
}



# Before executing command
add-zsh-hook preexec headline_preexec
headline_preexec() {
  # TODO better way of knowing the prompt is at the top of the terminal
  if [[ $2 == 'clear' ]]; then
    _HEADLINE_DO_SEP='false'
  fi
}

# Before prompting
add-zsh-hook precmd headline_precmd
headline_precmd() {
  # Information
  local user_str host_str path_str branch_str status_str
  [[ $HEADLINE_USER == 'true' ]] && user_str=$USER
  [[ $HEADLINE_HOST == 'true' ]] && host_str=$(hostname -s)
  [[ $HEADLINE_PATH == 'true' ]] && path_str=$(print -rP '%~')
  [[ $HEADLINE_GIT_BRANCH == 'true' ]] && branch_str=$(headline_git_branch)
  [[ $HEADLINE_GIT_STATUS == 'true' ]] && status_str=$(headline_git_status)

  # Trimming
  if (( $COLUMNS < 55 )); then
    user_str="${user_str:0:1}"
    host_str="${host_str:0:1}"
  fi

  # Shared variables
  _HEADLINE_LEN=0
  _HEADLINE_LEN_SUM=0
  _HEADLINE_INFO_LEFT=''
  _HEADLINE_LINE_LEFT=''
  _HEADLINE_INFO_RIGHT=''
  _HEADLINE_LINE_RIGHT=''

  local git_len len
  # Promp construction HEADLINE GIT STATUS
  if (( ${#status_str} )); then
    _headline_part JOINT "$HEADLINE_SINGLE_CORNER_BOTTOM_RIGHT" right
    _headline_part STATUS "$BRACKETS_OPEN$SPACE$status_str$SPACE$BRACKETS_CLOSE" right
  fi
  # Promp construction HEADLINE GIT BRANCH
  if (( ${#branch_str} )); then
    if (( ${#status_str} )); then
      _headline_part JOINT "$HEADLINE_SINGLE_BOTTOM_INTERSECTION" right
    else
      _headline_part JOINT "$HEADLINE_SINGLE_CORNER_BOTTOM_RIGHT" right
    fi
    _headline_part BRANCH "$BRACKETS_OPEN$SPACE$branch_str$SPACE$BRACKETS_CLOSE" right
  fi
  git_len=$_HEADLINE_LEN_SUM
  # Promp construction HEADLINE USER
  if (( ${#user_str} )); then
    _headline_part JOINT "$HEADLINE_SINGLE_CORNER_BOTTOM_LEFT" left
    _headline_part USER "$SPACE$user_str" left
  fi
  # Promp construction HEADLINE HOST
  if (( ${#host_str} )); then
    if (( ${#user_str} )); then
      _headline_part JOINT "$HEADLINE_SINGLE_BOTTOM_INTERSECTION" left
      _headline_part HOST "$host_str$SPACE" left
    else
      _headline_part JOINT "$HEADLINE_SINGLE_CORNER_BOTTOM_LEFT" left
      _headline_part HOST "$SPACE$host_str$SPACE" left
    fi
  fi
  # Promp construction HEADLINE PATH
  if (( ${#path_str} )); then
    if (( ${#host_str} )) || (( ${#user_str} )); then
      _headline_part JOINT "$HEADLINE_SINGLE_BOTTOM_INTERSECTION" left
    else
      _headline_part JOINT "$HEADLINE_SINGLE_CORNER_BOTTOM_LEFT" left
    fi
    len=$(( $COLUMNS - $_HEADLINE_LEN_SUM - ( $git_len ? ${#SPACE} + ${#SPACE} : 0 ) ))
    _headline_part PATH "$SPACE%$len<...<$path_str%<<$SPACE" left
    if (( ${#branch_str} )) || (( ${#status_str} )); then
      _headline_part JOINT "$HEADLINE_SINGLE_BOTTOM_INTERSECTION" right
    else
      _headline_part JOINT "$HEADLINE_SINGLE_CORNER_BOTTOM_RIGHT" right
    fi
  else
    if (( ${#host_str} )) || (( ${#user_str} )); then
      if (( ${#branch_str} )) || (( ${#status_str} )); then
        _headline_part JOINT "$HEADLINE_SINGLE_BOTTOM_INTERSECTION" left
      else
        _headline_part JOINT "$SPACE$HEADLINE_SINGLE_CORNER_BOTTOM_RIGHT" left
      fi
    else
      if (( ${#branch_str} )) || (( ${#status_str} )); then
        _headline_part JOINT "$HEADLINE_SINGLE_CORNER_BOTTOM_LEFT" left
      fi
    fi
  fi
  len=$(( $COLUMNS - $_HEADLINE_LEN_SUM - ${#SPACE} - ${#SPACE} ))

  # Separator line
  _HEADLINE_LINE_OUTPUT="$_HEADLINE_LINE_LEFT$_HEADLINE_LINE_RIGHT$RESET"
  if [[ $HEADLINE_LINE_MODE == 'on' || ($HEADLINE_LINE_MODE == 'auto' && $_HEADLINE_DO_SEP == 'true' ) ]]; then
    print -rP $_HEADLINE_LINE_OUTPUT
  fi
  _HEADLINE_DO_SEP='true'

  # Information line
  _HEADLINE_INFO_OUTPUT="$_HEADLINE_INFO_LEFT$_HEADLINE_INFO_RIGHT$RESET"
  if [[ $HEADLINE_INFO_MODE == 'precmd' ]]; then
    print -rP $_HEADLINE_INFO_OUTPUT
  fi
}

# Create a part of the prompt
_headline_part() { # (name, content, side)
  local style info line
  eval style="\$RESET\$HEADLINE_STYLE_DEFAULT\$HEADLINE_STYLE_${1}"
  info="%{$style%}$2"
  _HEADLINE_LEN=$(headline_prompt_len $info)
  _HEADLINE_LEN_SUM=$(( $_HEADLINE_LEN_SUM + $_HEADLINE_LEN ))
  eval style="\$RESET\$HEADLINE_STYLE_${1}"
  line="%{$style%}${(pl:$_HEADLINE_LEN::$HEADLINE_SINGLE_HORIZONTAL_LINE:)}"
  if [[ $3 == 'right' ]]; then
    _HEADLINE_INFO_RIGHT="$info$_HEADLINE_INFO_RIGHT"
    _HEADLINE_LINE_RIGHT="$line$_HEADLINE_LINE_RIGHT"
  else
    _HEADLINE_INFO_LEFT="$_HEADLINE_INFO_LEFT$info"
    _HEADLINE_LINE_LEFT="$_HEADLINE_LINE_LEFT$line"
  fi
}

# Prompt
headline_output() {
  print -rP $_HEADLINE_INFO_OUTPUT
  print -rP $HEADLINE_PROMPT
}

if [[ $HEADLINE_INFO_MODE == 'precmd' ]]; then
  PROMPT=$HEADLINE_PROMPT # line and info printed by precmd
else
  PROMPT='$(headline_output)' # only line printed by precmd
fi
PROMPT_EOL_MARK=''