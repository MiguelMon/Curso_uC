; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
list	p=16f887
INCLUDE	"p16f887.inc"   
;    STATUS	    EQU H'0003'
;    FSR		    EQU H'0004'
;    PORTA	    EQU H'0005'
;    PORTB	    EQU H'0006'
;    PORTC	    EQU H'0007'
;    PORTD	    EQU H'0008'
;    PORTE	    EQU H'0009'
;    PCLATCH	    EQU H'000A'
;    INTCON	    EQU H'000B'
;    TRISB	    EQU H'0086'
;    TRISD	    EQU	H'0088'	 
;_CONFIG1 EQU H'2007'
 
    ; CONFIG1
 ;__config 0xFBF2    3FFA       3FF7                       3FFF
 __CONFIG _CONFIG1, _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_OFF & _FCMEN_ON & _LVP_ON
; CONFIG2
 ;__config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
CBLOCK 0X20
 A_BAJO
 A_ALTO
 B_BAJO
 B_ALTO
 C_ALTO	;ALMACENA EL RESULTADO
 C_BAJO
 ENDC

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED

MAIN_PROG CODE	0x0005                     ; let linker place main program

START
 ;OPERACIONES DE BIT
    CLRF    PORTB
    BSF	    STATUS,5
    ;BCF	    TRISB,2
    CLRF    TRISB
    CLRF    TRISD
    CLRF    TRISC
    BCF	    STATUS,5
    BSF	    PORTB,2
    BANKSEL ANSELH
    CLRF    ANSELH
    BANKSEL PORTB
    CLRF    PORTD	;PARTE BAJA DE LA CUENTA DE 16 BITS
    CLRF    PORTC	;PARTE ALTA DE LA CUENTA DE 16 BITS
 
 
    

; CARGAR VALORES A LOS REGITROS DE 16 BITS
    ;CARGAMOS A =59200
    MOVLW   0xE7
    MOVWF   A_ALTO
    MOVLW   0x40 ;0X4B
    MOVWF   A_BAJO
    ;CARGAMOS B=3658
    MOVLW   0x0E
    MOVWF   B_ALTO
    MOVLW   0x4A
    MOVWF   B_BAJO
    ;RESULTADO SUMA F58A
    CALL    SUMA_16
    CALL    CARGAR_PORT
    ;RESULTADO RESTA D8F6
    CALL    RESTA_16
    CALL    CARGAR_PORT
     GOTO $                          ; loop forever
  
SUMA_16
    MOVF    B_BAJO,W 
    ADDWF   A_BAJO,W
    MOVWF   C_BAJO
    BTFSS   STATUS,C
    GOTO    NO_CERO
    ;CARRY =1
    INCF    A_ALTO,W
    ;MOVLW   0X01
    ;ADDWF   A_ALTO,W
    ADDWF   B_ALTO,W
    MOVWF   C_ALTO
    ;GOTO    FIN
    RETURN
    ;PARTE PARA CUANDO CARRY=0
NO_CERO
    MOVF    A_ALTO,W
    ADDWF   B_ALTO,W
    MOVWF   C_ALTO
    RETURN
;FIN   
    
CARGAR_PORT
    ;CARGA RESULTADO DE SUMA EN LOS PUERTOS C,D
    MOVF    C_ALTO,W
    MOVWF   PORTC
    MOVF    C_BAJO,W
    MOVWF   PORTD
    RETURN
    
RESTA_16
    MOVF    B_BAJO,W 
    SUBWF   A_BAJO,W
    MOVWF   C_BAJO
    BTFSC   STATUS,Z  ;SE CAMBIA EL VALOR DEL BIT DE TESTEO
    GOTO    NO_CERO_1
    ;CARRY =0
    DECF    A_ALTO,F
    MOVF    B_ALTO,W
    ;ADDWF   A_ALTO,W
    SUBWF   A_ALTO,W
    MOVWF   C_ALTO
    ;GOTO    FIN
    RETURN
    ;PARTE PARA CUANDO CARRY=1
NO_CERO_1
    MOVF    B_ALTO,W
    SUBWF   A_ALTO,W
    MOVWF   C_ALTO
    RETURN
    
   

    END