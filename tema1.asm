%include "io.inc"

extern getAST
extern freeAST

section .bss
    ; La aceasta adresa, scheletul stocheaza radacina arborelui
    root: resd 1
section .text   
section .data
    isnegative dd 0

atoi:
    mov cl, [ebx]
    cmp cl, '-'
    je negative ; marchez faptul ca numarul ce urmeaza a fi convertit este negativ
    
    cmp cl, 0
    je set_sign
    
    imul eax, 10    
    sub ecx, 48 ; convertesc cifra (care initial era vazuta ca un caracter) intr-un intreg
    lea eax, [eax + ecx] ; adaug cifra respectiva la numarul pe care vreau sa-l formez
    
    inc ebx
    jmp atoi
    
set_sign:
    cmp byte[isnegative], 1
    je is_negative
    jmp return
    
negative:
    mov byte [isnegative], 1
    inc ebx
    jmp atoi
    
is_negative:
    mov edx, eax
    imul edx, 2
    sub eax, edx
    mov byte [isnegative], 0
    jmp return
         
    
traverse_ast:
    push ebp
    mov ebp, esp
    
    xor edx, edx
    mov eax, [ebp + 8]
    mov eax, [eax]
    mov eax, [eax]
    push eax 
    
    mov eax, [ebp + 8]
    mov edx, [eax + 4]

    cmp edx, 0 ; daca nodul e o frunza, atunci va contine un operand ce va fi convertit la un intreg
    je convert
    
    push edx
    call traverse_ast
    pop edx

    push eax ; retinem pe stiva rezultatul obtinut din subarborele stang
        
    mov eax, [ebp + 8]
    mov edx, [eax + 8]
    push edx
    call traverse_ast
    pop edx

    cmp [esp + 4], dword '+'
    jz addition
    cmp [esp + 4], dword '*'
    jz multiply
    cmp [esp + 4], dword '-'
    jz substraction
    cmp [esp + 4], dword '/'
    jz division

convert:
    mov ebx, [ebp + 8]
    mov ebx, [ebx]
    
    xor eax, eax
    xor ecx, ecx
    
    call atoi ; convertesc operandul la un intreg
   
multiply:
    xor edx, edx
    pop edx
    imul eax, edx
    jmp return   
     
addition:
    xor edx, edx
    pop edx
    add eax, edx
    jmp return
    
division:
    xor ebx, ebx
    pop ebx
    xor eax, ebx ; pun operanzii in ordinea corecta
    xor ebx, eax
    xor eax, ebx
    cdq
    idiv ebx
    jmp return

substraction:
    pop edx
    xor eax, edx ; interschimb valorile operanzilor
    xor edx, eax
    xor eax, edx
    sub eax, edx
    jmp return
        
return:
    leave
    ret

global main
main:
    mov ebp, esp; for correct debugging
    ; NU MODIFICATI
    push ebp
    mov ebp, esp
    
    ; Se citeste arborele si se scrie la adresa indicata mai sus
    call getAST
    mov [root], eax
 
    ; Implementati rezolvarea aici:
    push eax
    call traverse_ast
    PRINT_DEC 4, eax
    
    ; NU MODIFICATI
    ; Se elibereaza memoria alocata pentru arbore
    push dword [root]
    call freeAST
    
    xor eax, eax
    leave
    ret