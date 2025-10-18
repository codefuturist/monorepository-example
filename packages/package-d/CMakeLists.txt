cmake_minimum_required(VERSION 3.14)
project(package_d VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Library
add_library(package_d
    src/math_utils.cpp
)

target_include_directories(package_d
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

# Tests
enable_testing()
add_subdirectory(tests)

# Install
install(TARGETS package_d
    EXPORT package_d-targets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/
    DESTINATION include
)

install(EXPORT package_d-targets
    FILE package_d-config.cmake
    DESTINATION lib/cmake/package_d
)
