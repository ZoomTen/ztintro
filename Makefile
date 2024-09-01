.PHONY: all clean

all: demo.gb

clean:
	rm -fv *.gb *.obj *.sym *.map

%.gb: %.obj
	rgblink -n $*.sym -o $@ $<
	rgbfix -v $<

%.obj: %.asm
	rgbasm -o $@ $<
