#!/bin/bash 2>nul || goto :windows

# linux + osx -----------------------------------------------------------------
cd `dirname $0`

# copy demos to root folder. local changes are preserved
cp -n art/demos/*.c .

# rem tests
# clang art/editor/tools/editor.c -I. -lm -lX11 -g -fsanitize=address,undefined && ./a.out
# cl art\editor\tools\editor.c -I. -fsanitize=address /DEBUG /Zi && editor

# tidy environment
if [ "$1" = "tidy" ]; then
    rm demo_* 2> /dev/null
    rm demo 2> /dev/null
    rm fwk.o 2> /dev/null
    rm .art*.zip 2> /dev/null
    rm art/demos/lua/.art*.zip 2> /dev/null
    rm art/demos/html5/.art*.zip 2> /dev/null
    rm fwk_*.* 2> /dev/null
    rm 3rd_*.* 2> /dev/null
    rm libfwk* 2> /dev/null
    rm -rf *.dSYM 2> /dev/null
    rm *.png 2> /dev/null
    rm *.mp4 2> /dev/null
    exit
fi
# shortcuts for split & join amalgamation scripts
if [ "$1" = "split" ]; then
    sh art/editor/tools/split.bat
    exit
fi
if [ "$1" = "join" ]; then
    sh art/editor/tools/join.bat
    exit
fi

if [ "$(uname)" != "Darwin" ]; then
    # setup (ArchLinux)
     sudo pacman -S --noconfirm gcc ffmpeg # -Syu
    # setup (Debian, Ubuntu, etc)
     sudo apt-get -y update
     sudo apt-get -y install gcc ffmpeg libx11-dev libxcursor-dev libxrandr-dev libxinerama-dev libxi-dev  # absolute minimum
    #sudo apt-get -y install gcc ffmpeg xorg-dev                                                           # memorable, around 100 mib
    #sudo apt-get -y install gcc ffmpeg xorg-dev libglfw3-dev libassimp-dev clang                          # initial revision

    # pipeline
    #cc art/editor/tools/ass2iqe.c   -o art/editor/tools/ass2iqe.linux  -lm -ldl -lpthread -w -g -lassimp
    #cc art/editor/tools/iqe2iqm.cpp -o art/editor/tools/iqe2iqm.linux  -lm -ldl -lpthread -w -g -lstdc++
    #cc art/editor/tools/mid2wav.c   -o art/editor/tools/mid2wav.linux  -lm -ldl -lpthread -w -g
    #cc art/editor/tools/xml2json.c  -o art/editor/tools/xml2json.linux -lm -ldl -lpthread -w -g

    # change permissions of precompiled tools binaries because of 'Permission denied' runtime error (@procedural)
    chmod +x art/editor/tools/ass2iqe.linux
    chmod +x art/editor/tools/iqe2iqm.linux
    chmod +x art/editor/tools/mid2wav.linux
    chmod +x art/editor/tools/xml2json.linux
    chmod +x art/editor/tools/sfxr2wav.linux
    chmod +x art/editor/tools/ffmpeg.linux
    chmod +x art/editor/tools/cuttlefish.linux
    chmod +x art/editor/tools/PVRTexToolCLI.linux
    chmod +x art/editor/tools/cook.linux
    chmod +x art/editor/tools/xlsx2ini.linux
    chmod +x art/demos/lua/luajit.linux

    # framework (as dynamic library)
    if [ "$1" = "dll" ]; then
        cc -o libfwk.so fwk.c -shared -fPIC -w -g -lX11
        cp libfwk.so art/demos/lua/
        echo generated art/demos/lua/libfwk.so 
        echo '[test] cd art/demos/lua && LD_LIBRARY_PATH=$(PWD)/libfwk.so:$LD_LIBRARY_PATH ./luajit.linux demo_luajit_model.lua'
        exit
    fi

    # framework
    echo fwk            && cc -c fwk.c -w -g $*

    # demos
    echo demo           && cc -o demo           demo.c           fwk.o -lm -ldl -lpthread -lX11 -w -g $* &
    echo demo_cubemap   && cc -o demo_cubemap   demo_cubemap.c   fwk.o -lm -ldl -lpthread -lX11 -w -g $* &
    echo demo_collide   && cc -o demo_collide   demo_collide.c   fwk.o -lm -ldl -lpthread -lX11 -w -g $* &
    echo demo_model     && cc -o demo_model     demo_model.c     fwk.o -lm -ldl -lpthread -lX11 -w -g $* &
    echo demo_scene     && cc -o demo_scene     demo_scene.c     fwk.o -lm -ldl -lpthread -lX11 -w -g $* &
    echo demo_shadertoy && cc -o demo_shadertoy demo_shadertoy.c fwk.o -lm -ldl -lpthread -lX11 -w -g $* &
    echo demo_sprite    && cc -o demo_sprite    demo_sprite.c    fwk.o -lm -ldl -lpthread -lX11 -w -g $* &
    echo demo_video     && cc -o demo_video     demo_video.c     fwk.o -lm -ldl -lpthread -lX11 -w -g $* &
    echo demo_script    && cc -o demo_script    demo_script.c    fwk.o -lm -ldl -lpthread -lX11 -w -g $* &
    echo demo_socket    && cc -o demo_socket    demo_socket.c    fwk.o -lm -ldl -lpthread -lX11 -w -g $* &
    echo demo_easing    && cc -o demo_easing    demo_easing.c    fwk.o -lm -ldl -lpthread -lX11 -w -g $* &
    echo demo_font      && cc -o demo_font      demo_font.c      fwk.o -lm -ldl -lpthread -lX11 -w -g $* &
    echo demo_material  && cc -o demo_material  demo_material.c  fwk.o -lm -ldl -lpthread -lX11 -w -g $* &
    echo demo_pbr       && cc -o demo_pbr       demo_pbr.c       fwk.o -lm -ldl -lpthread -lX11 -w -g $* &
    echo demo_instanced && cc -o demo_instanced demo_instanced.c fwk.o -lm -ldl -lpthread -lX11 -w -g $* &
    echo demo_audio     && cc -o demo_audio     demo_audio.c     fwk.o -lm -ldl -lpthread -lX11 -w -g $* &

    #editor
    echo editor         && cc -o editor         editor.c               -lm -ldl -lpthread -lX11 -w -g $*
fi

if [ "$(uname)" = "Darwin" ]; then
    # setup (osx)
    export SDKROOT=$(xcrun --show-sdk-path)
    # brew install glfw

    # pipeline
    #cc art/editor/tools/ass2iqe.c   -o art/editor/tools/ass2iqe.osx  -w -g -lassimp
    #cc art/editor/tools/iqe2iqm.cpp -o art/editor/tools/iqe2iqm.osx  -w -g -lstdc++
    #cc art/editor/tools/mid2wav.c   -o art/editor/tools/mid2wav.osx  -w -g
    #cc art/editor/tools/xml2json.c  -o art/editor/tools/xml2json.osx -w -g

    # change permissions of precompiled tools binaries because of 'Permission denied' runtime error (@procedural)
    chmod +x art/editor/tools/ass2iqe.osx
    chmod +x art/editor/tools/iqe2iqm.osx
    chmod +x art/editor/tools/mid2wav.osx
    chmod +x art/editor/tools/xml2json.osx
    chmod +x art/editor/tools/sfxr2wav.osx
    chmod +x art/editor/tools/ffmpeg.osx
    chmod +x art/editor/tools/cuttlefish.osx
    chmod +x art/editor/tools/PVRTexToolCLI.osx
    chmod +x art/editor/tools/cook.osx
    chmod +x art/editor/tools/xlsx2ini.osx
    chmod +x art/demos/lua/luajit.osx

    # framework (as dynamic library)
    if [ "$1" = "dll" ]; then
        cc -ObjC -dynamiclib -o libfwk.dylib fwk.c -framework cocoa -framework iokit -w -g
        cp libfwk.dylib art/demos/lua
        echo generated art/demos/lua/libfwk.dylib 
        echo '[test] cd art/demos/lua && ./luajit.osx demo_luajit_model.lua'
        exit
    fi

    # framework
    echo fwk            && cc -c -ObjC fwk.c -w -g $*

    # demos
    echo demo           && cc -o demo           demo.c           fwk.o -framework cocoa -framework iokit -w -g $* &
    echo demo_cubemap   && cc -o demo_cubemap   demo_cubemap.c   fwk.o -framework cocoa -framework iokit -w -g $* &
    echo demo_collide   && cc -o demo_collide   demo_collide.c   fwk.o -framework cocoa -framework iokit -w -g $* &
    echo demo_model     && cc -o demo_model     demo_model.c     fwk.o -framework cocoa -framework iokit -w -g $* &
    echo demo_scene     && cc -o demo_scene     demo_scene.c     fwk.o -framework cocoa -framework iokit -w -g $* &
    echo demo_shadertoy && cc -o demo_shadertoy demo_shadertoy.c fwk.o -framework cocoa -framework iokit -w -g $* &
    echo demo_sprite    && cc -o demo_sprite    demo_sprite.c    fwk.o -framework cocoa -framework iokit -w -g $* &
    echo demo_video     && cc -o demo_video     demo_video.c     fwk.o -framework cocoa -framework iokit -w -g $* &
    echo demo_script    && cc -o demo_script    demo_script.c    fwk.o -framework cocoa -framework iokit -w -g $* &
    echo demo_socket    && cc -o demo_socket    demo_socket.c    fwk.o -framework cocoa -framework iokit -w -g $* &
    echo demo_easing    && cc -o demo_easing    demo_easing.c    fwk.o -framework cocoa -framework iokit -w -g $* &
    echo demo_font      && cc -o demo_font      demo_font.c      fwk.o -framework cocoa -framework iokit -w -g $* &
    echo demo_material  && cc -o demo_material  demo_material.c  fwk.o -framework cocoa -framework iokit -w -g $* &
    echo demo_pbr       && cc -o demo_pbr       demo_pbr.c       fwk.o -framework cocoa -framework iokit -w -g $* &
    echo demo_instanced && cc -o demo_instanced demo_instanced.c fwk.o -framework cocoa -framework iokit -w -g $* &
    echo demo_audio     && cc -o demo_audio     demo_audio.c     fwk.o -framework cocoa -framework iokit -w -g $* &

    # editor
    echo editor         && cc -o editor         editor.c               -framework cocoa -framework iokit -w -g $*
fi

exit


:: -----------------------------------------------------------------------------
:windows
@echo off

rem setup
if "%cc%"=="" (
    echo Warning: Trying VS 2022/2019/2017/2015/2013 x64 ...
    set cc=cl
           if exist "%VS190COMNTOOLS%/../../VC/Auxiliary/Build/vcvarsx86_amd64.bat" (
              @call "%VS190COMNTOOLS%/../../VC/Auxiliary/Build/vcvarsx86_amd64.bat"
    ) else if exist "%VS160COMNTOOLS%/../../VC/Auxiliary/Build/vcvarsx86_amd64.bat" (
              @call "%VS160COMNTOOLS%/../../VC/Auxiliary/Build/vcvarsx86_amd64.bat"
    ) else if exist "%VS150COMNTOOLS%/../../VC/Auxiliary/Build/vcvarsx86_amd64.bat" (
              @call "%VS150COMNTOOLS%/../../VC/Auxiliary/Build/vcvarsx86_amd64.bat"
    ) else if exist "%VS140COMNTOOLS%/../../VC/bin/x86_amd64/vcvarsx86_amd64.bat" (
              @call "%VS140COMNTOOLS%/../../VC/bin/x86_amd64/vcvarsx86_amd64.bat"
    ) else if exist "%VS120COMNTOOLS%/../../VC/bin/x86_amd64/vcvarsx86_amd64.bat" (
              @call "%VS120COMNTOOLS%/../../VC/bin/x86_amd64/vcvarsx86_amd64.bat"
    ) else if exist "%ProgramFiles%/microsoft visual studio/2022/community/VC/Auxiliary/Build/vcvarsx86_amd64.bat" (
              @call "%ProgramFiles%/microsoft visual studio/2022/community/VC/Auxiliary/Build/vcvarsx86_amd64.bat"
    ) else if exist "%ProgramFiles(x86)%/microsoft visual studio/2019/community/VC/Auxiliary/Build/vcvarsx86_amd64.bat" (
              @call "%ProgramFiles(x86)%/microsoft visual studio/2019/community/VC/Auxiliary/Build/vcvarsx86_amd64.bat"
    ) else if exist "%ProgramFiles(x86)%/microsoft visual studio/2017/community/VC/Auxiliary/Build/vcvarsx86_amd64.bat" (
              @call "%ProgramFiles(x86)%/microsoft visual studio/2017/community/VC/Auxiliary/Build/vcvarsx86_amd64.bat"
    ) else (
        echo Warning: Trying Mingw64 ...
        set cc=gcc
        where /q gcc.exe || ( set cc=tcc&&echo Warning: Trying TCC ... )
    )
)

cd "%~dp0"
echo @if     "%%1"=="-impdef" @%~dp0\art\editor\tools\tcc-win\tcc %%* > tcc.bat
echo @if not "%%1"=="-impdef" @%~dp0\art\editor\tools\tcc-win\tcc -I %~dp0\art\editor\tools\tcc-win\include_mingw\winapi -I %~dp0\art\editor\tools\tcc-win\include_mingw\ %%* >> tcc.bat

echo @call %%* > sh.bat

rem generate cooker and cook
if "%1"=="cook" (
    cl art\editor\tools\cook.c -I.
    cook

    exit /b
)
rem generate bindings
if "%1"=="bindings" (
    rem luajit
    art\editor\tools\luajit art\editor\tools\luajit_make_bindings.lua > fwk.lua
    move /y fwk.lua art\demos\lua

    exit /b
)
rem generate documentation
if "%1"=="docs" (

    rem set symbols...
    rem git pull
    git describe --tags --abbrev=0 > info.obj
    set /p VERSION=<info.obj
    git rev-list --count --first-parent HEAD > info.obj
    set /p GIT_REVISION=<info.obj
    git rev-parse --abbrev-ref HEAD > info.obj
    set /p GIT_BRANCH=<info.obj
    date /t > info.obj
    set /p LAST_MODIFIED=<info.obj

    rem ...and generate docs
    cl art\docs\docs.c fwk.c -I. %2
    docs fwk.h --excluded=3rd_glad.h,fwk.h,fwk_compat.h, > fwk.html
    move /y fwk.html art\docs\docs.html

    exit /b
)
rem generate prior files to a github release
if "%1"=="github" (
    rem call make.bat dll
    call make.bat docs
    call make.bat bindings

    call make.bat split
    rd /q /s art\editor\tools\3rd\*
    rd /q /s art\editor\tools\src\*
    md art\editor\tools\3rd
    md art\editor\tools\src
    move /y 3rd_*.? art\editor\tools\3rd\
    move /y fwk_*.? art\editor\tools\src\
    echo.> "art\editor\tools\src\; for browsing purposes. do not compile these"
    echo.> "art\editor\tools\src\; required sources can be found at root folder"

    call make.bat tidy

    exit /b
)

rem build & execute single demo. usage: make demo name "compiler args" "program args"
if "%1"=="demo" (
    setlocal enableDelayedExpansion
    set "FILENAME=demo"
    if exist "demo_%2.c" (
        set "FILENAME=demo_%2"
    )
    copy /y !FILENAME!.c art\demos\!FILENAME!.c
    cl !FILENAME!.c /nologo /openmp /Zi fwk.c %~3%
    if %ERRORLEVEL%==0 (call !FILENAME!.exe %~4%) else (echo Compilation error: !FILENAME!)
    exit /b
)

rem copy demos to root folder. local changes are preserved
echo n | copy /-y art\demos\*.c 1> nul 2> nul

rem shortcuts for split & join amalgamation scripts
if "%1"=="split" (
    call art\editor\tools\split
    exit /b
)
if "%1"=="join" (
    call art\editor\tools\join
    exit /b
)

rem check memory api calls
if "%1"=="checkmem" (
    findstr /RNC:"[^_xv]realloc[(]" fwk.c
    findstr /RNC:"[^_xv]malloc[(]"  fwk.c
    findstr /RNC:"[^_xv]free[(]"    fwk.c
    findstr /RNC:"[^_xv]calloc[(]"  fwk.c
    findstr /RNC:"[^_xv]strdup[(]"  fwk.c
    exit /b
)

rem tidy environment
if "%1"=="tidy" (
    move /y demo_*.png art\demos
    move /y demo_*.c art\demos
    del .temp*.*
    del *.zip
    del *.mem
    del *.exp
    del *.lib
    del *.exe
    del *.obj
    del *.o
    del *.pdb
    del *.ilk
    del *.png
    del *.mp4
    del *.def
    del *.dll
    del 3rd_*.*
    del fwk_*.*
    del demo_*.*
    del temp_*.*
    rd /q /s .vs
    del tcc.bat
    del sh.bat
    exit /b
)

if exist "fwk_*" (
    call art\editor\tools\join
)

echo [%cc%]
prompt [%cc%] $p$g

if "%cc%"=="cl" (
    rem pipeline
    rem cl art/editor/tools/ass2iqe.c   /Feart/editor/tools/ass2iqe.exe  /nologo /openmp /O2 /Oy /MT /DNDEBUG /DFINAL assimp.lib
    rem cl art/editor/tools/iqe2iqm.cpp /Feart/editor/tools/iqe2iqm.exe  /nologo /openmp /O2 /Oy /MT /DNDEBUG /DFINAL
    rem cl art/editor/tools/mid2wav.c   /Feart/editor/tools/mid2wav.exe  /nologo /openmp /O2 /Oy /MT /DNDEBUG /DFINAL
    rem cl art/editor/tools/xml2json.c  /Feart/editor/tools/xml2json.exe /nologo /openmp /O2 /Oy /MT /DNDEBUG /DFINAL

    rem [HINT] static linking vs dll
    rem SLL: cl fwk.c && cl demo.c fwk.obj
    rem DLL: cl fwk.c /LD /DAPI=EXPORT && cl demo.c fwk.lib /DAPI=IMPORT

    rem [HINT] optimization flags for release builds
    rem method 1:         /Ox /Oy /MT /DNDEBUG /DFINAL
    rem method 2:         /O2 /Oy /MT /DNDEBUG /DFINAL
    rem method 3:             /O1 /MT /DNDEBUG /DFINAL /GL /GF /arch:AVX2
    rem method 3: /Os /Ox /O2 /Oy /MT /DNDEBUG /DFINAL /GL /GF /arch:AVX2 > small binaries!

    rem framework dynamic
    rem cl fwk.c        /nologo /openmp /Zi /DAPI=EXPORT /LD %*

    rem generate dll
    if "%1"=="dll" (
        rem cl fwk.c /LD /DAPI=EXPORT                         && rem 6.6MiB
        rem cl fwk.c /LD /DAPI=EXPORT /O2                     && rem 5.3MiB
        cl fwk.c /LD /DAPI=EXPORT /Os /Ox /O2 /Oy /GL /GF /MT && rem 4.7MiB
        copy /y fwk.dll art\demos\lua

        exit /b
    )

    rem framework static
    cl fwk.c            /nologo /openmp /Zi /MT /c %*

    rem demos
    cl demo.c           /nologo /openmp /Zi /MT fwk.obj %*
    cl demo_cubemap.c   /nologo /openmp /Zi /MT fwk.obj %*
    cl demo_collide.c   /nologo /openmp /Zi /MT fwk.obj %*
    cl demo_model.c     /nologo /openmp /Zi /MT fwk.obj %*
    cl demo_scene.c     /nologo /openmp /Zi /MT fwk.obj %*
    cl demo_shadertoy.c /nologo /openmp /Zi /MT fwk.obj %*
    cl demo_sprite.c    /nologo /openmp /Zi /MT fwk.obj %*
    cl demo_video.c     /nologo /openmp /Zi /MT fwk.obj %*
    cl demo_script.c    /nologo /openmp /Zi /MT fwk.obj %*
    cl demo_socket.c    /nologo /openmp /Zi /MT fwk.obj %*
    cl demo_easing.c    /nologo /openmp /Zi /MT fwk.obj %*
    cl demo_font.c      /nologo /openmp /Zi /MT fwk.obj %*
    cl demo_material.c  /nologo /openmp /Zi /MT fwk.obj %*
    cl demo_pbr.c       /nologo /openmp /Zi /MT fwk.obj %*
    cl demo_instanced.c /nologo /openmp /Zi /MT fwk.obj %*
    cl demo_audio.c     /nologo /openmp /Zi /MT fwk.obj %*

    rem editor
    cl editor.c         /nologo /openmp /Zi /MT         %*

) else if "%cc%"=="tcc" (
    rem pipeline
    rem gcc art/editor/tools/ass2iqe.c   -o art/editor/tools/ass2iqe.exe  -w -lassimp
    rem gcc art/editor/tools/iqe2iqm.cpp -o art/editor/tools/iqe2iqm.exe  -w -lstdc++
    rem gcc art/editor/tools/mid2wav.c   -o art/editor/tools/mid2wav.exe  -w
    rem gcc art/editor/tools/xml2json.c  -o art/editor/tools/xml2json.exe -w

    rem generate dll
    if "%1"=="dll" (
        call tcc fwk.c -shared -DAPI=EXPORT

        exit /b
    )

    rem framework
    echo fwk            && tcc -c fwk.c -w %*

    rem demos
    echo demo           && tcc demo.c           fwk.o %*
    echo demo_cubemap   && tcc demo_cubemap.c   fwk.o %*
    echo demo_collide   && tcc demo_collide.c   fwk.o %*
    echo demo_model     && tcc demo_model.c     fwk.o %*
    echo demo_scene     && tcc demo_scene.c     fwk.o %*
    echo demo_shadertoy && tcc demo_shadertoy.c fwk.o %*
    echo demo_sprite    && tcc demo_sprite.c    fwk.o %*
    echo demo_video     && tcc demo_video.c     fwk.o %*
    echo demo_script    && tcc demo_script.c    fwk.o %*
    echo demo_socket    && tcc demo_socket.c    fwk.o %*
    echo demo_easing    && tcc demo_easing.c    fwk.o %*
    echo demo_font      && tcc demo_font.c      fwk.o %*
    echo demo_material  && tcc demo_material.c  fwk.o %*
    echo demo_pbr       && tcc demo_pbr.c       fwk.o %*
    echo demo_instanced && tcc demo_instanced.c fwk.o %*
    echo demo_audio     && tcc demo_audio.c     fwk.o %*

    rem editor
    echo editor         && tcc editor.c               %*

) else ( rem if "%cc%"=="gcc" or "clang"
    rem pipeline
    rem %cc% art/editor/tools/ass2iqe.c   -o art/editor/tools/ass2iqe.exe  -w -lassimp
    rem %cc% art/editor/tools/iqe2iqm.cpp -o art/editor/tools/iqe2iqm.exe  -w -lstdc++
    rem %cc% art/editor/tools/mid2wav.c   -o art/editor/tools/mid2wav.exe  -w
    rem %cc% art/editor/tools/xml2json.c  -o art/editor/tools/xml2json.exe -w

    rem framework
    echo fwk            && %cc% -c fwk.c -w -g %*

    rem demos
    echo demo           && %cc% -o demo           demo.c           fwk.o -lws2_32 -lgdi32 -lwinmm -ldbghelp -lole32 -lshell32 -lcomdlg32 -w -g %*
    echo demo_cubemap   && %cc% -o demo_cubemap   demo_cubemap.c   fwk.o -lws2_32 -lgdi32 -lwinmm -ldbghelp -lole32 -lshell32 -lcomdlg32 -w -g %*
    echo demo_collide   && %cc% -o demo_collide   demo_collide.c   fwk.o -lws2_32 -lgdi32 -lwinmm -ldbghelp -lole32 -lshell32 -lcomdlg32 -w -g %*
    echo demo_model     && %cc% -o demo_model     demo_model.c     fwk.o -lws2_32 -lgdi32 -lwinmm -ldbghelp -lole32 -lshell32 -lcomdlg32 -w -g %*
    echo demo_scene     && %cc% -o demo_scene     demo_scene.c     fwk.o -lws2_32 -lgdi32 -lwinmm -ldbghelp -lole32 -lshell32 -lcomdlg32 -w -g %*
    echo demo_shadertoy && %cc% -o demo_shadertoy demo_shadertoy.c fwk.o -lws2_32 -lgdi32 -lwinmm -ldbghelp -lole32 -lshell32 -lcomdlg32 -w -g %*
    echo demo_sprite    && %cc% -o demo_sprite    demo_sprite.c    fwk.o -lws2_32 -lgdi32 -lwinmm -ldbghelp -lole32 -lshell32 -lcomdlg32 -w -g %*
    echo demo_video     && %cc% -o demo_video     demo_video.c     fwk.o -lws2_32 -lgdi32 -lwinmm -ldbghelp -lole32 -lshell32 -lcomdlg32 -w -g %*
    echo demo_script    && %cc% -o demo_script    demo_script.c    fwk.o -lws2_32 -lgdi32 -lwinmm -ldbghelp -lole32 -lshell32 -lcomdlg32 -w -g %*
    echo demo_socket    && %cc% -o demo_socket    demo_socket.c    fwk.o -lws2_32 -lgdi32 -lwinmm -ldbghelp -lole32 -lshell32 -lcomdlg32 -w -g %*
    echo demo_easing    && %cc% -o demo_easing    demo_easing.c    fwk.o -lws2_32 -lgdi32 -lwinmm -ldbghelp -lole32 -lshell32 -lcomdlg32 -w -g %*
    echo demo_font      && %cc% -o demo_font      demo_font.c      fwk.o -lws2_32 -lgdi32 -lwinmm -ldbghelp -lole32 -lshell32 -lcomdlg32 -w -g %*
    echo demo_material  && %cc% -o demo_material  demo_material.c  fwk.o -lws2_32 -lgdi32 -lwinmm -ldbghelp -lole32 -lshell32 -lcomdlg32 -w -g %*
    echo demo_pbr       && %cc% -o demo_pbr       demo_pbr.c       fwk.o -lws2_32 -lgdi32 -lwinmm -ldbghelp -lole32 -lshell32 -lcomdlg32 -w -g %*
    echo demo_instanced && %cc% -o demo_instanced demo_instanced.c fwk.o -lws2_32 -lgdi32 -lwinmm -ldbghelp -lole32 -lshell32 -lcomdlg32 -w -g %*
    echo demo_audio     && %cc% -o demo_audio     demo_audio.c     fwk.o -lws2_32 -lgdi32 -lwinmm -ldbghelp -lole32 -lshell32 -lcomdlg32 -w -g %*

    rem editor
    echo editor         && %cc% -o editor         editor.c               -lws2_32 -lgdi32 -lwinmm -ldbghelp -lole32 -lshell32 -lcomdlg32 -w -g %*
)

rem PAUSE only if double-clicked from Windows explorer
(((echo.%cmdcmdline%)|%WINDIR%\system32\find.exe /I "%~0")>nul)&&pause

exit /b