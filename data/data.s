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
.data

// my name is skokoo

.global eq, wel, reg, prompt, cy, cgn, cgb, cgbo
.global coin, exp, crit, leg, lvl, err, cderr
.global upg1, upg2, upgno, q, upgok, cancel
.global voff, von, path, old, env, def
.global user, ok, up, bye, off, on, verb, seed
.global buf, save

eq:     .asciz "==================================================\n"
wel:    .asciz " Welcome to DeShell\n"
reg:    .asciz " Player Registered: %s\n"
prompt: .asciz "[LV.%d][%sEXP:%d/%d\033[0m][\033[1;33mCoins:%d\033[0m] %s> "

cy:     .asciz "\033[93m"
cgn:    .asciz "\033[32m"
cgb:    .asciz "\033[92m"
cgbo:   .asciz "\033[1;92m"

coin:   .asciz "\033[1;33m[$] +%d Coins\033[0m\n"
exp:    .asciz "[+] +%d EXP (+%d)\n"
crit:   .asciz "\033[92m[^] [Crit! EXP x2]\033[0m\n"
leg:    .asciz "\033[96m[^] [Legendary!! EXP x5]\033[0m\n"
lvl:    .asciz "\n \033[1;92m[*] level up! (%s reached LV.%d)\033[0m \n\n"
err:    .asciz "\033[1;31m[-]\033[0m Command executed with error code, no EXP granted :)\n"
cderr:  .asciz "\033[1;31m[-]\033[0m cd failed\n"

upg1:   .asciz "\n\033[1;33m--- UPGRADE ---\033[0m\n Current Boost : Permanent EXP Boost +%d\n"
upg2:   .asciz " Upgrade Cost  : \033[1;33m%d Coins\033[0m\n Effect        : Permanently increases EXP gain by \033[92m+5\033[0m.\n------------------------------------------------\n"
upgno:  .asciz "\033[1;31m[X]\033[0m Insufficient coins\n"
q:      .asciz "Type '\033[32mproceed\033[0m' to confirm purchase: "
upgok:  .asciz "\n\033[1;92m[+]\033[0m upgraded! Your EXP boost is now: \033[1;92m+%d\033[0m.\n\n"
cancel: .asciz "Purchase cancelled.\n\n"

voff:   .asciz "\033[90m[verbose off]\033[0m\n"
von:    .asciz "\033[90m[verbose on]\033[0m\n"

path:   .asciz "/data/data/com.termux/files/usr/tmp/.deshell_save2"
old:    .asciz "/data/data/com.termux/files/usr/tmp/.deshell_save"
env:    .asciz "USER"
def:    .asciz "u0_a382"
ok:     .asciz "proceed"
up:     .asciz "UPGRADE"
bye:    .asciz "exit"
off:    .asciz "OFFVERBOSE"
on:     .asciz "ONVERBOSE"

user:   .quad 0
verb:   .word 1
seed:   .quad 0x9E3779B97F4A7C15

buf:    .space 512
save:   .space 16