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
.global random
.extern seed

/*
  random = random xorshift
  seed   = current seed
  done   = return value
*/

random:
    adrp    x1, seed
    add     x1, x1, :lo12:seed
    ldr     x2, [x1] // load seed

    // xorshift thing
    eor     x2, x2, x2, lsl 13
    eor     x2, x2, x2, lsr 7
    eor     x2, x2, x2, lsl 17
    str     x2, [x1] // save new seed

    and     x0, x2, 127 // 0-127
    cmp     x0, 100
    b.lt    done // if <100 = ok

    sub     x0, x0, 100 // 100-127 -> 0-27
    cmp     x0, 100
    b.lt    done

    sub     x0, x0, 28 // (just in case) clamp again

done:
    ret // back into, idk