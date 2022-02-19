cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

set(MOLD_VERSION 0.9.6)

project(mold LANGUAGES CXX VERSION ${MOLD_VERSION})

# Include Conan generated find modules
list(APPEND CMAKE_MODULE_PATH ${CMAKE_BINARY_DIR})

set(THREADS_PREFER_PTHREAD_FLAG ON)
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

#cmake_dependent_option(ENABLE_CODE_COVERAGE "Enable code coverage" ON "\"${CMAKE_CXX_COMPILER_ID}\" STREQUAL \"Clang\" OR \"${CMAKE_CXX_COMPILER_ID}\" STREQUAL \"GNU\"" OFF)
#cmake_dependent_option(ENABLE_INCLUDE_NATVIS "Enable inclusion of a natvis file for debugging" ON "\"${CMAKE_CXX_COMPILER_ID}\" STREQUAL \"MSVC\"" OFF)
#option(ENABLE_SANITIZERS "Enable Address Sanitizer and Undefined Behaviour Sanitizer if available" OFF)

add_executable(mold "")

set_property(TARGET mold PROPERTY POSITION_INDEPENDENT_CODE ON)

target_include_directories(mold
    INTERFACE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_sources(mold
    PRIVATE
        archive-file.h
        byteorder.h
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

target_compile_options(mold
    PRIVATE
        $<$<CXX_COMPILER_ID:AppleClang>:-Wno-deprecated-declarations> # warning: 'daemon' is deprecated: first deprecated in macOS 10.5 - Use posix_spawn APIs instead.
        $<$<CXX_COMPILER_ID:AppleClang,Clang>:-fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables>
)

target_compile_definitions(mold
    PRIVATE
        MOLD_VERSION="${MOLD_VERSION}"
)

target_link_libraries(mold
    PUBLIC
        $<$<NOT:$<BOOL:APPLE>>:OpenSSL::Crypto>
        TBB::tbb
        Threads::Threads    
        xxHash::xxhash
        ZLIB::ZLIB
)

add_subdirectory(elf)
add_subdirectory(macho)