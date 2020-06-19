#!/bin/bash

if [ "$OSTYPE" == "linux-gnu" ]
then
    # Linux
    echo "script running on linux"

    DOCDEPS="doxygen graphviz-dev"
    GLFWDEPS="xorg-dev libgl1-mesa-dev"
    REDHANDDEPS="cmake clang-9 clang++-9 ninja-build libglm-dev libglfw3 libglfw3-dev devscripts libmagick++-dev"
    ADDITIONALDEPS="python3-setuptools python-setuptools build-essential autoconf libtool pkg-config python-pil libqtgui4 libqtcore4 libqt4-xml libqt4-test libqt4-script libqt4-network libqt4-dbus python-qt4 python-dev"

    sudo apt update
    if [ "$1" == "--ci" ]
    then
        sudo apt install $DOCDEPS $GLFWDEPS $REDHANDDEPS --yes
        if [ $? -eq 0 ]
        then
        echo "Successfully installed dependencies"
        else
        echo "Could not install dependencies" >&2
        exit 2
        fi
    else
        sudo apt install $DOCDEPS $GLFWDEPS $REDHANDDEPS $ADDITIONALDEPS --yes
        if [ $? -eq 0 ]
        then
        echo "Successfully installed dependencies"
        else
        echo "Could not install dependencies" >&2
        exit 2
        fi
    fi

elif [ "$OSTYPE" == "darwin"* ]
then
    # Mac OSX
    echo "script running on mac osx"
        
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]
then
    # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    # or 
    # POSIX compatibility layer and Linux environment emulation for Windows
    echo "script running on windows"

    if [ "$1" == "--ci" ]
    then
        choco install imagemagick  -PackageParameters InstallDevelopmentHeaders=true  --yes --no-progress
        if [ $? -eq 0 ]
        then
            echo "Successfully installed magick"
        else
            echo "Could not install magick" >&2
            exit 2
        fi
        
        choco install ninja --yes --no-progress
        if [ $? -eq 0 ]
        then
            echo "Successfully installed ninja"
        else
            echo "Could not install ninja" >&2
            exit 2
        fi

        choco install llvm --version 9.0.1 --yes --no-progress
        if [ $? -eq 0 ]
        then
            echo "Successfully installed llvm"
        else
            echo "Could not install llvm" >&2
            exit 2
        fi

    else
        choco install -PackageParameters InstallDevelopmentHeaders=true imagemagick
        if [ $? -eq 0 ]
        then
            echo "Successfully installed magick"
        else
            echo "Could not install magick" >&2
            exit 2
        fi

        choco install doxygen.install mingw cmake ninja  --yes --verbose --no-progress
        if [ $? -eq 0 ]
        then
            echo "Successfully installed dependencies"
        else
            echo "Could not install dependencies" >&2
            exit 2
        fi
    fi

else
    # Unknown os
    echo "running on something else."
    echo "Not a supported OS: $OSTYPE" >&2
    exit 1
fi
