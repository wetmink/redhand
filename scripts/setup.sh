#!/bin/bash

THREADS="3"
CI="0"
VSCODE="0"

#parse parameter
pars=$#
for ((i=1;i<=pars;i+=2))
do
  case "$1" in
    "-j")
      shift
      if [ $1 ]
      then
        THREADS="$(($1+1))"
      fi
      shift
      ;;
    "--ci")
      CI="1"
      shift
      ;;
    "--vscode")
      VSCODE="1"
      shift
      ;;
    "--help")
      echo "Usage: scripts/build.sh [options]"
      echo "Options:"
      echo "    --help              Display this information"
      echo "    --ci                To run in CI mode to disable git-lfs pull."
      echo "    -j [threadnumber]   Build the project with the specified number of threads."
      echo "    --vscode            Addes the configurations for visual studio code to the .vscode folder"
      echo ""
      echo "view the source on https://github.com/noah1510/redhand"
      exit 1
      ;;
    *)
      echo "Invalid option try --help for information on how to use the script"
      exit 1
      ;;
  esac
done

if [ "$THREADS" == "3" ]
then
  THREADS="$(nproc)"
  THREADS="$(($THREADS+1))"
fi

REPOROOT="$(pwd)"
PROJECTNAME="redhand"

if [ "$OSTYPE" == "linux-gnu" ]
then
    # Linux
    echo "script running on linux"

    GLFWLIB="libglfw.so"
    GLFWDEPLOY="libglfw.so.3"

    if [ $VSCODE -eq "1" ]
    then
      cp -r "configurations/linux/.vscode" "."
    fi


elif [ "$OSTYPE" == "darwin"* ]
then
    # Mac OSX
    echo "script running on mac osx"

    GLFWLIB="libglfw.so"

    if [ $VSCODE -eq "1" ]
    then
      echo "The configurations are for linux and not guaranteed to work"
      cp -r "configurations/linux/.vscode" "."
    fi

        
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]
then
    # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    # or 
    # POSIX compatibility layer and Linux environment emulation for Windows
    echo "script running on windows"

    GLFWLIB="glfw3.dll"
    GLFWDEPLOY="glfw3.dll"

    if [ $VSCODE -eq "1" ]
    then
      echo "The configurations are for linux and not guaranteed to work"
      cp -r "configurations/linux/.vscode" "."
    fi

else
    # Unknown os
    echo "running on something else."
    echo "Not a supported OS: $OSTYPE" >&2
    exit 1
fi

echo "number of THREADS:$THREADS"

git submodule update --init
if [ $? -eq 0 ]
then
    echo "Successfully initiated submodules"
else
    echo "Could not initiate submodules" >&2
    exit 1
fi

if [ $CI -eq "0" ]
then
  git lfs install
  if [ $? -eq 0 ]
  then
      echo "Successfully initiated git-lfs"
  else
      echo "Could not initiate git-lfs" >&2
      exit 2
  fi

  git-lfs pull
  if [ $? -eq 0 ]
  then
      echo "Successfully pulled git-lfs"
  else
      echo "Could not pulled git-lfs" >&2
      exit 2
  fi
else
  echo "running in ci mode"
fi


cd "dependencies/gladRepo"
python -m glad --generator=c --extensions=GL_EXT_framebuffer_multisample,GL_EXT_texture_filter_anisotropic --out-path="../glad" --reproducible --profile core
if [ $? -eq 0 ]
then
  echo "Successfully initilized glad"
else
  echo "Could not initilize glad" >&2
  cd "../.."
  exit 3
fi
cd "../.."

cp -r "include/gitglm/glm" "include/glm"
if [ $? -eq 0 ]
then
    echo "Successfully copied glm"
else
    echo "Could not copy glm" >&2
    exit 2
fi


cp -r "dependencies/glfw/include/GLFW" "include/GLFW"
if [ $? -eq 0 ]
then
    echo "Successfully copied GLFW"
else
    echo "Could not copy GLFW" >&2
    exit 2
fi

mkdir -p "build"

#compiling glfw
mkdir -p "build/glfw"
cd "build/glfw"
cmake -G "Ninja" -DBUILD_SHARED_LIBS=ON  "../../dependencies/glfw"
ninja -j"$THREADS"

if [ $? -eq 0 ]
then
  echo "Successfully compiled glfw"
else
  echo "Could not compile glfw" >&2
  cd "../.."
  exit 2
fi
cd "../.."

#copy results
mkdir -p "lib"
mkdir -p "build/$BUILDNAME"
mkdir -p "deploy"

cp "build/glfw/src/$GLFWLIB" "lib"
cp "build/glfw/src/$GLFWDEPLOY" "lib"

cp "build/glfw/src/$GLFWLIB" "build/$BUILDNAME"

cp "build/glfw/src/$GLFWLIB" "deploy"
cp "build/glfw/src/$GLFWDEPLOY" "deploy"

cp -r "dependencies/glad/include" "."
cp -r "dependencies/glad/src/glad.c" "src"


echo "Successfully finished setup"
exit 0