# NROM makefile
# Sean Latham, 2019

GAME_NAME = game.nes
GAME_DIR = ..
GAME = $(GAME_DIR)\$(GAME_NAME)

# Command references
CA65 = ca65
LD65 = ld65
MKDIR = mkdir
COPY = copy /b
PYTHON = python

# Directories
BUILD_DIR = ..\build

# List of source files
SOURCES = main.s player.s level.s debug.s
OBJECTS = $(addprefix $(BUILD_DIR)\,$(SOURCES:.s=.o))

# Files whose symbols are only exported once (built with EXPORT_GLOBALS set)
GLOBALS = global.s
GLOBALS_OBJECTS = $(addprefix $(BUILD_DIR)\,$(GLOBALS:.s=.o))

# Config/binaries/etc. Mostly boring stuff
HEADER = header.s
HEADER_CFG = $(HEADER:.s=.cfg)
HEADER_OBJ = $(BUILD_DIR)\$(HEADER:.s=.o)
HEADER_BIN = $(BUILD_DIR)\$(HEADER:.s=.bin)

CHR = chr.s
CHR_CFG = $(CHR:.s=.cfg)
CHR_OBJ = $(BUILD_DIR)\$(CHR:.s=.o)
CHR_BIN = $(BUILD_DIR)\$(CHR:.s=.bin)

PRG_CFG = prg.cfg
PRG_BIN = $(BUILD_DIR)\$(PRG_CFG:.cfg=.bin)
PRG_LABELS = $(BUILD_DIR)\$(PRG_CFG:.cfg=.labels.txt)

# Symbols provided to each file
BUILD_SYMBOLS :=

# Support for string substitution
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)

# TARGETS
.PHONY: all
all : directories $(GAME)

debugBuild : BUILD_SYMBOLS += -D DEBUG
debugBuild : all

$(GAME) : $(HEADER_BIN) $(PRG_BIN) $(CHR_BIN) FCEUX_SYMBOLS
	$(COPY) $(subst $(SPACE),+,$^) $(GAME)

$(HEADER_BIN) : $(HEADER_OBJ)
	$(LD65) -o $@ -C $(HEADER_CFG) $^

$(CHR_BIN) : $(CHR_OBJ)
	$(LD65) -o $@ -C $(CHR_CFG) $^

$(PRG_BIN) : $(OBJECTS) $(GLOBALS_OBJECTS)
	$(LD65) -o $@ -C $(PRG_CFG) $^ -Ln $(PRG_LABELS)

FCEUX_SYMBOLS : $(PRG_BIN)
	$(PYTHON) exportFCEUXsymbols.py $(PRG_LABELS) $(GAME)

$(GLOBALS_OBJECTS) : $(GLOBALS)
	$(CA65) $(notdir $(subst .o,.s,$@)) -g -U $(BUILD_SYMBOLS) -D EXPORT_GLOBALS -o $@

$(HEADER_OBJ) : $(HEADER)
	$(CA65) $(notdir $(subst .o,.s,$@)) -g -U $(BUILD_SYMBOLS) -o $@

$(CHR_OBJ) : $(CHR)
	$(CA65) $(notdir $(subst .o,.s,$@)) -g -U $(BUILD_SYMBOLS) -o $@

$(OBJECTS) : $(SOURCES)
	$(CA65) $(notdir $(subst .o,.s,$@)) -g -U $(BUILD_SYMBOLS) -o $@

# Make build directory if it doesn't exist
.PHONY: directories
directories : $(BUILD_DIR)

$(BUILD_DIR) :
	$(MKDIR) $(BUILD_DIR)

# Clean
.PHONY: clean
clean:
	del $(BUILD_DIR)\*.o $(BUILD_DIR)\*.bin $(BUILD_DIR)\*.labels.txt
	del $(GAME_DIR)\*.nl
