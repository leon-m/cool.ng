#
# Inputs:
#   COOL_NG_HOME          top of source tree
#   COOL_NG_BUILD_DIR     build directory
#   COOL_NG_UNIT_TESTS    build unit tests (true/false)
#   COOL_NG_BUILD_DOC     build documentation (true/false)
#   COOL_NG_LIB_DIR       output directory for libraries
#   COOL_NG_BIN_DIR       output directory for binaries
#   COOL_NG_DOC_DIR       output directory for documentation
#   COOL_NG_DEV_LIBS      build development libraries (true/false)
#
# Outputs:
#   COOL_NG_COMPONENT_ARCHIVES              list of archive libraries provided by the component
#   COOL_NG_COMPONENT_LIBRARIES             list of shared (dynamic) libraries provided by the component
#   COOL_NG_COMPONENT_DEPENDS               list of libraries (static or dynamic) this component depends on
#   COOL_NG_COMPONENT_INCLUDE_DIRECTORIES   list of include directories for component
#


# --- top of source tree
if( NOT DEFINED COOL_NG_HOME )
  set( COOL_NG_HOME ${CMAKE_SOURCE_DIR} )
endif()

# --- build directory
if( NOT DEFINED COOL_NG_BUILD_DIR )
  set( COOL_NG_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR} )
endif()

# --- enable/disable and control unit tests
if( NOT DEFINED COOL_NG_UNIT_TESTS )
  set( COOL_NG_UNIT_TESTS true)
endif()

# --- enable/disable documentation build
if( NOT DEFINED COOL_NG_BUILD_DOC )
  set( COOL_NG_BUILD_DOC true )
endif()

# --- library and binary directories
if( NOT DEFINED COOL_NG_LIB_DIR )
  set( COOL_NG_LIB_DIR ${CMAKE_CURRENT_BINARY_DIR}/lib)
endif()

if( NOT DEFINED COOL_NG_BIN_DIR)
  set( COOL_NG_BIN_DIR ${CMAKE_CURRENT_BINARY_DIR}/bin)
endif()

if( NOT DEFINED COOL_NG_DOC_DIR)
  set( COOL_NG_DOC_DIR ${CMAKE_CURRENT_BINARY_DIR}/doc)
endif()

# --- test programs location
if( COOL_NG_UNIT_TESTS )
  if( NOT DEFINED COOL_NG_TEST_DIR )
    set( COOL_NG_TEST_DIR ${COOL_NG_BIN_DIR} )
  endif()
endif()

# --- Boost root, needed for unit tests
if ( NOT DEFINED BOOST_ROOT )
  if ( COOL_NG_UNIT_TESTS )
    message("BOOST_ROOT is not set, will use internal hardcoded location")
  endif()
endif()

# --- whether to compile development library versions or not
if( NOT DEFINED COOL_NG_DEV_LIBS )
  set ( COOL_NG_DEV_LIBS true)
endif()



# --- platform dependencies
if (WINDOWS)
  set( COOL_NG_PLATFORM_LIBRARIES DbgHelp.dll Ws2_32.dll )
  if( ${MSVC_VERSION} MATCHES "1800")
    set( COOL_NG_MSVC "12" )
  elseif( ${MSVC_VERSION} MATCHES "1900" )
    set( COOL_NG_MSVC "14" )
  elseif( ${MSVC_VERSION} MATCHES "1910" )
    set( COOL_NG_MSVC "15" )
  else()
    message( FATAL "unsupported visual studio compiler version ${MSVC_VERSION}" )
  endif()
elseif(LINUX)
  set( COOL_NG_PLATFORM_LIBRARIES pthread dispatch )
endif()


# --- library names
if( NOT WINDOWS )
  set( COOL_NG_LIB_STATIC      cool.ng)
  set( COOL_NG_LIB_DYNAMIC     cool.ng)
  set( COOL_NG_LIB_STATIC_DEV  cool.ng-dev)
  set( COOL_NG_LIB_DYNAMIC_DEV cool.ng-dev)
else()
  set( COOL_NG_LIB_STATIC      libcool.ng-vc${COOL_NG_MSVC})
  set( COOL_NG_LIB_DYNAMIC     cool.ng-vc${COOL_NG_MSVC})
  set( COOL_NG_LIB_STATIC_DEV  libcool.ng-dev-vc${COOL_NG_MSVC})
  set( COOL_NG_LIB_DYNAMIC_DEV cool.ng-dev-vc${COOL_NG_MSVC})
endif()


# --- library API header files
set( COOL_NG_API_HEADERS
    include/cool/ng/async.h
    include/cool/ng/error.h
    include/cool/ng/exception.h
    include/cool/ng/traits.h
    include/cool/ng/bases.h
    include/cool/ng/ip_address.h
    include/cool/ng/binary.h
    include/cool/ng/async/task.h
    include/cool/ng/async/runner.h
    include/cool/ng/async/event_sources.h
    include/cool/ng/async/net/server.h
    include/cool/ng/async/net/stream.h
)

