
# Welcome to Greenfoot++ [![Build Status](https://travis-ci.com/noah1510/greenfoot-.svg?token=2eVNi9H2pzmQyzez9TXo&branch=master)](https://travis-ci.com/noah1510/greenfoot-)

The goal is to create an easy to use 2D Game engine using C++.
Its purpose is to give new programmers an easy introduction into game programming and even more abstract topics like object oriented programming and graphics programming in general.
The used OpenGL APIs are GLFW and glad so this project should run on all operating systems.

This Project provides several functions and objects that make it easier to start building your own games.
While these objects give you a simple way to get started, they also allow you to insert advanced OpenGL commands.

## License information

The code is licensed under the LGPL-3.0 License.

All the other stuff, like Textures, Images and Sounds are Licensed under CC-0.
If they are not made by me, I will publish the source in the [wiki](https://github.com/noah1510/greenfoot-/wiki/External-Sources).
In case the license differs from CC-0 it will also be mentioned there.

## How to compile/install this project

Before you start make shure you installed cmake, make, gcc ang g++ (`sudo apt install cmake make gcc g++`).
Note that while it should work on Windows and Mac I don't actively support those platforms.
Also you need CMake version 3.12 or newer, on LTS Linux distributions you might need to install it over a diffent route.

* Clone the repo with --recursive flag
* Download and install GLFW and GLM for your operating system (on Ubuntu: `sudo apt install xorg-dev`
* run `./scripts/install_linux.sh` (You can specify a custom filename just put it after the script).
* enjoy (you can run the main.out)

### Extra Ntes for contibutors

All changes have to be made on the dev branch and merged to master via a pull request.
Open a Terminal in the folder where you cloned the repository to, type `git checkout dev` and you are ready to go.

## Getting started

If you want to get started using this project, begin by modifying the games.cpp file.
The functions that specify the game logic are here.

game_init is called in the beginning to construct the main world that the game will enter first.
game_loop is called every game tick, here is where all the logic happens.

## How to contribute to this project

Just open a new issue if you find a bug or miss a feature, just make shure to use the appropiate tags.

If you have implemented a new feature or bugfix just make a pull request and wait till I have time to watch it.
Please document your changes, this will mak it easier for everyone.

Also feel free to propose updates/changes for the wiki to improve the overall documentation and allow newcomers to have more fun (because they don't have to guess what the functions and objects are doing).
