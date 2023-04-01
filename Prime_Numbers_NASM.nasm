; Display all prime numbers between 0 and 100,000
; ISS Program at SADT, Southern Alberta Institute of Technology
; March, 2023
; x86-64, NASM

; *******************************
; Group work portion -  Lab 4 part 3
; Ezra, Mitchell, Mykola, Ulysses
; *******************************

; Compile Instructions:
;    nasm -f elf64 -o p3_prime_group.o p3_prime_group.nasm
;    ld p3_prime_group.o -o p3_prime_group.bin -lc -dynamic-link /lib64/ld-linux-x86-64.so.2
;    ./p3_prime_group.bin


section .text

global _start

extern malloc

_start:

    mov r14, 0
    mov r15, 0              ; counter for _checking answers in stack
    mov rax, 1

    mov rbx, 10
    mov rdi, rbx            ; len integers in array
    imul rdi, 8             ; multiply by 8 to get a byte count (this is the parameter being given to malloc)
    call malloc             ; rax is a pointer to the allocated space (40 bytes)
    mov r12, rax

    mov rcx, 99998
    mov rbx, 2              ; rbx holds the base address of array
    push 0                  ; needed for end of algorith


_pushonstack:

    push rbx
    inc rbx

    loop _pushonstack       ; loop automatically looks at rcx and decrements rcx (if 0 decrement 1 and repeat)
    xor rsi, rsi
    xor rax, rax


_popoffrax:                 ; here we can pop the values in the array off the stack 1 by 1
    pop rax                 ; rax contains the current array value to apply the algorithm to, r12 contains the base address of new array
    cmp rax, 0x00
    je _stack_check
    mov r13, rax
    mov rbx, rax
    mov rcx, 0x2


_algorithm:

    ; Divide the number by the current divisor
    mov rax, r13            ; If second loop, need to refresh rax with number
    mov rdx, 0              ; If second loop, need to set remainder back to 0
    div rcx

    ; _check if the remainder is zero
    cmp rdx, 0
    je _check

    ; Increment the divisor
    inc rcx

    ; Continue looping
    jmp _algorithm


_add:
    mov [r12+r14*8], r13
    inc r14
    jmp _popoffrax


_check:
    cmp rcx, r13
    je _add
    jmp _popoffrax


_stack_check:
     push qword[r12+r15*8]
     cmp r15, 4
     je _display_start_text
     inc r15
     jmp _stack_check


_display_start_text:

    mov rax, 1
    mov rdi, 1
    mov rsi, prime_numbers
    mov rdx, prime_len
    syscall

    ; Preperation for _heretofore
    dec r14
    mov r15, 10


_heretofore:

    xor rbx, rbx
    xor r9, r9
    mov r9, [r12+r14*8]
    mov rax, r9

    ; _check if greater 9
    cmp r9, 9
    jg _base_10
    mov rbx, r9

    add r9, 0x30
    mov [value], r9
    mov rax, 1
    mov rdi, 1
    mov rsi, value
    mov rdx, 8
    syscall

    cmp rbx, 0
    je _exit

    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall
    dec r14
    jmp _heretofore


_base_10:
    xor r9, r9
    xor rdx, rdx
    div r15
    push rdx
    inc rbx

    jmp _double_loop


_double_loop:

    cmp rax, 9
    jg _base_10
    ; push rax
    mov r11, rax
    add r11, 0x30
    mov [value], r11
    mov rax, 1
    mov rdi, 1
    mov rsi, value
    mov rdx, 1
    syscall


_iterate_stack_and_display:

    cmp rbx, 0
    je _spacing
    pop r11
    add r11, 0x30
    mov [value], r11

    ; print
    mov rax, 1
    mov rdi, 1
    mov rsi, value
    mov rdx, 1
    syscall

    dec rbx
    jmp _iterate_stack_and_display


_spacing:
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall

    cmp r14, 0
    je _exit
    dec r14
    jmp _heretofore


_exit:
    mov rax, 60
    mov rdi, 0
    syscall


section .data
    space: db 0x20
    prime_numbers: db "The Prime Numbers: ", 0x00
    prime_len: equ $-prime_numbers


section .bss
    value resb 2            ; uninitialize buffer