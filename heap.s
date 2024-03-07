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
	;; Implement by yourself
	
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory Allocation
; void* _k_alloc( int size )
		EXPORT	_kalloc
_kalloc
	;; Implement by yourself
		MOV		pc, lr
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory De-allocation
; void free( void *ptr )
		
_rfree

		SUB 		R8, R0, 0x20000000			; R0 = mcb_addr
  		LDR 		R1, =MCB_TOP				; R8 = m2a(mcb_addr)
  		SUB		R2, R0, R1		 		; mcb_offset = mcb_addr - mcb_top
    
		LDR 		R3, [R8]                 		; R3 = mcb_contents
		ASR		R4, R3, #4		 		; R4 = mcb_chunk
		LSL		R5, R3, #4		 		; R5 = my_size

  		DIV 		R6, R2, R4	
    		AND 		R7, R6, #1
      		CMP 		R7, #0			 		; Line 146 in heap.c
		BNE		odd_case		
		
		; Even Case
		ADD 		R6, R0, R4
  		LDR		R7, =MCB_BOT
  		CMP		R6, R7					; Line 150 in heap.c
		BGE		return_zero

  		SUB		R6, R6, 0x20000000			
    		LDR		R7, [R6]				; R7 = mcb_buddy

							  		
    		ANDS		R8, R7, #1				; Line 158 
      		CMP		R8, #0
		BNE		odd_case
  

  		LSR 		R7, R7, #5
    		LSL		R7, R7, #5				; Line 162

		CMP		R7, R5
  		BNE		odd_case				; Line 163

      		MOV		[R6], #0				; Line 168
		LSL		R5, R5, #1				; my_size *= 2
  		STR		R5, [R0]

      		STMFD		sp!, {R0-R12,lr}			; save registers
		BL		_rfree					; Recursion (line 178)
		LDMFD		sp!, {R0-R12,lr}			; resume registers
	
    	_odd_case:							; Line 183
     		SUB		R6, R0, R4				; R6 = mcb_addr - mcb_chunk
       		CMP		R1, R6
	 	BGE		return_zero

   		SUB		R6, R6, 0x20000000			; R6 = m2a(mcb_addr - mcb_chunk)			
     		LDR		R7, [R6]				; R7 = mcb_buddy
       	
		ANDS		R8, R7, #1				; Line 195
  		CMP		R8, #0
    		BNE		return_zero
    		; Can't understand where it branches to

  		LSR 		R7, R7, #5
    		LSL		R7, R7, #5				; Line 199

      		CMP		R7, R5
		BQE 		return_zero				; Line 200
		
		STR		R8, #0
    		LSL		R5, R5, #1				; my_size *= 2
		STR		R5, [R6]				; Line 207

  		
		STMFD		sp!, {R0-R12,lr}			; save registers
  		MOV		R0, R6
		BL		_rfree					; Recursion (line 216)
		LDMFD		sp!, {R0-R12,lr}			; resume registers
      		
	return_zero
  		return 		R0, #0
    		BX		LR					; Return from function
  		
    		BX		LR					; Return mcb_addr
  		
		END

		EXPORT	_kfree
_kfree
	;; Implement by yourself
		MOV		pc, lr					; return from rfree( )
  
		MOV		R1, R0					; Move pointer address into register R1
  		LDR		R2, =HEAP_TOP				; Load the HEAP_TOP value into R2
    		LDR		R3, =HEAP_BOT				; Load the HEAP_BOT value into R3	

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
		CMP  		R1, #0           			; Check if MCB address passed into _rfree() returns 0
		MOVEQ 		R1, #0          			; If above is true, address is assigned as null (zero)
  									; If not true, we will pass the MCB adress
		

		_invalid_address:
		MOV  		R0, #0           			; Set the return value to NULL
		

		END
