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
.global autosave
.global load_save
.extern save
.extern path
.extern old

/*
  load_save = load save
  oldpath   = fallback
  autosave  = save game
  done      = return
*/

// check your $TMPDIR. you see .deshell_save2 thingy oh yeahh, just dont delete it.
load_save:
    mov     x0, #-100
    adrp    x1, path
    add     x1, x1, :lo12:path
    mov     x2, 0
    mov     x8, 56
    svc     0

    cmp     x0, 0
    b.lt    oldpath // no save

    mov     x9, x0
    adrp    x1, save
    add     x1, x1, :lo12:save
    mov     x2, 16 // lvl+exp+coin+boost
    mov     x8, 63 // read save
    svc     0

    mov     x10, x0
    mov     x0, x9
    mov     x8, 57 // close
    svc     0

    mov     x0, x10
    ret

oldpath:
    mov     x0, #-100
    adrp    x1, old
    add     x1, x1, :lo12:old
    mov     x8, 35
    svc     0

    mov     x0, 0
    ret

autosave:
    // save all regs first,
    stp     x29, x30, [sp, -96]!
    stp     x19, x20, [sp, 16]
    stp     x27, x28, [sp, 80]
    stp     x21, x22, [sp, 32]
    stp     x25, x26, [sp, 64]
    stp     x23, x24, [sp, 48]

    adrp    x0, save
    add     x0, x0, :lo12:save
    stp     w19, w20, [x0]
    stp     w21, w22, [x0, 8] // save data

    mov     x0, #-100
    adrp    x1, path
    add     x1, x1, :lo12:path
    mov     x2, 577 // create/write
    mov     x3, 420
    mov     x8, 56 // open
    svc     0

    cmp     x0, 0
    b.lt    done  // if fail open, skip saving

    mov     x9, x0
    adrp    x1, save
    add     x1, x1, :lo12:save
    mov     x2, 16
    mov     x3, 0
    mov     x8, 68 // write
    svc     0

    mov     x0, x9
    mov     x8, 57 // close
    svc     0

done:
    // ...
    ldp     x19, x20, [sp, 16]
    ldp     x27, x28, [sp, 80]
    ldp     x21, x22, [sp, 32]
    ldp     x25, x26, [sp, 64]
    ldp     x23, x24, [sp, 48]
    ldp     x29, x30, [sp], 96
    ret