//utility chronometer main.c as part of laboratory coursework in embedded systems.
//by Alfred Pierre
//10/21/2024

#include <msp430.h> 
#include <stdint.h>


#define redLED BIT0
#define greenLED BIT7
#define BUT1 BIT1
#define BUT2 BIT2

typedef enum {Run, FF, Stop}State_t;    //FSM

static State_t currentState = Run;      //Initial state

volatile uint32_t counter = 0;          //32-bit integer used as counter.

const unsigned char LCD_Shapes[10] = {0xFC, 0x60, 0xDB, 0xF3, 0x67, 0xB7, 0xBF, 0xE0, 0xFF, 0xF7}; //register values for each numeric shapes

//function prototypes
void Initialize_LCD();
void lcd_write_uint32(volatile uint32_t count);
void lcd_col_on(void);
void lcd_col_off(void);

//Function to initialize LCD from lab manual.
void Initialize_LCD() {
    PJSEL0 = BIT4 | BIT5; // For LFXT
    LCDCPCTL0 = 0xFFD0;
    LCDCPCTL1 = 0xF83F;
    LCDCPCTL2 = 0x00F8;
    // Configure LFXT 32kHz crystal
    CSCTL0_H = CSKEY >> 8; // Unlock CS registers
    CSCTL4 &= ~LFXTOFF; // Enable LFXT
    do {
        CSCTL5 &= ~LFXTOFFG; // Clear LFXT fault flag
        SFRIFG1 &=   ~OFIFG;
    }while (SFRIFG1 & OFIFG); // Test oscillator fault flag
    CSCTL0_H = 0; // Lock CS registers
    LCDCCTL0 = LCDDIV__1 | LCDPRE__16 | LCD4MUX | LCDLP;
    LCDCVCTL = VLCD_1 | VLCDREF_0 | LCDCPEN;
    LCDCCPCTL = LCDCPCLKSYNC; // Clock synchronization enabled
    LCDCMEMCTL = LCDCLRM; // Clear LCD memory
    LCDCCTL0 |= LCDON;
    return;
}

//This function convert the value of counter in second to hours minutes and second and write the results on the LCD display.
void lcd_write_uint32(volatile uint32_t count){
    //If counter is equal to 86400, which is equivalent to 24:00:00, roll back to zero.
    if(count >= 86400 ){
        count = 0;
        counter = 0;
    }
    volatile unsigned int h1, h2, m1, m2, s1, s2;
    //Modulo arithmetic to convert from seconds to hh:mm:ss format.

    //hours
    h1 = (count / 36000) % 10;
    h2 = (count / 3600) % 10;
    //minutes
    m1 = ((count % 3600) / 600) % 10;
    m2 = ((count % 3600) / 60) % 10;
    //seconds
    s1 = (((count % 3600) % 60) / 10) %10;
    s2 = ((count % 3600) % 60) %10;

    //assign corresponding register values to be displayed on LCD
    LCDM10 = LCD_Shapes[h1];
    LCDM6 = LCD_Shapes[h2];
    LCDM4 = LCD_Shapes[m1];
    LCDM19 = LCD_Shapes[m2];
    LCDM15 = LCD_Shapes[s1];
    LCDM8 = LCD_Shapes[s2];
    return;
}

//This function turns the colon shape on in the LCD display
void lcd_col_on(void){
    LCDM7 |= BIT2;
    LCDM20 |= BIT2;
}

//Turns colon shape off
void lcd_col_off(void){
    LCDM7 &= ~BIT2;
    LCDM20 &= ~BIT2;
}

//configures ACLK freq to 32768Hz
void config_ACLK_to_32KHz_crystal() {
    PJSEL1 &= ~BIT4;
    PJSEL0 |= BIT4;
    CSCTL0 = CSKEY; // Unlock CS registers
    do {
        CSCTL5 &= ~LFXTOFFG; // Local fault flag
        SFRIFG1 &= ~OFIFG; // Global fault flag
    } while((CSCTL5 & LFXTOFFG) != 0);
    CSCTL0_H = 0; // Lock CS registers
    return;
}

