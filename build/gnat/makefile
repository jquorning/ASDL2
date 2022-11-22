DESTDIR		?=	/opt

GPRMAKE		=	gprbuild
GPRINSTALL	=	gprinstall
GPRCLEAN	=	gprclean
INSTALL		=	install

SDL_MODE	?=	debug
SDL_PLATFORM	?=	linux

SRC_DIR		=	../..

SRCS		=	src/sdl.ads

TESTS_SRCS	=	$(SRC_DIR)/test/clipboard.adb \
			$(SRC_DIR)/test/error.adb \
			$(SRC_DIR)/test/libraries.adb \
			$(SRC_DIR)/test/platform.adb \
			$(SRC_DIR)/test/stream.adb \
			$(SRC_DIR)/test/stream2.adb \
			$(SRC_DIR)/test/test.adb \
			$(SRC_DIR)/test/version.adb \
			$(SRC_DIR)/test/maths/maths.ad[sb] \
			$(SRC_DIR)/test/maths/maths.c

AUDIO_SRCS	=	$(SRC_DIR)/test/audio/audio_io.ad[bs] \
			$(SRC_DIR)/test/audio/audiostream.adb \
			$(SRC_DIR)/test/audio/audiostream_callbacks.ad[bs] \
			$(SRC_DIR)/test/audio/capture.adb \
			$(SRC_DIR)/test/audio/inspection.adb \
			$(SRC_DIR)/test/audio/play_callbacks.ad[bs] \
			$(SRC_DIR)/test/audio/play_cb.adb \
			$(SRC_DIR)/test/audio/play_wav.adb

GEN_KB		=	gen/src/sdl-events-keyboards.ads

ifeq (,$(filter $(SDL_PLATFORM), "linux" "windows" "bsd" "android"))
SDL2_CONFIG	=	-cargs `sdl2-config --cflags` -largs `sdl2-config --libs` -lSDL2_ttf -lSDL2_image
else ifeq ($(SDL_PLATFORM),macosx)
SDL2_CONFIG	=
endif

# With GNAT, all static libs end with .a
LIB_NAME	=	lib/libadasdl.a

.PHONY: sdlada.gpr test_maths_build.gpr test.gpr tests_audio.gpr tools.gpr

all: tools $(LIB_NAME) tests tests_audio

# TODO: Fix the compiler so we actually get shared libs!
#

#####################################################################################
# SDL library

$(LIB_NAME): sdlada.gpr $(GEN_KB)
	$(GPRMAKE) -p -gnat2012 -XSDL_MODE=$(SDL_MODE) -XSDL_PLATFORM=$(SDL_PLATFORM) \
		-Psdlada.gpr

.PHONY: clean-lib

clean-lib:
	$(GPRCLEAN) -XSDL_MODE=$(SDL_MODE) -XSDL_PLATFORM=$(SDL_PLATFORM) \
		-Psdlada.gpr


#####################################################################################
# Tools

tools: $(GEN_KB)

$(GEN_KB): gen/$(SDL_MODE)/tools/gen_keyboard
	./gen/$(SDL_MODE)/tools/gen_keyboard > $@

gen/$(SDL_MODE)/tools/gen_keyboard:
	$(GPRMAKE) -p -gnat2012 -XSDL_MODE=$(SDL_MODE) -XSDL_PLATFORM=$(SDL_PLATFORM) \
		-Ptools.gpr

.PHONY: clean-kb clean-tools

clean-kb:
	-rm $(GEN_KB)

clean-tools:

	$(GPRCLEAN) -XSDL_MODE=$(SDL_MODE) -XSDL_PLATFORM=$(SDL_PLATFORM) -Ptools.gpr

#####################################################################################
# Tests

tests: $(LIB_NAME) tests.gpr $(TESTS_SRCS) tests_audio.gpr $(AUDIO_SRCS)

.PHONY: $(TESTS_SRCS) $(AUDIO_SRCS)

tests.gpr: $(TESTS_SRCS) gen/$(SDL_MODE)/test/libtestmaths.so
	$(GPRMAKE) -p -gnat2012 -XSDL_MODE=$(SDL_MODE) -XSDL_PLATFORM=$(SDL_PLATFORM) \
		-Ptests.gpr ${SDL2_CONFIG}

tests_audio.gpr: $(AUDIO_SRCS)
	$(GPRMAKE) -p -gnat2012 -XSDL_MODE=$(SDL_MODE) -XSDL_PLATFORM=$(SDL_PLATFORM) \
		-P tests_audio.gpr ${SDL2_CONFIG}

# Maths library

gen/$(SDL_MODE)/test/libtestmaths.so: $(SRC_DIR)/test/maths/maths.ad[sb] $(SRC_DIR)/test/maths/maths.c
	$(GPRMAKE) -p -gnat2012 -XSDL_MODE=$(SDL_MODE) -XSDL_PLATFORM=$(SDL_PLATFORM) \
		-Ptest_maths_build.gpr

.PHONY: clean-tests

clean-tests:
	$(GPRCLEAN) -XSDL_MODE=$(SDL_MODE) -XSDL_PLATFORM=$(SDL_PLATFORM) -Ptests.gpr
	$(GPRCLEAN) -XSDL_MODE=$(SDL_MODE) -XSDL_PLATFORM=$(SDL_PLATFORM) -Ptest_maths_build.gpr
	$(GPRCLEAN) -XSDL_MODE=$(SDL_MODE) -XSDL_PLATFORM=$(SDL_PLATFORM) -Ptests_audio.gpr

#####################################################################################
# Unit tests

unit_tests: $(LIB_NAME) build_unit_tests/unit_tests

build_unit_tests/unit_tests:
	$(GPRMAKE) -p -gnat2012 -XSDL_MODE=$(SDL_MODE) -XSDL_PLATFORM=$(SDL_PLATFORM) \
		-Punit_tests.gpr ${SDL2_CONFIG}

.PHONY: clean-unit_tests

clean-unit_tests:
	-$(GPRCLEAN) -XSDL_MODE=$(SDL_MODE) -XSDL_PLATFORM=$(SDL_PLATFORM) -Punit_tests.gpr

#####################################################################################
.PHONY: install

install: all
	$(GPRINSTALL) --prefix=$(DESTDIR) --build-name=$(SDL_MODE) -p -f \
		-XSDL_MODE=$(SDL_MODE) -XSDL_PLATFORM=$(SDL_PLATFORM) \
		-Psdlada.gpr

#####################################################################################

.PHONY: clean

clean: clean-kb clean-tools clean-tests clean-unit_tests clean-lib
