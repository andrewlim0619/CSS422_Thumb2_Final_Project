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
		LDR		R0, =MCB_TOP
		LDR 	R1, =MAX_SIZE
		STR		R1, [R0]
		
		LDR 	R0, =MCB_TOP+0x4		; 0x20006804
		LDR		R1, =0x20006C00
		MOV		R2, #0x0
			
_heap_mcb_init
		CMP 	R0, R1
		BGE	_heap_init_done
		
		STR		R2, [R0]			; zero out mem[mcb index]
		ADD		R0, R0, #1			; zero out mem[mcb index + 1]
		STR		R2, [R0]
		ADD		R0, R0, #2			; mcb index += 2
		B 	_heap_mcb_init
	
_heap_init_done
		MOV	pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory Allocation
; void* _k_alloc( int size )
		EXPORT	_kalloc
_kalloc
		PUSH	{lr}
		CMP	R0, #32
		BGE	_ralloc_init
		MOV	R0, #32

_ralloc_init
									; R0 == size
		LDR	R1, =MCB_TOP			; R1 == MCB_TOP == left
		LDR	R2, =MCB_BOT			; R2 == MCB_BOT == right
		LDR	R3, =MCB_ENT_SZ			; R3 == MCB_ENT_SZ
		BL	_ralloc
		
		POP		{lr}
		MOV		R0, R12
		MOV		pc, lr
		
_ralloc		
		PUSH	{lr}
		
		SUB	R4, R2, R1			
		ADD	R4, R4, R3			; R4 == entire
		ASR	R5, R4, #1			; R5 == half
		ADD	R6, R1, R5			; R6 == midpoint
		LSL	R7, R4, #4			; R7 == act_entire_size
		LSL	R8, R5, #4			; R8 == act_half_size
		MOV	R12, #0x0			; R12 == heap_addr
		
		CMP	R0, R8
		BGT	_no_alloc
		
		PUSH	{r0-r8}		; save registers
		SUB	R2, R6, R3
		BL	_ralloc
		POP		{r0-r8}		; resume registers
		
		CMP	R12, #0x0
		BEQ	_ralloc_right
		
		LDR	R9, [R6]			; R9 == mem[midpoint]
		AND R9, R9, #0x01
		CMP	R9, #0
		BEQ	_return_heap_addr
		B	_ralloc_done
		
_ralloc_right
		PUSH	{r0-r8}		; save registers
		MOV	R1, R6
		BL	_ralloc
		POP		{r0-r8}		; resume registers
		B 	_ralloc_done
		
_return_heap_addr
		STR	R8, [R6]
		B	_ralloc_done
		
_no_alloc
		LDR 	R9, [R1]			; R9 == mem[left]
		AND 	R9, R9, #0x01
		CMP	R9, #0
		BNE	_return_invalid			; return invalid
		
		LDR	R9, [R1]			; R9 == mem[left]
		CMP	R9, R7
		BLT	_return_invalid			; return invalid
		
		ORR	R9, R7, #0x01			; *(short *)&array[ m2a( left ) ] = act_entire_size | 0x01;
		STR	R9, [R1]
		
		LDR	R9, =MCB_TOP			; R9 == MCB_TOP
		LDR	R10, =HEAP_TOP			; R10 == HEAP_TOP
		SUB	R1, R1, R9			; left -= mcb_top
		LSL	R1, R1, #4			; left *= 16
		ADD	R10, R10, R1			; heap_top += left
		MOV	R12, R10			; heap_addr = heap_top + ( left - mcb_top ) * 16
		B	_ralloc_done
		
_return_invalid
		MOV	R12, #0
		B	_ralloc_done

_ralloc_done
		POP		{lr}
		BX		LR
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory De-allocation
; void free( void *ptr )
		EXPORT	_kfree

