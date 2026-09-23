.include "m328pdef.inc"

.def TEMP            = R16
.def INDICE_FILA     = R17
.def MODO            = R18
.def ESTADO_BOTON    = R19
.def CONT_RETARDO    = R20
.def CERO            = R21
.def BYTE_PATRON     = R22
.def CONT_DESPL      = R23
.def VAL_VELOCIDAD   = R24
.def PUNT_MENSAJE    = R25

.dseg
.org SRAM_START
BUFFER_FILAS: .byte 8

.cseg
.org 0x0000
    rjmp INICIO

INICIO:
    ldi TEMP, LOW(RAMEND)
    out SPL, TEMP
    ldi TEMP, HIGH(RAMEND)
    out SPH, TEMP

    clr CERO

    ldi TEMP, 0xFE
    out DDRD, TEMP
    clr TEMP
    out PORTD, TEMP

    ldi TEMP, 0x3F
    out DDRB, TEMP
    ldi TEMP, 0x3E
    out PORTB, TEMP

    ldi TEMP, 0x27
    out DDRC, TEMP
    ldi TEMP, 0x1F
    out PORTC, TEMP

    ldi TEMP, HIGH(103)
    sts UBRR0H, TEMP
    ldi TEMP, LOW(103)
    sts UBRR0L, TEMP

    ldi TEMP, (1<<RXEN0) | (1<<TXEN0)
    sts UCSR0B, TEMP

    ldi TEMP, (1<<UCSZ01) | (1<<UCSZ00)
    sts UCSR0C, TEMP

    clr MODO
    clr ESTADO_BOTON
    clr CONT_DESPL
    clr PUNT_MENSAJE
    
    ldi VAL_VELOCIDAD, 120

    rcall LIMPIAR_BUFF_FILAS
    rcall IMPRIMIR_MENU_UART

BUCLE_PRINCIPAL:
    rcall VERIFICAR_UART
    rcall VERIFICAR_BOTONES
    rcall DIBUJAR_CUADRO
    rjmp BUCLE_PRINCIPAL




	DESACTIVAR_FILAS:
    in TEMP, PORTB
    ori TEMP, 0x3E
    out PORTB, TEMP
    in TEMP, PORTC
    ori TEMP, 0x07
    out PORTC, TEMP
    ret

DIBUJAR_CUADRO:
    tst MODO
    breq DIBUJAR_MODO_DESPL

    ldi ZL, LOW(PATRONES * 2)
    ldi ZH, HIGH(PATRONES * 2)

    mov TEMP, MODO
    dec TEMP
    lsl TEMP
    lsl TEMP
    lsl TEMP

    add ZL, TEMP
    adc ZH, CERO

    clr INDICE_FILA

BUCLE_FILA_ESTATICO:
    rcall DESACTIVAR_FILAS
    clr TEMP
    out PORTD, TEMP
    cbi PORTB, 0

    lpm BYTE_PATRON, Z+
    rcall APLICAR_FILA_Y_COLUMNAS
    rcall RETARDO_1MS

    inc INDICE_FILA
    cpi INDICE_FILA, 8
    brne BUCLE_FILA_ESTATICO
    rcall DESACTIVAR_FILAS
    ret

DIBUJAR_MODO_DESPL:
    inc CONT_DESPL
    cp CONT_DESPL, VAL_VELOCIDAD
    brlo RENDER_CUADRO_DESPL
    
    clr CONT_DESPL
    rcall AVANZAR_PASO_DESPL

RENDER_CUADRO_DESPL:
    clr INDICE_FILA
    ldi XL, LOW(BUFFER_FILAS)
    ldi XH, HIGH(BUFFER_FILAS)

BUCLE_FILA_DESPL:
    rcall DESACTIVAR_FILAS
    clr TEMP
    out PORTD, TEMP
    cbi PORTB, 0

    ld BYTE_PATRON, X+
    rcall APLICAR_FILA_Y_COLUMNAS
    rcall RETARDO_1MS

    inc INDICE_FILA
    cpi INDICE_FILA, 8
    brne BUCLE_FILA_DESPL
    rcall DESACTIVAR_FILAS
    ret

AVANZAR_PASO_DESPL:
    ldi ZL, LOW(COLS_TEXTO_MSG * 2)
    ldi ZH, HIGH(COLS_TEXTO_MSG * 2)

    add ZL, PUNT_MENSAJE
    adc ZH, CERO

    lpm BYTE_PATRON, Z

    cpi BYTE_PATRON, 0xFF
    brne BYTE_VALIDO
    clr PUNT_MENSAJE
    rjmp AVANZAR_PASO_DESPL

BYTE_VALIDO:
    inc PUNT_MENSAJE

    ldi XL, LOW(BUFFER_FILAS)
    ldi XH, HIGH(BUFFER_FILAS)
    ldi TEMP, 8

