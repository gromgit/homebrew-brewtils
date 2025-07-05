#!/usr/bin/env bash
[[ $(uname -s || true) == "Darwin" ]] && GNU_PREFIX=g
# string formatters
# Ref: console_codes(4) man page
if [[ -t 1 ]]; then
  # Csi_escape <param> - ECMA-48 CSI sequence
  Csi_escape() { printf "\033[%s" "$1"; }
else
  Csi_escape() { :; }
fi
# Sgr_escape <param> - ECMA-48 Set Graphics Rendition
Sgr_escape() { Csi_escape "${1}m"; }
Tty_mkbold() { Sgr_escape "1;${1:-39}"; }
Tty_red=$(Tty_mkbold 31)
Tty_green=$(Tty_mkbold 32)
# shellcheck disable=SC2034 # it's not used in here, but other scripts may use it
Tty_brown=$(Tty_mkbold 33)
Tty_blue=$(Tty_mkbold 34)
# shellcheck disable=SC2034 # it's not used in here, but other scripts may use it
Tty_magenta=$(Tty_mkbold 35)
Tty_cyan=$(Tty_mkbold 36)
# shellcheck disable=SC2034 # it's not used in here, but other scripts may use it
Tty_white=$(Tty_mkbold 37)
# shellcheck disable=SC2034 # it's not used in here, but other scripts may use it
Tty_underscore=$(Sgr_escape 38)
# shellcheck disable=SC2034 # it's not used in here, but other scripts may use it
Tty_bold=$(Tty_mkbold 39)
Tty_reset=$(Sgr_escape 0)
# shellcheck disable=SC2034 # it's not used in here, but other scripts may use it
Tty_clear_to_eol=$(Csi_escape K)
# shellcheck disable=SC2034 # it's not used in here, but other scripts may use it
Tty_clear_line=$(Csi_escape 2K)

# XDG Base Directory Specifications
# REF: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share/:/usr/share/}"
export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS:-/etc/xdg}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"

# fatal: Report fatal error
# USAGE: fatal <msg> ...
fatal() {
  local opts=(); while [[ $1 == "-"* ]]; do opts+=("$1"); shift; done
  # shellcheck disable=SC2154 # msg_prefix is set externally
  echo "${opts[@]}" "${Tty_red}${msg_prefix}FATAL ERROR:${Tty_reset} $*" >&2
  exit 1
}

# error: Report error
# USAGE: error <msg> ...
error() {
  local opts=(); while [[ $1 == "-"* ]]; do opts+=("$1"); shift; done
  echo "${opts[@]}" "${Tty_red}${msg_prefix}ERROR:${Tty_reset} $*" >&2
}

# warn: Report warning
# USAGE: warn <msg> ...
warn() {
  local opts=(); while [[ $1 == "-"* ]]; do opts+=("$1"); shift; done
  echo "${opts[@]}" "${Tty_blue}${msg_prefix}Warning:${Tty_reset} $*" >&2
}

# info: Informational message
# USAGE: info <msg> ...
info() {
  local opts=(); while [[ $1 == "-"* ]]; do opts+=("$1"); shift; done
  echo "${opts[@]}" "${Tty_green}${msg_prefix}Info:${Tty_reset} $*" >&2
}

# need_progs: Checks for command dependencies
# USAGE: need_progs <cmd> ...
need_progs() {
  local missing=()
  local i
  for i in "$@"; do
    type -P "${i}" &>/dev/null || missing+=("${i}")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    fatal "Commands missing: ${missing[*]}"
  fi
}

# dedup_list: deduplicate list of items
# USAGE: readarray -t arr < <(dedup_list "${arr[@]}")
dedup_list() {
  printf '%s\n' "$@" | awk '!x[$0]++'
}

