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
.global go
.extern printf, fflush, chdir, system, strcmp
.extern eq, prompt, cy, cgn, cgb, cgbo, user, buf
.extern bye, off, on, up, cderr, cmd_err, gain, upg, verb_off, verb_on

/*
  go       = main loop
  ycol     = yellow (color)
  gn       = green normal
  gb       = green mid
  gbo      = green bold
  doprompt = print prompt
  af       = router
  ex       = exit check
  offon    = OFF/ON verbose
  upgchk   = upgrade
  cd       = cd handler
  cdfail   = cd error
  dosys    = run system cmd
  nn       = no newline handling
*/

go:
    // calc max exp for this level (max)
    lsl     x1, x19, 5 // x1 = lvl * 32
    sub     x1, x1, x19 // x1 = (lvl * 32) - lvl = lvl * 31
    sub     x1, x1, x19 // x19 * 30
    mov     x25, x1 // max exp for this level

    // calc percent
    lsl     x1, x20, 6
    lsl     x2, x20, 5
    add     x1, x1, x2
    lsl     x2, x20, 2
    add     x0, x1, x2 // exp * 100

    cbz     x25, ycol
    udiv    x0, x0, x25 // x0 = percent (0 - 100+)

    // UX? (pick color by percent)
    cmp     x0, 75
    b.ge    gbo
    cmp     x0, 50
    b.ge    gb
    cmp     x0, 25
    b.ge    gn

ycol:
    adrp    x2, cy
    add     x2, x2, :lo12:cy
    b       doprompt

gn:
    adrp    x2, cgn
    add     x2, x2, :lo12:cgn
    b       doprompt

gb:
    adrp    x2, cgb
    add     x2, x2, :lo12:cgb
    b       doprompt

gbo:
    adrp    x2, cgbo
    add     x2, x2, :lo12:cgbo

doprompt:
    // prompt
    // x19 = lvl, x20 = exp, x25 = max, x21= coin (incase i forgot)
    adrp    x0, prompt
    add     x0, x0, :lo12:prompt
    mov     x1, x19
    mov     x3, x20
    mov     x4, x25 
    mov     x5, x21 
    adrp    x6, user
    add     x6, x6, :lo12:user
    ldr     x6, [x6] // user ptr
    bl      printf

    mov     x0, 0
    bl      fflush

    // read input
    mov     x0, 0 // stdin
    adrp    x1, buf
    add     x1, x1, :lo12:buf
    mov     x2, 511 // max len
    mov     x8, 63 // read
    svc     0
    cmp     x0, 0
    b.le    go // empty. loop again

    // no \n
    adrp    x1, buf
    add     x1, x1, :lo12:buf
    sub     x2, x0, 1
    ldrb    w3, [x1, x2]
    cmp     w3, 10 // \n?
    b.ne    nn
    strb    wzr, [x1, x2] // replace with 0
    b       af

nn:
    add     x1, x1, x0
    strb    wzr, [x1] // null term

af:
    // route cmd by first char
    // router? more like traffic police (laugh?)
    adrp    x0, buf
    add     x0, x0, :lo12:buf
    ldrb    w1, [x0]
    cbz     w1, go // enter

    cmp     w1, 'c'
    b.eq    cd // cd?
    cmp     w1, 'e'
    b.eq    ex // exit?
    cmp     w1, 'O'
    b.eq    offon // verbose stuff
    cmp     w1, 'U'
    b.eq    upgchk // upgrade
    b       dosys // run as sys cmd (obvious)

ex:
    // check exit
    adrp    x1, bye
    add     x1, x1, :lo12:bye
    bl      strcmp
    cbz     x0, quit
    b       dosys

offon:
    // check verbose (off/on)
    adrp    x0, buf
    add     x0, x0, :lo12:buf
    adrp    x1, off
    add     x1, x1, :lo12:off
    bl      strcmp
    cbz     x0, verb_off
    adrp    x0, buf
    add     x0, x0, :lo12:buf
    adrp    x1, on
    add     x1, x1, :lo12:on
    bl      strcmp
    cbz     x0, verb_on
    b       dosys

upgchk:
    // upgrade? its all yours. (if you have enough coins)
    adrp    x0, buf
    add     x0, x0, :lo12:buf
    adrp    x1, up
    add     x1, x1, :lo12:up
    bl      strcmp
    cbz     x0, upg
    b       dosys

cd:
    adrp    x0, buf
    add     x0, x0, :lo12:buf
    ldrb    w1, [x0, 1]
    cmp     w1, 'd'
    b.ne    dosys
    add     x0, x0, 3 // skip "cd "
    bl      chdir
    cbnz    x0, cdfail
    b       gain // award

cdfail:
    adrp    x0, cderr
    add     x0, x0, :lo12:cderr
    bl      printf
    b       go

dosys:
    // run external cmd
    adrp    x0, buf
    add     x0, x0, :lo12:buf
    bl      system
    cbnz    x0, cmd_err // if exit code != 0, trigger thing
    b       gain // reward