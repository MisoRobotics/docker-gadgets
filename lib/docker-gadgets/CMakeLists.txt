cmake_minimum_required(VERSION 3.15)

install(
  DIRECTORY .
  DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR}/${PROJECT_NAME}
  PATTERN "CMakeLists.txt" EXCLUDE)

# add_make_directory_target(${CMAKE_CURRENT_BINARY_DIR})
glob(FILES "./*")
list(FILTER FILES EXCLUDE REGEX "^CMakeLists\\.txt$")
foreach(sh_file ${FILES})
  add_code_doc_sh(${sh_file})
endforeach()
# DEPENDS_MAKE_DIRECTORY ${doc_BINARY_DIR}

install(
  DIRECTORY ${doc_BINARY_DIR}/
  DESTINATION ${CMAKE_INSTALL_FULL_DOCDIR}
  FILE_PERMISSIONS
    OWNER_READ
    OWNER_WRITE
    OWNER_EXECUTE
    GROUP_READ
    GROUP_EXECUTE
    WORLD_READ
    WORLD_EXECUTE
  PATTERN "CMakeLists.txt" EXCLUDE)
