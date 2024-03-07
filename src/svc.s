		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table
SYSTEMCALLTBL	EQU		0x20007B00 ; originally 0x20007500
SYS_EXIT		EQU		0x0		; address 20007B00
SYS_ALARM		EQU		0x1		; address 20007B04
SYS_SIGNAL		EQU		0x2		; address 20007B08
SYS_MEMCPY		EQU		0x3		; address 20007B0C
SYS_MALLOC		EQU		0x4		; address 20007B10
SYS_FREE		EQU		0x5		; address 20007B14

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table Initialization
		EXPORT	_syscall_table_init
_syscall_table_init
		LDR		R0, =SYSTEMCALLTBL		; originally 0x20007500
		
		LDR		R1, =0x0				; address 20007B00
		STR		R1, [R0, #SYS_EXIT*4]
		
		LDR		R1, =0x1				; address 20007B04
		STR		R1, [R0, #SYS_ALARM*4]
		
		LDR		R1, =0x2				; address 20007B08
		STR		R1, [R0, #SYS_SIGNAL*4]
		
		LDR		R1, =0x3				; address 20007B0C
		STR		R1, [R0, #SYS_MEMCPY*4]
		
		LDR		R1, =0x4				; address 20007B10
		STR		R1, [R0, #SYS_MALLOC*4]
		
		LDR		R1, =0x5				; address 20007B14
		STR		R1, [R0, #SYS_FREE*4]
	
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table Jump Routine
        EXPORT	_syscall_table_jump
		IMPORT _kfree
		IMPORT _kalloc
		IMPORT _signal_handler
		IMPORT _timer_start
			
_syscall_table_jump
		CMP 	R7, #1
		BEQ 	_timer_start 	; go to _timer_start
		CMP 	R7, #2
		BEQ 	_signal_handler	; go to _signal_handler
		CMP 	R7, #3
		BEQ 	_kalloc			; go to _kalloc
		CMP 	R7, #4
		BEQ 	_kfree			; go to _kfree
		
		MOV		pc, lr			
		
		END