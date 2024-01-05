# Makefile

WARNINGS        = -Wno-padded -Wno-cast-align -Wno-unreachable-code -Wno-packed -Wno-missing-noreturn -Wno-float-equal -Wno-unused-macros -Werror=return-type -Wextra -Wno-unused-parameter -Wno-trigraphs

COMMON_CFLAGS   = -Wall -O0 -g

CC              := clang
CXX             := clang++

CFLAGS          = $(COMMON_CFLAGS) -std=c99 -fPIC -O3
CXXFLAGS        = $(COMMON_CFLAGS) -Wno-old-style-cast -std=c++17 -fno-exceptions

CXXSRC          = $(shell find source -iname "*.cpp" -print)
CXXOBJ          = $(CXXSRC:.cpp=.cpp.o)
CXXDEPS         = $(CXXOBJ:.o=.d)

UTF8PROC_SRCS   = external/utf8proc/utf8proc.c
UTF8PROC_OBJS   = $(UTF8PROC_SRCS:.c=.c.o)

PRECOMP_HDRS    := source/include/precompile.h
PRECOMP_GCH     := $(PRECOMP_HDRS:.h=.h.gch)

DEFINES         :=
INCLUDES        := -Isource/include -Iexternal

OUTPUT_DIR      := build
OUTPUT_BIN      := lc

.PHONY: all clean build output_headers
.PRECIOUS: $(PRECOMP_GCH)
.DEFAULT_GOAL = all

all: build

test: build
	@$(OUTPUT_BIN)

build: $(OUTPUT_DIR)/$(OUTPUT_BIN)

$(OUTPUT_DIR)/$(OUTPUT_BIN): $(CXXOBJ) $(UTF8PROC_OBJS) 
	@echo "  $(notdir $@)"
	@mkdir -p $(OUTPUT_DIR)
	@$(CXX) $(CXXFLAGS) $(WARNINGS) $(DEFINES) -Iexternal -o $@ $^

%.cpp.o: %.cpp Makefile $(PRECOMP_GCH)
	@echo "  $(notdir $<)"
	@$(CXX) $(CXXFLAGS) $(WARNINGS) $(INCLUDES) $(DEFINES) -include source/include/precompile.h -MMD -MP -c -o $@ $<

%.c.o: %.c Makefile
	@echo "  $(notdir $<)"
	@$(CC) $(CFLAGS) -MMD -MP -c -o $@ $<

%.h.gch: %.h Makefile
	@printf "# precompiling header $<\n"
	@$(CXX) $(CXXFLAGS) $(WARNINGS) $(INCLUDES) -x c++-header -o $@ $<

clean:
	-@find source -iname "*.cpp.d" | xargs rm 2>/dev/null || true
	-@find source -iname "*.cpp.o" | xargs rm 2>/dev/null || true
	-@find build -iname "*.a" | xargs rm 2>/dev/null || true
	-@rm $(PRECOMP_GCH) 2>/dev/null || true
	-@rm $(OUTPUT_DIR)/$(OUTPUT_BIN) 2>/dev/null || true

-include $(CXXDEPS)
-include $(CDEPS)












