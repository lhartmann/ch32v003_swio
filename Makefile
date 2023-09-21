
all : flash

TARGET  := out/code
SOURCES := ch32v003_swio.cpp
HEADERS := funconfig.h

CH32V003FUN=support/ch32v003fun

# Compiler selection
PREFIX := riscv64-unknown-elf-
CC  := $(PREFIX)gcc
CXX := $(PREFIX)g++
LD  := $(PREFIX)ld
AR  := $(PREFIX)ar
OD  := $(PREFIX)objdump
OC  := $(PREFIX)objcopy

ARCHFLAGS:=-march=rv32ec -mabi=ilp32e

# Pre-processor flags
CPPFLAGS:=

# C compiler flags
CFLAGS:=-g $(ARCHFLAGS) -Os -flto -ffunction-sections \
	-I/usr/include/newlib \
	-I$(CH32V003FUN)/extralibs \
	-I$(CH32V003FUN)/ch32v003fun \
	-I. -Wall

# C++ compiler flags
CXXFLAGS:=$(CFLAGS)

# Link flags
LINKER_SCRIPT?=$(CH32V003FUN)/ch32v003fun/ch32v003fun.ld
LDFLAGS:=-T $(LINKER_SCRIPT) $(ARCHFLAGS) -Wl,--gc-sections
LDLIBS:=-L$(CH32V003FUN)/misc -nostdlib --static -lgcc

WRITE_SECTION?=flash
SOURCES+=$(CH32V003FUN)/ch32v003fun/ch32v003fun.c

OBJS=$(patsubst %.c,%.o,$(patsubst %.cpp,%.o,$(SOURCES)))
$(TARGET).elf : $(OBJS)
	$(CC) -o $@ $(LDFLAGS) $^ $(LDLIBS)

$(TARGET).bin : $(TARGET).elf
	echo "$(OBJS)"
	$(PREFIX)size $^
	$(OD) -S $^ > $(TARGET).lst
	$(OD) -t $^ > $(TARGET).map
	$(OC) -O binary $< $(TARGET).bin
	$(OC) -O ihex $< $(TARGET).hex

closechlink :
	killall minichlink

terminal : monitor

monitor :
	minichlink -T

gdbserver :
	-minichlink -baG

clean :
	-rm -rf out/
	-rm -f $(OBJS)

out :
	mkdir out

build : out $(TARGET).bin

flash : build
	minichlink -w $(TARGET).bin $(WRITE_SECTION) -b
