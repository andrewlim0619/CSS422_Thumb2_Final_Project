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
		

		_invalid_address
		MOV  		R0, #0           			; Set the return value to NULL
		

		END