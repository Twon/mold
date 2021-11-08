cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

set(MOLD_VERSION 0.9.6)

project(mold LANGUAGES CXX VERSION ${MOLD_VERSION})

# Include necessary submodules
list(APPEND CMAKE_MODULE_PATH ${CMAKE_BINARY_DIR})
find_package(TBB)
find_package(xxHash)
find_package(OpenSSL)
find_package(ZLIB)

add_executable(mold "")
target_include_directories(mold
    INTERFACE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_sources(mold
    PRIVATE
        byteorder.h
        cmdline.h
        compress.cc
        demangle.cc
        filepath.cc
        hyperloglog.cc
        main.cc
        mold.h
        perf.cc
        tar.cc
)

target_compile_features(mold
    PRIVATE
        cxx_std_20
)

target_compile_definitions(mold
    PRIVATE
        MOLD_VERSION="${MOLD_VERSION}"
)

target_link_libraries(mold
    PUBLIC
        OpenSSL::Crypto
        TBB::tbb
        xxHash::xxhash
        ZLIB::ZLIB
)

#if(LINUX)
    add_subdirectory(elf)
#elseif(APPLE)
    add_subdirectory(macho)
#else()
#    message(FATAL_ERROR "Unsupported operating system")
#endif()