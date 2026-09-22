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