BUCLE_DESPLAZAR:
    ld R17, X
    lsr R17

    sbrc BYTE_PATRON, 0
    ori R17, 0x80

    st X+, R17
    lsr BYTE_PATRON
    dec TEMP
    brne BUCLE_DESPLAZAR

    ret

LIMPIAR_BUFF_FILAS:
    ldi XL, LOW(BUFFER_FILAS)
    ldi XH, HIGH(BUFFER_FILAS)
    clr TEMP
    ldi R17, 8
BUCLE_LIMPIAR:
    st X+, TEMP
    dec R17
    brne BUCLE_LIMPIAR
    ret

APLICAR_FILA_Y_COLUMNAS:
    mov TEMP, BYTE_PATRON
    andi TEMP, 0x7F
    lsl TEMP
    andi TEMP, 0xFC
    out PORTD, TEMP

    sbrc BYTE_PATRON, 7
    sbi PORTB, 0
    sbrs BYTE_PATRON, 7
    cbi PORTB, 0

    cpi INDICE_FILA, 0
    breq ACT_Y1
    cpi INDICE_FILA, 1
    breq ACT_Y2
    cpi INDICE_FILA, 2
    breq ACT_Y3
    cpi INDICE_FILA, 3
    breq ACT_Y4
    cpi INDICE_FILA, 4
    breq ACT_Y5
    cpi INDICE_FILA, 5
    breq ACT_Y6
    cpi INDICE_FILA, 6
    breq ACT_Y7
    cpi INDICE_FILA, 7
    breq ACT_Y8
    ret

ACT_Y1:
    in TEMP, PORTB
    andi TEMP, 0x01
    ori TEMP, 0x3C
    out PORTB, TEMP
    ldi TEMP, 0x1F
    out PORTC, TEMP
    rjmp DEF_COL_A5

ACT_Y2:
    in TEMP, PORTB
    andi TEMP, 0x01
    ori TEMP, 0x3A
    out PORTB, TEMP
    ldi TEMP, 0x1F
    out PORTC, TEMP
    rjmp DEF_COL_A5

ACT_Y3:
    in TEMP, PORTB
    andi TEMP, 0x01
    ori TEMP, 0x36
    out PORTB, TEMP
    ldi TEMP, 0x1F
    out PORTC, TEMP
    rjmp DEF_COL_A5

ACT_Y4:
    in TEMP, PORTB
    andi TEMP, 0x01
    ori TEMP, 0x2E
    out PORTB, TEMP
    ldi TEMP, 0x1F
    out PORTC, TEMP
    rjmp DEF_COL_A5

ACT_Y5:
    in TEMP, PORTB
    andi TEMP, 0x01
    ori TEMP, 0x1E
    out PORTB, TEMP
    ldi TEMP, 0x1F
    out PORTC, TEMP
    rjmp DEF_COL_A5

ACT_Y6:
    in TEMP, PORTB
    andi TEMP, 0x01
    ori TEMP, 0x3E
    out PORTB, TEMP
    ldi TEMP, 0x1E
    out PORTC, TEMP
    rjmp DEF_COL_A5

ACT_Y7:
    in TEMP, PORTB
    andi TEMP, 0x01
    ori TEMP, 0x3E
    out PORTB, TEMP
    ldi TEMP, 0x1D
    out PORTC, TEMP
    rjmp DEF_COL_A5

ACT_Y8:
    in TEMP, PORTB
    andi TEMP, 0x01
    ori TEMP, 0x3E
    out PORTB, TEMP
    ldi TEMP, 0x1B
    out PORTC, TEMP
    rjmp DEF_COL_A5

DEF_COL_A5:
    sbrc BYTE_PATRON, 0
    sbi PORTC, 5
    sbrs BYTE_PATRON, 0
    cbi PORTC, 5
    ret

VERIFICAR_UART:
    lds TEMP, UCSR0A
    sbrs TEMP, RXC0
    ret

    lds TEMP, UDR0

    cpi TEMP, '+'
    breq AUMENTAR_VELOCIDAD
    cpi TEMP, '-'
    breq DISMINUIR_VELOCIDAD

    cpi TEMP, '0'
    brlo UART_FIN
    cpi TEMP, '7'
    brsh UART_FIN

    subi TEMP, '0'
    mov MODO, TEMP

    tst MODO
    brne UART_FIN
    clr PUNT_MENSAJE
    rcall LIMPIAR_BUFF_FILAS
    rjmp UART_FIN

AUMENTAR_VELOCIDAD:
    cpi VAL_VELOCIDAD, 30
    brlo UART_FIN
    subi VAL_VELOCIDAD, 20
    ret

DISMINUIR_VELOCIDAD:
    cpi VAL_VELOCIDAD, 230
    brsh UART_FIN
    ldi TEMP, 20
    add VAL_VELOCIDAD, TEMP
    ret

UART_FIN:
    ret

