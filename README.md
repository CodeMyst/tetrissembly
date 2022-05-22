# tetrissembly

An attempt at making a tetris game in 8086 assembly.

Currently, everything but different shapes (and rotation) are implemented.

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
