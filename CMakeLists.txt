cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

set(MOLD_VERSION 1.0.3)

project(mold LANGUAGES CXX VERSION ${MOLD_VERSION})

# Include Conan generated find modules
list(APPEND CMAKE_MODULE_PATH ${CMAKE_BINARY_DIR})

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(mimalloc REQUIRED)
find_package(Threads REQUIRED)
find_package(TBB REQUIRED)
find_package(xxHash REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(ZLIB REQUIRED)

include(CTest)
include(FetchContent)
include(GNUInstallDirs)
include(CMakeDependentOption)
include(CMakePackageConfigHelpers)

option(USE_MIMALLOC "Enable mimalloc as a memory allocator" ON)
option(ENABLE_LTO "Enable link-time optimisation" OFF)

find_package(Git)
find_file(GITDIR NAMES .git PATHS ${CMAKE_SOURCE_DIR} NO_DEFAULT_PATH)

if (Git_FOUND AND GITDIR)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
        OUTPUT_VARIABLE GIT_HEAD_SHA1
    )
    string(STRIP ${GIT_HEAD_SHA1} GIT_HEAD_SHA1) # Remove newline character
    message(STATUS "Git found.  GIT_HEAD_SHA1 is set to ${GIT_HEAD_SHA1}")
else()
    message(STATUS "Git not found.  GIT_HEAD_SHA1 is not set")
endif()

add_executable(mold "")

set_target_properties(mold 
    PROPERTIES
        CXX_STANDARD 20
        CXX_STANDARD_REQUIRED YES
        CXX_EXTENSIONS NO
        POSITION_INDEPENDENT_CODE ON
)

target_include_directories(mold
    INTERFACE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_sources(mold
    PRIVATE
        archive-file.h
        big-endian.h
        cmdline.h
        compress.cc
        demangle.cc
        filepath.cc
        filetype.h
        hyperloglog.cc
        lto.h
        main.cc
        mold.h
        perf.cc
        sha.h
        strerror.cc
        tar.cc
)

target_compile_features(mold
    PRIVATE
        cxx_std_20
)

target_compile_definitions(mold
    PRIVATE
        MOLD_VERSION=\"${MOLD_VERSION}\"
        GIT_HASH=\"${GIT_HEAD_SHA1}\"
        $<$<BOOL:${USE_MIMALLOC}>:USE_SYSTEM_MIMALLOC>
)

target_compile_options(mold
    PRIVATE
        $<$<BOOL:${ENABLE_LTO}>:-flto>
        $<$<CXX_COMPILER_ID:AppleClang>:-Wno-deprecated-declarations> # warning: 'daemon' is deprecated: first deprecated in macOS 10.5 - Use posix_spawn APIs instead.
        $<$<CXX_COMPILER_ID:AppleClang,Clang>:-fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables>
)

target_link_options(mold
    PRIVATE
        $<$<BOOL:${ENABLE_LTO}>:-flto>
)

target_link_libraries(mold
    PUBLIC
        $<$<BOOL:${USE_MIMALLOC}>:mimalloc::mimalloc>
        $<$<NOT:$<BOOL:APPLE>>:OpenSSL::Crypto>
        TBB::tbb
        Threads::Threads    
        xxHash::xxhash
        ZLIB::ZLIB
)

add_subdirectory(elf)
add_subdirectory(macho)