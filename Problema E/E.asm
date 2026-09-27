ISR_PCINT0:
    in TEMP, PINB
    sbrc TEMP, PB0
    reti

    cpi ESTADO, EST_CERRANDO
    breq INVERTIR_A_ABRIR

    cpi ESTADO, EST_ABRIENDO
    breq INVERTIR_A_CERRAR

    reti

INVERTIR_A_ABRIR:
    cbi PORTB, PB2
    sbi PORTB, PB1
    sbi PORTB, PB3
    ldi ESTADO, EST_ABRIENDO

    ldi ZL, LOW(MSG_OBSTACULO * 2)
    ldi ZH, HIGH(MSG_OBSTACULO * 2)
    rcall TRANSMIT_STRING

    ldi ZL, LOW(MSG_REVERSA_ABRIR * 2)
    ldi ZH, HIGH(MSG_REVERSA_ABRIR * 2)
    rcall TRANSMIT_STRING
    reti

INVERTIR_A_CERRAR:
    cbi PORTB, PB1
    sbi PORTB, PB2
    sbi PORTB, PB3
    ldi ESTADO, EST_CERRANDO

    ldi ZL, LOW(MSG_OBSTACULO * 2)
    ldi ZH, HIGH(MSG_OBSTACULO * 2)
    rcall TRANSMIT_STRING

    ldi ZL, LOW(MSG_REVERSA_CERRAR * 2)
    ldi ZH, HIGH(MSG_REVERSA_CERRAR * 2)
    rcall TRANSMIT_STRING
    reti

	TRANSMIT_STRING:
    lpm r18, Z+
    cpi r18, 0
    breq FIN_TRANSMIT
WAIT_TX:
    lds TEMP, UCSR0A
    sbrs TEMP, UDRE0
    rjmp WAIT_TX
    sts UDR0, r18
    rjmp TRANSMIT_STRING
FIN_TRANSMIT:
    ret

DELAY_DEBOUNCE:
    ldi r18, 100
D1: ldi r19, 200
D2: ldi r20, 200
D3: dec r20
    brne D3
    dec r19
    brne D2
    dec r18
    brne D1
    ret

MSG_ABRIENDO:       .db "Puerta abriendo", 0x0D, 0x0A, 0
MSG_ABIERTA:        .db "Puerta abierta", 0x0D, 0x0A, 0
MSG_CERRANDO:       .db "Puerta cerrando", 0x0D, 0x0A, 0
MSG_CERRADA:        .db "Puerta cerrada", 0x0D, 0x0A, 0
MSG_OBSTACULO:      .db "Obstaculo detectado!", 0x0D, 0x0A, 0
MSG_DETENIDO:       .db "Movimiento detenido por seguridad", 0x0D, 0x0A, 0
MSG_REVERSA_ABRIR:  .db "Invirtiendo marcha: Abriendo...", 0x0D, 0x0A, 0
MSG_REVERSA_CERRAR: .db "Invirtiendo marcha: Cerrando...", 0x0D, 0x0A, 0