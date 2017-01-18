################################################################################
# Makefile
################################################################################

# Program Paths
AVRDIR	= d:\Programme\Arduino\hardware\tools\avr
AVRDUDE	= $(AVRDIR)\bin\avrdude
CXX	= $(AVRDIR)\bin\avr-g++ 
AS	= $(AVRDIR)\bin\avr-as
LD	= $(AVRDIR)\bin\avr-ld
OBJCOPY	= $(AVRDIR)\bin\avr-objcopy
OBJDUMP	= $(AVRDIR)\bin\avr-objdump.exe
BootSetup = ruby ../../BootSetup/BootSetup.rb

# Build Target
MCU	?= attiny45
PROG	?= stk500v1

# Source Files
Main	= led-8x8
SrcAsm	= boot.$(MCU) $(Main)
IncAsm	= ports.$(MCU) # settings
SrcCpp	= ledMatrix ball constCol pump flow
IncCpp	= ledMatrix
Eeprom	= # -U eeprom:w:$<:r
Fuses	= -U lfuse:w:0xff:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m

# Programmer Settings
ifeq ($(PROG), arduino)
BAUD	?= 115200
PORT	?= COM5
ERASE	?= -D
else ifeq ($(PROG), stk500v1)
BAUD	?= 19200
PORT	?= COM4
ERASE	?=
else
$(error unknown PROG $(PROG))
endif

################################################################################
# nothing to be configured below
################################################################################

ifeq ($(MCU),attiny24)
DEFSYM  = 24
else ifeq ($(MCU),attiny44)
DEFSYM  = 44
else ifeq ($(MCU),attiny25)
DEFSYM  = 25
else ifeq ($(MCU),attiny45)
DEFSYM  = 45
else ifeq ($(MCU),attiny85)
DEFSYM  = 85
else ifeq ($(MCU),atmega8)
DEFSYM  = 8
else ifeq ($(MCU),atmega328p)
DEFSYM  = 328
else
$(error unknown MCU $(MCU))
endif

################################################################################

ObjAsm  = $(addsuffix .$(MCU).o,$(SrcAsm))
ObjCpp	= $(addsuffix .$(MCU).o,$(SrcCpp))

.PHONY:	ALL

ALL:	$(Main).$(MCU).hex

boot.$(MCU).asm ports.$(MCU).inc: Config.$(MCU)
	$(BootSetup) -c Config.$(MCU)

%.$(MCU).o %.o: %.asm $(addsuffix .inc, $(IncAsm))
	$(AS) -g -mmcu=$(MCU) -defsym __MCU__=$(DEFSYM) -o $@ $<

%.$(MCU).o: %.cpp $(addsuffix .h, $(IncCpp))
	$(CXX) -DRAMSIZE=$(RAMSIZE) -O2 -Wall -std=c++11 -c -mmcu=$(MCU) -o $@ $<

$(Main).$(MCU).elf: $(ObjAsm) $(ObjCpp)
	$(LD) -o $@ $(ObjAsm) $(ObjCpp)

%.hex: %.elf
	$(OBJCOPY) -O ihex -R .eeporm $< $@

################################################################################
# PHONY targets

AVRDUDEParam = -C $(AVRDIR)\etc\avrdude.conf -p $(MCU) -c $(PROG) -P $(PORT) -b $(BAUD)

.PHONY:	Upload Clean Eeprom Fuses Dism Help

Upload: $(Main).$(MCU).hex
	$(AVRDUDE) $(AVRDUDEParam) $(ERASE) -U flash:w:$<:i

Clean:
	del boot.*.asm ports.*.inc *.o *.elf *.hex *.dism *~

ifneq ($(Eeprom),)
Eeprom:
	$(AVRDUDE) $(AVRDUDEParam) $(Eeprom)
endif

ifneq ($(Fuses),)
Fuses:
	$(AVRDUDE) $(AVRDUDEParam) $(Fuses)
endif

Dism:	$(Main).$(MCU).elf
	$(OBJDUMP) -D -m avr5 $< > $(Main).$(MCU).dism

Help:
	@echo 'make [MCU=atmega328p|attiny45|attiny85] [PROG=stk500v1|arduino] [Upload] [Clean] [Eeprom] [Fuses] [Help]'

################################################################################
# EOF
################################################################################
