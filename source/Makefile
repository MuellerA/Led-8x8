AVRDIR	= d:\Programme\Arduino\hardware\tools\avr

#MCU	?= atmega328p
MCU	?= attiny45

ifeq ($(MCU),attiny45)
PROG	= stk500v1
BAUD	= 19200
ERASE	= 
PORT	?= COM6
DEFSYM  = 45
else
PROG	= arduino
BAUD	= 115200
ERASE	= -D
PORT	?= COM3
DEFSYM  = 328
endif


# nothing to be configured below

ALL:	led-8x8.$(MCU).hex

Upload: led-8x8.$(MCU).hex
	$(AVRDIR)\bin\avrdude -C $(AVRDIR)\etc\avrdude.conf -p $(MCU) -c $(PROG) -P $(PORT) -b $(BAUD) $(ERASE) -U flash:w:$<:i

ifeq ($(MCU),attiny45)
BurnFuse:
	$(AVRDIR)\bin\avrdude -C $(AVRDIR)\etc\avrdude.conf -p $(MCU) -c $(PROG) -P $(PORT) -b $(BAUD) -U lfuse:w:0xff:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m
endif

boot.$(MCU).asm ports.$(MCU).inc: Config.$(MCU)
	ruby ../../BootSetup/BootSetup.rb -c Config.$(MCU) -s boot.$(MCU).asm -p ports.$(MCU).inc --regXYZ

led-8x8.$(MCU).o: led-8x8.asm ports.$(MCU).inc
	$(AVRDIR)\bin\avr-as -g -mmcu=$(MCU) -defsym __MCU__=$(DEFSYM) -o $@ $<

%.o: %.asm ports.$(MCU).inc
	$(AVRDIR)\bin\avr-as -g -mmcu=$(MCU) -defsym __MCU__=$(DEFSYM) -o $@ $<

led-8x8.$(MCU).elf: boot.$(MCU).o led-8x8.$(MCU).o ball.o
	$(AVRDIR)\bin\avr-ld -o $@ boot.$(MCU).o led-8x8.$(MCU).o ball.o

%.hex: %.elf
	$(AVRDIR)\bin\avr-objcopy -O ihex -R .eeporm $< $@

Clean:
	del boot.asm ports.*.inc *.o *.elf *.hex *~

Help:
	@echo 'make [MCU=atmega328p|attiny45] [Upload] [Clean] [Help]'
