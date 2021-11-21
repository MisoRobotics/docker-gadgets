# @brief Print usage information.

# @description Print usage information.
print-usage() {
  (>&2 echo "usage: ${FUNCNAME[1]} $@")
}
