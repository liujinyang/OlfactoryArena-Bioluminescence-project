cmake_minimum_required(VERSION 3.16)
project(c8855_dual_acquire LANGUAGES CXX)

add_executable(c8855_dual_acquire main.cpp c8855_dynamic_api.h C8855-01api.h)
target_compile_features(c8855_dual_acquire PRIVATE cxx_std_17)
if (MSVC)
  target_compile_options(c8855_dual_acquire PRIVATE /W4)
endif()
# No C8855-01api.lib is required. The program loads C8855-01api.dll at runtime.
