cmake_minimum_required(VERSION 3.26)

# Project Settings
project(UnionPlugin)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(UNION_API_DIR "${CMAKE_SOURCE_DIR}/dependencies/union-api")
set(GOTHIC_API_DIR "${CMAKE_SOURCE_DIR}/dependencies/gothic-api")
set(GOTHIC_USERAPI_DIR "${CMAKE_SOURCE_DIR}/gothic-userapi")

include(cmake/union-api.cmake)
include(cmake/gothic-api.cmake)

add_subdirectory(plugin)