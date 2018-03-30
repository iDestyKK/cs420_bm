# Handy
*An attempt at a swiss-army knife for the C Programming Language*

## About
Handy is my own library which aims to be multi-purpose.
It's goal is to take the tasks that I found to be tedious in C programming and make it simpler.

## What's featured?
* Remakes of C++ STL data structures in C with time complexity guarantees compliant to the STL Standard.
  * CN\_Vec
  * CN\_List
  * CN\_Stack
  * CN\_Queue
  * CN\_Map (w/ CN\_Comp)
  * CN\_String
* Input Streams in 3 forms:
  * File Stream
  * Buffered File Stream
  * String Stream
* It's own memory allocation mechanism (lmalloc, lfree, lfreeall)
* Math library
* CN datatype-aliases which allow guarantees across platforms.

## Why use Handy?
One use of a generic library is to ensure that, across different platforms, it acts the exact same.
Implementations of a std::map may be different on another platform. But if you use CN\_Map, you are guaranteed to have the code do the *exact intended task* on every platform.

Also, it's made to make your life easier... duh.

## Versions Available
The primary version is written in the GNU89 Standard of C. But there is also a C++ version available. I will maintain both versions and make sure they are as portable as possible.
