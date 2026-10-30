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
.global gain, cmd_err, verb_off, verb_on, upg, quit
.extern printf, fflush, strcmp, random, autosave, go
.extern leg, crit, coin, exp, verb, err
.extern voff, von, upg1, upg2, upgno
.extern q, buf, ok, upgok, cancel, lvl, user


/*
  gain     = calc reward EXP & coins (RNG)
  chkcrit  = check legendary | critical event
  docoin   = add coins & EXP (also check verbose)
  cmd_err  = handler if sys cmd fails
  verb_off = turn off verbose log
  verb_on  = turn on verbose log
  upg      = shop for boost
  can      = confirm purchase
  cc       = cancel upgrade
  quit     = autosave (again) and exit
*/

// warning: you might face some RNG again :)
// yk this file name is "action.s", action have consequences.
gain:
    // base EXP = 10 + boost/x22
    add     x26, x22, 10
    bl      random
    cmp     x0, 3
    b.gt    chkcrit
    b.eq    chkcrit

    // 2nd event: "Legendary" (EXP x5)
    adrp    x0, leg
    add     x0, x0, :lo12:leg
    bl      printf
    lsl     x1, x26, 2
    add     x26, x1, x26
    b       docoin

chkcrit:
    cmp     x0, 15
    b.gt    docoin
    // 1st event: "Critical" (EXP x2)
    adrp    x0, crit
    add     x0, x0, :lo12:crit
    bl      printf
    add     x26, x26, x26

docoin:
    // roll random coins (1 to 8)
    bl      random
    and     x28, x0, 7
    add     x28, x28, 1
    add     x20, x20, x26 // add total EXP (x20)
    add     x21, x21, x28 // add total coin (x21)

    // check verbose (if 0, skip log)
    adrp    x0, verb
    add     x0, x0, :lo12:verb
    ldr     w0, [x0]
    cbz     w0, skiplog

    adrp    x0, coin
    add     x0, x0, :lo12:coin
    mov     x1, x28
    bl      printf

    adrp    x0, exp
    add     x0, x0, :lo12:exp
    mov     x1, x26
    mov     x2, x22
    bl      printf

skiplog:
    // autosave every action
    bl      autosave

    // check if enough EXP to level up
    lsl     x1, x19, 5
    lsl     x0, x19, 1
    sub     x0, x1, x0
    sub     x0, x0, x19 // max exp for this level (x0)
    cmp     x20, x0
    b.lt    go

    // LEVEL UP!
    sub     x20, x20, x0 // leftover
    add     x19, x19, 1 // so much lvl++
    adrp    x0, lvl
    add     x0, x0, :lo12:lvl
    adrp    x1, user
    add     x1, x1, :lo12:user
    ldr     x1, [x1]
    mov     x2, x19
    bl      printf
    bl      autosave
    b       go

cmd_err:
    // only if sys cmd failed (exit code != 0)
    adrp    x0, err
    add     x0, x0, :lo12:err
    bl      printf
    b       go

verb_off:
    // set verbose 0 
    adrp    x0, verb
    add     x0, x0, :lo12:verb
    str     wzr, [x0]
    adrp    x0, voff
    add     x0, x0, :lo12:voff
    bl      printf
    b       go

verb_on:
    // set verbose 1
    adrp    x0, verb
    add     x0, x0, :lo12:verb
    mov     w1, 1
    str     w1, [x0]
    adrp    x0, von
    add     x0, x0, :lo12:von
    bl      printf
    b       go

upg:
    // calc upgrade prize based on current boost
    lsr     x0, x22, 2
    mov     x1, 1
    lsl     x1, x1, x0
    lsl     x2, x1, 4
    add     x2, x2, x1
    lsl     x25, x2, 3
    add     x25, x25, x2 // x25 = total price

    adrp    x0, upg1
    add     x0, x0, :lo12:upg1
    mov     x1, x22
    bl      printf
    adrp    x0, upg2
    add     x0, x0, :lo12:upg2
    mov     x1, x25
    bl      printf

    // check if player have enough coins
    cmp     x21, x25
    b.ge    can // confirm
    adrp    x0, upgno // not enough? broke
    add     x0, x0, :lo12:upgno
    bl      printf
    b       go

can:
    // user, please type "proceed" to confirm. typo
    adrp    x0, q
    add     x0, x0, :lo12:q
    bl      printf
    mov     x0, 0
    bl      fflush

    // read confirm inpt
    mov     x0, 0
    adrp    x1, buf
    add     x1, x1, :lo12:buf
    mov     x2, 511
    mov     x8, 63
    svc     0
    cmp     x0, 0
    b.le    go

    adrp    x1, buf
    add     x1, x1, :lo12:buf
    sub     x2, x0, 1
    strb    wzr, [x1, x2]

    // compare with proceed
    adrp    x0, buf
    add     x0, x0, :lo12:buf
    adrp    x1, ok
    add     x1, x1, :lo12:ok
    bl      strcmp
    cbnz    x0, cc // if not "proceed", cancel

    // yeyy success! deduct coins and +5 boost
    sub     x21, x21, x25
    add     x22, x22, 5
    adrp    x0, upgok
    add     x0, x0, :lo12:upgok
    mov     x1, x22
    bl      printf
    bl      autosave
    b       go

cc:
    // cancel for what? upgrade
    adrp    x0, cancel
    add     x0, x0, :lo12:cancel
    bl      printf
    b       go

quit:
    // cleanup stack, autosave, exit clean
    bl      autosave
    ldp     x19, x20, [sp, 16]
    ldp     x27, x28, [sp, 80]
    ldp     x21, x22, [sp, 32]
    ldp     x25, x26, [sp, 64]
    ldp     x23, x24, [sp, 48]
    ldp     x29, x30, [sp], 96
    mov     x0, 0
    ret