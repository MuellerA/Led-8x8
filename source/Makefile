AVRDIR	= d:\Programme\Arduino\hardware\tools\avr

#MCU	?= atmega328p
#MCU	?= attiny85
MCU	?= attiny45

ifeq ($(MCU),attiny45)
PROG	= stk500v1
BAUD	= 19200
ERASE	= 
PORT	?= COM6
DEFSYM  = 45
RAMSIZE = 256
else ifeq ($(MCU),attiny85)
PROG	= stk500v1
BAUD	= 19200
ERASE	= 
PORT	?= COM6
DEFSYM  = 85
RAMSIZE = 512
else
PROG	= arduino
BAUD	= 115200
ERASE	= -D
PORT	?= COM3
DEFSYM  = 328
RAMSIZE = 2048
endif


# nothing to be configured below

ALL:	led-8x8.$(MCU).hex

Files = boot.$(MCU).o led-8x8.$(MCU).o ledMatrix.$(MCU).o ball.$(MCU).o constCol.$(MCU).o pump.$(MCU).o flow.$(MCU).o

Upload: led-8x8.$(MCU).hex
	$(AVRDIR)\bin\avrdude -C $(AVRDIR)\etc\avrdude.conf -p $(MCU) -c $(PROG) -P $(PORT) -b $(BAUD) $(ERASE) -U flash:w:$<:i

ifeq ($(MCU),attiny45)
BurnFuse:
	$(AVRDIR)\bin\avrdude -C $(AVRDIR)\etc\avrdude.conf -p $(MCU) -c $(PROG) -P $(PORT) -b $(BAUD) -U lfuse:w:0xff:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m

ResetFuse:
	$(AVRDIR)\bin\avrdude -C $(AVRDIR)\etc\avrdude.conf -p $(MCU) -c $(PROG) -P $(PORT) -b $(BAUD) -U lfuse:w:0x62:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m
endif

ifeq ($(MCU),attiny85)
BurnFuse:
	$(AVRDIR)\bin\avrdude -C $(AVRDIR)\etc\avrdude.conf -p $(MCU) -c $(PROG) -P $(PORT) -b $(BAUD) -U lfuse:w:0xff:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m

ResetFuse:
	$(AVRDIR)\bin\avrdude -C $(AVRDIR)\etc\avrdude.conf -p $(MCU) -c $(PROG) -P $(PORT) -b $(BAUD) -U lfuse:w:0x62:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m
endif

boot.$(MCU).asm ports.$(MCU).inc: Config.$(MCU)
	ruby ../../BootSetup/BootSetup.rb -c Config.$(MCU)

led-8x8.$(MCU).o: led-8x8.asm ports.$(MCU).inc
	$(AVRDIR)\bin\avr-as -g -mmcu=$(MCU) -defsym __MCU__=$(DEFSYM) -o $@ $<

%.o: %.asm ports.$(MCU).inc
	$(AVRDIR)\bin\avr-as -g -mmcu=$(MCU) -defsym __MCU__=$(DEFSYM) -o $@ $<

%.$(MCU).o: %.cpp ledMatrix.h
	$(AVRDIR)\bin\avr-g++ -DRAMSIZE=$(RAMSIZE) -O2 -Wall -std=c++11 -c -mmcu=$(MCU) -o $@ $<

ball.$(MCU).o: ball.h

led-8x8.$(MCU).elf: $(Files)
	$(AVRDIR)\bin\avr-ld -o $@ $(Files)

%.hex: %.elf
	$(AVRDIR)\bin\avr-objcopy -O ihex -R .eeporm $< $@

Clean:
	del boot.asm ports.*.inc *.o *.elf *.hex *~

Help:
	@echo 'make [MCU=atmega328p|attiny45|attiny85] [Upload] [Clean] [BurnFuse] [ResetFuse] [Help]'
