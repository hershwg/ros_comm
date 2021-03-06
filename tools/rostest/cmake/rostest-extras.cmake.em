find_package(catkin REQUIRED)

include(CMakeParseArguments)

function(add_rostest file)
@[if BUILDSPACE]@
  # find program in buildspace
  find_program_required(ROSTEST_EXE rostest 
    PATHS @(PROJECT_SOURCE_DIR)/scripts
    NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
@[else]@
  # find program in installspace
  find_program_required(ROSTEST_EXE rostest 
    PATHS @(CMAKE_INSTALL_PREFIX)/bin
    NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
@[end if]@

  cmake_parse_arguments(_rostest "" "WORKING_DIRECTORY" "" ${ARGN})

  # Check that the file exists, #1621
  set(_file_name _file_name-NOTFOUND)
  if(IS_ABSOLUTE ${file})
    set(_file_name ${file})
  else()
    find_file(_file_name ${file}
              PATHS ${CMAKE_CURRENT_SOURCE_DIR}
              NO_DEFAULT_PATH
              NO_CMAKE_FIND_ROOT_PATH)  # for cross-compilation.  thanks jeremy.
    if(NOT _file_name)
      message(FATAL_ERROR "Can't find rostest file \"${file}\"")
    endif()
  endif()

  # strip PROJECT_SOURCE_DIR from absolute filename to get unique test name (as rostest does it internally)
  set(_testname ${_file_name})
  string(LENGTH "${PROJECT_SOURCE_DIR}/" prefix_length)
  string(SUBSTRING "${_testname}" 0 ${prefix_length} prefix)
  if("${PROJECT_SOURCE_DIR}/" STREQUAL "${prefix}")
    string(SUBSTRING "${_testname}" ${prefix_length} -1 _testname)
  endif()

  string(REPLACE "/" "_" _testname ${_testname})
  get_filename_component(_output_name ${_testname} NAME_WE)
  set(_output_name "${_output_name}.xml")
  set(cmd "${ROSTEST_EXE} --pkgdir=${PROJECT_SOURCE_DIR} --package=${PROJECT_NAME} ${_file_name}")
  catkin_run_tests_target("rostest" ${_testname} "rostest-${_output_name}" COMMAND ${cmd} WORKING_DIRECTORY ${_rostest_WORKING_DIRECTORY})
endfunction()
