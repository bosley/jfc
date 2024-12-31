# Project metadata
PROJECT_NAME := slp
VERSION := 0.0.1

# Compiler settings
CC := gcc
CFLAGS := -Wall -Wextra -Werror -std=c11 -g
CPPFLAGS := -MMD -MP
LDFLAGS :=
LDLIBS :=

# Apply external configurations
LDLIBS += $(foreach lib,$(EXTERNAL_LIBS),$(shell echo $(lib) | cut -d'=' -f2))
CFLAGS += $(EXTERNAL_CFLAGS)
LDFLAGS += $(EXTERNAL_LDFLAGS)
CPPFLAGS += $(foreach dir,$(EXTERNAL_INCLUDES),-I$(dir))

# Project structure (Go-like)
CMD_DIR := cmd
PKG_DIR := pkg
INTERNAL_DIR := internal
BUILD_DIR := build
BIN_DIR := bin

# Find all source files (maintaining Go-like structure)
CMD_SRCS := $(shell find $(CMD_DIR) -name '*.c')
PKG_SRCS := $(shell find $(PKG_DIR) -name '*.c')
INTERNAL_SRCS := $(shell find $(INTERNAL_DIR) -name '*.c')
SRCS := $(CMD_SRCS) $(PKG_SRCS) $(INTERNAL_SRCS)

# Generate object files list
OBJS := $(SRCS:%.c=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

# Main target name
TARGET := $(BIN_DIR)/$(PROJECT_NAME)

# Default target
.PHONY: all
all: $(TARGET)

# Create necessary directories
$(BUILD_DIR) $(BIN_DIR):
	@mkdir -p $@

# Linking
$(TARGET): $(OBJS) | $(BIN_DIR)
	@echo "Linking: $@"
	@$(CC) $(OBJS) $(LDFLAGS) $(LDLIBS) -o $@

# Compilation
$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	@echo "Compiling: $<"
	@mkdir -p $(dir $@)
	@$(CC) $(CPPFLAGS) $(CFLAGS) -I$(PKG_DIR) -I$(INTERNAL_DIR) -c $< -o $@

# Include dependency files
-include $(DEPS)

# Build for development
.PHONY: dev
dev: CFLAGS += -DDEVELOPMENT
dev: all

# Build for production
.PHONY: prod
prod: CFLAGS += -O2 -DPRODUCTION
prod: all

# Run tests
.PHONY: test
test:
	@echo "Running tests..."
	@find test -name '*_test.c' -exec $(CC) $(CFLAGS) {} -o $(BUILD_DIR)/test_runner \;
	@[ -f $(BUILD_DIR)/test_runner ] && $(BUILD_DIR)/test_runner

# Run benchmarks
.PHONY: bench
bench:
	@echo "Running benchmarks..."
	@find test -name '*_bench.c' -exec $(CC) $(CFLAGS) {} -o $(BUILD_DIR)/bench_runner \;
	@[ -f $(BUILD_DIR)/bench_runner ] && $(BUILD_DIR)/bench_runner

# Clean build files
.PHONY: clean
clean:
	@echo "Cleaning..."
	@rm -rf $(BUILD_DIR) $(BIN_DIR)

# Clean and rebuild
.PHONY: rebuild
rebuild: clean all

# Run the program
.PHONY: run
run: all
	@./$(TARGET)

# Format code (using clang-format with LLVM style)
.PHONY: fmt
fmt:
	@command -v clang-format >/dev/null 2>&1 && \
		find . -name '*.c' -o -name '*.h' | xargs clang-format -i -style=LLVM || \
		echo "clang-format not installed"

# Lint code
.PHONY: lint
lint:
	@command -v cppcheck >/dev/null 2>&1 && \
		cppcheck --enable=all --suppress=missingIncludeSystem . || \
		echo "cppcheck not installed"

# Generate documentation
.PHONY: docs
docs:
	@command -v doxygen >/dev/null 2>&1 && doxygen Doxyfile || echo "Doxygen not installed"

# Install the program
.PHONY: install
install: all
	@echo "Installing to /usr/local/bin"
	@install -m 755 $(TARGET) /usr/local/bin

# Show version
.PHONY: version
version:
	@echo $(PROJECT_NAME) version $(VERSION)

# Show help
.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all     : Build the project (default)"
	@echo "  dev     : Build for development"
	@echo "  prod    : Build for production"
	@echo "  test    : Run tests"
	@echo "  bench   : Run benchmarks"
	@echo "  fmt     : Format code"
	@echo "  lint    : Run static code analysis"
	@echo "  clean   : Remove build files"
	@echo "  rebuild : Clean and rebuild"
	@echo "  run     : Build and run the program"
	@echo "  docs    : Generate documentation"
	@echo "  install : Install the program"
	@echo "  version : Show version information"
	@echo "  help    : Show this help message"