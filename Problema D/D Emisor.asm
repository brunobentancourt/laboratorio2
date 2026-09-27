; Emisor 

.include "m328pdef.inc"

.org 0x0000
    rjmp RESET

RESET:
    ldi r16, LOW(RAMEND)
    out SPL, r16
    ldi r16, HIGH(RAMEND)
    out SPH, r16

    cbi DDRD, 2
    cbi DDRD, 3
    cbi DDRD, 4

    sbi PORTD, 2
    sbi PORTD, 3
    sbi PORTD, 4

    ldi r16, 0
    sts UBRR0H, r16
    ldi r16, 103
    sts UBRR0L, r16

    ldi r16, (1<<TXEN0)
    sts UCSR0B, r16

    ldi r16, (1<<UCSZ01) | (1<<UCSZ00)
    sts UCSR0C, r16

MAIN_LOOP:
    clr r17

    sbis PIND, 2
    sbr r17, (1<<0)

    sbis PIND, 3
    sbr r17, (1<<1)

    sbis PIND, 4
    sbr r17, (1<<2)

WAIT_TX:
    lds r16, UCSR0A
    sbrs r16, UDRE0
    rjmp WAIT_TX

    sts UDR0, r17

    rcall DELAY
    rjmp MAIN_LOOP

DELAY:
    ldi r18, 100
D1: ldi r19, 200
D2: dec r19
    brne D2
    dec r18
    brne D1
    ret