# deurlify: %-decode input strings
# REF: https://en.wikipedia.org/wiki/Percent-encoding
# USAGE: deurlify <str> ...
deurlify() {
  local s
  for s in "$@"; do
    s=${s//%21/\!}
    s=${s//%23/\#}
    s=${s//%24/\$}
    s=${s//%25/\%}
    s=${s//%26/\&}
    s=${s//%27/\'}
    s=${s//%28/\(}
    s=${s//%29/\)}
    s=${s//%2[aA]/\*}
    s=${s//%2[bB]/\+}
    s=${s//%2[cC]/\,}
    s=${s//%2[fF]/\/}
    s=${s//%3[aA]/\:}
    s=${s//%3[bB]/\;}
    s=${s//%3[dD]/\=}
    s=${s//%3[fF]/\?}
    s=${s//%40/\@}
    s=${s//%5[bB]/\[}
    s=${s//%5[dD]/\]}
    echo "${s}"
  done
}

declare -A darwin_versions=(
  [monterey]=120000
  [big_sur]=110000
  [catalina]=101500
  [mojave]=101400
  [high_sierra]=101300
  [sierra]=101200
  [el_capitan]=101100
  [yosemite]=101000
  [mavericks]=100900
  [mountain_lion]=100800
  [lion]=100700
  [snow_leopard]=100600
)
# Ref: https://xcodereleases.com/
declare -A max_xcode_versions=(
  [big_sur]=130299
  [catalina]=120499
  [mojave]=110399
  [high_sierra]=100199
  [sierra]=090299
  [el_capitan]=080299
  [yosemite]=070299
  [mavericks]=060299
  [mountain_lion]=050199
  [lion]=040699
  [snow_leopard]=040299
)

# Generate integer version number
# USAGE: int_ver X.Y...
int_ver() {
  if [[ $1 =~ ([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    printf '%d%02d%02d' "${BASH_REMATCH[1]##0}" "${BASH_REMATCH[2]##0}" "${BASH_REMATCH[3]##0}"
  elif [[ $1 =~ ([0-9]+)\.([0-9]+) ]]; then
    printf '%d%02d00' "${BASH_REMATCH[1]##0}" "${BASH_REMATCH[2]##0}"
  elif [[ $1 =~ ([0-9]+) ]]; then
    printf '%d0000' "${BASH_REMATCH[1]##0}"
  fi
}

os_ver() {
  local v=${darwin_versions["$1"]}
  echo "${v:-999999}"
}

max_xcode_ver() {
  local v=${max_xcode_versions["$1"]}
  echo "${v:-999999}"
}

# os_name: Print Homebrew name of OS
# USAGE: os_name
os_name() {
  case "$(uname -s)" in
    Darwin)
      case "$(sw_vers -productVersion)" in
        14.*) echo "sonoma";;
        13.*) echo "ventura";;
        12.*) echo "monterey";;
        11.*) echo "big_sur";;
        10.15.*) echo "catalina";;
        10.14.*) echo "mojave";;
        10.13.*) echo "high_sierra";;
        10.12.*) echo "sierra";;
        10.11.*) echo "el_capitan";;
        *) fatal "Your macOS is too old to support Homebrew"
      esac
    ;;
    Linux)
      echo "$(uname -m || true)_linux"
    ;;
    *)
      fatal "Homebrew only supported on macOS and Linux"
    ;;
  esac
}

my_os=$(os_name)
my_os_sha256=$(os_name | shasum -a 256 | awk '{print $1}' || true)
my_ver=$(os_ver "${my_os}")
my_xcode_ver=$(max_xcode_ver "${my_os}")
if [[ -z ${HOMEBREW_LOGS} ]]; then
  case "$(uname -s)" in
    Darwin) dir=${HOME}/Library/Logs/Homebrew;;
    Linux) for dir in ${XDG_CACHE_HOME}/Homebrew/Logs ${HOME}/.cache/Homebrew/Logs; do [[ -d ${dir} ]] && break; done;;
    *) fatal "Unable to support '$(uname -s)'";;
  esac
  if [[ -d ${dir} ]]; then
    export HOMEBREW_LOGS=${dir}
  else
    fatal "Log directory '${dir}' not found"
  fi
fi
unset dir

# Memoization for can_build()
declare -A b_cache=()
shopt -s lastpipe extglob

# formula_names <formula_spec>...
formula_names() {
  local i; for i in "$@"; do
    case "${i}" in
      *Formula/*.rb) if [[ ${i} =~ .*Formula/(.*)\.rb ]]; then echo "${BASH_REMATCH[1]}"; fi;;
      \@new) git status -s | grep -E '^\?\? Formula/' | sed 's!.*/\(.*\)\.rb!\1!';;
      *) [[ -s Formula/${i}.rb ]] && echo "${i}";;
    esac
  done
}

# formula_path <formula>
formula_path() {
  need_progs "${GNU_PREFIX}realpath"
  local fpath
  if [[ -e Aliases/$1 ]]; then
    # Check for alias
    fpath=$("${GNU_PREFIX}realpath" --relative-base="${repo}" -e Aliases/"$1" 2>/dev/null)
  else
    fpath=Formula/${1}.rb
  fi
  if [[ -s ${fpath} ]]; then
    echo "${fpath}"
  else
    error "formula_path: $1 not found"
    return 1
  fi
}

# can_build <formula.rb>
can_build() {
  [[ -f $1 ]] || { warn "can_build: $1 not a file"; b_cache+=(["${name}"]=1); return 1; }
  local drop f1 f2 name
  local metajson=${repo}/.meta/formula.json
  name=$(basename "$1" .rb)

  # First check cache
  [[ -n ${b_cache["${name}"]} ]] && return "${b_cache["${name}"]}"

  # First check for explicit block
  grep -E "^${name}"$'\t' "${repo}/.settings/blocked" 2>/dev/null | while read -r _ drop; do
    warn "Skipping ${name} because ${drop}"
    b_cache+=(["${name}"]=1); return 1
  done

  # Then check for disabled!
  grep 'disable!' "$1" | while read -r _ f1 f2 _; do
    if [[ ${f1} == "date:" && ${f2//[\",]} < $(date +%Y-%m-d) ]]; then
      warn "Skipping ${name} because :disabled"
      b_cache+=(["${name}"]=1); return 1
    fi
  done

  # Then check for OS building
  local os_dep
  case "$(uname -s)" in
    Darwin)

      os_dep=$(jq '.[]|select(.name=="'"${name}"'" and .requirements[].name=="linux")' "${metajson}")
      if [[ -n ${os_dep} ]]; then
        warn "Skipping ${name} because depends_on :linux"
        b_cache+=(["${name}"]=1); return 1
      fi

      local min_os; min_os=$(grep "depends_on macos: :" "$1" 2>/dev/null)
      if [[ ${min_os} =~ .*macos:\ :([^ ]*) && $(os_ver "${BASH_REMATCH[1]}") -gt ${my_ver} ]]; then
        warn "Skipping ${name} because ${BASH_REMATCH[0]}"
        b_cache+=(["${name}"]=1); return 1
      fi

      local min_xcode; min_xcode=$(grep "depends_on xcode:" "$1" 2>/dev/null)
      if [[ ${min_xcode} =~ .*xcode:\ [^\"]*\"([^\"]+)\".* && $(int_ver "${BASH_REMATCH[1]}") -gt ${my_xcode_ver} ]]; then
        warn "Skipping ${name} because ${BASH_REMATCH[0]}"
        b_cache+=(["${name}"]=1); return 1
      fi

    ;;
    Linux)
      os_dep=$(jq 'map(select(.name=="'"${name}"'"))|.[].requirements[]|select(.name=="macos" and .version==null)' "${metajson}")
      if [[ -n ${os_dep} ]]; then
        warn "Skipping ${name} because depends_on :macos"
        b_cache+=(["${name}"]=1); return 1
      fi
    ;;
    *)
      warn "Skipping ${name} because unknown OS"
      b_cache+=(["${name}"]=1); return 1
    ;;
  esac

  # Then see if it's dependency-blocked
  # shellcheck disable=SC2154
  for drop in "${block_depends[@]}"; do
    if grep -Eq "depends_on ${drop}" "$1"; then
      warn "Skipping ${name} because ${drop}"
      b_cache+=(["${name}"]=1); return 1
    fi
  done

  b_cache+=(["${name}"]=0); return 0
}

# cmd: Show command being run
# USAGE: cmd <cmd> ...
cmd() {
  echo "${Tty_cyan}>>> $*${Tty_reset}" >&2
  command "$@"
}

# Check if formula needs rebottling
needs_rebottling() {
  # If no ${my_os}: or all: bottle spec...
  ! grep -Eq "sha256 .*(${my_os}|all):" "$@" ||
  # or it has a fake ${my_os} spec
  grep -Eq "sha256 .*${my_os}:.*\"${my_os_sha256}\"" "$@"
}

list_rebottling() {
  local f; for f in "$@"; do
    needs_rebottling "${f}" && echo "${f}"
  done
}

# remove_bottle_filter: Drop bottle block from stdin
remove_bottle_filter() {
  need_progs "${GNU_PREFIX}sed" "${GNU_PREFIX}cat"
  "${GNU_PREFIX}sed" '/^  bottle do/,/^  end/d' | "${GNU_PREFIX}cat" -s
}

# remove_bottle_block: Remove bottle block from formulae
remove_bottle_block() {
  local f
  for f in "$@"; do
    info "Debottling ${f}"
    remove_bottle_filter < "${f}" > "${HOMEBREW_TEMP}"/temp.rb && mv "${HOMEBREW_TEMP}"/temp.rb "${f}"
  done
}

# Replace existing bottle block with fake ${my_os} one
# This is a hack to force `brew test-bot` to fail properly
fake_bottle_filter() {
  "${funcs_dir}"/reset-bottle OS="${my_os}" SHA="${my_os_sha256}" COMMENT="fake ${my_os}"
}

# fake_bottle_block: Reset bottle block to fake one
fake_bottle_block() {
  local f
  for f in "$@"; do
    [[ -s ${f} ]] || continue
    info "Fake-bottling ${f}"
    fake_bottle_filter < "${f}" > "${HOMEBREW_TEMP}"/temp.rb && mv "${HOMEBREW_TEMP}"/temp.rb "${f}"
  done
}

# cmd_retry: Retry Git command on failure
# USAGE: cmd_retry [--tries=<n>] <cmd> <args>...
cmd_retry() {
  need_progs timelimit
  local tries=5
  while true; do
    case "$1" in
      --tries=*) tries=${1#*=};;
      *) break;
    esac
    shift
  done
  while [[ $((--tries)) -ge 0 ]]; do
    if cmd timelimit -t 120 "$@"; then
      return 0
    else
      warn "Command failed, ${tries} tries left."
    fi
  done
  return 1 # we failed
}

# git_in: Run Git command in repo
# USAGE: git_in <repo> <cmd> ...
git_in() {
  local repo=$1; shift
  pushd "${repo}" >/dev/null || fatal "Can't cd to '${repo}'"
  cmd_retry git "$@"
  popd >/dev/null || fatal "Can't popd"
}

# faketty: Run command with fake tty (optional logging)
# USAGE: faketty [-f <log_file>] <cmd> ...
faketty () {
  # Create a temporary file for storing the status code
  local logfile=/dev/null tmp cmd err
  while true; do
    case "$1" in
      -f) logfile=$2; shift;;
      *) break;;
    esac
    shift
  done

  tmp=$(mktemp)

  # Ensure it worked or fail with status 99
  [[ -n ${tmp} ]] || return 99

  # Produce a script that runs the command provided to faketty as
  # arguments and stores the status code in the temporary file
  cmd="$(printf '%q ' "$@")"'; echo $? > '"${tmp}"

  # Run the script through /bin/sh with fake tty
  if [[ $(uname) == "Darwin" ]]; then
    # MacOS
    SHELL=/bin/sh script -qF "${logfile}" /bin/sh -c "${cmd}"
  else
    SHELL=/bin/sh script -qfc "/bin/sh -c $(printf "%q " "${cmd}")" "${logfile}"
  fi

  # Ensure that the status code was written to the temporary file or
  # fail with status 99
  [[ -s ${tmp} ]] || return 99

  # Collect the status code from the temporary file
  err=$(cat "${tmp}")

  # Remove the temporary file
  rm -f "${tmp}"

  # Return the status code
  return "${err}"
}

# append_unique: Append elements to array if they don't already exist
# USAGE: append_unique <array_name> <element>...
append_unique() {
  local -n a=$1; shift
  local i n; for i in "$@"; do
    for n in "${a[@]}"; do
      [[ ${n} == "${i}" ]] && return 0
    done
    a+=("${i}")
  done
}

need_progs git

# Derive some important vars
cache_root=$(dirname "$(realpath "$(brew --cache)")")
export cache_root
funcs_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

export HOMEBREW_CACHE=${HOMEBREW_CACHE:-$(readlink "$(brew --cache)")}

for myvar in GITHUB_API_TOKEN GITHUB_PACKAGES_TOKEN GITHUB_PACKAGES_USER GITHUB_UPSTREAM GIT_EMAIL GIT_NAME GH_TOKEN; do
  mynewvar=HOMEBREW_${myvar}
  [[ -n ${!mynewvar} ]] && export "${myvar}=${!mynewvar}"
done
unset myvar mynewvar

# Run this script to get the necessary source instructions
# Ref: https://stackoverflow.com/a/28776166
(return 0 2>/dev/null) || {
#U USAGE: $0 [`-sh` [<script>]]
#U   Development standard bash library (when sourced)
#U   Output library `source` instructions (when run)
#U   `-sh` = Add bash shebang to instructions
#U   <script> = Write shebang to <script> and make it executable
  src_lib=../lib/funcs.sh
  case "$1" in
    -h|--help) usage 0;;
    -sh)
      [[ -n $2 ]] && {
        touch "$2" || fatal "unable to create '$2'"
        chmod +x "$2" || fatal "unable to make '$2' executable"
        exec >"$2"
      }
      echo "#!/usr/bin/env bash"
    ;;
    *) : ;;
  esac
  cat <<-EOF
	# Load development standard shell library
	# shellcheck source=${src_lib}
	. "\$(dirname "\$0")/${src_lib}"
	EOF
}