set( COOL_NG_IMPL_HEADERS
    include/cool/ng/impl/platform.h
    include/cool/ng/impl/ip_address.h
    include/cool/ng/impl/async/task_traits.h
    include/cool/ng/impl/async/context.h
    include/cool/ng/impl/async/task.h
    include/cool/ng/impl/async/simple_impl.h
    include/cool/ng/impl/async/sequential_impl.h
    include/cool/ng/impl/async/intercept_impl.h
    include/cool/ng/impl/async/conditional_impl.h
    include/cool/ng/impl/async/repeat_impl.h
    include/cool/ng/impl/async/loop_impl.h
    include/cool/ng/impl/async/event_sources_types.h
    include/cool/ng/impl/async/net_server.h
    include/cool/ng/impl/async/net_stream.h
)

# ### ##################################################
# ###
# ### Cool library
# ###
# ### ##################################################

set( COOL_NG_LIB_HEADERS
  ${COOL_NG_HOME}/lib/include/lib/async/executor.h
)

set( COOL_NG_LIB_SRCS
  ${COOL_NG_HOME}/lib/src/bases.cpp
  ${COOL_NG_HOME}/lib/src/exception.cpp
  ${COOL_NG_HOME}/lib/src/error.cpp
  ${COOL_NG_HOME}/lib/src/ip_address.cpp
  ${COOL_NG_HOME}/lib/src/async/runner.cpp
  ${COOL_NG_HOME}/lib/src/async/event_sources.cpp
)

# --- executor sources
set (COOL_NG_GCD_EVENT_SOURCES_SRCS       ${COOL_NG_HOME}/lib/src/async/gcd/event_sources.cpp )
set (COOL_NG_GCD_EVENT_SOURCES_HEADERS    ${COOL_NG_HOME}/lib/src/async/gcd/event_sources.h )
set (COOL_NG_GCD_EXECUTOR_SRCS            ${COOL_NG_HOME}/lib/src/async/gcd/executor.cpp )
set (COOL_NG_GCD_EXECUTOR_HEADERS         ${COOL_NG_HOME}/lib/src/async/gcd/executor.h)

set (COOL_NG_WINCP_EVENT_SOURCES_SRCS     ${COOL_NG_HOME}/lib/src/async/wincp/event_sources.cpp )
set (COOL_NG_WINCP_EVENT_SOURCES_HEADERS  ${COOL_NG_HOME}/lib/src/async/wincp/event_sources.h )
set (COOL_NG_WINCP_EXECUTOR_SRCS          ${COOL_NG_HOME}/lib/src/async/wincp/executor.cpp)
set (COOL_NG_WINCP_EXECUTOR_HEADERS       ${COOL_NG_HOME}/lib/src/async/wincp/executor.h ${COOL_NG_HOME}/lib/src/async/wincp/critical_section.h)

if ( NOT WINDOWS )
  set (COOL_NG_EXECUTOR_FILES ${COOL_NG_GCD_EXECUTOR_SRCS} ${COOL_NG_GCD_EXECUTOR_HEADERS})
  set (COOL_NG_EVENT_SOURCES_FILES ${COOL_NG_GCD_EVENT_SOURCES_SRCS} ${COOL_NG_GCD_EVENT_SOURCES_HEADERS})
else()
  set (COOL_NG_EXECUTOR_FILES ${COOL_NG_WINCP_EXECUTOR_SRCS} ${COOL_NG_WINCP_EXECUTOR_HEADERS})
  set (COOL_NG_EVENT_SOURCES_FILES ${COOL_NG_WINCP_EVENT_SOURCES_SRCS} ${COOL_NG_WINCP_EVENT_SOURCES_HEADERS})
endif()

set( COOL_NG_GCD_IMPL_HEADERS
  ${COOL_NG_GCD_EXECUTOR_HEADERS}
  ${COOL_NG_GCD_EVENT_SOURCES_HEADERS}
)

set( COOL_NG_GCD_IMPL_SRCS
  ${COOL_NG_GCD_EXECUTOR_SRCS}
  ${COOL_NG_GCD_EVENT_SOURCES_SRCS}
)

set( COOL_NG_WINCP_IMPL_HEADERS
  ${COOL_NG_WINCP_EXECUTOR_HEADERS}
  ${COOL_NG_WINCP_EVENT_SOURCES_HEADERS}
)
set( COOL_NG_WINCP_IMPL_SRCS
  ${COOL_NG_WINCP_EXECUTOR_SRCS}
  ${COOL_NG_WINCP_EVENT_SOURCES_SRCS}
)

# -- cool library sources
set( COOL_NG_LIB_FILES ${COOL_NG_LIB_HEADERS} ${COOL_NG_LIB_SRCS} )
if( WINDOWS )
  set( COOL_NG_LIB_FILES ${COOL_NG_LIB_FILES} ${COOL_NG_WINCP_IMPL_HEADERS} ${COOL_NG_WINCP_IMPL_SRCS} )
