NAME=fortharm
# Selecting Core
CORTEX_M=0

# Use newlib-nano. To disable it, specify USE_NANO=
USE_NANO=--specs=nano.specs

# Use seimhosting or not
USE_SEMIHOST=--specs=rdimon.specs 
USE_NOHOST=--specs=nosys.specs

CORE=CM$(CORTEX_M)
BASE=../..
INCLUDES = $(BASE)/include

# Compiler & Linker
CC=arm-none-eabi-gcc
CXX=arm-none-eabi-g++

# Options for specific architecture
ARCH_FLAGS=-mthumb -mcpu=cortex-m$(CORTEX_M)

# Startup code
STARTUP=$(BASE)/startup/startup_ARM$(CORE).S

# -Os -flto -ffunction-sections -fdata-sections to compile for code size
CFLAGS=$(ARCH_FLAGS) $(STARTUP_DEFS) -Os -flto -ffunction-sections -fdata-sections -I$(INCLUDES)
CXXFLAGS=$(CFLAGS)

# Link for code size
GC=-Wl,--gc-sections

# Create map file
MAP=-Wl,-Map=$(NAME).map

STARTUP_DEFS=-D__STARTUP_CLEAR_BSS -D__START=main

# Need following option for LTO as LTO will treat retarget(syscall_hardware)
# functions as unused without following option
CFLAGS+=-fno-builtin

LDSCRIPTS=-L. -T  gcc_6_2.ld    # -T gcc.ld
#LDSCRIPTS=-L. -L$(BASE)/ldscripts/LPC11xx -T LPC11x14_10x_rom.ld 

LFLAGS= $(USE_NANO) $(USE_NOHOST) $(LDSCRIPTS) $(GC) $(MAP)  -L$(BASE)/lib/LPC11xx -llpc11xx

#$(NAME)-$(CORE).axf: main.c $(NAME).c $(STARTUP)
$(NAME).hex: $(NAME).axf
	arm-none-eabi-objcopy -I ihex -S $(NAME).axf $(NAME).hex

$(NAME).axf: main.c asm_test.S forth.S dictionary_83.S $(STARTUP)
	$(CC) $(CFLAGS) main.c syscall_hardware.c asm_test.S forth.S dictionary_83.S $(LFLAGS) -o $@  #$^
	# arm-none-eabi-objcopy -I ihex -S prog.axf prog.hex # retarget-CM0.axf retarget.hex

flash: $(NAME).hex
	lpc21isp $(NAME).hex /dev/ttyUSB1 115200 12000


#main:	main.c
#	$(CC) $(CFLAGS)  $(LFLAGS) $(LDSCRIPS) main.c  $(BASE)/src/LPC11xx/startup_1114fn28.S

clean:
	rm -f *.axf *.map *.o *.hex *.a 
