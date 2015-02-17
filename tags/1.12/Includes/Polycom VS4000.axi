PROGRAM_NAME='Polycom VS4000'
DEFINE_CONSTANT
//vdvExecCodec1  = 33000:1:0           // Polycom VS4000 Virtual device 
vdvCodec1         = 33018:1:0
no_btn = 257
VOLATILE INTEGER nVTCControls1[] =  // Codec 1 control
{
  145,                                      // 'NEAR' BUTTON
  126,                                      // MUTE NEAR END
  124,                                      // VOLUME UP
  125,                                      // VOLUME DOWN
  158,                                      // MENU
  148,                                      // CURSOR UP
  149,                                      // CURSOR DOWN
  151,                                      // CURSOR LEFT
  150,                                      // CURSOR RIGHT
  152,                                      // SELECT
  159,                                      // HELP
  NO_BTN,                                   // AUTO
  110,                                      // KEY PAD 0
  111,                                      // KEY PAD 1
  112,                                      // KEY PAD 2
  113,                                      // KEY PAD 3
  114,                                      // KEY PAD 4
  115,                                      // KEY PAD 5
  116,                                      // KEY PAD 6
  117,                                      // KEY PAD 7
  118,                                      // KEY PAD 8
  119,                                      // KEY PAD 9
  156,                                      // KEY PAD *
  157,                                      // KEY PAD #
  143,                                      // CALL/HANGUP
  147,                                      // ADDRESS BOOK
  146,                                      // FAR button
  NO_BTN,                                   // Codec Lock 
  154,                                      // hang up video 
  155,					    //BACK button
  160,					    //HOME Button
  161,					    //DOT or Period
  162					    //Backspace 
}
VOLATILE INTEGER nFarEndCamera1[] =        // Codec 1 control
{
  52,                                      // TILT UP
  53,                                      // TILT DOWN
  54,                                      // PAN LEFT
  55,                                      // PAN RIGHT
  56,                                      // ZOOM TELE
  57,                                      // ZOOM WIDE
  58,                                      // PRESET #1
  59,                                      // PRESET #2
  60,                                      // PRESET #3
  61                                       // PRESET #4
}
VOLATILE INTEGER nNearEndCamera1[] =       // Codec 1 control
{
  256,                                      // TILT UP
  256,                                      // TILT DOWN
  256,                                      // PAN LEFT
  256,                                      // PAN RIGHT
  256,                                      // ZOOM TELE
  256,                                      // ZOOM WIDE
  256,                                      // PRESET #1
  256,                                      // PRESET #2
  256,                                      // PRESET #3
  256                                       // PRESET #4
}  
 
VOLATILE INTEGER nDialButtons[] =  // call number directly 
{
  21,                                      // KEY PAD 0
  22,                                      // KEY PAD 1
  23,                                      // KEY PAD 2
  24,                                      // KEY PAD 3
  25,                                      // KEY PAD 4
  26,                                      // KEY PAD 5
  27,                                      // KEY PAD 6
  28,                                      // KEY PAD 7
  29,                                      // KEY PAD 8
  30,                                      // KEY PAD 9
  31,                                      // KEY PAD #
  32,                                      // KEY PAD *
  33,                                      // .
  34,                                      // CLEAR
  35,                                      // back
  36,                                      // DIAL
  73,                                      // line speed 384
  74,                                      // line speed 512
  75,                                      // line speed 768
  76,                                      // line speed 1024
  77                                       // line speed 1536
}
VOLATILE INTEGER nKeyboardBtns[] =  // call number directly 
{
    300,
    301,
    302,
    303,
    304,
    305,
    306,
    307,
    308,
    309,
    310,
    311,
    312,
    313,
    314,
    315,
    316,
    317,
    318,
    319,
    320,
    321,
    322,
    323,
    324,
    325,
    326,
    327,
    328,
    329,
    330,
    331,
    332,
    333,
    334,
    335,
    336,
    337,
    338    
}
VOLATILE INTEGER nKeyboardMiscBtns[] =  //
{
    339,
    340,
    341,
    342,
    343,
    344,
    345,
    346,
    347,
    348,
    349,
    350,
    351,
    352,
    353,
    354,
    355,
    356,
    357,
    358,
    359,
    360,
    361,
    362,
    363,
    364,
    365,
    366,
    367,
    368,
    369
}

DEFINE_VARIABLE
 

DEFINE_EVENT