else()
  set( COOL_NG_LIB_FILES ${COOL_NG_LIB_FILES} ${COOL_NG_GCD_IMPL_HEADERS} ${COOL_NG_GCD_IMPL_SRCS} )
endif()



# --- outputs
set( COOL_NG_COMPONENT_INCLUDE_DIRECTORIES
  ${COOL_NG_HOME}/include
  ${COOL_NG_HOME}/lib
  ${COOL_NG_HOME}/lib/include
)
set( COOL_NG_COMPONENT_ARCHIVES cool.ng-dev )
set( COOL_NG_COMPONENT_LIBRARIES cool.ng-dyn-dev )
set( COOL_NG_COMPONENT_DEPENDS ${COOL_NG_PLATFORM_LIBRARIES} )


# --- development libraries
add_library( cool.ng-dev STATIC ${COOL_NG_LIB_FILES} )
add_library( cool.ng-dyn-dev SHARED ${COOL_NG_LIB_FILES} )
target_include_directories( cool.ng-dev BEFORE PRIVATE ${COOL_NG_HOME}/lib/include)
target_include_directories( cool.ng-dev PUBLIC ${COOL_NG_COMPONENT_INCLUDE_DIRECTORIES})
target_include_directories( cool.ng-dyn-dev BEFORE PRIVATE ${COOL_NG_HOME}/lib/include)
target_include_directories( cool.ng-dyn-dev PUBLIC ${COOL_NG_COMPONENT_INCLUDE_DIRECTORIES})
target_compile_definitions( cool.ng-dev PUBLIC COOL_NG_BUILD COOL_NG_STATIC_LIBRARY )
target_compile_definitions( cool.ng-dyn-dev PUBLIC COOL_NG_BUILD )

# --- now set file names and locations
if( NOT WINDOWS )
  set_target_properties( cool.ng-dyn-dev PROPERTIES
    PREFIX "lib"
    OUTPUT_NAME "${COOL_NG_LIB_DYNAMIC_DEV}"
    LIBRARY_OUTPUT_DIRECTORY "${COOL_NG_LIB_DIR}"
  )
  set_target_properties( cool.ng-dev PROPERTIES
    PREFIX "lib"
    OUTPUT_NAME "${COOL_NG_LIB_STATIC_DEV}"
    ARCHIVE_OUTPUT_DIRECTORY "${COOL_NG_LIB_DIR}"
  )

  target_compile_options( cool.ng-dyn-dev PUBLIC -g -std=c++11 -fPIC )
  target_compile_options( cool.ng-dev PUBLIC -g -std=c++11 -fPIC )

  if (OSX)
    set_target_properties( cool.ng-dyn-dev PROPERTIES LINK_FLAGS "-undefined dynamic_lookup" )
    target_compile_options( cool.ng-dyn-dev PUBLIC -fbracket-depth=10000 )
    target_compile_definitions( cool.ng-dyn-dev PUBLIC OSX_TARGET OS_OBJECT_USE_OBJC=0 )
    target_compile_options( cool.ng-dev PUBLIC -fbracket-depth=10000 )
    target_compile_definitions( cool.ng-dev PUBLIC OSX_TARGET OS_OBJECT_USE_OBJC=0 )
  else()
    target_compile_definitions( cool.ng-dyn-dev PUBLIC LINUX_TARGET )
    target_compile_definitions( cool.ng-dev PUBLIC LINUX_TARGET )
  endif()

  target_compile_definitions( cool.ng-dyn-dev PUBLIC COOL_ASYNC_PLATFORM_GCD )
  target_compile_definitions( cool.ng-dev PUBLIC COOL_ASYNC_PLATFORM_GCD )

else()

  set_target_properties( cool.ng-dyn-dev PROPERTIES
    PREFIX ""
    OUTPUT_NAME "${COOL_NG_LIB_DYNAMIC_DEV}"
    RUNTIME_OUTPUT_DIRECTORY "${COOL_NG_BIN_DIR}"
  )
  target_link_libraries( cool.ng-dyn-dev ${COOL_NG_PLATFORM_LIBRARIES} )
  set_target_properties( cool.ng-dev PROPERTIES
    PREFIX "lib"
    OUTPUT_NAME "${COOL_NG_LIB_STATIC_DEV}"
    ARCHIVE_OUTPUT_DIRECTORY "${COOL_NG_LIB_DIR}"
  )
  target_link_libraries( cool.ng-dev ${COOL_NG_PLATFORM_LIBRARIES} )

  target_compile_options( cool.ng-dyn-dev PUBLIC /EHsc /bigobj /Zm750 )
  target_compile_definitions( cool.ng-dyn-dev PUBLIC _SCL_SECURE_NO_WARNINGS WINDOWS_TARGET COOL_ASYNC_PLATFORM_WINCP )
  target_compile_options( cool.ng-dev PUBLIC /EHsc /bigobj /Zm750 )
  target_compile_definitions( cool.ng-dev PUBLIC _SCL_SECURE_NO_WARNINGS WINDOWS_TARGET COOL_ASYNC_PLATFORM_WINCP )

endif()
