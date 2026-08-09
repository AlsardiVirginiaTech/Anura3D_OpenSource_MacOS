# Makefile for Anura3D on macOS
# Fortran Compiler: gfortran (GNU Fortran)
# Dependencies: HDF5

# Compiler and flags
FC = gfortran
FFLAGS = -O2 -fPIC -cpp -ffree-line-length-none -fimplicit-none
HDF5_FLAGS = $(shell h5fc -showconfig | grep "Fortran compiler" | awk '{print $$NF}')
HDF5_INCLUDE = $(shell pkg-config --cflags hdf5-fortran)
HDF5_LIBS = $(shell pkg-config --libs hdf5-fortran)

# Directories
SRC_DIR = src
BUILD_DIR = build
BIN_DIR = .

# Source files
SOURCES = \
	$(SRC_DIR)/Anura3D.for \
	$(SRC_DIR)/Kernel.for \
	$(SRC_DIR)/FileIO.for \
	$(SRC_DIR)/ErrorHandler.for \
	$(SRC_DIR)/Feedback.for \
	$(SRC_DIR)/String.for \
	$(SRC_DIR)/timing.for \
	$(SRC_DIR)/getversion.for \
	$(SRC_DIR)/InitialiseElementType.for \
	$(SRC_DIR)/ExternalSoilModel.for \
	$(SRC_DIR)/VS/NURBS.for \
	$(SRC_DIR)/WriteOutPut_GiD.for

# Object files
OBJECTS = $(SOURCES:.for=.o)
OBJECTS := $(addprefix $(BUILD_DIR)/,$(notdir $(OBJECTS)))

# Executable
EXECUTABLE = $(BIN_DIR)/Anura3D

# Default target
all: $(EXECUTABLE)

# Create build directory
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Link executable
$(EXECUTABLE): $(BUILD_DIR) $(OBJECTS)
	@echo "Linking $@..."
	$(FC) $(FFLAGS) $(HDF5_INCLUDE) -o $@ $(OBJECTS) $(HDF5_LIBS)
	@echo "Build complete: $@"

# Compile Fortran files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.for
	@echo "Compiling $<..."
	$(FC) $(FFLAGS) $(HDF5_INCLUDE) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/VS/%.for
	@echo "Compiling $<..."
	$(FC) $(FFLAGS) $(HDF5_INCLUDE) -c $< -o $@

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)
	rm -f $(EXECUTABLE)
	@echo "Clean complete"

# Rebuild
rebuild: clean all

.PHONY: all clean rebuild
