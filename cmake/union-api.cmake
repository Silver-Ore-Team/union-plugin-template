add_library(union-api SHARED)
set_target_properties(union-api PROPERTIES
        OUTPUT_NAME "UnionAPI"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
        RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}"
        RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}")

target_include_directories(union-api PUBLIC "${UNION_API_DIR}/union-api")
target_link_directories(union-api PUBLIC "${UNION_API_DIR}/union-api")
target_compile_definitions(union-api PUBLIC WIN32 _CONSOLE _UNION_API_DLL "$<IF:$<CONFIG:DEBUG>,_DEBUG,NDEBUG>" PRIVATE _UNION_API_BUILD)

file(GLOB_RECURSE UNION_SOURCES "${UNION_API_DIR}/union-api/**.cpp")
target_sources(union-api PRIVATE ${UNION_SOURCES})

install(FILES $<TARGET_RUNTIME_DLLS:union-api> "${CMAKE_BINARY_DIR}/UnionAPI.dll" TYPE BIN)