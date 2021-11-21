cmake_minimum_required(VERSION 3.15)
project(
  docker-gadgets
  LANGUAGES NONE
  HOMEPAGE_URL https://github.com/MisoRobotics/docker-gadgets
  DESCRIPTION "Tools for containers and the humans who build them."
  VERSION 0.1.0)
set(CMAKE_SIZEOF_VOID_P 8) # Prevent a warning in GNUInstallDirs.
include(GNUInstallDirs)
include(cmake/utils.cmake)

set(PROJECT_AUTHOR "Ryan Sinnet <rsinnet@misorobotics.com>")
set(PROJECT_MAINTAINER "Ryan Sinnet <rsinnet@misorobotics.com>")
set(PROJECT_SERVICE_ORG "Miso Robotics, Inc.")

set(doc_BINARY_DIR "${CMAKE_BINARY_DIR}/share/doc/${PROJECT_NAME}")

add_subdirectory(lib)

include(cmake/package.cmake)
