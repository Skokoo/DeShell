/*

   Copyright 2026 Skokoo

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

*/

.arch armv8-a
.text
.global main
.extern printf, getenv, random, autosave, load_save
.extern eq, wel, reg, user, def, save, env, go

/*
  main   = entry point
  got    = env var / user ptr
  banner = OBVIOUS
  go     = jump to main loop (on loop.s)
*/

// no need to explain who motivated me to code this
main:
    // no need to explain
    stp     x29, x30, [sp, -96]!
    stp     x19, x20, [sp, 16]
    stp     x21, x22, [sp, 32]
    stp     x23, x24, [sp, 48]
    stp     x25, x26, [sp, 64]
    stp     x27, x28, [sp, 80]

    // init :D
    mov     x19, 1 // x19 = level (starts from 1)
    mov     x20, 0 // x20 = exp (0)
    mov     x21, 0 // x21 = coins (0)
    mov     x22, 0 // x22 = exp boost (0)

    adrp    x0, env
    add     x0, x0, :lo12:env
    bl      getenv // check user env
    cbnz    x0, got // use it
    adrp    x0, def // use def
    add     x0, x0, :lo12:def

got:
    // store
    adrp    x1, user
    add     x1, x1, :lo12:user
    str     x0, [x1]

    bl      load_save
    cmp     x0, 16 // make sure save file is 16 bytes
    b.ne    banner // if not valid = skip, make new one

    // sanity check so save isn't corrupt
    adrp    x0, save
    add     x0, x0, :lo12:save
    ldr     w1, [x0]
    mov     w2, 10000
    cmp     w1, w2
    b.hi    banner // just remember the keyword "banner"

    // load save into game regs (x19-22)
    ldp     w1, w2, [x0]
    ldp     w3, w4, [x0, 8]
    sxtw    x19, w1
    sxtw    x20, w2
    sxtw    x21, w3
    sxtw    x22, w4

banner:
    adrp    x0, eq
    add     x0, x0, :lo12:eq
    bl      printf

    adrp    x0, wel
    add     x0, x0, :lo12:wel
    bl      printf

    adrp    x0, reg
    add     x0, x0, :lo12:reg
    adrp    x1, user
    add     x1, x1, :lo12:user
    ldr     x1, [x1]
    bl      printf

    adrp    x0, eq
    add     x0, x0, :lo12:eq
    bl      printf

    bl      go // check loop.s if you wondering

    // cleanup
    bl      autosave
    ldp     x19, x20, [sp, 16] // restore regs
    ldp     x21, x22, [sp, 32]
    ldp     x23, x24, [sp, 48]
    ldp     x25, x26, [sp, 64]
    ldp     x27, x28, [sp, 80]
    ldp     x29, x30, [sp], 96 // restore sp
    mov     x0, 0
    ret