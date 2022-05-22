# tetrissembly

An attempt at making a tetris game in 8086 assembly.

Currently, everything but different shapes (and rotation) are implemented.

Here is some example (and very boring) gameplay:

https://user-images.githubusercontent.com/7966628/169717452-7656e5df-1995-41c0-a0bb-fc972d8e06ae.mp4

## How to run

You can compile this to a COM executable either by using emu8086 or using fasm directly.

### emu8086

Open this file in emu8086, and uncomment the #fasm# line so that emu8086 knows to use the fasm syntax. Now you can compile the file.

Now open the COM executable in DOSbox.

### fasm

If you have fasm installed just run it:

```
fasm tetris.asm
```

Now open the COM executable in DOSbox.
