# can be included multiple times

if( MULLE_TRACE_INCLUDE)
   message( STATUS "# Include \"${CMAKE_CURRENT_LIST_FILE}\"" )
endif()

#
# must be ahead of AllLoadC
#
include( ExecutableCAux OPTIONAL)

include( AllLoadC)
include( StartupC)

CreateForceAllLoadList( ALL_LOAD_DEPENDENCY_LIBRARIES FORCE_ALL_LOAD_DEPENDENCY_LIBRARIES)

set( EXECUTABLE_LIBRARY_LIST
   ${FORCE_ALL_LOAD_DEPENDENCY_LIBRARIES}
   ${DEPENDENCY_LIBRARIES}
   ${OPTIONAL_DEPENDENCY_LIBRARIES}
   ${OS_SPECIFIC_LIBRARIES}
)
