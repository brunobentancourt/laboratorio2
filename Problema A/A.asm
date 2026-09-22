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