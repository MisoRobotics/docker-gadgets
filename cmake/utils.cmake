cmake_minimum_required(VERSION 3.15)

# ~~~
# ! make_target_name Make the name of the target from a path.
#
# Replaces slashes with hyphens.
#
# \arg:output_variable Name of the CMake variable to output the result
# \arg:prefix A prefix for the target name.
# \arg:path Name of the directory to convert to a target name
# ~~~
function(make_target_name output_variable prefix path)
  string(REPLACE / - target ${path})
  set(${output_variable}
      "${prefix}${target}"
      PARENT_SCOPE)
endfunction()

# ~~~
# ! add_code_doc_sh : Generate documentation from the input shell code.
#
# \arg:sh_file the shell code file from which
# \group:DEPENDS targets of dependencies for generating documentation
# ~~~
function(add_code_doc_sh sh_file)
  set(multi_value_args DEPENDS)
  cmake_parse_arguments(fargs "" "" "${multi_value_args}" ${ARGN})

  get_filename_component(sh_file_name ${sh_file} NAME)
  set(md_file ${doc_BINARY_DIR}/${sh_file_name}.md)
  message(STATUS "Generating ${md_file}")

  make_target_name(target shdocs ${md_file})
  add_custom_target(
    ${target} ALL
    COMMAND ${CMAKE_COMMAND} -E make_directory "${doc_BINARY_DIR}"
    COMMAND shdoc ${sh_file} > ${md_file}
    DEPENDS ${fargs_DEPENDS}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endfunction()

macro(glob variable globbing_expression)
  file(
    GLOB ${variable}
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    CONFIGURE_DEPENDS ${globbing_expression})
endmacro()
