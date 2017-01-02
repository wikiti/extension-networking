# Basic example

## Description

This example is a simple networking session which will share the position of a sprite between a server and multiple clients.

![](preview.gif)

## Directory tree

This is the directory tree structure:

````
basic-example
  |- assets      # Assets folder (images and icons). Not important.
  |- src         # Haxe code folder.
  |  |- Main.hx  # Main code content.
  |- preview.gif # Example GIF.
  |- project.xml # OpenFL XML project file.
  |- README.md   # This file.
````

The main content is inside the [src/Main.hx](src/Main.hx) file. It is well documented, so you can ignore everything else and focus on that file.

## Usage

Open a terminal within the example folder, and run:

````sh
$ lime build <linux|windows|...>
````

After that, you can run it with:

````sh
$ lime run <linux|windows|...>
````

Run it twice in two different terminals; create a server and a client, click the screen on any window, and check the output!

