MODULE_NAME = 'VS4000 Module' (DEV dvVS4000,DEV vdvVS4000,DEV dvPanel[],
                               INTEGER nMainFunctions[],INTEGER nFarEndCamera[],INTEGER nNearEndCamera[],INTEGER nDialButtons[],integer nKeyBoardB[], integer nKeyboardBoardMisc[])
(*{{PS_SOURCE_INFO(PROGRAM STATS)                          *)
(***********************************************************)
(*  FILE CREATED ON: 10/18/2001 AT: 15:26:08               *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 12/16/2003  AT: 15:51:41        *)
(***********************************************************)
(*!!FILE REVISION: Rev 0                                   *)
(*  REVISION DATE: 06/17/2002                              *)
(*                                                         *)
(*  COMMENTS:                                              *)
(*                                                         *)
(***********************************************************)
(*!!FILE REVISION: Rev 0                                   *)
(*  REVISION DATE: 05/24/2002                              *)
(*                                                         *)
(*  COMMENTS:                                              *)
(*                                                         *)
(***********************************************************)
(*!!FILE REVISION: Rev 0                                   *)
(*  REVISION DATE: 01/16/2002                              *)
(*                                                         *)
(*  COMMENTS:                                              *)
(*                                                         *)
(***********************************************************)
(*}}PS_SOURCE_INFO                                         *)
(***********************************************************)