_kfree
	;; Implement by yourself
		PUSH	{lr}
		
		MOV		R1, R0					; Move pointer address into register R1
  		LDR		R2, =HEAP_TOP				; Load the HEAP_TOP value into R2
    	LDR		R3, =HEAP_BOT				; Load the HEAP_BOT value into R3	
		ADD		R1, R1, R2

		; If statement
	    CMP  		R1, R2					; If address is smaller than HEAP_TOP
    	BLT  		_invalid_address			; Return Null
   	 	CMP  		R1, R3					; If address is larger than HEAP_BOT
    	BGT  		_invalid_address			; Return Null

		 ; Compute the MCB address
		LDR  		R4, =MCB_TOP     			; Load the top of the MCB
    	SUB  		R1, R1, R2      			; Subtract HEAP_TOP from the pointer
    	LSR  		R1, R1, #4       			; Divide the difference by 16 (logical shift right by 4 bits)
    	ADD  		R1, R4, R1       			; Add the result to MCB_TOP to get the MCB address

		; Call the _rfree function 
		BL   		_rfree
		POP			{LR}
		CMP  		R0, #0           			; Check if MCB address passed into _rfree() returns 0
		BEQ			_invalid_address
		MOV			pc, lr
		
_invalid_address
		MOV  		R0, #0           			; Set the return value to NULL
		B			_free_done
	
_rfree
		PUSH	{lr}
		
		MOV		R0, R1						; R0 = mcb_addr
  		LDR 	R1, =MCB_TOP				; R1 = MCB_TOP
  		SUB		R2, R0, R1		 		; R2 = mcb_offset -> mcb_addr - mcb_top
    
		LDR 	R3, [R0]                 ; R3 = mcb_contents
		ASR		R4, R3, #4		 		; R4 = mcb_chunk
		LSL		R5, R3, #4		 		; R5 = my_size
		
		STR		R3, [R0]

  		SDIV 	R6, R2, R4
    	AND 	R6, R6, #1
      	CMP 	R6, #0			 		; Line 146 in heap.c
		BNE		_odd_case		
		
		; Even Case
		ADD 	R6, R0, R4
  		LDR		R7, =MCB_BOT
  		CMP		R6, R7					; Line 150 in heap.c
		BGE		return_zero
		
    	LDR		R7, [R6]				; R7 = mcb_buddy
							  		
    	AND		R8, R7, #1				; Line 158 
      	CMP		R8, #0
		BNE		_free_done
  
  		LSR 	R7, R7, #5
    	LSL		R7, R7, #5				; Line 162

		CMP		R7, R5
  		BNE		_free_done				; Line 163

		MOV		R8, #0
      	STR		R8, [R6]				; Line 168
		LSL		R5, R5, #1				; my_size *= 2
  		STR		R5, [R0]

      	PUSH	{R0-R12,lr}			; save registers
		BL		_rfree					; Recursion (line 178)
		POP		{R0-R12,lr}			; resume registers
	
_odd_case								; Line 183
     	SUB		R6, R0, R4				; R6 = mcb_addr - mcb_chunk
       	CMP		R1, R6
	 	BGT		return_zero
		
     	LDR		R7, [R6]				; R7 = mcb_buddy
       	
		AND		R8, R7, #1				; Line 195
  		CMP		R8, #0
    	BNE		_free_done

  		LSR 	R7, R7, #5
    	LSL		R7, R7, #5				; Line 199

      	CMP		R7, R5
		BEQ	 	_free_done				; Line 200
		
		MOV		R9, #0
		STR		R9, [R0]
    	LSL		R5, R5, #1				; my_size *= 2
		STR		R5, [R6]				; Line 207

  		
		PUSH	{R0-R12,lr}			; save registers
		LDR		R0, [R6]
		BL		_rfree					; Recursion (line 216)
		POP		{R0-R12,lr}			; resume registers
      		
return_zero
  		MOV 	R0, #0
    	BX		LR					; Return from function

_free_done
  		POP	{lr}
		BX		lr					; return from rfree( )

		END