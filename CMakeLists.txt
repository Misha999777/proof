cmake_minimum_required(VERSION 3.20)
project(ProofApp)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_WIN32_EXECUTABLE ON)

include(FetchContent)
FetchContent_Declare(
    saucer
    GIT_REPOSITORY https://github.com/saucer/saucer.git
    GIT_TAG        master
)
FetchContent_MakeAvailable(saucer)

file(GLOB_RECURSE SOURCES 
    "src/*.cpp" 
    "src/*.hpp"
    "src/*.rc"
)
add_executable(Proof ${SOURCES})
target_include_directories(Proof PRIVATE src)

target_link_libraries(Proof PRIVATE saucer::saucer saucer::embedded)
target_link_libraries(Proof PRIVATE dwmapi comctl32)

saucer_embed("${CMAKE_SOURCE_DIR}/build/frontend" TARGET Proof)