//main function starts
int main(void) {
WDTCTL = WDTPW | WDTHOLD; // Stop WDT
PM5CTL0 &= ~LOCKLPM5; // Enable GPIO pins

//configuration of IO pins
P1DIR |= redLED; //Sets pin as output
P9DIR |= greenLED;
P1OUT |= redLED; // Red on
P9OUT &= ~greenLED; // Green off
P1DIR &= ~(BUT1 | BUT2); //Sets button pins as input.
P1REN |= (BUT1 | BUT2);
P1OUT |= (BUT1 | BUT2);
P1IES |= (BUT1 | BUT2);
P1IFG &= ~(BUT1 | BUT2); //clear interrupt flag.
P1IE |= (BUT1 | BUT2);  //enable button interrupt.

//timer module configuration
config_ACLK_to_32KHz_crystal(); //32768Hz
TA0CTL = TASSEL_1 | ID_0 | MC_1 | TA0R;
TA0CCTL0 |= CCIE;
TA0CCR0 = 32768; //1 second delay
Initialize_LCD();
lcd_col_on();
LCDM3 |= BIT3; //Turns chronometer logo on
_low_power_mode_3(); //low power mode 3 turning off CPU clock;
return 0;
}

//interrupt service routine
#pragma vector = TIMER0_A0_VECTOR
__interrupt void Timer0(void){
    switch(currentState){
        case Run:
            lcd_write_uint32(counter);
            lcd_col_on();
            counter += 1;
            _delay_cycles(500000);      //delay to flash colon sign.
            lcd_col_off();
            break;
        case Stop:
            break;
        case FF:
            if( ((P1IN & BUT2) == 0) && ((P1IN & BUT1) != 0 ) ){    //only s2 is pressed
                lcd_write_uint32(counter);
                counter += 1;
                if(TA0CCR0 > 2){
                    TA0CCR0 /= 2;
                } else {
                    counter += 21; //fast foward
                }
            } else if (((P1IN & BUT2) == 0 ) && ((P1IN & BUT1) == 0 )){     //s2 and s1 is pressed
                lcd_write_uint32(counter);
                counter -= 1; //rewind
                if(TA0CCR0 != 50){
                    TA0CCR0 = 50;
                }

            } else {        //s2 is no longer pressed
                TA0R = 0;
                TA0CCR0 = 32768;
                P1IE |= (BUT1 | BUT2);
                lcd_col_off();
                currentState = Run;
            }
            break;

    }
}


//interrupt service routine
#pragma vector = PORT1_VECTOR
__interrupt void Port_1(void){
    switch(currentState){
        case Run:
            if( ((P1IN & BUT1) == 0) && ((P1IN & BUT2) != 0) ){
                TA0R = 0;
                while(((P1IN & BUT1) == 0) && ((P1IN & BUT2) != 0)){
                    if(TA0R > 16000){       //if long press, then reset counter.
                        LCDCMEMCTL = LCDCLRM;
                        counter = 0;
                        lcd_write_uint32(counter);
                        break;
                    }
                }
                TA0CTL = TASSEL_1 | ID_0 | MC_0;
                LCDM3 &= ~BIT3; //Turns chronometer logo off
                LCDM3 |= BIT0 ; //turns exclamation point on
                currentState = Stop;
                lcd_col_on();
            }


            if((P1IN & BUT2) == 0 ){
                TA0R = 16000;
                lcd_col_on();
                currentState = FF;
                P1IE &= ~(BUT1 | BUT2);
            }
            break;
        case Stop:
            if( ((P1IN & BUT1) == 0) && ((P1IN & BUT2) != 0) ){
                TA0R = 0;
                LCDM3 &= ~BIT0;
                LCDM3 |= BIT3;
                currentState = Run;
                TA0CTL = TASSEL_1 | ID_0 | MC_1;
                while(((P1IN & BUT1) == 0) && ((P1IN & BUT2) != 0)){
                    if(TA0R > 16000){       //if long press then reset counter
                        TA0CTL = TASSEL_1 | ID_0 | MC_0;
                        LCDCMEMCTL = LCDCLRM;
                        counter = 0;
                        lcd_write_uint32(counter);
                        currentState = Stop;
                        LCDM3 &= ~BIT3;
                        LCDM3 |= BIT0;
                        lcd_col_on();
                        break;
                    }
                }
            }
            break;
    }
    _delay_cycles(20000);   //delay to reduce bouncing
    P1IFG &= ~(BUT1 | BUT2);
}
