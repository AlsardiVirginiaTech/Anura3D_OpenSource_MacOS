cmake_minimum_required(VERSION 3.15)
project(Anura3D Fortran C)

# Set Fortran standard and free-form format for .FOR files
set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules)
# Use -std=legacy to support Windows Fortran extensions (logical comparisons with ==, etc.)
set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -std=legacy -ffree-form -ffree-line-length-none -cpp -fcray-pointer")
set(CMAKE_Fortran_FLAGS_RELEASE "-O2")
set(CMAKE_Fortran_FLAGS_DEBUG "-g -O0 -fbacktrace")

# Ensure all .FOR files are treated as free-form
set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "export FFLAGS='${CMAKE_Fortran_FLAGS}';")

# Set default build type
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# Find required packages
find_package(HDF5 REQUIRED COMPONENTS Fortran)

# Include directories
include_directories(${HDF5_INCLUDE_DIRS})
include_directories(${CMAKE_Fortran_MODULE_DIRECTORY})

# Source files - include ALL source files
set(ANURA3D_SOURCES
    src/GlobalConstants.FOR
    src/DynamicLoading.for
    src/Anura3D.for
    src/Kernel.for
    src/FileIO.for
    src/ErrorHandler.for
    src/Feedback.for
    src/String.for
    src/timing.for
    src/getversion.for
    src/InitialiseElementType.for
    src/ExternalSoilModel.for
    src/WriteOutPut_GiD.for
    src/VS/NURBS.for
    src/VS/PM4Sand.FOR
)

# Additional source files from Soilmodels
file(GLOB SOILMODEL_SOURCES
    "src/Soilmodels/*.FOR"
    "src/Soilmodels/*.f"
    "src/Soilmodels/ThirdPartyLibraries/*.for"
)
list(APPEND ANURA3D_SOURCES ${SOILMODEL_SOURCES})

# Find additional .FOR files in src directory
file(GLOB ADDITIONAL_SOURCES
    "src/*.FOR"
)
# Remove duplicates (GlobalConstants already explicitly listed)
list(FILTER ADDITIONAL_SOURCES EXCLUDE REGEX "GlobalConstants")
list(APPEND ANURA3D_SOURCES ${ADDITIONAL_SOURCES})

# Remove duplicates
list(REMOVE_DUPLICATES ANURA3D_SOURCES)

# Create executable
add_executable(Anura3D ${ANURA3D_SOURCES})

# Link HDF5
target_link_libraries(Anura3D ${HDF5_Fortran_LIBRARIES})

# Set output directory
set_target_properties(Anura3D PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

# Print configuration
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Fortran compiler: ${CMAKE_Fortran_COMPILER}")
message(STATUS "HDF5 include: ${HDF5_INCLUDE_DIRS}")
message(STATUS "HDF5 libraries: ${HDF5_Fortran_LIBRARIES}")
message(STATUS "Source files: ${ANURA3D_SOURCES}")
