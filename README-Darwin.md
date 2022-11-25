This is how I install SDL2 on Darwin 10.15.7:
-

Introduction
--
This document describes how I build SDLAda on Darwin.

```sh
sw_vers
ProductName:	Mac OS X
ProductVersion:	10.15.7
BuildVersion:	19H2
```
Install
--
1. Get **SDL2-2.0.8.dmg** from [1]().
2. Get **SDL2_image-2.24.1.dmg** from [2]().
3. Get **SDL2_ttf-2.0.15.dmg** from [3]().
4. Copy `SDL2.framwork` , `SDL2_image.framework` , `SDL2_ttf.framework` to `/Library/Frameworks`.

[1]: <https://github.com/libsdl-org/SDL/releases>
[2]: <https://www.libsdl.org/projects/SDL_image/release/>
[3]: <https://www.libsdl.org/projects/SDL_ttf/release/>

Build
--
```sh
cd build/gnat
SDL_PLATFORM=darwin
make
make tests
```

Todo
--
```sh
make unit_tests  # does not work at the moment
```
