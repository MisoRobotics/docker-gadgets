# @brief Utilities for text manipulation.
thisdir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
. "${thisdir}/usage.sh"

# @description Remove all but the last trailing newline.
#
# @arg $1 str Path to file to trim.
#
# @exitcode 1 Invalid number of arguments.
trim-extra-trailing-newlines() {
  if [[ "$#" -ne "1" ]]; then
    print-usage "<url>" ; return 1
  fi
  # Source: https://unix.stackexchange.com/a/552195
  sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' $1
}

# @description Prepend the item to the list.

# @arg $1 str The list of items separated by `:`.
# @arg $2 str The item to prepend to the list if not already present.
#
# @exitcode 1 Invalid number of arguments.
prepend-item-if-not-present() {
  if [[ "$#" -ne "1" ]]; then
    print-usage "<url>" ; return 1
  fi
  local list="$1"
  local -r item="$2"
  if [[ ":${list}:" != *":${item}:"* ]]; then
    list="${item}${list:+:${list}}"
  fi
  # TODO(RWS): Else this should probably bring the path to the front.
  echo "${list}"
}
