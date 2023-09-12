include(cmake/SystemLink.cmake)
include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)


macro(best_practices_starter_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    set(SUPPORTS_UBSAN ON)
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    set(SUPPORTS_ASAN ON)
  endif()
endmacro()

macro(best_practices_starter_setup_options)
  option(best_practices_starter_ENABLE_HARDENING "Enable hardening" ON)
  option(best_practices_starter_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    best_practices_starter_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    best_practices_starter_ENABLE_HARDENING
    OFF)

  best_practices_starter_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR best_practices_starter_PACKAGING_MAINTAINER_MODE)
    option(best_practices_starter_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(best_practices_starter_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(best_practices_starter_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(best_practices_starter_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(best_practices_starter_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(best_practices_starter_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(best_practices_starter_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(best_practices_starter_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(best_practices_starter_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(best_practices_starter_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(best_practices_starter_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(best_practices_starter_ENABLE_PCH "Enable precompiled headers" OFF)
    option(best_practices_starter_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(best_practices_starter_ENABLE_IPO "Enable IPO/LTO" ON)
    option(best_practices_starter_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(best_practices_starter_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(best_practices_starter_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(best_practices_starter_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(best_practices_starter_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(best_practices_starter_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(best_practices_starter_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(best_practices_starter_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(best_practices_starter_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(best_practices_starter_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(best_practices_starter_ENABLE_PCH "Enable precompiled headers" OFF)
    option(best_practices_starter_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      best_practices_starter_ENABLE_IPO
      best_practices_starter_WARNINGS_AS_ERRORS
      best_practices_starter_ENABLE_USER_LINKER
      best_practices_starter_ENABLE_SANITIZER_ADDRESS
      best_practices_starter_ENABLE_SANITIZER_LEAK
      best_practices_starter_ENABLE_SANITIZER_UNDEFINED
      best_practices_starter_ENABLE_SANITIZER_THREAD
      best_practices_starter_ENABLE_SANITIZER_MEMORY
      best_practices_starter_ENABLE_UNITY_BUILD
      best_practices_starter_ENABLE_CLANG_TIDY
      best_practices_starter_ENABLE_CPPCHECK
      best_practices_starter_ENABLE_COVERAGE
      best_practices_starter_ENABLE_PCH
      best_practices_starter_ENABLE_CACHE)
  endif()

  best_practices_starter_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  if(LIBFUZZER_SUPPORTED AND (best_practices_starter_ENABLE_SANITIZER_ADDRESS OR best_practices_starter_ENABLE_SANITIZER_THREAD OR best_practices_starter_ENABLE_SANITIZER_UNDEFINED))
    set(DEFAULT_FUZZER ON)
  else()
    set(DEFAULT_FUZZER OFF)
  endif()

  option(best_practices_starter_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

macro(best_practices_starter_global_options)
  if(best_practices_starter_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    best_practices_starter_enable_ipo()
  endif()

  best_practices_starter_supports_sanitizers()

  if(best_practices_starter_ENABLE_HARDENING AND best_practices_starter_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR best_practices_starter_ENABLE_SANITIZER_UNDEFINED
       OR best_practices_starter_ENABLE_SANITIZER_ADDRESS
       OR best_practices_starter_ENABLE_SANITIZER_THREAD
       OR best_practices_starter_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${best_practices_starter_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${best_practices_starter_ENABLE_SANITIZER_UNDEFINED}")
    best_practices_starter_enable_hardening(best_practices_starter_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(best_practices_starter_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(best_practices_starter_warnings INTERFACE)
  add_library(best_practices_starter_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  best_practices_starter_set_project_warnings(
    best_practices_starter_warnings
    ${best_practices_starter_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  if(best_practices_starter_ENABLE_USER_LINKER)
    include(cmake/Linker.cmake)
    configure_linker(best_practices_starter_options)
  endif()

  include(cmake/Sanitizers.cmake)
  best_practices_starter_enable_sanitizers(
    best_practices_starter_options
    ${best_practices_starter_ENABLE_SANITIZER_ADDRESS}
    ${best_practices_starter_ENABLE_SANITIZER_LEAK}
    ${best_practices_starter_ENABLE_SANITIZER_UNDEFINED}
    ${best_practices_starter_ENABLE_SANITIZER_THREAD}
    ${best_practices_starter_ENABLE_SANITIZER_MEMORY})

  set_target_properties(best_practices_starter_options PROPERTIES UNITY_BUILD ${best_practices_starter_ENABLE_UNITY_BUILD})

  if(best_practices_starter_ENABLE_PCH)
    target_precompile_headers(
      best_practices_starter_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(best_practices_starter_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    best_practices_starter_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(best_practices_starter_ENABLE_CLANG_TIDY)
    best_practices_starter_enable_clang_tidy(best_practices_starter_options ${best_practices_starter_WARNINGS_AS_ERRORS})
  endif()

  if(best_practices_starter_ENABLE_CPPCHECK)
    best_practices_starter_enable_cppcheck(${best_practices_starter_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(best_practices_starter_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    best_practices_starter_enable_coverage(best_practices_starter_options)
  endif()

  if(best_practices_starter_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(best_practices_starter_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(best_practices_starter_ENABLE_HARDENING AND NOT best_practices_starter_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR best_practices_starter_ENABLE_SANITIZER_UNDEFINED
       OR best_practices_starter_ENABLE_SANITIZER_ADDRESS
       OR best_practices_starter_ENABLE_SANITIZER_THREAD
       OR best_practices_starter_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    best_practices_starter_enable_hardening(best_practices_starter_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()
