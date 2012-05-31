PROGRAM_NAME='Training Lab 606'
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE
(*System number changed to 3 so that the MVP would not conect*)
(*to the system in Room 612/614*)
dvAudia1 = 5001:1:3	//Biamp Nexia CS		(A)<--Ref on DWG
dvProjA  = 5001:2:3	//Proxima C450 Right side as looking at Screen (B)
dvProjB  = 5001:3:3	//Proxima C450 Left side as looking at Screen (C)
dvScaler = 5001:4:3	//Extron DVS304 Video Scaler	(D)
DvCombo	 = 5001:9:3	//VCR/DVD Combo
dvTp     = 10006:1:3	//MVP8400 Touchpanel	
dvTpVcr_Dvd = 10006:2:3	//Port 2 for VCR and DVD control
Relay = 5001:8:3	//Relay used for Power Strip
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT
integer nLeft = 1	//Used for selecting Left Proj
integer nRight = 2	//Used for selecting Right Proj
integer nDvd = 1
integer nVCR = 2
integer nPC = 3
integer PowerRelay = 1
TL1 = 1
integer nRgbPortBtn[]=	//For selecting the RGB floor jacks
{
    50,51,52,53		//Currently only the first one is used.
}
INTEGER nSrcSelects[] = 
{
    91,	//DVD
    92,	//VCR
    93	//Laptop
}
integer nBtnDest[] = 
{
    1,	//Left Proj
    2,	//Right Proj
    3	//Both Projectors
    
}
integer nBtnRightProjAdvance[] = 
{
    94,		//Proj Power ON
    95,		//Proj Power Off
    96,		//VCR Input
    97,		//DVD Input
    98		//PC Input
}
integer nBtnLeftProjAdvance[] = 
{
    99,		//Proj Power ON
    100,	//Proj Power Off
    101,	//VCR Input
    102,	//DVD Input
    103		//PC Input
}
integer nBtnPwrOff[] = 
{
    4	//This is the YES button.
}
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE
INTEGER nBtnDVDMisc[] = 
{
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29
}
integer nCurrentSource
integer RightProjPwrStatus
integer LeftProjPwrStatus
integer nTimeBlock
integer TimeArray[61]
integer Count
INTEGER RUN1
INTEGER RUN2
PROJ_POWER1
PROJ_POWER2
PROJ_BUFFER1[10]
PROJ_BUFFER2[10]
INTEGER DISPLAY
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
INCLUDE 'AMX_ArrayLib.axi'
INCLUDE 'nAMX_QUEUE.axi'
INCLUDE 'Biamp_Audia.axi'

DEFINE_CALL 'Proj Power'(integer Proj_Num, char Proj_Control[10]) //Projector Control Sub.
{
    SELECT
    {
	ACTIVE(Proj_Num = 1):			//left_proj
	{
	    SELECT
	    {
		ACTIVE(Proj_Control = 'PON'):
		{
		    IF(PROJ_POWER1 = 0)
		    {
			SEND_STRING dvProjA,'(PWR1)'
			WAIT 25
			{
			    RUN1 = 1
			}
		    }
		}
		ACTIVE(Proj_Control = 'POF'):
		{
		    IF(PROJ_POWER1 = 1)
		    {
			SEND_STRING dvProjA,'(PWR0)'
			RUN1 = 0
		    }
		}
	    }
	}
	ACTIVE(Proj_Num = 2):			//right
	{
	    SELECT
	    {
		ACTIVE(Proj_Control = 'PON'):
		{
		    IF(PROJ_POWER2 = 0)
		    {
			SEND_STRING dvProjB,'(PWR1)'
			WAIT 25
			{
			    RUN2 = 1
			}
		    }
		}
		ACTIVE(Proj_Control = 'POF'):
		{
		    IF(PROJ_POWER2 = 1)
		    {
			SEND_STRING dvProjB,'(PWR0)'
			RUN2 = 0
		    }
		}
	    }
	}
	ACTIVE(Proj_Num = 3):			//BOTH
	{
	    SELECT
	    {
		ACTIVE(Proj_Control = 'PON'):
		{
		    IF(PROJ_POWER1 = 0)
		    {
			SEND_STRING dvProjA,'(PWR1)'
			WAIT 25
			{
			    RUN1 = 1
			}
		    }
		    IF(PROJ_POWER2 = 0)
		    {
			SEND_STRING dvProjB,'(PWR1)'
			WAIT 25
			{
			    RUN2 = 1
			}
		    }
		}
		ACTIVE(Proj_Control = 'POF'):
		{
		    
		    SEND_STRING dvProjB,'(PWR0)'
		    SEND_STRING dvProjA,'(PWR0)'
		    RUN1 = 0
		    RUN2 = 0
		}
	    }
	}
    }
}