(***********************************************************)
(* System Type : Netlinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE
                

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

(* COMMON *)
CR                        =   13
LF                        =   10
BUSY                      =   250
IS_ONLINE                 =   251
DISABLE                   =   252
DEBUG                     =   254
FEEDBACK1                 =   1

(* VS4000 *)
FRONTCAM                  =   1     (* primary camera *)
REARCAM                   =   4 
VCRINPUT                  =   5
FARENDCAM                 =   6

(*!!! very strange sources <> inputs!!! *)
FRONTCAM_SOURCE           =   1
REARCAM_SOURCE            =   2
VCRINPUT_SOURCE           =   5

VS4000_QUEUE              =   1
VS4000_SCREEN             =   2
VS4000_GET_SCREEN         =   3
VS4000_VOLUME_UP          =   4
VS4000_VOLUME_DOWN        =   5
VS4000_VOLUME_GET         =   6
VS4000_HANGUP             =   7
VS4000_CURSOR_UP          =   8
VS4000_CURSOR_DOWN        =   9
VS4000_CURSOR_LEFT        =   10
VS4000_CURSOR_RIGHT       =   11
VS4000_SELECT             =   12
VS4000_MENU               =   13
VS4000_CALLHANGUP         =   14
VS4000_NEAR               =   15
VS4000_FAR                =   16
VS4000_MUTE               =   17
VS4000_NEAR_MUTE          =   18
VS4000_FAR_MUTE           =   19
VS4000_HELP               =   20
VS4000_AUTO               =   21
VS4000_FAR_MOVE_UP        =   22
VS4000_FAR_MOVE_DOWN      =   23
VS4000_FAR_MOVE_LEFT      =   24
VS4000_FAR_MOVE_RIGHT     =   25
VS4000_FAR_MOVE_ZOOMI     =   26
VS4000_FAR_MOVE_ZOOMO     =   27
VS4000_FAR_MOVE_STOP      =   28
VS4000_FAR_PRESET         =   29
VS4000_NEAR_MOVE_UP       =   30
VS4000_NEAR_MOVE_DOWN     =   31
VS4000_NEAR_MOVE_LEFT     =   32
VS4000_NEAR_MOVE_RIGHT    =   33
VS4000_NEAR_MOVE_ZOOMI    =   34
VS4000_NEAR_MOVE_ZOOMO    =   35
VS4000_NEAR_MOVE_STOP     =   36
VS4000_NEAR_PRESET        =   37
VS4000_NEAR_PRESET_STORE  =   38
VS4000_WAKE_UP            =   39
VS4000_RESET              =   40
CODEC_CAM1                =   50
CODEC_DOC                 =   51
CODEC_VCR                 =   52
CODEC_CAM2                =   53
CODEC_HANGUP              =   54



VS4000QueueMAX            =   100

VS4000_RINGING            =   200
VS4000_CONNECTED          =   201
VS4000_BUSY               =   202
VS4000_COMPLETE           =   203
VS4000_NOT_CONNECTED      =   204
VS4000_RESET_PORT         =   253

IN_USE                    =   100
START_TIMER   =1
char cAlphabet[]="'0123456789abcdefghijklmnopqrstuvwxyz'"
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

(*GENERAL*)
BLINK
LONG TIMEARRAY[1]

(* DIALING *)
INTEGER nEnteringNumber
CHAR    cNumbers[2][32]
CHAR    cDefaultSpeed[8]

(* VS4000 *)
VS4000_DEBUG
VS4000_BUFFER[255]
VS4000Queue[VS4000QueueMAX][50]
VS4000QueueHead
VS4000QueueTail
VS4000QueueHasItems

VS4000_CallInuse[4]
VS4000_SPD[10][8]
VS4000_PBOOK_NAME[60][50]
VS4000_PBOOK_NUMBER[60][100]
VS4000_PBOOK_SPEED[60][20]
VS4000_ACTIVE_SCREEN[25]
INTEGER nPanel
INTEGER nVolumeLevel
CHAR cNearMuteStatus
CHAR cFarEndPrest[1]
CHAR cNearEndPrest[1]

VS4000_CAMERAS[6]
VS4000_ACTIVE_CAMERA
VS4000_ACTIVE_SOURCE


VOLATILE CHAR cWhichChar[14]
VOLATILE CHAR cCodecStr[50]         // actual string sent out
VOLATILE CHAR cKeyPadChar[1]        // used for Pulling out correct command from KEYPAD_CHAR
volatile Char cNumPad[1]
volatile CHAR cTpNum[20]
VOLATILE INTEGER nCommand      	    // used in Button event
VOLATILE CHAR cKeyPad[1]            // used for Pulling out correct command from KEYPAD_CHAR
volatile CHAR cTpKeyp[1]
volatile CHAR CKeyBoardChar[1]
PCOM_DIAL_SPEED[4]


(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)
(*
DEFINE_CALL 'OPEN PORT'
{
  IP_CLIENT_CLOSE(dvVS4000.PORT)
  IP_CLIENT_OPEN(dvVS4000.PORT,cIpAddress,24,1)
}
*)
DEFINE_CALL 'ADD TO VS4000 QUEUE' (CMD[])
{
  IF (VS4000QueueHead = VS4000QueueMAX) 
  {  
    IF (VS4000QueueTail <> 1)
    {
      VS4000QueueHead = 1
      VS4000Queue[VS4000QueueHead] = CMD 
      ON[VS4000QueueHasItems]
    }
  }
  ELSE IF (VS4000QueueTail <> VS4000QueueHead + 1)
  {
    VS4000QueueHead = VS4000QueueHead + 1
    VS4000Queue[VS4000QueueHead] = CMD
    ON[VS4000QueueHasItems]
  }
}

DEFINE_CALL 'CHECK VS4000 QUEUE'
{
  local_var CHAR cmd[80]
  
  ON[vdvVS4000,BUSY]
  
  IF (VS4000QueueTail = VS4000QueueMax)  
    VS4000QueueTail = 1
  ELSE
    VS4000QueueTail = VS4000QueueTail + 1 
    
  IF (VS4000QueueTail = VS4000QueueHead)
    OFF[VS4000QueueHasItems]

  cmd = VS4000Queue[VS4000QueueTail]
  SEND_STRING dvVS4000, "cmd,CR,LF"
  
  WAIT 30 'VS4000 BUSY'
    OFF[vdvVS4000,BUSY]

  IF ([vdvVS4000,DEBUG])
    SEND_STRING 0 ,"'TO VS4000: ',cmd,CR,LF"
}

DEFINE_CALL 'VS4000 FUNCTION' (FUNCTION,DATA[])
{
  OFF[vdvVS4000,VS4000_NEAR_PRESET_STORE]
  
  SELECT
  {
    ACTIVE (FUNCTION = VS4000_QUEUE):  
      CALL 'ADD TO VS4000 QUEUE' (DATA)
      
    ACTIVE (FUNCTION = VS4000_HANGUP):
      CALL 'ADD TO VS4000 QUEUE' ("'hangup ',DATA")
      
    (* 'addressbook', 'farvideo', 'main', 'nearvideo', 'speedial', 'enableUI', 'DISABLEUI' *)
    ACTIVE (FUNCTION = VS4000_SCREEN):
    {
      VS4000_ACTIVE_SCREEN = DATA                       // PROVIDE TEMP FEEDBACK
      
      CALL 'ADD TO VS4000 QUEUE' ("'screen ',DATA")
      
      CALL 'ADD TO VS4000 QUEUE' ('get screen')
    }
      
    ACTIVE (FUNCTION = VS4000_GET_SCREEN):
      CALL 'ADD TO VS4000 QUEUE' ('get screen')
      
    ACTIVE (FUNCTION = VS4000_VOLUME_UP):
      CALL 'ADD TO VS4000 QUEUE' ('button volume+')
      
    ACTIVE (FUNCTION = VS4000_VOLUME_DOWN):
      CALL 'ADD TO VS4000 QUEUE' ('button volume-')
      
    ACTIVE (FUNCTION = VS4000_VOLUME_GET):
      CALL 'ADD TO VS4000 QUEUE' ('volume get')
      
    ACTIVE (FUNCTION = VS4000_CURSOR_UP):
      CALL 'ADD TO VS4000 QUEUE' ('button up')
      
    ACTIVE (FUNCTION = VS4000_CURSOR_DOWN):
      CALL 'ADD TO VS4000 QUEUE' ('button down')
      
    ACTIVE (FUNCTION = VS4000_CURSOR_LEFT):
      CALL 'ADD TO VS4000 QUEUE' ('button left')
      
    ACTIVE (FUNCTION = VS4000_CURSOR_RIGHT):
      CALL 'ADD TO VS4000 QUEUE' ('button right')
      
    ACTIVE (FUNCTION = VS4000_SELECT):
      CALL 'ADD TO VS4000 QUEUE' ('button select')
      
    ACTIVE (FUNCTION = VS4000_MENU): 
    {
      CALL 'ADD TO VS4000 QUEUE' ('button menu')
//      CALL 'PREVIEW MULTI'(15,2)
    }
    
    ACTIVE (FUNCTION = VS4000_CALLHANGUP):
      CALL 'ADD TO VS4000 QUEUE' ('button callhangup')
      
    ACTIVE (FUNCTION = VS4000_HELP):
      CALL 'ADD TO VS4000 QUEUE' ('button info')
      
    ACTIVE (FUNCTION = VS4000_HELP):
      CALL 'ADD TO VS4000 QUEUE' ('button auto')
      
    ACTIVE (FUNCTION = VS4000_NEAR):
      CALL 'ADD TO VS4000 QUEUE' ('button near')
      
    ACTIVE (FUNCTION = VS4000_FAR):
      CALL 'ADD TO VS4000 QUEUE' ('button far')
     
    ACTIVE (FUNCTION = VS4000_MUTE):
      CALL 'ADD TO VS4000 QUEUE' ('button mute')
      
    ACTIVE (FUNCTION = VS4000_FAR_MUTE):
      CALL 'ADD TO VS4000 QUEUE' ('mute far toggle')
      
    ACTIVE (FUNCTION = VS4000_NEAR_MUTE):
      CALL 'ADD TO VS4000 QUEUE' ('mute near toggle')
      
    ACTIVE (FUNCTION = VS4000_FAR_MOVE_UP):
      CALL 'ADD TO VS4000 QUEUE' ('camera far move up')
    
    ACTIVE (FUNCTION = VS4000_FAR_MOVE_DOWN):
      CALL 'ADD TO VS4000 QUEUE' ('camera far move down')
      
    ACTIVE (FUNCTION = VS4000_FAR_MOVE_LEFT):
      CALL 'ADD TO VS4000 QUEUE' ('camera far move left')
      
    ACTIVE (FUNCTION = VS4000_FAR_MOVE_RIGHT):
      CALL 'ADD TO VS4000 QUEUE' ('camera far move right')
      
    ACTIVE (FUNCTION = VS4000_FAR_MOVE_STOP):
      CALL 'ADD TO VS4000 QUEUE' ('camera far move stop')
      
    ACTIVE (FUNCTION = VS4000_FAR_MOVE_ZOOMI):
      CALL 'ADD TO VS4000 QUEUE' ('camera far move zoom+')
      
    ACTIVE (FUNCTION = VS4000_FAR_MOVE_ZOOMO):
      CALL 'ADD TO VS4000 QUEUE' ('camera far move zoom-')
      
    ACTIVE (FUNCTION = VS4000_FAR_PRESET):  
      CALL 'ADD TO VS4000 QUEUE' ("'preset far go ',DATA")
      
    ACTIVE (FUNCTION = VS4000_NEAR_MOVE_UP):
      CALL 'ADD TO VS4000 QUEUE' ('camera near move up')
    
    ACTIVE (FUNCTION = VS4000_NEAR_MOVE_DOWN):
      CALL 'ADD TO VS4000 QUEUE' ('camera near move down')
      
    ACTIVE (FUNCTION = VS4000_NEAR_MOVE_LEFT):
      CALL 'ADD TO VS4000 QUEUE' ('camera near move left')
      
    ACTIVE (FUNCTION = VS4000_NEAR_MOVE_RIGHT):
      CALL 'ADD TO VS4000 QUEUE' ('camera near move right')
      
    ACTIVE (FUNCTION = VS4000_NEAR_MOVE_ZOOMI):
      CALL 'ADD TO VS4000 QUEUE' ('camera near move zoom+')
      
    ACTIVE (FUNCTION = VS4000_NEAR_MOVE_ZOOMO):
      CALL 'ADD TO VS4000 QUEUE' ('camera near move zoom-')
      
    ACTIVE (FUNCTION = VS4000_NEAR_MOVE_STOP):
      CALL 'ADD TO VS4000 QUEUE' ('camera near move stop')
      
    ACTIVE (FUNCTION = VS4000_NEAR_PRESET):  
      CALL 'ADD TO VS4000 QUEUE' ("'preset near go ',DATA")
    
    ACTIVE (FUNCTION = VS4000_NEAR_PRESET_STORE):  
      CALL 'ADD TO VS4000 QUEUE' ("'preset near set ',DATA")
      
    ACTIVE (FUNCTION = VS4000_WAKE_UP):  
      CALL 'ADD TO VS4000 QUEUE' ("'screen wake'")
  }
}

DEFINE_CALL 'RESET VS4000'
{
  VS4000_ACTIVE_CAMERA  = FRONTCAM
  
  CALL 'VS4000 FUNCTION' (VS4000_SCREEN, 'main')
  CALL 'VS4000 FUNCTION' (VS4000_HANGUP, 'video')
  CALL 'VS4000 FUNCTION' (VS4000_VOLUME_GET, '')
  
  CALL 'VS4000 FUNCTION' (VS4000_QUEUE, 'mute register')
  CALL 'VS4000 FUNCTION' (VS4000_QUEUE, 'volume register')
  
  CALL 'VS4000 FUNCTION' (VS4000_QUEUE, 'listen video')
  CALL 'VS4000 FUNCTION' (VS4000_QUEUE, 'listen phone')
  
  IF ([vdvVS4000,DEBUG])
    SEND_STRING 0, "'VS4000 RESET...HANGUP/MAIN...',CR"
  
}

DEFINE_CALL 'INIT VS4000'
{
  VS4000QueueHead = 1
  VS4000QueueTail = 1
  OFF[VS4000QueueHasItems]
  
  CALL 'RESET VS4000'
  
  // CALL 'VS4000 FUNCTION' (VS4000_QUEUE, 'abk all')
}

DEFINE_CALL 'PARSE VS4000' 
LOCAL_VAR
CHAR VS4000_MSG[200]
CHAR JUNK[80]
TEMP
CALL_NUMBER
ENTRY_NUMBER
{
  VS4000_MSG = REMOVE_STRING(VS4000_BUFFER,"CR,LF",1)
  
  IF (LENGTH_STRING(VS4000_MSG))
  {  
    IF (VS4000_DEBUG)
      SEND_STRING 0, "'FROM VS4000: ',VS4000_MSG"

    SET_LENGTH_STRING(VS4000_MSG,LENGTH_STRING(VS4000_MSG) - 2) // STRIP CR,LF

    TEMP = FIND_STRING(VS4000_MSG,'CALL[',1)
    IF (temp)
      CALL_NUMBER = ATOI(RIGHT_STRING(VS4000_MSG,TEMP + 5)) + 1

    SELECT
    {
      ACTIVE (FIND_STRING(VS4000_MSG,'cs:',1)):             // CALL STATUS
      {
        SELECT 
        {
          ACTIVE (FIND_STRING(VS4000_MSG,'RINGING',1)):
            ON[vdvVS4000,VS4000_RINGING]
            
          ACTIVE (FIND_STRING(VS4000_MSG,'BUSY',1)):
            ON[vdvVS4000,VS4000_BUSY]
        
          ACTIVE (FIND_STRING(VS4000_MSG,'CONNECTED',1)):
          {
            ON[vdvVS4000,VS4000_CONNECTED]
            OFF[vdvVS4000,VS4000_NOT_CONNECTED]
          }
        }
        
        IF (CALL_NUMBER)                                    // JUST IN CASE ITS ZERO
          ON[VS4000_CallInuse[CALL_NUMBER]]
      }
      
      ACTIVE (FIND_STRING(VS4000_MSG,'ended call',1)): 
      {
        IF (CALL_NUMBER)                                   // JUST IN CASE ITS ZERO                            
          OFF[VS4000_CallInuse[CALL_NUMBER]] 
        
        IF (VS4000_CallInuse[1] = 0 && VS4000_CallInuse[2] = 0 && VS4000_CallInuse[3] = 0 && VS4000_CallInuse[4] = 0)
        {  
          OFF[vdvVS4000,VS4000_CONNECTED]     
          ON[vdvVS4000,VS4000_NOT_CONNECTED]
        }                                 
      }
    
      ACTIVE (FIND_STRING(VS4000_MSG,'cleared:',1)):        // CLEARED STATUS 
      {
        OFF[vdvVS4000,VS4000_RINGING]
        OFF[vdvVS4000,VS4000_BUSY]
        OFF[vdvVS4000,VS4000_CONNECTED]
        OFF[vdvVS4000,VS4000_COMPLETE]
      }
      
      ACTIVE (FIND_STRING(VS4000_MSG,'volume ',1)):         // VOLUME 
      {
        JUNK = REMOVE_STRING(VS4000_MSG,'volume ',1)
        
        nVolumeLevel = ATOI(VS4000_MSG)
        
       // SEND_LEVEL dvPanel, 8, (nVolumeLevel * 255) / 24
      }
      
      ACTIVE (FIND_STRING(VS4000_MSG,'mute near ',1)):      // MUTE NEAR 
      {
        JUNK = REMOVE_STRING(VS4000_MSG,'mute near ',1)
        
        cNearMuteStatus = VS4000_MSG = 'on'
      }
      
      ACTIVE (FIND_STRING(VS4000_MSG,'screen: ',1)):        // screen info... if 'screen' command is used... poll 'get screen' 
      {
        JUNK = REMOVE_STRING(VS4000_MSG,'screen: ',1)
        
        VS4000_ACTIVE_SCREEN = VS4000_MSG
      }
      
      ACTIVE (FIND_STRING(VS4000_MSG,'camera near source ',1)):
      {
        JUNK = REMOVE_STRING(VS4000_MSG,'camera near source ',1)
        
        VS4000_ACTIVE_SOURCE = ATOI(VS4000_MSG)
      }
      
      ACTIVE (LEFT_STRING(VS4000_MSG,3) = 'abk'):           // THE ADDRESSBOOK A.K.A. PHONE BOOK 
      {
        JUNK = REMOVE_STRING(VS4000_MSG,'.  ',1)
        
        ENTRY_NUMBER = ATOI(JUNK) + 1
        
        VS4000_PBOOK_NAME[ENTRY_NUMBER] = REMOVE_STRING(VS4000_MSG,'spd:',1)
        SET_LENGTH_STRING(VS4000_PBOOK_NAME[ENTRY_NUMBER],LENGTH_STRING(VS4000_PBOOK_NAME[ENTRY_NUMBER]) - 5)
        
        VS4000_PBOOK_SPEED[ENTRY_NUMBER] = REMOVE_STRING(VS4000_MSG,'num:',1)
        SET_LENGTH_STRING(VS4000_PBOOK_SPEED[ENTRY_NUMBER],LENGTH_STRING(VS4000_PBOOK_SPEED[ENTRY_NUMBER]) - 5)
        
        VS4000_PBOOK_NUMBER[ENTRY_NUMBER] = VS4000_MSG 
      }
    }
  }
  
  IF (FIND_STRING(VS4000_BUFFER,"CR,LF",1))
    CALL 'PARSE VS4000'
}

DEFINE_FUNCTION CHAR[50] PrettyNumber(CHAR cDigits[])
{    
  LOCAL_VAR INTEGER I
  LOCAL_VAR CHAR cVT[50]
  
  I = LENGTH_STRING(cDigits)
  
  SELECT
  {
    ACTIVE (I = 0):
      cVT = ""
    ACTIVE (I = 7):
      cVT = "LEFT_STRING(cDigits,3),'-',RIGHT_STRING(cDigits,4)"
    ACTIVE (I = 10):
      cVT = "'(',LEFT_STRING(cDigits,3),') ',MID_STRING(cDigits,4,3),'-',RIGHT_STRING(cDigits,4)"
    ACTIVE (I = 11):
      cVT = "LEFT_STRING(cDigits,1),' (',MID_STRING(cDigits,2,3),') ',MID_STRING(cDigits,5,3),'-',RIGHT_STRING(cDigits,4)"
    ACTIVE (I = 12):
      cVT = "LEFT_STRING(cDigits,2),' (',MID_STRING(cDigits,3,3),') ',MID_STRING(cDigits,6,3),'-',RIGHT_STRING(cDigits,4)"
    ACTIVE (1):
      cVT = "cDigits"            
  }
  
  RETURN cVT
}

Define_Function Char[100] PrintHex(Char cString[])
{
  Stack_Var Char TString[100],TTString[100]; 
  Stack_Var Integer nTemp

  If (Length_String(cString))
  {  
    TTString = cString;
    TString = '"';
    
    For (;Length_String(TTString);)
    {
      nTemp = Get_Buffer_Char(TTString)
      
      TString = "TString,'$',ItoHex(nTemp),','";    
    }
    Set_Length_String(TString,Length_String(TString)-1)
    TString = "TString,'"'"
  }
  Return TString;
}

// DEFINE_FUNCTION GET_IP_ERROR
// PARAMETER:    
// lERR - ERROR NUMBER
// RETURNS: 
// ERROR STRING
DEFINE_FUNCTION CHAR[100] GET_IP_ERROR (LONG lERR)
{
  SWITCH (lERR)
  {
    CASE 0:
      RETURN "";
    CASE 2:
      RETURN "'IP ERROR (',ITOA(lERR),'): General Failure (IP_CLIENT_OPEN/IP_SERVER_OPEN)'";
    CASE 4:
      RETURN "'IP ERROR (',ITOA(lERR),'): unknown host (IP_CLIENT_OPEN)'";
    CASE 6:
      RETURN "'IP ERROR (',ITOA(lERR),'): connection refused (IP_CLIENT_OPEN)'";
    CASE 7:
      RETURN "'IP ERROR (',ITOA(lERR),'): connection timed out (IP_CLIENT_OPEN)'";
    CASE 8:
      RETURN "'IP ERROR (',ITOA(lERR),'): unknown connection error (IP_CLIENT_OPEN)'";
    CASE 9:
      RETURN "'IP ERROR (',ITOA(lERR),'): Already closed (IP_CLIENT_CLOSE/IP_SERVER_CLOSE)'";  
    CASE 10:
      RETURN "'IP ERROR (',ITOA(lERR),'): Binding error (IP_SERVER_OPEN)'";
    CASE 11:
      RETURN "'IP ERROR (',ITOA(lERR),'): Listening error (IP_SERVER_OPEN)'";  
    CASE 14:
      RETURN "'IP ERROR (',ITOA(lERR),'): local port already used (IP_CLIENT_OPEN/IP_SERVER_OPEN)'";
    CASE 15:
      RETURN "'IP ERROR (',ITOA(lERR),'): UDP socket already listening (IP_SERVER_OPEN)'";
    CASE 16:
      RETURN "'IP ERROR (',ITOA(lERR),'): too many open sockets (IP_CLIENT_OPEN/IP_SERVER_OPEN)'";
    DEFAULT:
      RETURN "'IP ERROR (',ITOA(lERR),'): Unknown'";
  }
}
(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START 
cWhichChar = "'0123456789#*.'";

PCOM_DIAL_SPEED  = '384'


CREATE_BUFFER dvVS4000  , VS4000_BUFFER

VS4000_SPD[1]           = '2X64'
VS4000_SPD[2]           = '128'
VS4000_SPD[3]           = '256'
VS4000_SPD[4]           = '384'
VS4000_SPD[5]           = '512'
VS4000_SPD[6]           = '768'
VS4000_SPD[7]           = '1024'
VS4000_SPD[8]           = '1472'

OFF[vdvVS4000,210]   // codec not in use


cDefaultSpeed = VS4000_SPD[4]

TIMEARRAY[1] = 250
TIMELINE_CREATE(FEEDBACK1,TIMEARRAY,1,TIMELINE_ABSOLUTE,TIMELINE_REPEAT)

(***********************************************************)
(*                THE EVENTS GOES BELOW                    *)
(***********************************************************)
DEFINE_EVENT
DATA_EVENT[dvVS4000]
{
  ONLINE:
  {
   (* CANCEL_WAIT 'OPENING'*)
    //SEND_COMMAND data.device,"'SET BAUD 9600,8,N,1'" 
    ON[vdvVS4000,IS_ONLINE]
    CALL 'INIT VS4000'
  }
  
  OFFLINE:
  {
    OFF[vdvVS4000,IS_ONLINE]
  }
  
  ONERROR:
  {
    IF ([vdvVS4000,DEBUG])
      SEND_STRING 0, "'VS4000/FX ERROR: ',GET_IP_ERROR(DATA.NUMBER),CR"
  }
  
  STRING:
  {
    LOCAL_VAR CHAR cEcho[100]
    
    IF ([vdvVS4000,DEBUG])
      SEND_STRING 0, "'FROM VS4000: ',PrintHex(DATA.TEXT),CR"
      
    cEcho = REMOVE_STRING(VS4000_BUFFER,"LF,CR",1)          // ACKING THE SENT COMMAND
    IF (LENGTH_STRING(cEcho))
      OFF[vdvVS4000,BUSY]                                  
    
    IF (FIND_STRING(VS4000_BUFFER,"CR,LF",1))
      CALL 'PARSE VS4000'
  }
}

BUTTON_EVENT[dvPanel,nMainFunctions]
{
  PUSH:
  {
    nPanel = GET_LAST(dvPanel)
    send_string 0:1:0,"'mainfunction was called ',itoa(button.input.channel),13,10"
    //PULSE[vdvTimeProxy1,START_TIMER]// reset and start timer
    //PULSE[vdvTimeProxy2,START_TIMER]// reset and start timer
     
   (* IF (![vdvVS4000,DISABLE])
    {*)  
      SWITCH (GET_LAST(nMainFunctions))
      {
        CASE 1:                                               // 'NEAR' BUTTON
        {
          TO[BUTTON.INPUT]
          
          CALL 'VS4000 FUNCTION' (VS4000_NEAR,'')
        }
        
        CASE 2:                                               // NEAR MUTE
        {
          CALL 'VS4000 FUNCTION' (VS4000_NEAR_MUTE,'')
        }
        
        CASE 3:                                               // VOLUME UP
        {
          TO[BUTTON.INPUT]
          
          CALL 'VS4000 FUNCTION' (VS4000_VOLUME_UP,'')
        }
        
        CASE 4:                                               // VOLUME DOWN
        {
          TO[BUTTON.INPUT]
          
          CALL 'VS4000 FUNCTION' (VS4000_VOLUME_DOWN,'')
        }
        CASE 5:                                               // MENU (main screen)
        { 
          TO[BUTTON.INPUT]
        
          CALL 'VS4000 FUNCTION' (VS4000_SCREEN,'main')
        }
        
        CASE 6:                                               // CURSOR UP
        {
          TO[BUTTON.INPUT]
          
          CALL 'VS4000 FUNCTION' (VS4000_CURSOR_UP,'')
        }
        
        CASE 7:                                               // CURSOR DOWN
        {
          TO[BUTTON.INPUT]
          
          CALL 'VS4000 FUNCTION' (VS4000_CURSOR_DOWN,'')
        }
        
        CASE 8:                                               // CURSOR LEFT
        {
          TO[BUTTON.INPUT]
          CALL 'VS4000 FUNCTION' (VS4000_CURSOR_LEFT,'')
	  SET_LENGTH_STRING(cTpNum,LENGTH_STRING(cTpNum) - 1)
          SEND_COMMAND dvPanel,"'TEXT1-',cTpNum"
        }
        
        CASE 9:                                               // CURSOR RIGHT
        {
          TO[BUTTON.INPUT]
          
          CALL 'VS4000 FUNCTION' (VS4000_CURSOR_RIGHT,'')
        }
        
        CASE 10:                                              // SELECT
        {
          TO[BUTTON.INPUT]
          
          CALL 'VS4000 FUNCTION' (VS4000_SELECT,'')
        }
        
        CASE 11:                                              // HELP (info)
        {
          TO[BUTTON.INPUT]
        
          CALL 'VS4000 FUNCTION' (VS4000_HELP,'')
        }
        
        CASE 12:                                              // AUTO
        {
          TO[BUTTON.INPUT]
          
          CALL 'VS4000 FUNCTION' (VS4000_AUTO,'')
        }
        
        CASE 13:                                             // KEY PAD 0
        CASE 14:                                             // KEY PAD 1
        CASE 15:                                             // KEY PAD 2
        CASE 16:                                             // KEY PAD 3
        CASE 17:                                             // KEY PAD 4
        CASE 18:                                             // KEY PAD 5
        CASE 19:                                             // KEY PAD 6
        CASE 20:                                             // KEY PAD 7
        CASE 21:                                             // KEY PAD 8
        CASE 22:                                             // KEY PAD 9
        {
          TO[BUTTON.INPUT]
          CALL 'VS4000 FUNCTION' (VS4000_QUEUE, "'button ',itoa(GET_LAST(nMainFunctions) - 13)")
	  cNumPad = itoa(get_last(nMainFunctions) - 13)
	  send_string 0:1:0,"'Cnumpad = ',cnumpad,13,10"
	  cTpNum = "cTpNum,cNumPad"
	  send_string 0:1:0,"'cTpNum = ',cTpNum,13,10"
	  SEND_COMMAND dvPanel,"'TEXT1-',cTpNum"
        }
        
        CASE 23:                                             // KEY *
        {
          TO[BUTTON.INPUT]
          
          CALL 'VS4000 FUNCTION' (VS4000_QUEUE, 'button *')
        }
        
        CASE 24:                                             // KEY #
        {
          TO[BUTTON.INPUT]
          
          CALL 'VS4000 FUNCTION' (VS4000_QUEUE, 'button #')
        }
        
        CASE 25:                                             // CALL/HANGUP
        {
          TO[BUTTON.INPUT]
          
          CALL 'VS4000 FUNCTION' (VS4000_CALLHANGUP, '')
        }
        
        CASE 26:                                             // ADDRESS BOOK
        {
        
          TO[BUTTON.INPUT]
          CALL 'VS4000 FUNCTION' (VS4000_QUEUE, 'button directory')//was 'addressbook'
        }
        
        CASE 27:                                            // far
        {
          TO[BUTTON.INPUT]
        
          CALL 'VS4000 FUNCTION' (VS4000_FAR,'')
        }
        CASE 28:                                            // lock / unlock
        {
          [vdvVS4000,210] = ![vdvVS4000,210] 
        }
        CASE 29:                                            // hangup video
        {
          CALL 'VS4000 FUNCTION' (VS4000_HANGUP, 'video')
          OFF[vdvVS4000,VS4000_CONNECTED]     
          ON[vdvVS4000,VS4000_NOT_CONNECTED]
        }
	CASE 30:                                            // BACK
        {
	  CALL 'VS4000 FUNCTION' (VS4000_QUEUE, 'button back')  
	}
	CASE 31:                                            // Home
        {
	  CALL 'VS4000 FUNCTION' (VS4000_QUEUE, 'button home')  
	}
	CASE 32:                                            //DOT
        {
	  CALL 'VS4000 FUNCTION' (VS4000_QUEUE, 'button .')
	}
	
      }
   (* }*)
  }
  
  HOLD[3,REPEAT]:
  {
   (* IF (![vdvVS4000,DISABLE])
    {*)   
      SWITCH (GET_LAST(nMainFunctions))
      {
        CASE 3:                                              // VOLUME UP
        {
          CALL 'VS4000 FUNCTION' (VS4000_VOLUME_UP,'')
        }
        
        CASE 4:                                              // VOLUME DOWN
        {
          CALL 'VS4000 FUNCTION' (VS4000_VOLUME_DOWN,'')
        }
        CASE 6:                                               // CURSOR UP
        {
          
          CALL 'VS4000 FUNCTION' (VS4000_CURSOR_UP,'')
        }
        
        CASE 7:                                               // CURSOR DOWN
        {
          
          CALL 'VS4000 FUNCTION' (VS4000_CURSOR_DOWN,'')
        }
        
        CASE 8:                                               // CURSOR LEFT
        {
          
          CALL 'VS4000 FUNCTION' (VS4000_CURSOR_LEFT,'')
        }
        
        CASE 9:                                               // CURSOR RIGHT
        {
          
          CALL 'VS4000 FUNCTION' (VS4000_CURSOR_RIGHT,'')
        }
      }
   (* }*)
  }
}
BUTTON_EVENT[dvPanel,nKeyboardb]	//This is not used @ Univ of Ill
{
    Push:
    {
	cKeyBoardChar[1] = cAlphabet[get_last(nkeyboardb)+1]
	SWITCH(button.input.channel)
	{
	    Case 300:{ }
	    Case 301:{ }
	    Case 302:{ }
	    Case 303:{ }
	    Case 304:{ }
	    Case 305:{ }
	    Case 306:{ }
	    Case 307:{ }
	    Case 308:{ }
	    Case 309:{ }
	    Case 310:{ }
	    Case 311:{ }
	    Case 312:{ }
	    Case 313:{ }
	    Case 314:{ }
	    Case 315:{ }
	    Case 316:{ }
	    Case 317:{ }
	    Case 318:{ }
	    Case 319:{ }
	    Case 320:{ }
	    Case 321:{ }
	    Case 322:{ }
	    Case 323:{ }
	    Case 324:{ }
	    Case 325:{ }
	    Case 326:{ }
	    Case 327:{ }
	    Case 328:{ }
	    Case 329:{ }
	    Case 330:{ }
	    Case 331:{ }
	    Case 332:{ }
	    Case 333:{ }
	    Case 334:{ }
	    Case 335:{ }
	    Case 336:{ }
	    Case 337:{ }
	    Case 338:{ }
	}
	cCodecStr = "cCodecStr,CKeyBoardChar[1]"
        SEND_COMMAND dvPanel,"'TEXT1-',cCodecStr"
    }
}

BUTTON_EVENT[dvPanel,nKeyboardBoardMisc]
{
    Push:
    {
	SWITCH (button.input.channel)
	{
	    Case 339:{ }
	    Case 340:{ }
	    Case 341:{ }
	    Case 342:{ }
	    Case 343:{ }
	    Case 344:{ }
	    Case 345:{ }
	    Case 346:{ }
	    Case 347:{ }
	    Case 348:{ }
	    Case 349:{ }
	    Case 350:{ }
	    Case 351:{ }
	    Case 352:{ }
	    Case 353:{ }
	    Case 354:{ }
	    Case 355:{ }
	    Case 356:{ }
	    Case 357:{ }
	    Case 358:{ }
	    Case 359:{ }
	    Case 360:{ }
	    Case 361:{ }
	    Case 362:{ }
	    Case 363:{ }
	}
    }
}
BUTTON_EVENT[dvPanel,nFarEndCamera]
{
  PUSH:
  {
    nPanel = GET_LAST(dvPanel)
   // PULSE[vdvTimeProxy1,START_TIMER]// reset and start timer

    IF (![vdvVS4000,DISABLE])
    {   
      SWITCH (GET_LAST(nFarEndCamera))
      {
        CASE 1:
        {
          TO[BUTTON.INPUT]
          
          cFarEndPrest = ""
          
          CALL 'VS4000 FUNCTION' (VS4000_FAR_MOVE_UP,'')
        }
        
        CASE 2:
        {
          TO[BUTTON.INPUT]
          
          cFarEndPrest = ""
          
          CALL 'VS4000 FUNCTION' (VS4000_FAR_MOVE_DOWN,'')
        }
        
        CASE 3:
        {
          TO[BUTTON.INPUT]
          
          cFarEndPrest = ""
          
          CALL 'VS4000 FUNCTION' (VS4000_FAR_MOVE_LEFT,'')
        }
        
        CASE 4:
        {
          TO[BUTTON.INPUT]
          
          cFarEndPrest = ""
          
          CALL 'VS4000 FUNCTION' (VS4000_FAR_MOVE_RIGHT,'')
        }
        
        CASE 5:
        {
          TO[BUTTON.INPUT]
          
          cFarEndPrest = ""
          
          CALL 'VS4000 FUNCTION' (VS4000_FAR_MOVE_ZOOMI,'')
        }
        
        CASE 6:
        {
          TO[BUTTON.INPUT]
          
          cFarEndPrest = ""
          
          CALL 'VS4000 FUNCTION' (VS4000_FAR_MOVE_ZOOMO,'')
        }
        
        CASE 7:
        {
          cFarEndPrest = '1'
          
          CALL 'VS4000 FUNCTION' (VS4000_FAR_PRESET,'1')
        }
        
        CASE 8:
        {
          cFarEndPrest = '2'
          
          CALL 'VS4000 FUNCTION' (VS4000_FAR_PRESET,'2')
        }
        
        CASE 9:
        {
          cFarEndPrest = '3'
          
          CALL 'VS4000 FUNCTION' (VS4000_FAR_PRESET,'3')
        }
        
        CASE 10:
        {
          cFarEndPrest = '4'
          
          CALL 'VS4000 FUNCTION' (VS4000_FAR_PRESET,'4')
        }
      }
    }
  }
  
  RELEASE:
  {
    IF (![vdvVS4000,DISABLE])
    {   
      SWITCH (GET_LAST(nFarEndCamera))
      {
        CASE 1:
        CASE 2:
        CASE 3:
        CASE 4:
        CASE 5:
        CASE 6:
        {
          CALL 'VS4000 FUNCTION' (VS4000_FAR_MOVE_STOP,'')
        }
      }
    }
  }
}

BUTTON_EVENT[dvPanel,nNearEndCamera]
{
  PUSH:
  {
    nPanel = GET_LAST(dvPanel)
    //PULSE[vdvTimeProxy1,START_TIMER]// reset and start timer

    IF (![vdvVS4000,DISABLE])
    {   
      SWITCH (GET_LAST(nNearEndCamera))
      {
        CASE 1:
        {
          TO[BUTTON.INPUT]
          
          cNearEndPrest = ""
          
          CALL 'VS4000 FUNCTION' (VS4000_NEAR_MOVE_UP,'')
        }
        
        CASE 2:
        {
          TO[BUTTON.INPUT]
          
          cNearEndPrest = ""
          
          CALL 'VS4000 FUNCTION' (VS4000_NEAR_MOVE_DOWN,'')
        }
        
        CASE 3:
        {
          TO[BUTTON.INPUT]
          
          cNearEndPrest = ""
          
          CALL 'VS4000 FUNCTION' (VS4000_NEAR_MOVE_LEFT,'')
        }
        
        CASE 4:
        {
          TO[BUTTON.INPUT]
          
          cNearEndPrest = ""

          CALL 'VS4000 FUNCTION' (VS4000_NEAR_MOVE_RIGHT,'')
        }
        
        CASE 5:
        {
          TO[BUTTON.INPUT]
          
          cNearEndPrest = ""
          
          CALL 'VS4000 FUNCTION' (VS4000_NEAR_MOVE_ZOOMI,'')
        }
        
        CASE 6:
        {
          TO[BUTTON.INPUT]
          
          cNearEndPrest = ""
          
          CALL 'VS4000 FUNCTION' (VS4000_NEAR_MOVE_ZOOMO,'')
        }
        
        CASE 7:
        {
          cNearEndPrest = '1'
          
          CALL 'VS4000 FUNCTION' (VS4000_NEAR_PRESET,'1')
        }
        
        CASE 8:
        {
          cNearEndPrest = '2'
          
          CALL 'VS4000 FUNCTION' (VS4000_NEAR_PRESET,'2')
        }
        
        CASE 9:
        {
          cNearEndPrest = '3'
          
          CALL 'VS4000 FUNCTION' (VS4000_NEAR_PRESET,'3')
        }
        
        CASE 10:
        {
          cNearEndPrest = '4'
          
          CALL 'VS4000 FUNCTION' (VS4000_NEAR_PRESET,'4')
        }
      }
    }
  }
  
  RELEASE:
  {
    IF (![vdvVS4000,DISABLE])
    {   
      SWITCH (GET_LAST(nNearEndCamera))
      {
        CASE 1:
        CASE 2:
        CASE 3:
        CASE 4:
        CASE 5:
        CASE 6:
        {
          CALL 'VS4000 FUNCTION' (VS4000_NEAR_MOVE_STOP,'')
        }
      }
    }
  }
}

CHANNEL_EVENT[vdvVS4000,VS4000_WAKE_UP]
{
  ON:
    CALL 'VS4000 FUNCTION' (VS4000_WAKE_UP,'')
}

CHANNEL_EVENT[vdvVS4000,VS4000_RESET]
{
  ON:
    CALL 'RESET VS4000'
}

CHANNEL_EVENT[vdvVS4000,VS4000_RESET_PORT]
{
  ON:
    OFF[vdvVS4000,IS_ONLINE]
}
(*
CHANNEL_EVENT[vdvVS4000,IN_USE]
{
  ON:
  {
    ON[vdvVS4000,210]     // codec locked
  }
  OFF:
  {
    OFF[vdvVS4000,210]
  }

}
*)

CHANNEL_EVENT[vdvVS4000,CODEC_CAM1]
{
  ON:                               // cam INPUT of CODEC
    CALL 'VS4000 FUNCTION' (VS4000_QUEUE,'camera near 1')
}

CHANNEL_EVENT[vdvVS4000,CODEC_DOC]
{
  ON:                               // cam INPUT of CODEC
    CALL 'VS4000 FUNCTION' (VS4000_QUEUE,'camera near 2')
}

CHANNEL_EVENT[vdvVS4000,CODEC_VCR]
{
  ON:                               // cam INPUT of CODEC
    CALL 'VS4000 FUNCTION' (VS4000_QUEUE,'camera near 3')
}

CHANNEL_EVENT[vdvVS4000,CODEC_CAM2]
{
  ON:                               // cam INPUT of CODEC
    CALL 'VS4000 FUNCTION' (VS4000_QUEUE,'camera near 4')
}

CHANNEL_EVENT[vdvVS4000,CODEC_HANGUP]
{
  ON:                               // 
    CALL 'VS4000 FUNCTION' (VS4000_HANGUP, 'video')
}

TIMELINE_EVENT[FEEDBACK1]
{
  LOCAL_VAR CHAR cCounter, cBlink
  
  // cCounter++
  
  WAIT 2 
    cBlink = !cBlink
  
 (* SWITCH (cCounter)
  {
    CASE 40:
    {
      IF (!VS4000QueueHasItems)
       {
     //  CALL 'VS4000 FUNCTION' (VS4000_GET_SCREEN,'')
       }
      cCounter = 0
    }
  }
  *)
  IF (VS4000QueueHasItems && (![vdvVS4000,BUSY]))// && [vdvVS4000,IS_ONLINE] )
  {
    CALL 'CHECK VS4000 QUEUE'
  }  
  //SEND_LEVEL dvPanel, 8, (nVolumeLevel * 255) / 24
  
  [dvPanel,nDialButtons[16]] = [vdvVS4000,VS4000_CONNECTED] || ([vdvVS4000,VS4000_RINGING] && cBlink) // connected
  [dvPanel,nMainFunctions[29]] = ([vdvVS4000,VS4000_NOT_CONNECTED])  // not connected
  
  [dvPanel,nDialButtons[17]] = (PCOM_DIAL_SPEED  = VS4000_SPD[4])
  [dvPanel,nDialButtons[18]] = (PCOM_DIAL_SPEED  = VS4000_SPD[5])
  [dvPanel,nDialButtons[19]] = (PCOM_DIAL_SPEED  = VS4000_SPD[6])
  [dvPanel,nDialButtons[20]] = (PCOM_DIAL_SPEED  = VS4000_SPD[7])
  [dvPanel,nDialButtons[21]] = (PCOM_DIAL_SPEED  = VS4000_SPD[8])
  
  [dvPanel,nMainFunctions[2]]  = cNearMuteStatus
  [dvPanel,nMainFunctions[5]]  = VS4000_ACTIVE_SCREEN = 'CMainScreen'  
  [dvPanel,nMainFunctions[11]] = VS4000_ACTIVE_SCREEN = 'CHelpMenuScrn'  
  [dvPanel,nMainFunctions[26]] = VS4000_ACTIVE_SCREEN = 'CAddressBookScreen'
  [dvPanel,nMainFunctions[27]] = VS4000_ACTIVE_SCREEN = 'CNearAutoScreen'   
  
  [dvPanel,nMainFunctions[25]] = [vdvVS4000,VS4000_CONNECTED] || ([vdvVS4000,VS4000_RINGING] && cBlink)

  [dvPanel,nNearEndCamera[ 7]] = cNearEndPrest = '1'
  [dvPanel,nNearEndCamera[ 8]] = cNearEndPrest = '2'
  [dvPanel,nNearEndCamera[ 9]] = cNearEndPrest = '3'
  [dvPanel,nNearEndCamera[10]] = cNearEndPrest = '4'
  [dvPanel,nFarEndCamera[ 7]]  = cFarEndPrest = '1'
  [dvPanel,nFarEndCamera[ 8]]  = cFarEndPrest = '2'
  [dvPanel,nFarEndCamera[ 9]]  = cFarEndPrest = '3'
  [dvPanel,nFarEndCamera[10]]  = cFarEndPrest = '4'
  
  
}

BUTTON_EVENT[dvPanel,nDialButtons]
{
  PUSH:
  {
    nPanel = GET_LAST(dvPanel)
    //PULSE[vdvTimeProxy1,START_TIMER]// reset and start timer

    nCommand = GET_LAST(nDialButtons)
    SELECT
    {                                 
      ACTIVE(nCommand <= 13):       // 0,1,2,3,4,5,6,7,8,9,#,*, or '.' BUTTON
      {
        TO[dvPanel,nDialButtons[nCommand]]
        cKeyPadChar = "cWhichChar[nCommand]"
        cCodecStr = "cCodecStr,cKeyPadChar"
        SEND_COMMAND dvPanel,"'TEXT1-',cCodecStr"
      } 
      ACTIVE(nCommand = 14):     // clear numbers
      {
         TO[dvPanel,nCommand]
         IF(LENGTH_STRING (cCodecStr))
         {
           SET_LENGTH_STRING(cCodecStr,0)
           SEND_COMMAND dvPanel,'TEXT1-'  (*NUMBER DISPLAY*)
         }
       }  
      ACTIVE(nCommand = 15):      // back space
      {
        TO[dvPanel,nCommand]
        IF(LENGTH_STRING (cCodecStr))
        {
          SET_LENGTH_STRING(cCodecStr,LENGTH_STRING(cCodecStr) - 1)
          SEND_COMMAND dvPanel,"'TEXT1-',cCodecStr"
        }
      }
      ACTIVE(nCommand = 16):      // DIal  
      {
        TO[dvPanel,nCommand]
        
        IF(FIND_STRING(cCodecStr,'.',1))  (* H323 call *)
        {
          CALL 'ADD TO VS4000 QUEUE' ("'dial manual ',PCOM_DIAL_SPEED,' ',cCodecStr,' ip ',13,10")
        } 
        ELSE
        {
          CALL 'ADD TO VS4000 QUEUE' ("'dial manual ',PCOM_DIAL_SPEED,' ',cCodecStr,' isdn ',13,10")
        }           
        ON[vdvVS4000,VS4000_CONNECTED]     
        OFF[vdvVS4000,VS4000_NOT_CONNECTED]
      }
      ACTIVE(nCommand >= 17):      // line speed selection  
      {
        TO[dvPanel,nCommand]
        PCOM_DIAL_SPEED  = VS4000_SPD[nCommand - 13]
      }  
    }
  }
}     
        
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

