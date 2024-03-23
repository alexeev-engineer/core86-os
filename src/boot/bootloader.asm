; -----------------------------------------------------------------------------
; File: 		src/boot/bootloader.asm
; Title:		Basic bootloader for Core86 OS
; Copyright (c) 2024, Alexeev Bronislav
; -----------------------------------------------------------------------------
; Description:
;  To let the BIOS know that the current flash drive, CD or hard drive 
;  contains an OS, there must be a boot sector on this media. The BIOS 
;  recognizes the boot sector by the “magic number” of 2 bytes (511 and 512), 
;  equal to 0xaa55 (in hexadecimal notation).
; -----------------------------------------------------------------------------

[bits 16]								; Enter 16-bit real address mode
[org 0x7c00]							; First sector of RAM

; *************************************************************************** ;
;                       START OF BOOTLOADER 16 BIT CODE                       ;
; *************************************************************************** ;

start:
	xor ax, ax 							; Set ax register to 0
	mov ds, ax 							; Set data segment to 0
	mov es, ax 							; Set extra segment to 0

	; Jumping from real mode (16bit) to protected mode (32bit)
	; by using disk interrupt

	mov ah, 0x02 						; Load second stage to memory
	mov al, 0x10						; Numbers of sectors to read into memory
	mov dl, 0x80 						; Sector read from fixed
	mov ch, 0 							; Cylinder number
	mov dh, 0 							; Head number
	mov cl, 2							; Sector number
	mov bx, _start						; Load into es:bx offset of buffer
	int 0x13							; Disk I/O interrupt

	; Clearing all interrupts
	cli

	; Load protected 32 bit mode
	jmp _start							; Jump to second stage of booting

	times (510-($-$$)) db 0x00 			; Set 512 bytes for boot sector
	dw 0xaa55							; Magic number 0xAA55

disk_interrupt:


; *************************************************************************** ;
;                        END OF BOOTLOADER 16 BIT CODE                        ;
; *************************************************************************** ;

; *************************************************************************** ;
;                 x86 (32 bit protected mode) code begin here                 ;
; *************************************************************************** ;

_start:
main:
	;; Set pointer to heap and stack pointer to stack for functions and vars

	mov ebp, __HEAP__
	mov esp, __STACK__

	lea ebx, [msg]
	push ebx
	call cout_str
	add esp, 4

	hlt

cout_str:
	push ebp
	;; Get string address in memory
	mov ebx, dword[ebp-8]
	mov ecx, 0

.cout_loop:
	cmp byte[ebx + ecx], 0
	je .exit

	; Get byte from buffer
	mov al, byte[ebx+ecx]
	mov ah, 0x0E
	int 0x10

	inc ecx

	jmp .cout_loop

.exit:
	pop ebp
	ret

; *************************************************************************** ;
;                  x86 (32 bit protected mode) code end here                  ;
; *************************************************************************** ;

;; Set the required disk space we need the size of image (4096 bytes)
times (4096-($-$$)) db 0x00

section .rodata
	__STACK__ dd 0x00FFFFFF
	__HEAP__ dd 0x00008C24

section .data
	msg db "Core86 OS", 0