DEFINE_CALL 'Proj Control'(integer Proj_Num, char Proj_Control[10]) //Projector Control Sub.
{
    LOCAL_VAR CHAR CMD[10]
    DISPLAY = Proj_Num
    SELECT
    {
	ACTIVE(Proj_Control = 'VID1'):
	{
	    //SEND_STRING dvProjB,'(SRC2)'
	    CMD = '(SRC2)' 
	}
	ACTIVE(Proj_Control = 'VID2'):
	{
	    //SEND_STRING dvProjB,'(SRC3)'
	    CMD = '(SRC3)'
	}
	ACTIVE(Proj_Control = 'VID3'):
	{
	    //SEND_STRING dvProjB,'(SRC4)'
	    CMD = '(SRC4)'
	}
	ACTIVE(Proj_Control = 'RGB1'):
	{
	    //SEND_STRING dvProjB,"'(SRC0)'"
	    CMD = '(SRC0)'
	}
	ACTIVE(Proj_Control = 'RGB2'): 
	{
	    //SEND_STRING dvProjB,"'(SRC1)'"
	    CMD = '(SRC1)'
	}
	ACTIVE(Proj_Control = 'RGB3'):
	{
	    //SEND_STRING dvProjB,"'(SRC5)'"
	    CMD = '(SRC5)'
	}
    }
    SELECT
    {
	ACTIVE(Proj_Num = 1):
	{
	    SEND_STRING dvProjA,CMD
	}
	ACTIVE(Proj_Num = 2):
	{
	    SEND_STRING dvProjB,CMD
	}
	ACTIVE(Proj_Num = 3):
	{
	    SEND_STRING dvProjA,CMD
	    SEND_STRING dvProjB,CMD
	}
    }
}

