.include "m328pdef.inc"

.equ PIN_SOL_DOWN = 2    ; D2 -> Bajar solenoide 
.equ PIN_SOL_UP   = 3    ; D3 -> Subir solenoide 
.equ PIN_DOWN     = 4    ; D4 -> Abajo 
.equ PIN_UP       = 5    ; D5 -> Arriba 
.equ PIN_LEFT     = 7    ; D7 -> Izquierda 
.equ PIN_RIGHT    = 6    ; D6 -> Derecha 

.equ UBRR_VAL = 103      ; 9600 baudios @ 16 MHz

.cseg
.org 0x0000
    rjmp RESET

RESET:
    ; Stack Pointer
    ldi r16, HIGH(RAMEND)
    out SPH, r16
    ldi r16, LOW(RAMEND)
    out SPL, r16

    



    ldi r16, 0xFC
    out DDRD, r16
    clr r16
    out PORTD, r16

    ldi r16, HIGH(UBRR_VAL)
    sts UBRR0H, r16
    ldi r16, LOW(UBRR_VAL)
    sts UBRR0L, r16

    ldi r16, (1 << RXEN0) | (1 << TXEN0)
    sts UCSR0B, r16

    ldi r16, (1 << UCSZ01) | (1 << UCSZ00)
    sts UCSR0C, r16

    rcall PEN_UP

MAIN_LOOP:
    rcall UART_RECEIVE

    cpi r16, '1'
    breq EXEC_1
    cpi r16, '2'
    breq EXEC_2
    cpi r16, '3'
    breq EXEC_3
    cpi r16, '4'
    breq EXEC_4
    cpi r16, 'p'
    breq EXEC_P
    cpi r16, 'P'
    breq EXEC_P
    cpi r16, 't'
    breq EXEC_T
    cpi r16, 'T'
    breq EXEC_T

    rjmp MAIN_LOOP

EXEC_1:
    rcall OFFSET_MARGIN
    rcall DRAW_TRIANGLE
    rcall PEN_UP
    rjmp MAIN_LOOP

EXEC_2:
    rcall OFFSET_MARGIN
    rcall DRAW_CIRCLE
    rcall PEN_UP
    rjmp MAIN_LOOP

EXEC_3:
    rcall OFFSET_MARGIN
    rcall DRAW_PENTAGRAM
    rcall PEN_UP
    rjmp MAIN_LOOP

EXEC_4:
    rcall OFFSET_MARGIN
    rcall DRAW_UTEC
    rcall PEN_UP
    rjmp MAIN_LOOP

EXEC_P:
	rcall OFFSET_MARGIN
	rcall DRAW_POKEMON
	rcall PEN_UP
	rjmp MAIN_LOOP


EXEC_T:
    rcall OFFSET_MARGIN
    rcall DRAW_ALL
    rcall PEN_UP
    rjmp MAIN_LOOP






; MARGEN DE SEGURIDAD 


OFFSET_MARGIN:
    rcall PEN_UP
    ldi r17, 50         
    rcall MOVE_LEFT
    ldi r17, 30           
    rcall MOVE_DOWN
    ret






















































	;  T / t: Secuencia completa
DRAW_ALL:
    rcall DRAW_TRIANGLE

    ldi r17, 40
    rcall MOVE_LEFT

    rcall DRAW_CIRCLE

    ldi r17, 40
    rcall MOVE_LEFT

    rcall DRAW_PENTAGRAM

    ldi r17, 40
    rcall MOVE_DOWN

    rcall DRAW_UTEC

	 ldi r17, 70
    rcall MOVE_RIGHT

	rcall DRAW_POKEMON
    ret



; RUTINAS DE MOVIMIENTO


MOVE_DOWN:
    sbi PORTD, PIN_DOWN
    rcall WAIT_R17_50MS
    cbi PORTD, PIN_DOWN
    rcall DELAY_SETTLE
    ret

MOVE_UP:
    sbi PORTD, PIN_UP
    rcall WAIT_R17_50MS
    cbi PORTD, PIN_UP
    rcall DELAY_SETTLE
    ret

MOVE_LEFT:
    sbi PORTD, PIN_LEFT
    rcall WAIT_R17_50MS
    cbi PORTD, PIN_LEFT
    rcall DELAY_SETTLE
    ret

MOVE_RIGHT:
    sbi PORTD, PIN_RIGHT
    rcall WAIT_R17_50MS
    cbi PORTD, PIN_RIGHT
    rcall DELAY_SETTLE
    ret

MOVE_DN_LT:
    sbi PORTD, PIN_DOWN
    sbi PORTD, PIN_LEFT
    rcall WAIT_R17_50MS
    cbi PORTD, PIN_DOWN
    cbi PORTD, PIN_LEFT
    rcall DELAY_SETTLE
    ret

MOVE_DN_RT:
    sbi PORTD, PIN_DOWN
    sbi PORTD, PIN_RIGHT
    rcall WAIT_R17_50MS
    cbi PORTD, PIN_DOWN
    cbi PORTD, PIN_RIGHT
    rcall DELAY_SETTLE
    ret

MOVE_UP_LT:
    sbi PORTD, PIN_UP
    sbi PORTD, PIN_LEFT
    rcall WAIT_R17_50MS
    cbi PORTD, PIN_UP
    cbi PORTD, PIN_LEFT
    rcall DELAY_SETTLE
    ret

MOVE_UP_RT:
    sbi PORTD, PIN_UP
    sbi PORTD, PIN_RIGHT
    rcall WAIT_R17_50MS
    cbi PORTD, PIN_UP
    cbi PORTD, PIN_RIGHT
    rcall DELAY_SETTLE
    ret


; CONTROL DE SOLENOIDE Y TEMPORIZADORES


PEN_DOWN:
    sbi PORTD, PIN_SOL_DOWN
    cbi PORTD, PIN_SOL_UP
    rcall DELAY_SOLENOID
    ret

PEN_UP:
    cbi PORTD, PIN_SOL_DOWN
    sbi PORTD, PIN_SOL_UP
    rcall DELAY_SOLENOID
    ret

UART_RECEIVE:
    lds r16, UCSR0A
    sbrs r16, RXC0
    rjmp UART_RECEIVE
    lds r16, UDR0
    ret

WAIT_R17_50MS:
    rcall DELAY_50MS
    dec r17
    brne WAIT_R17_50MS
    ret

DELAY_50MS:
    ldi r19, 10
D50_1:
    ldi r20, 200
D50_2:
    ldi r21, 200
D50_3:
    dec r21
    brne D50_3
    dec r20
    brne D50_2
    dec r19
    brne D50_1
    ret

DELAY_SETTLE:
    rcall DELAY_50MS
    ret

DELAY_SOLENOID:
    rcall DELAY_50MS
    rcall DELAY_50MS
    ret


