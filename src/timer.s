		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Timer Definition
STCTRL		EQU		0xE000E010		; SysTick Control and Status Register
STRELOAD	EQU		0xE000E014		; SysTick Reload Value Register
STCURRENT	EQU		0xE000E018		; SysTick Current Value Register
	
STCTRL_STOP	EQU		0x00000004		; Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 0, Bit 0 (ENABLE) = 0
STCTRL_GO	EQU		0x00000007		; Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 1, Bit 0 (ENABLE) = 1
STRELOAD_MX	EQU		0x00FFFFFF		; MAX Value = 1/16MHz * 16M = 1 second
STCURR_CLR	EQU		0x00000000		; Clear STCURRENT and STCTRL.COUNT	
SIGALRM		EQU		14				; sig alarm

; System Variables
SECOND_LEFT	EQU		0x20007B80		; Secounds left for alarm( )
USR_HANDLER EQU		0x20007B84		; Address of a user-given signal handler function	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer initialization
; void timer_init( )
		EXPORT		_timer_init
_timer_init
	;; Implement by yourself
		;;(1) Make sure to stop SysTick:
		;;	Set SYST_CSR’s Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 0, Bit 0 (ENABLE) = 0
		;;(2) Load the maximum value to SYST_RVR:
		;;	The value should be 0x00FFFFFF which means MAX Value = 1/16MHz * 16M = 1 second
		
		;; Stop SysTick:
		LDR		R0, =STCTRL_STOP		; load systick control
		LDR		R1, =STCTRL				; load systick stop value (4)
		STR		R0, [R1]				; update systick control to stop
		
		;; Load the maximum value to SYST_RVR
		LDR		R0, =STRELOAD_MX		; load countdown to r0 to equal 1 second
		LDR		R1, =STRELOAD			; load address of systick reload into r1
		STR		R0, [R1]				

		LDR		r0, =STCURRENT	
		LDR		r1, =0x00000000			; Ensure register is clear for use and no remaining time leftovers
		STR		r1, [r0]
	
		MOV		pc, lr		; return to Reset_Handler
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer start
; int timer_start( int seconds )
		EXPORT		_timer_start
_timer_start
	;; Implement by yourself
		;; The alarm( seconds ) function relays this seconds argument in R0 from main( ) all the way to _timer_start
		;; in timer.s. Retrieve the previous value at 0x20007B80 that is recognized as the previous time valuve and
		;; returned to main( ) through R0, save the new seconds value to 0x20007B80, and start the SysTick timer.
		;; (1) Retrieve the seconds parameter from memory address 0x20007B80, which is the previous time
		;; 		value and should be returned to main( ).
		;; (2) Save a new seconds parameter from alarm( ) to memory address 0x20007B80.
		;; (3) Enable SysTick:
		;; 		Set SYST_CSR’s Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 1, Bit 0 (ENABLE) = 1
		;; (4) Clear SYST_CVR:
		;; 		Set 0x00000000 in SYST_CVR
		
		;; R0 = new seconds value returned by the _signal_handler
		LDR 	R1, =SECOND_LEFT	; Retrieve the seconds parameter from memory address 0x20007B80 (SECONDS_LEFT)
		LDR		R2, [R1]		; Create a copy of the value (seconds left) inside 0x20007B80 into R2
		STR 	R0, [R1]		; Replace seconds left (R0) with new seconds parameter from alarm( ) to memory address 0x20007B80 (R1)
		
		;; Enable SysTick:
		;; Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 1, Bit 0 (ENABLE) = 1 ---> STCTRL_GO
		LDR		R3, =STCTRL		; R3 holds memory address of SysTick Control and Status Register
		LDR		R4, =STCTRL_GO		; R4 holds [Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 1, Bit 0 (ENABLE) = 1 ---> STCTRL_GO]
		STR		R4, [R3]		; Update address of SysTick Control and Status Register ---> Systick Enabled
		
		;; Clear SYST_CVR:
		LDR		R5, =STCURRENT
		MOV 	R6, #0x00000000			
		STR		R6, [R5]		; Set 0x00000000 in SYST_CVR
		
		MOV 	R0, R2			; Return seconds left into main through R0
		
		MOV		pc, lr			; return to SVC_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer update
; void timer_update( )
		EXPORT		_timer_update
_timer_update
	;; Implement by yourself
		;; _timer_update in timer.s to decrement the count provided by alarm( ), to check if the count
		;; reached 0, and if so to stop the timer as well as invoke func specified by signal( SIG_ALRM, func )
		;; Decrement seconds at 0x2000.7B80 and invokes *func at 0x2000.7B84

		LDR		R1, =SECOND_LEFT	; R1 holds memory address to how many seconds left
		LDR		R2, [R1] 		; R2 holds how many seconds left
		SUB 	R2, R2, #1		; Decrement seconds left by 1
		STR 	R2, [R1]
		
		; If seconds == 0, go to stop_Timer, else go to return
		CMP 	R2, #0
		BNE		_timer_update_done
		

		;; Stop the timer first
		LDR		R3, =STCTRL
		LDR		R4, =STCTRL_STOP
		STR		R4, [R3]
		
		;; Invoke *func at 0x2000.7B84
		LDR 	R5, =USR_HANDLER
		LDR		R6, [R5]
		
		STMFD	sp!, {r1-r12,lr}		; save registers
		BLX 	R6
		LDMFD	sp!, {r1-r12,lr}		; resume registers

_timer_update_done
		MOV		pc, lr			; return to SysTick_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer update
; void* signal_handler( int signum, void* handler )
	    EXPORT	_signal_handler
_signal_handler
	;; Implement by yourself
		;; If R0 is SIG_ALRM, (i.e., 14), save it in memory address at
		;; 0x20007B84. Return the previous value of 0x2007B84 to main( ) through R0.
		CMP	R0, #SIGALRM
		BNE	return_Res			; if R0 != SIG_ALARM, continue --> line 64, else Branch to "stop"	
		
if_Clause
		LDR	R2, =USR_HANDLER	; Load R2 with the address of a user-given signal handler function 
		
		; Since R1 holds *func, we need to store *func at 0x20007B84 (USR_HANDLER at R2). R3 acts as a temp for previous value
		LDR		R3, [R2]		; Load R3 with the value at R2 (Value at the address 0x20007B84)
		STR		R1, [R2]		; Store *func located in R1 in the address of R2, 0x20007B84 (USR_HANDLER at R2)
		MOV 	R0, R3 			; Move value in R3 to R0 to return value to main through R0

return_Res
		MOV		pc, lr			; return to Reset_Handler
		END		