DEFINE_CALL 'Scaler'(integer nIn,integer nOut)
{
    send_string dvScaler,"itoa(nIn),'&'"	//Video Only
    SEND_STRING 0:1:0,"'Scaler in = ',itoa(nIn),13"
}
DEFINE_CALL 'System Off'
{
    Call 'Proj Power'(3,'POF')
    off[Relay,PowerRelay]
    PULSE[DvCombo,2]	//Stop VCR/DVD.
    AUDIA_SetVolumeFn (1, AUDIA_VOL_MUTE)
    AUDIA_MatchVolumeLvl (2,1)      // Example: If this was a stereo pair
    AUDIA_MatchVolumeLvl (3,1)      // Example: If this was a stereo pair
    RightProjPwrStatus = 0
    LeftProjPwrStatus = 0
    
}
(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START
RightProjPwrStatus = 0
LeftProjPwrStatus = 0
FOR (COUNT=0 ; COUNT<70 ; COUNT++)
{
    TimeArray[Count] = 1000
}
TIMELINE_CREATE(TL1, TimeArray, 61, TIMELINE_RELATIVE, TIMELINE_REPEAT) 
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT
DATA_EVENT[dvAudia1]	
{
    Online:
    {
	SEND_COMMAND dvAudia1,"'SET BAUD 38400,8,N,1'"
	Wait 10
	{
	    (*-- Biamp Parms (Lvl,Dev,VolCmd,MuteCmd,Min,Max) ---------*)
	    AUDIA_AssignVolumeParms (1, dvAUDIA1, 'SET 2 OUTLVL 12 1 ', 'SET 2 OUTMUTE 12 1 ', 0, 1120)
	    AUDIA_AssignVolumeParms (2, dvAUDIA1, 'SET 2 OUTLVL 12 2 ', 'SET 2 OUTMUTE 12 2 ', 0, 1120)
	    AUDIA_AssignVolumeParms (3, dvAUDIA1, 'SET 2 OUTLVL 12 6 ', 'SET 2 OUTMUTE 12 6 ', 0, 1120)
	    
	}
    }
}
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
DATA_EVENT[dvProjA]
{
    Online:
    {
	SEND_COMMAND data.device,"'SET BAUD 19200,8,N,1'" //Baud Rate of the Proj
	PROJ_POWER1 = 0
	
    }
     STRING:
    {
             
        LOCAL_VAR X
        PROJ_BUFFER1 = DATA.TEXT
        X = LENGTH_STRING(PROJ_BUFFER1)
        IF(X > 2)
        {
            SELECT
            {
                ACTIVE (MID_STRING(PROJ_BUFFER1,5,1) = '0'):PROJ_POWER1 = 0 //OFF
                ACTIVE (MID_STRING(PROJ_BUFFER1,5,1) = '1'):PROJ_POWER1 = 1 //ON
	    }
            SET_LENGTH_STRING(PROJ_BUFFER1,0)
            PROJ_BUFFER1 = '' 
	}
    }
}
DATA_EVENT[dvProjB]
{
    Online:
    {
	SEND_COMMAND data.device,"'SET BAUD 19200,8,N,1'" //Baud Rate of the Proj
	PROJ_POWER2 = 0
    }
     STRING:
    {
             
        LOCAL_VAR X
        PROJ_BUFFER2 = DATA.TEXT
        X = LENGTH_STRING(PROJ_BUFFER2)
        IF(X > 2)
        {
            SELECT
            {
                ACTIVE (MID_STRING(PROJ_BUFFER2,5,1) = '0'):PROJ_POWER2 = 0 //OFF
                ACTIVE (MID_STRING(PROJ_BUFFER2,5,1) = '1'):PROJ_POWER2 = 1 //ON
	    }
            SET_LENGTH_STRING(PROJ_BUFFER2,0)
            PROJ_BUFFER2 = '' 
	}
    }
}
DATA_EVENT[dvScaler]
{
    Online:
    {
	send_command dvScaler,"'SET BAUD 9600,8,N,1'"
    }
}
BUTTON_EVENT[dvTp,nSrcSelects]
{
    Push:
    {
	On[Relay,PowerRelay]
	SWITCH(get_last(nSrcSelects))
	{
	    Case 1:
	    {
		nCurrentSource = nDvd
	    }
	    Case 2:
	    {
		nCurrentSource = nVCR
	    }
	    Case 3:
	    {
		nCurrentSource = nPC
	    }
	}
    }
}
button_event[dvTP,nBtnDVDMisc]	
{				
    push:
    {
	STACK_VAR integer nDvdIrChan
	to[dvTp,button.input.channel]
       switch(get_last(nBtnDVDMisc))
	{
	    case 1: //Up Arrow
	    {	 
		nDvdIrChan = 45
	    }
	    case 2: //Down Arrow
	    {	 
		nDvdIrChan = 46
	    }
	    case 3: //Left Arrow
	    {	 
		nDvdIrChan = 47
	    }
	    case 4: //Right Arrow
	    {	 
		nDvdIrChan = 48
	    }
	    case 5: //Enter
	    {	 
		nDvdIrChan = 49
	    }
	    case 6: //Menu
	    {	 
		nDvdIrChan = 44
	    }
	    case 7: //Main
	    {	 
		nDvdIrChan = 54
	    }
	    case 8:  //Display
	    {	 
		nDvdIrChan = 58
	    } 
	    case 9:  //Return
	    {	 
		nDvdIrChan = 54
	    } 
	}
    }
}

BUTTON_EVENT[dvTp,nBtnDest]	//Select Left or Right Proj
{
    Push:
    {
	send_string 0:1:0,"'this is button.input ',itoa(get_last(nBtnDest)),13,10"
	Switch (get_last(nBtnDest))
	{
	    Case 1:	//Left Proj
	    {
		IF(PROJ_POWER1 = 0)
		{
		    CALL 'Proj Power'(nLeft,'PON')
		}
		WAIT_UNTIL (RUN1 = 1)
		{
		    SWITCH (nCurrentSource)
		    {
			CASE nDvd:
			{
			    Call 'Scaler'(2,1)
			    Call 'Proj Control'(nLeft,'RGB1')
			    Pulse[DvCombo,114]	//Select the DVD Side of Combo Deck
			    //Need to call the Nexia for audio
			}
			Case nVCR:
			{
			    Call 'Scaler'(1,1)
			    Call 'Proj Control'(nLeft,'RGB1')
			    Pulse[DvCombo,113]	//Select the VCR Side of Combo Deck
			    //Need to call the Nexia for audio
			}
			Case nPC:
			{
			    Call 'Proj Control'(nLeft,'RGB3')
			    //Need to call the Nexia for audio
			}
		    }
		}
	    }
	    Case 2:	//Right Proj
	    {
		IF(PROJ_POWER2 = 0)
		{
		    CALL 'Proj Power'(nRight,'PON')
		}
		WAIT_UNTIL (RUN2 = 1)
		{
		    SWITCH (nCurrentSource)
		    {
			CASE nDvd:
			{
			    Call 'Scaler'(2,1)
			    Call 'Proj Control'(nRight,'RGB1')
			    Pulse[DvCombo,114]	//Select the DVD Side of Combo Deck
			}
			Case nVCR:
			{
			    Call 'Scaler'(1,1)
			    Call 'Proj Control'(nRight,'RGB1')
			    Pulse[DvCombo,113]	//Select the VCR Side of Combo Deck
			}
			Case nPC:
			{
			    Call 'Proj Control'(nRight,'RGB3')
			}
		    }
		}
	    }
	    Case 3:	//Both Projectors
	    {
		IF(PROJ_POWER1 = 0)
		{
		    CALL 'Proj Power'(nLeft,'PON')
		}
		IF(PROJ_POWER2 = 0)
		{
		    CALL 'Proj Power'(nRight,'PON')
		}
		WAIT_UNTIL((RUN1 = 1) && (RUN2 = 1))
		{
		    SWITCH (nCurrentSource)
		    {
			CASE nDvd:
			{
			    Call 'Scaler'(2,1)
			    Call 'Proj Control'(3,'RGB1')
			    Pulse[DvCombo,114]	//Select the DVD Side of Combo Deck
			}
			Case nVCR:
			{
			    Call 'Scaler'(1,1)
			    Call 'Proj Control'(3,'RGB1')
			    Pulse[DvCombo,113]	//Select the VCR Side of Combo Deck
			}
			Case nPC:
			{
			    Call 'Proj Control'(3,'RGB3')
			}
		    }
		}
	    }
	}
    }
}
BUTTON_EVENT[dvTp,nBtnLeftProjAdvance]	//99 - 103
{
    Push:
    {
	SEND_STRING 0:1:0,"'This button does not switch the Scaler',13,10"
	SWITCH(get_last(nBtnLeftProjAdvance))
	{
	    Case 1:	//Power On
	    {
		Call 'Proj Power'(nLeft,'PON')
		
	    }
	    Case 2:	//Power Off
	    {
		Call 'Proj Power'(nLeft,'POF')
		
	    }
	    Case 3:	//VCR Input	
	    {
		Call 'Proj Control'(nLeft,'RGB1')
	    }
	    Case 4:	//DVD Input
	    {
		Call 'Proj Control'(nLeft,'RGB1')
	    }
	    Case 5:	//PC Input
	    {	
		Call 'Proj Control'(nLeft,'RGB2')
	    }
	}
    }
}
BUTTON_EVENT[dvTp,nBtnRightProjAdvance]	//94 - 98
{
    Push:
    {
	SEND_STRING 0:1:0,"'This button does not switch the Scaler',13,10"
	SWITCH(get_last(nBtnRightProjAdvance))
	{
	    Case 1:	//Power On
	    {
		Call 'Proj Power'(nRight,'PON')
		RightProjPwrStatus =1
	    }
	    Case 2:	//Power Off
	    {
		Call 'Proj Power'(nRight,'POF')
		RightProjPwrStatus = 0
	    }
	    Case 3:	//VCR Input	
	    {
		Call 'Proj Control'(nRight,'RGB1')
	    }
	    Case 4:	//DVD Input
	    {
		Call 'Proj Control'(nRight,'RGB1')
	    }
	    Case 5:	//PC Input
	    {	
		Call 'Proj Control'(nRight,'RGB2')
	    }
	}
    }
}
BUTTON_EVENT[dvTp,nBtnPwrOff]
{
    Push:
    {
	Call 'System Off'
    }
}
BUTTON_EVENT[dvTp,204]        // Vol Up
BUTTON_EVENT[dvTp,205]        // Vol Down
BUTTON_EVENT[dvTp,206]        // Vol Mute
{
  PUSH :
  { 
    STACK_VAR INTEGER nVolChn
    nVolChn = 1
    SWITCH(BUTTON.INPUT.CHANNEL)
    {
      CASE 204 :    // Vol Up
      {
        IF(uAudiaVol[nVolChn].nMute)
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE_OFF)
        ELSE
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_UP)
      }
      CASE 205 :    // Vol Down
      {
        IF(uAudiaVol[nVolChn].nMute)
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE_OFF)
        ELSE
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_DOWN)
      }
      CASE 206 :    // Vol Mute
      {
        IF(uAudiaVol[nVolChn].nMute)
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE_OFF)
        ELSE
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE)
      }
    }

    AUDIA_MatchVolumeLvl (3,2)      // Example: If this was a stereo pair
  }
  RELEASE :
  {
    STACK_VAR INTEGER nVolChn

    nVolChn = 1
    AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_STOP)
  }
  HOLD[3,REPEAT] :
  {
    STACK_VAR INTEGER nVolChn

    nVolChn = 1
    SWITCH(BUTTON.INPUT.CHANNEL)
    {
      CASE 204 :    // Vol Up
      {
        AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_UP)
      }
      CASE 205 :    // Vol Down
      {
        AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_DOWN)
      }
    }