IMPRIMIR_MENU_UART:
    ldi TEMP, (1<<TXC0)
    sts UCSR0A, TEMP

    ldi ZL, LOW(TEXTO_MENU * 2)
    ldi ZH, HIGH(TEXTO_MENU * 2)

BUCLE_ENVIAR_MENU:
    lpm TEMP, Z+
    tst TEMP
    breq FIN_MENU

ESPERAR_TX:
    lds R0, UCSR0A
    sbrs R0, UDRE0
    rjmp ESPERAR_TX

    sts UDR0, TEMP
    rjmp BUCLE_ENVIAR_MENU

FIN_MENU:
ESPERAR_TX_COMPLETO:
    lds R0, UCSR0A
    sbrs R0, TXC0
    rjmp ESPERAR_TX_COMPLETO

    lds TEMP, UCSR0B
    cbr TEMP, (1<<TXEN0)
    sts UCSR0B, TEMP

    ldi TEMP, 0xFE
    out DDRD, TEMP
    ret

VERIFICAR_BOTONES:
    in TEMP, PINC

    sbrs TEMP, 3
    rjmp BOTON_SIGUIENTE

    sbrs TEMP, 4
    rjmp BOTON_ANTERIOR

    clr ESTADO_BOTON
    ret

BOTON_SIGUIENTE:
    sbrc ESTADO_BOTON, 0
    ret
    ori ESTADO_BOTON, 0x01

    inc MODO
    cpi MODO, 7
    brne BOTON_FIN
    clr MODO
    rcall LIMPIAR_BUFF_FILAS
    clr PUNT_MENSAJE
    rjmp BOTON_FIN

BOTON_ANTERIOR:
    sbrc ESTADO_BOTON, 1
    ret
    ori ESTADO_BOTON, 0x02

    tst MODO
    breq MODO_MAXIMO
    dec MODO
    tst MODO
    brne BOTON_FIN
    rcall LIMPIAR_BUFF_FILAS
    clr PUNT_MENSAJE
    rjmp BOTON_FIN

MODO_MAXIMO:
    ldi MODO, 6

BOTON_FIN:
    rcall RETARDO_20MS
    ret

RETARDO_1MS:
    ldi CONT_RETARDO, 250
BUCLE_R1:
    nop
    nop
    dec CONT_RETARDO
    brne BUCLE_R1
    ret

RETARDO_20MS:
    push R23
    ldi R23, 20
BUCLE_R20_EXT:
    rcall RETARDO_1MS
    dec R23
    brne BUCLE_R20_EXT
    pop R23
    ret

TEXTO_MENU:
    .db "0: Mensaje (HELLO WORLD)", 13, 10
    .db "1: Figura 1 (Carita feliz)", 13, 10
    .db "2: Figura 2 (Carita guino)", 13, 10
    .db "3: Figura 3 (Corazon) ", 13, 10
    .db "4: Figura 4 (:3)", 13, 10
    .db "5: Figura 5 (XD)", 13, 10
    .db "6: Figura 6 (*) ", 13, 10
    .db "------------------------------------", 13, 10
    .db "Use '+' o '-' para cambiar velocidad", 13, 10
    .db "Seleccione una opcion (0-6): ", 0

PATRONES:
    .db 0x3C, 0x42, 0xA5, 0x81, 0xA5, 0x99, 0x42, 0x3C
    .db 0x3C, 0x42, 0xA6, 0x81, 0xA5, 0x99, 0x42, 0x3C
    .db 0x66, 0xFF, 0xFF, 0xFF, 0x7E, 0x3C, 0x18, 0x00
    .db 0x00, 0x24, 0x00, 0x42, 0x5A, 0x24, 0x00, 0x00
    .db 0x18, 0x99, 0x5A, 0x3C, 0x3C, 0x5A, 0x99, 0x18
    .db 0x9E, 0x6A, 0x0A, 0x6A, 0x9E, 0x00, 0x00, 0x00

COLS_TEXTO_MSG:
    .db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db 0x7F, 0x08, 0x08, 0x08, 0x7F, 0x00
    .db 0x7F, 0x49, 0x49, 0x49, 0x41, 0x00
    .db 0x7F, 0x40, 0x40, 0x40, 0x40, 0x00
    .db 0x7F, 0x40, 0x40, 0x40, 0x40, 0x00
    .db 0x3E, 0x41, 0x41, 0x41, 0x3E, 0x00
    .db 0x00, 0x00, 0x00, 0x00
    .db 0x7F, 0x20, 0x18, 0x20, 0x7F, 0x00
    .db 0x3E, 0x41, 0x41, 0x41, 0x3E, 0x00
    .db 0x7F, 0x09, 0x19, 0x29, 0x46, 0x00
    .db 0x7F, 0x40, 0x40, 0x40, 0x40, 0x00
    .db 0x7F, 0x41, 0x41, 0x22, 0x1C, 0x00
    .db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db 0xFF, 0x00