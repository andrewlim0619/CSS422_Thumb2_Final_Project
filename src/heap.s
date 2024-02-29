		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table
HEAP_TOP	EQU		0x20001000
HEAP_BOT	EQU		0x20004FE0
MAX_SIZE	EQU		0x00004000		; 16KB = 2^14
MIN_SIZE	EQU		0x00000020		; 32B  = 2^5
	
MCB_TOP		EQU		0x20006800      	; 2^10B = 1K Space
MCB_BOT		EQU		0x20006BFE
MCB_ENT_SZ	EQU		0x00000002		; 2B per entry
MCB_TOTAL	EQU		512			; 2^9 = 512 entries
	
INVALID		EQU		-1			; an invalid id
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory Control Block Initialization
		EXPORT	_heap_init
_heap_init
		LDR 	R0, =MCB_TOP+0x4	; 	0x20006804
		LDR		R1, =0x20006C00
		B		_heap_mcb_init
			
_heap_mcb_init
		CMP 	R0, R1
		BEQ		_heap_init_done
		LDR 	R2, [R0]			; 	R2 == mem[MCB index]
		MOV		R2, #0x0			;	set R2 to 0
		ADD		R0, R0, #0x1		; 	increment index
		LDR 	R2, [R0]			; 	R2 == mem[MCB index]
		MOV		R2, #0x0			;	set R2 to 0
		ADD		R0, R0, #0x1		; 	increment index
		B 		_heap_mcb_init
	
_heap_init_done
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory Allocation
; void* _k_alloc( int size )
		EXPORT	_kalloc
_kalloc
		CMP		R0, #32
		BGE		_ralloc_init
		MOV		R0, #32

_ralloc_init
									;	R0 == size
		LDR		R1, =MCB_TOP		; 	R1 == MCB_TOP == left
		LDR		R2, =MCB_BOT		; 	R2 == MCB_BOT == right
		LDR		R3, =MCB_ENT_SZ		; 	R3 == MCB_ENT_SZ
		B		_ralloc
		
_ralloc
		SUB		R4, R2, R1			
		ADD		R4, R4, R3			;	R4 == entire
		ASR		R5, R4, #1			; 	R5 == half
		ADD		R6, R1, R5			; 	R6 == midpoint
		LSL		R7, R4, #4			;	R7 == act_entire_size
		LSL		R8, R5, #4			;	R8 == act_half_size
		MOV		R12, #0x0			; 	R12 == heap_addr
		
		CMP		R0, R8
		BGT		_no_alloc
		
		STMFD	sp!, {r0-r11,lr}	; save registers
		SUB		R2, R6, R3
		BL		_ralloc
		LDMFD	sp!, {r0-r11,lr}	; resume registers
		
		CMP		R12, #0x0
		BEQ		_ralloc_right
		LDR		R9, [R6]			; R9 == mem[midpoint]
		AND 	R9, R9, #0x01
		CMP		R9, #0
		BEQ		_return_heap_addr
		
_ralloc_right
		STMFD	sp!, {r0-r11,lr}	; save registers
		MOV		R1, R6
		BL		_ralloc
		LDMFD	sp!, {r0-r11,lr}	; resume registers
		B 		_ralloc_done
		
_return_heap_addr
		STR		R8, [R6]
		B		_ralloc_done
		
_no_alloc
		LDR 	R9, [R1]			; R9 == mem[left]
		AND 	R9, R9, #0x01
		CMP		R9, #0
		BEQ		_ralloc_done		; return null
		LDR		R9, [R1]			; R9 == mem[left]
		CMP		R9, R7
		BLT		_ralloc_done		; return null
		ORR		R9, R7, #0x01		; *(short *)&array[ m2a( left ) ] = act_entire_size | 0x01;
		STR		R9, [R1]
		LDR		R10, =MCB_TOP		; R10 == MCB_TOP
		LDR		R11, =HEAP_TOP		; R11 == HEAP_TOP
		SUB		R1, R1, R10			; left -= mcb_top
		LSL		R1, R1, #4			; left *= 16
		ADD		R11, R11, R1		; heap_top += left
		MOV		R12, R11			; heap_addr = heap_top + ( left - mcb_top ) * 16
		B		_ralloc_done

_ralloc_done
		MOV		pc, lr
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory De-allocation
; void free( void *ptr )
		EXPORT	_kfree
_kfree
	;; Implement by yourself
		MOV		pc, lr					; return from rfree( )
		
		END