//    AUDIA_MatchVolumeLvl (2,1)      // Example: If this was a stereo pair
  }
}


BUTTON_EVENT[dvTp,214]        // Vol Up
BUTTON_EVENT[dvTp,215]        // Vol Down
BUTTON_EVENT[dvTp,216]        // Vol Mute
{
  PUSH :
  { 
    STACK_VAR INTEGER nVolChn
    nVolChn = 1
    SWITCH(BUTTON.INPUT.CHANNEL)
    {
      CASE 214 :    // Vol Up
      {
        IF(uAudiaVol[nVolChn].nMute)
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE_OFF)
        ELSE
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_UP)
      }
      CASE 215 :    // Vol Down
      {
        IF(uAudiaVol[nVolChn].nMute)
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE_OFF)
        ELSE
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_DOWN)
      }
      CASE 216 :    // Vol Mute
      {
        IF(uAudiaVol[nVolChn].nMute)
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE_OFF)
        ELSE
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE)
      }
    }

    AUDIA_MatchVolumeLvl (2,1)      // Example: If this was a stereo pair
    AUDIA_MatchVolumeLvl (3,1)      // Example: If this was a stereo pair
  }
  RELEASE :
  {
    STACK_VAR INTEGER nVolChn

    nVolChn = 1
    AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_STOP)
  }
  HOLD[3,REPEAT] :
  {
    STACK_VAR INTEGER nVolChn

    nVolChn = 1
    SWITCH(BUTTON.INPUT.CHANNEL)
    {
      CASE 214 :    // Vol Up
      {
        AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_UP)
      }
      CASE 215 :    // Vol Down
      {
        AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_DOWN)
      }
    }

    AUDIA_MatchVolumeLvl (2,1)      // Example: If this was a stereo pair
    AUDIA_MatchVolumeLvl (3,1)      // Example: If this was a stereo pair
  }
}

DEFINE_PROGRAM
If((time_to_hour(time) = 21)&&(time_to_minute(time) = 00)&&(nTimeBlock = 0))
{
    send_string 0:1:0,"'the time is ',time,13,10"
    nTimeBlock = 1		//Keeps this from running over and over for the whole minute.
    TIMELINE_CREATE(TL1, TimeArray, 61, TIMELINE_RELATIVE, TIMELINE_ONCE) 
    wait 620			//Need to wait until the minute is over.
	nTimeBlock = 0	
}
SYSTEM_CALL 'VCR1'(DvCombo,dvTpVcr_Dvd,1,2,3,4,5,6,7,0,0)
SYSTEM_CALL 'DVD1'(dvCombo,dvTpVcr_Dvd,11,12,13,14,15,16,17,0)
SEND_LEVEL dvTp,1,AUDIA_GetBgLvl(1)
SEND_LEVEL dvTp,2,AUDIA_GetBgLvl(2) 
[dvTp,214] = (uAudiaVol[1].nVolRamp = AUDIA_VOL_UP)
[dvTp,215] = (uAudiaVol[1].nVolRamp = AUDIA_VOL_DOWN)
[dvTp,216] = (uAudiaVol[1].nMute)

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

