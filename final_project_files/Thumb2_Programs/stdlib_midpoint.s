		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _bzero( void *s, int n )
; Parameters
;	s 		- pointer to the memory location to zero-initialize
;	n		- a number of bytes to zero-initialize
; Return value
;   none
		EXPORT	_bzero
_bzero
		; r0 = s
		; r1 = n
		; r2 = 0
		STMFD	sp!, {r1-r12,lr}
		MOV		r3, r0				; r3 = dest
		MOV		r2, #0				; r2 = 0;	
_bzero_loop							; while( ) {
		SUBS	r1, r1, #1			; 	n--;
		BMI		_bzero_return		;   if ( n < 0 ) break;	
		STRB	r2, [r0], #0x1		;	[s++] = 0;
		B		_bzero_loop			; }
_bzero_return
		MOV		r0, r3				; return dest;
		LDMFD	sp!, {r1-r12,lr}
		MOV		pc, lr	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; char* _strncpy( char* dest, char* src, int size )
; Parameters
;   dest 	- pointer to the buffer to copy to
;	src		- pointer to the zero-terminated string to copy from
;	size	- a total of n bytes
; Return value
;   dest
		EXPORT	_strncpy
_strncpy
		; r0 = dest
		; r1 = src
		; r2 = size
		; r3 = a copy of original dest
		; r4 = src[i]
		STMFD	sp!, {r1-r12,lr}
		MOV		r3, r0				; r3 = dest
_strncpy_loop						; while( ) {
		SUBS	r2, r2, #1			; 	size--;
		BMI		_strncpy_return		; 	if ( size < 0 ) break; 		
		LDRB	r4, [r1], #0x1		; 	r4 = [src++];
		STRB	r4, [r0], #0x1		;	[dest++] = r4;
		CMP		r4, #0				;   
		BEQ		_strncpy_return		;	if ( r4 = '\0' ) break;
		B		_strncpy_loop		; }
_strncpy_return
		MOV		r0, r3				; return dest;
		LDMFD	sp!, {r1-r12,lr}
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void* _malloc( int size )
; Parameters
;	size	- #bytes to allocate
; Return value
;   	void*	a pointer to the allocated space
		EXPORT	_malloc
_malloc
		; save registers
		; set the system call # to R7
	        SVC     #0x0
		; resume registers
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _free( void* addr )
; Parameters
;	size	- the address of a space to deallocate
; Return value
;   	none
		EXPORT	_free
_free
		; save registers
		; set the system call # to R7
        	SVC     #0x0
		; resume registers
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; unsigned int _alarm( unsigned int seconds )
; Parameters
;   seconds - seconds when a SIGALRM signal should be delivered to the calling program	
; Return value
;   unsigned int - the number of seconds remaining until any previously scheduled alarm
;                  was due to be delivered, or zero if there was no previously schedul-
;                  ed alarm. 
		EXPORT	_alarm
_alarm
		; save registers
		; set the system call # to R7
        	SVC     #0x0
		; resume registers	
		MOV		pc, lr		
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void* _signal( int signum, void *handler )
; Parameters
;   signum - a signal number (assumed to be 14 = SIGALRM)
;   handler - a pointer to a user-level signal handling function
; Return value
;   void*   - a pointer to the user-level signal handling function previously handled
;             (the same as the 2nd parameter in this project)
		EXPORT	_signal
_signal
		; save registers
		; set the system call # to R7
        	SVC     #0x0
		; resume registers
		MOV		pc, lr	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		END			
