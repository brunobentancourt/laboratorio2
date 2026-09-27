.include "m328pdef.inc"

.org 0x0000
    rjmp RESET

RESET:
    ldi r16, LOW(RAMEND)
    out SPL, r16
    ldi r16, HIGH(RAMEND)
    out SPH, r16

    in r16, DDRD
    ori r16, 0xFC
    out DDRD, r16

    in r16, DDRB
    ori r16, 0x03
    out DDRB, r16

    rcall APAGAR_LEDS

    ldi r16, 0
    sts UBRR0H, r16
    ldi r16, 103
    sts UBRR0L, r16

    ldi r16, (1<<RXEN0)
    sts UCSR0B, r16

    ldi r16, (1<<UCSZ01) | (1<<UCSZ00)
    sts UCSR0C, r16

MAIN_LOOP:
    lds r16, UCSR0A
    sbrs r16, RXC0
    rjmp MAIN_LOOP

    lds r16, UDR0

    cpi r16, 8
    brsh MAIN_LOOP

    rcall APAGAR_LEDS

    cpi r16, 0
    breq LED_0
    cpi r16, 1
    breq LED_1
    cpi r16, 2
    breq LED_2
    cpi r16, 3
    breq LED_3
    cpi r16, 4
    breq LED_4
    cpi r16, 5
    breq LED_5
    cpi r16, 6
    breq LED_6
    cpi r16, 7
    breq LED_7

    rjmp MAIN_LOOP

APAGAR_LEDS:
    in r17, PORTD
    andi r17, 0x03
    out PORTD, r17

    in r17, PORTB
    andi r17, 0xFC
    out PORTB, r17
    ret

LED_0: sbi PORTD, 2
       rjmp MAIN_LOOP
LED_1: sbi PORTD, 3
       rjmp MAIN_LOOP
LED_2: sbi PORTD, 4
       rjmp MAIN_LOOP
LED_3: sbi PORTD, 5
       rjmp MAIN_LOOP
LED_4: sbi PORTD, 6
       rjmp MAIN_LOOP
LED_5: sbi PORTD, 7
       rjmp MAIN_LOOP
LED_6: sbi PORTB, 0
       rjmp MAIN_LOOP
LED_7: sbi PORTB, 1
       rjmp MAIN_LOOP


