# cmake/_Headers.cmake is generated by `mulle-sde`. Edits will be lost.
#
if( MULLE_TRACE_INCLUDE)
   MESSAGE( STATUS "# Include \"${CMAKE_CURRENT_LIST_FILE}\"" )
endif()

set( INCLUDE_DIRS
src
) 

set( PRIVATE_HEADERS
src/import-private.h
src/include-private.h
)

set( PUBLIC_HEADERS
src/import.h
src/include.h
src/version.h
src/vm.h
) 

