#!/bin/bash

if [ "$OSTYPE" == "linux-gnu" ]
then
    # Linux
    echo "script running on linux"

    sudo apt update
    sudo apt install doxygen cmake gcc g++ ninja-build xorg-dev libgl1-mesa-dev libflac++-dev libogg-dev libudev-dev libvorbis-dev libopenal-dev --yes
    if [ $? -eq 0 ]
    then
    echo "Successfully installed dependencies"
    else
    echo "Could not install dependencies" >&2
    exit 2
    fi

    sudo apt install python3-setuptools python-setuptools build-essential autoconf libtool pkg-config python-pil libqtgui4 libqtcore4 libqt4-xml libqt4-test libqt4-script libqt4-network libqt4-dbus python-qt4 python-dev
    if [ $? -eq 0 ]
    then
    echo "Successfully installed python dependencies"
    else
    echo "Could not install python dependencies" >&2
    exit 2
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
        choco install doxygen.install ninja --yes --verbose --no-progress
        if [ $? -eq 0 ]
        then
            echo "Successfully installed dependencies"
        else
            echo "Could not install dependencies" >&2
            exit 2
        fi
    else
        choco install doxygen.install mingw cmake ninja --yes --verbose --no-progress
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
