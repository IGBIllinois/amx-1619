PROGRAM_NAME='Conf 612 & 614'
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE
dvAudia1 	= 5001:1:0	//Biamp Nexia CS Straight Thru Cable 38400 Baud.				
dvMatrix  	= 5001:2:0	//Extron 450
dvProj612   	= 5001:3:0	//Proxima C450 
dvProj614Rt   	= 5001:4:0	//Proxima C450 Right side as looking at Screen
dvProj614Lt   	= 5001:5:0	//Proxima C450 Left side as looking at Screen
dvScaler614 	= 5001:6:0	//Extron DVS304A
dvScaler612 	= 5001:7:0	//Extron DVS304A
dvRelay	  	= 5001:8:0	//Relay for Rack Power.
dvCombo614  	= 5001:9:0	//Panasonic AG-VP320 VCR/DVD
dvCombo612  	= 5001:10:0	//Panasonic AG-VP320 VCR/DVD
dvTp614	  	= 10001:1:0   	//MVP-8400 in the room with 1 Projectors.
dvTp612	  	= 10005:1:0   	//MVP-8400 in the room with 2 Projector.
dvTp614Combo 	= 10001:2:0   	//MVP-8400 port 2 to control Combo Deck
dvTp612Combo 	= 10005:2:0   	//MVP-8400 port 2 to control Combo Deck

//Dvtp1a = 10001:1:0
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT
dev dvTpBoth[] = 
{
    dvTp612,dvTp614
}
dev dvTpCombos[] = 
{
    dvTp612Combo,dvTp614Combo
}
integer PowerRelay1 = 1
integer PowerRelay2 = 2
integer PowerRelay3 = 3
integer PowerRelay4 = 4

integer ProjCenter612 = 3
integer ProjRight614 = 4
integer ProjLeft614 = 5
integer Proj614comb = 6

integer nDvd = 1
integer nVCR = 2
integer nPC = 3
integer nRight = 5
integer nLeft = 6
integer nCombined = 1
integer CombineRooms = 41
INTEGER TL1 = 1
INTEGER TL2 = 2
integer OffTime = 60	//Used to count down the time to turn the system off.
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

integer nRgbPortBtn[]=		//For selecting the RGB floor jacks
{
    50,	//612 Right
    51,	//612 Left
    52,	//614 Right
    53	//614 Left
}
integer nRoomMode[]= 
{
    12,	//Normal Mode
    13,	//Expanded Mode.
    14	//UnCombine Rooms.
}
integer nBtnDest[] = 
{
    1,	//Left Proj 614
    2,	//Right Proj 614
    3	//Both
}
integer nBtnPwrOff[] = 
{
    4	//This is the YES button.
}
integer nBtnPodiumLoc[]=
{
    5,	//Right side of room.
    6	//Left side of room.
}
INTEGER nSrcSelects[] = 
{
    91,	//DVD
    92,	//VCR
    93	//Laptop
}
integer nProjAdvance[] = 
{
    99,		//Proj Power ON	612
    100,	//Proj Power Off 612
    101,	//Proj Power ON	614 Left
    102,	//Proj Power OFF 614 Left 
    103,	//Proj Power ON	614 right 
    104,	//Proj Power OFF 614 right 
    105,	//Proj Power Blank 612
    106,	//Proj Power Blank Left
    107 	//Proj Power Blank Right

}

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE
dev dvProj[] = 
{
    dvProj612,dvProj614Lt,dvProj614Rt
}
dev dvBothCombos[] =
{
    dvCombo612,dvCombo614
}
integer SystemPower
integer nCurrentSource[2]	//1st location is 612, 2nd is 614.
integer nPodiumLocation[2]
integer PowerState[2]		//Relays.
ProjPowerStatus[3]
integer RoomCombineMode
LONG TimeArray[100] 
INTEGER COUNT
INTEGER nTimeBlock
INTEGER nCheckPwr[3]
INTEGER nProjPwrStatus[3]
CenterProjstring[100]	//612 Only Projector
RightProjstring[100]	//614 right Projector
LeftProjstring[100]	//614 Left Projector

PROJ_POWER1
PROJ_POWER2
PROJ_POWER3
PROJ_BUFFER1[10]
PROJ_BUFFER2[10]
PROJ_BUFFER3[10]
DISPLAY
RUN1
RUN2
RUN3

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
DEFINE_CALL 'Power Relay'(integer Relay,integer nRoom)	//1 = 612 2 = 614
{
    PowerState[nRoom] = Relay
    If((PowerState[1] = 0) && (PowerState[2] = 0))
    {
	SEND_STRING 0:1:0,"'Power Relays OFF',13,10"
	OFF[dvRelay,PowerRelay1]
	OFF[dvRelay,PowerRelay2]
	OFF[dvRelay,PowerRelay3]
	OFF[dvRelay,PowerRelay4]
    }
    If((PowerState[1] = 1) || (PowerState[2] = 1))
    {
	SEND_STRING 0:1:0,"'Should have turned Power Relays ON',13,10"
	If(![dvRelay,PowerRelay1])
	{
	    SEND_STRING 0:1:0,"'Power Relays ON',13,10"
	    ON[dvRelay,PowerRelay1]
	    ON[dvRelay,PowerRelay2]
	    ON[dvRelay,PowerRelay3]
	    ON[dvRelay,PowerRelay4]
	    Wait 30
	    {
		Pulse[dvCombo612,9]
		Pulse[dvCombo614,9]
	    }
	}
    }
}
DEFINE_CALL 'Proj Power'(integer Proj_Num, char Proj_Control[10]) //Projector Control Sub.
{
    SELECT
    {
	ACTIVE(Proj_Num = 3):			//612_proj
	{
	    SELECT
	    {
		ACTIVE(Proj_Control = 'PON'):
		{
		    IF(PROJ_POWER1 = 0)
		    {
			SEND_STRING dvProj612,'(PWR1)'
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
			SEND_STRING dvProj612,'(PWR0)'
			RUN1 = 0
		    }
		}
	    }
	}
	ACTIVE(Proj_Num = 4):			//614R
	{
	    SELECT
	    {
		ACTIVE(Proj_Control = 'PON'):
		{
		    IF(PROJ_POWER2 = 0)
		    {
			SEND_STRING dvProj614Rt,'(PWR1)'
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
			SEND_STRING dvProj614Rt,'(PWR0)'
			RUN2 = 0
		    }
		}
	    }
	}
	ACTIVE(Proj_Num = 5):			//614left
	{
	    SELECT
	    {
		ACTIVE(Proj_Control = 'PON'):
		{
		    IF(PROJ_POWER3 = 0)
		    {
			SEND_STRING dvProj614Lt,'(PWR1)'
			WAIT 25
			{
			    RUN3 = 1
			}
		    }
		}
		ACTIVE(Proj_Control = 'POF'):
		{
		    IF(PROJ_POWER3 = 1)
		    {
			SEND_STRING dvProj614Lt,'(PWR0)'
			RUN3 = 0
		    }
		}
	    }
	}
	ACTIVE(Proj_Num = 6):			//BOTH
	{
	    SELECT
	    {
		ACTIVE(Proj_Control = 'PON'):
		{
		    IF(PROJ_POWER2 = 0)
		    {
			SEND_STRING dvProj614Rt,'(PWR1)'
			WAIT 25
			{
			    RUN2 = 1
			}
		    }
		    IF(PROJ_POWER3 = 0)
		    {
			SEND_STRING dvProj614Lt,'(PWR1)'
			WAIT 25
			{
			    RUN3 = 1
			}
		    }
		}
		ACTIVE(Proj_Control = 'POF'):
		{
		    
		    SEND_STRING dvProj614Rt,'(PWR0)'
		    SEND_STRING dvProj614Lt,'(PWR0)'
		    RUN2 = 0
		    RUN3 = 0
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
	ACTIVE(Proj_Num = 3):
	{
	    SEND_STRING dvProj614Rt,CMD
	}
	ACTIVE(Proj_Num = 4):
	{
	    SEND_STRING dvProj614Rt,CMD
	}
	ACTIVE(Proj_Num = 5):
	{
	    SEND_STRING dvProj614Lt,CMD
	}
	ACTIVE(Proj_Num = 6):
	{
	    SEND_STRING dvProj614Rt,CMD
	    SEND_STRING dvProj614Lt,CMD
	}
    }
}

DEFINE_CALL 'Scaler 612'(integer nIn,integer nOut)
{
    //send_string dvScaler612,"itoa(nIn),'&'"	//Video Only
    Call 'QUEUE ADD'(dvScaler612,"itoa(nIn),'&'",5,0)
    //send_string dvScaler612,"itoa(nIn),'*',itoa(nOut),'!'"	//Audio and Video
    SEND_STRING 0:1:0,"'dvScaler612 IN ',itoa(nIn),' to OUT ',itoa(nOut),13,10"
}
DEFINE_CALL 'Scaler 614'(integer nIn, integer nOut)
{
    Call 'QUEUE ADD'(dvScaler614,"itoa(nIn),'&'",5,0)
    SEND_STRING 0:1:0,"'dvScaler614 IN ',itoa(nIn),' to OUT ',itoa(nOut),13,10"
}
DEFINE_CALL 'Matrix'(integer nIn,integer nOut,Char Clvl)	//! = A&V, & = Video, $ = Audio
{
    Call 'QUEUE ADD'(dvMatrix,"itoa(nIn),'*',itoa(nOut),cLvl",5,0)
    //Call 'QUEUE ADD'(dvMatrix,"itoa(nIn),'*',itoa(nOut),'!'",5,0)
    //send_string dvMatrix,"itoa(nIn),'*',itoa(nOut),'!'"	//Audio and Video
    SEND_STRING 0:1:0,"'dvMatrix IN ',itoa(nIn),' to OUT ',itoa(nOut),13,10"
}
DEFINE_CALL 'System Off'(Char nRoom[3])
{
    If(nRoom = '612')
    {
	Call 'Proj Power'(ProjCenter612,'POF')
	AUDIA_SetVolumeFn (2, AUDIA_VOL_MUTE)
	AUDIA_SetVolumeFn (6, AUDIA_VOL_MUTE)
	Call'Power Relay'(0,1)
    }
    If(nRoom = '614')
    {
	Call 'Proj Power'(ProjLeft614,'POF')
	Call 'Proj Power'(ProjRight614,'POF')
	AUDIA_SetVolumeFn (1, AUDIA_VOL_MUTE)
	AUDIA_SetVolumeFn (5, AUDIA_VOL_MUTE)
	Call'Power Relay'(0,2)
    }

    Send_string 0:1:0,"'Need to MUTE the AUDIO',13,10"
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
//SEND_STRING dvAudia1,"'SET 2 RTRMUTEXP 13 1 3 0',10" //SETS ROUTER INSTANCE 13 INPUT 1 TO OUTPUT 2 

DEFINE_START
PowerState[1] = 0
PowerState[2] = 0
FOR (COUNT=0 ; COUNT<70 ; COUNT++)
{
    TimeArray[Count] = 1000
}
TIMELINE_CREATE(TL2, TimeArray, 50, TIMELINE_RELATIVE, TIMELINE_REPEAT) 
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
		(* add a channel for stereo pair mrc Z1 right and Left 614*)
	    AUDIA_AssignVolumeParms (1, dvAUDIA1, 'SET 2 INPLVL 22 5 ', 'SET 2 INPMUTE 22 5 ', 0, 1120)
	    AUDIA_AssignVolumeParms (5, dvAUDIA1, 'SET 2 INPLVL 22 6 ', 'SET 2 INPMUTE 22 6 ', 0, 1120)
		(* add a channel for stereo pair mrc Z2 right and left 612*)
	    AUDIA_AssignVolumeParms (2, dvAUDIA1, 'SET 2 INPLVL 22 9 ', 'SET 2 INPMUTE 22 9 ', 0, 1120)
	    AUDIA_AssignVolumeParms (6, dvAUDIA1, 'SET 2 INPLVL 22 10 ', 'SET 2 INPMUTE 22 10 ', 0, 1120)
		(*mic 612*)
	    AUDIA_AssignVolumeParms (3, dvAUDIA1, 'SET 2 INPLVL 22 1 ', 'SET 2 INPMUTE 22 1 ', 0, 1120)
		(*mic 614*)
	    AUDIA_AssignVolumeParms (4, dvAUDIA1, 'SET 2 INPLVL 22 2 ', 'SET 2 INPMUTE 22 2 ', 0, 1120)
	    
	}
    }
}

DATA_EVENT[dvMatrix]
{
    Online:
    {
	SEND_COMMAND dvMatrix,"'SET BAUD 9600,8,N,1'"
    }
}

DATA_EVENT[dvScaler612]
{
    Online:
    {
	SEND_COMMAND data.device,"'SET BAUD 9600,8,N,1'"
    }
}
DATA_EVENT[dvScaler614]
{
    Online:
    {
	SEND_COMMAND data.device,"'SET BAUD 9600,8,N,1'"
    }
}
DATA_EVENT[dvProj612]
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
DATA_EVENT[dvProj614Lt]
{
    Online:
    {
	SEND_COMMAND data.device,"'SET BAUD 19200,8,N,1'" //Baud Rate of the Proj
	PROJ_POWER2 = 0
	
    }
     STRING:
    {
             
        LOCAL_VAR X
        PROJ_BUFFER3 = DATA.TEXT
        X = LENGTH_STRING(PROJ_BUFFER3)
        IF(X > 2)
        {
            SELECT
            {
                ACTIVE (MID_STRING(PROJ_BUFFER3,5,1) = '0'):PROJ_POWER3 = 0 //OFF
                ACTIVE (MID_STRING(PROJ_BUFFER3,5,1) = '1'):PROJ_POWER3 = 1 //ON
	    }
            SET_LENGTH_STRING(PROJ_BUFFER3,0)
            PROJ_BUFFER3 = '' 
	}
    }
}
DATA_EVENT[dvProj614Rt]
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
DATA_EVENT[dvTpBoth]
{
    Online:
	SEND_COMMAND data.device,"'Page-Splash'"
}

BUTTON_EVENT[dvTpBoth,nProjAdvance]
{
    Push:
    {
	switch (get_last(nProjAdvance))
	{
	    Case 1:
	    {
		Call 'Proj Control'(ProjCenter612,'PON')
	    }
	    Case 2:
	    {
		Call 'Proj Control'(ProjCenter612,'POF')
	    }
	    Case 3:
	    {
		Call 'Proj Control'(ProjRight614,'PON')
	    }
	    Case 4:
	    {
		Call 'Proj Control'(ProjRight614,'POF')
	    }
	    Case 5:
	    {
		Call 'Proj Control'(ProjLeft614,'PON')
	    }
	    Case 6:
	    {
		Call 'Proj Control'(ProjLeft614,'POF')
	    }
	    Case 7:
	    {
		[dvTpBoth,105] = ![dvTpBoth,105]
		IF([dvTpBoth,105])
		    SEND_STRING dvProj612,'(BLK1)'
		ELSE
		    SEND_STRING dvProj612,'(BLK0)'
	    }
	    Case 8:
	    {
		[dvTpBoth,106] = ![dvTpBoth,106]
		IF([dvTpBoth,106])
		    SEND_STRING dvProj614Lt,'(BLK1)'
		ELSE
		    SEND_STRING dvProj614Lt,'(BLK0)'
	    }
	    Case 9:
	    {
		[dvTpBoth,107] = ![dvTpBoth,107]
		IF([dvTpBoth,107])
		    SEND_STRING dvProj614Rt,'(BLK1)'
		ELSE
		    SEND_STRING dvProj614Rt,'(BLK0)'
	    }
	}
    }
}

button_event[dvTpCombos,nBtnDVDMisc]
{
    push:
    {
	STACK_VAR integer nDvdIrChan
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
	Pulse[dvBothCombos[(get_last(dvTpCombos))],ndvdirchan]
    }
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
BUTTON_EVENT[dvTpBoth,nBtnPodiumLoc]
{
    Push:
    {	
	send_string 0:1:0,"'tp is ',itoa(get_last(dvTpBoth)),13,10"
	//send_string 0:1:0,"'btn is ',itoa(nBtnPodiumLoc),13,10"
	SWITCH(get_last(dvTpBoth))
	{
	    Case 1:	//612
	    {
		Switch (button.input.channel)
		{
		    Case nRight:
		    {
			nPodiumLocation[(get_last(dvTpBoth))] = 3	//3 is the sw input #
		    }
		    Case nLeft:
		    {
			nPodiumLocation[(get_last(dvTpBoth))] = 4	//4 is the sw input #
		    }
		}    
	    }
	    Case 2:	//614
	    {
		Switch (button.input.channel)
		{
		    Case nRight:
		    {
			nPodiumLocation[(get_last(dvTpBoth))] = 1	//1 is the sw input #
		    }
		    Case nLeft:
		    {
			nPodiumLocation[(get_last(dvTpBoth))] = 2	//2 is the sw input #
		    }
		}
	    }
	}
    }
}
BUTTON_EVENT[dvTpBoth,nBtnDest]	//Select Left/Right/Both Projs
{
    Push:
    {
	Switch (get_last(nBtnDest))
	{
	    Case 1:	//Left Proj
	    {
		IF(PROJ_POWER3 = 0)
		{
		    CALL 'Proj Power'(ProjLeft614,'PON')
		}
		WAIT_UNTIL (RUN3 = 1)
		{
		    SWITCH (nCurrentSource[get_last(dvTpBoth)])
		    {
			CASE nDvd:
			{
			    Pulse[dvCombo614,114]	//Select the DVD Side of Combo Deck
			    Call 'Scaler 614'(2,1)
			    Call 'Matrix'(5,3,'!')
			    Call 'Proj Control'(ProjLeft614,'RGB3')
			}
			Case nVCR:
			{
			    Pulse[dvCombo614,113]	//Select the VCR Side of Combo Deck
			    Call 'Scaler 614'(1,1)
			    Call 'Matrix'(5,3,'!')
			    Call 'Proj Control'(ProjLeft614,'RGB3')
			}
			Case nPC:
			{
			    Call 'Proj Control'(ProjLeft614,'RGB3')
			    Call 'Matrix'(nPodiumLocation[2],3,'!')
			}
		    }
		}
	    }
	    Case 2:	//Right Proj
	    {
		IF(PROJ_POWER2 = 0)
		{
		    CALL 'Proj Power'(ProjRight614,'PON')
		}
		WAIT_UNTIL (RUN2 = 1)
		{
		    SWITCH (nCurrentSource[get_last(dvTpBoth)])
		    {
			CASE nDvd:
			{
			    Pulse[dvCombo614,114]	//Select the VCR Side of Combo Deck
			    Call 'Scaler 614'(2,1)
			    Call 'Matrix'(5,2,'&')
			    Call 'Matrix'(5,3,'$')
			    Call 'Proj Control'(ProjRight614,'RGB3')
			}
			Case nVCR:
			{
			    Pulse[dvCombo614,113]	//Select the VCR Side of Combo Deck
			    Call 'Scaler 614'(1,1)
			    Call 'Matrix'(5,2,'&')
			    Call 'Matrix'(5,3,'$')
			    Call 'Proj Control'(ProjRight614,'RGB3')
			}
			Case nPC:
			{
			    Call 'Proj Control'(ProjRight614,'RGB3')
			    Call 'Matrix'(nPodiumLocation[2],2,'&')//VIDEO
			    Call 'Matrix'(nPodiumLocation[2],3,'$')//AUDIO
			}
		    }
		}
	    }
	    Case 3:	//BOTH PROJECTORS)
	    {
		IF(PROJ_POWER2 = 0)
		{
		    CALL 'Proj Power'(ProjRight614,'PON')
		}
		IF(PROJ_POWER3 = 0)
		{
		    CALL 'Proj Power'(ProjLeft614,'PON')
		}
		WAIT_UNTIL((RUN2 = 1) && (RUN3 = 1))
		{
		    SWITCH (nCurrentSource[get_last(dvTpBoth)])
		    {
			CASE nDvd:
			{
			    Call 'Proj Control'(ProjRight614,'RGB3')
			    Call 'Proj Control'(ProjLeft614,'RGB3')
			    Pulse[dvCombo614,114]	//Select the dvd Side of Combo Deck
			    Call 'Scaler 614'(2,1)
			    Call 'Matrix'(5,2,'&')
			    Call 'Matrix'(5,3,'&')
			    Call 'Matrix'(5,3,'$')
			}
			Case nVCR:
			{
			    Call 'Proj Control'(ProjRight614,'RGB3')
			    Call 'Proj Control'(ProjLeft614,'RGB3')
			    Pulse[dvCombo614,113]	//Select the VCR Side of Combo Deck
			    Call 'Scaler 614'(1,1)
			    Call 'Matrix'(5,2,'&')
			    Call 'Matrix'(5,3,'&')
			    Call 'Matrix'(5,3,'$')
			}
			Case nPC:
			{
			    Call 'Proj Control'(ProjRight614,'RGB3')
			    Call 'Proj Control'(ProjLeft614,'RGB3')
			    Call 'Matrix'(nPodiumLocation[2],2,'&')//VIDEO
			    Call 'Matrix'(nPodiumLocation[2],3,'&')//VIDEO
			    Call 'Matrix'(nPodiumLocation[2],3,'$')//AUDIO
			}
		    }
		}
            }			
	}
    }
}
BUTTON_EVENT[dvTpBoth,nSrcSelects]
{
    Push:
    {
	SWITCH(get_last(nSrcSelects))
	{
	    Case 1:	//DVD
	    {
		If (button.input.device.number = 10005)	//Room 612
		{
		    IF(PROJ_POWER1 = 0)
		    {
			CALL 'Proj Power'(ProjCenter612,'PON')
		    }
		    WAIT_UNTIL (RUN1 = 1)
		    {
			Call 'Proj Control'(ProjCenter612,'RGB3')
			Pulse[dvCombo612,114]	//Select the DVD Side of Combo Deck
			Call 'Scaler 612'(2,1)
			Call 'Matrix'(6,1,'!')
		    }
		}
		nCurrentSource[get_last(dvTpBoth)] = nDvd
	    }
	    Case 2:	//VCR
	    {
		If (button.input.device.number = 10005)
		{
		    IF(PROJ_POWER1 = 0)
		    {
			CALL 'Proj Power'(ProjCenter612,'PON')
		    }
		    WAIT_UNTIL (RUN1 = 1)
		    {
			Call 'Proj Control'(ProjCenter612,'RGB3')
			Pulse[dvCombo612,113]	//Select the VCR Side of Combo Deck
			Call 'Scaler 612'(1,1)
			Call 'Matrix'(6,1,'!')
		    }
		    nCurrentSource[get_last(dvTpBoth)] = nVCR
		}
	    }
	    Case 3:	//Laptop
	    {
		If (button.input.device.number = 10005)
		{
		    IF(PROJ_POWER1 = 0)
		    {
			CALL 'Proj Power'(ProjCenter612,'PON')
		    }
		    WAIT_UNTIL (RUN1 = 1)
		    {
			Call 'Proj Control'(ProjCenter612,'RGB3')
			Call 'Matrix'(nPodiumLocation[1],1,'!')
		    }
		}
		nCurrentSource[get_last(dvTpBoth)] = nPC
	    }
	}
    }
}
BUTTON_EVENT[dvTpBoth,nBtnPwrOff]
{
    Push:
    {
	Switch (get_last(dvTpBoth))
	{
	    Case 1:
	    {
		Call 'System Off'('612')
	    }
	    Case 2:
	    {
		Call 'System Off'('614')
	    }
	}
    }
}
BUTTON_EVENT[dvTpBoth,8]	//This is on the Splash page. Basically a big translucent button.
{
    Push:
    {
	Switch (get_last(dvTpBoth))
	{
	    Case 1:
	    {
		Call 'Power Relay'(1,1)
	    }
	    Case 2:
	    {
		Call 'Power Relay'(1,2)
	    }
	}
    }
}

BUTTON_EVENT[dvTp614,nRoomMode]
{
    Push:
    {
	SWITCH(button.input.channel)
	{
	    Case 12:	//Normal
	    {
		RoomCombineMode = 0
		SEND_COMMAND dvTp612,"'PPOF-Room in use'"
		send_string dvAudia1,"'SET 2 RTRMUTEXP 14 1 2 1',10"
		send_string dvAudia1,"'SET 2 RTRMUTEXP 14 1 3 0',10"
		send_string dvAudia1,"'SET 2 RTRMUTEXP 12 1 3 1',10"
		send_string dvAudia1,"'SET 2 RTRMUTEXP 15 1 2 1',10"
		send_string dvAudia1,"'SET 2 RTRMUTEXP 16 1 3 1',10"
	    }
	    Case 13:	//Expanded or Combined
	    {
		If(PowerState[1])	//Other room is on.
		{
		    SEND_COMMAND dvTp614,"'PPON-Room in use'"
		}
		Else
		{
		    SEND_COMMAND dvTp612,"'PPON-Room in use'"
		    send_string dvAudia1,"'SET 2 RTRMUTEXP 14 1 2 1',10"
		    send_string dvAudia1,"'SET 2 RTRMUTEXP 14 1 3 1',10"
		    send_string dvAudia1,"'SET 2 RTRMUTEXP 12 1 3 0',10"
		    send_string dvAudia1,"'SET 2 RTRMUTEXP 15 1 2 0',10"
		    send_string dvAudia1,"'SET 2 RTRMUTEXP 16 1 3 0',10"
		    RoomCombineMode = 1
		}
	    }
	    Case 14:	
	    {
		
	    }
	}
    }
}
BUTTON_EVENT[dvTp614,CombineRooms]// BTN41 //YES - Combine the two rooms
{
    Push:
    {
	RoomCombineMode = 1
	SEND_COMMAND dvTp612,"'PPON-Room in use'"
	send_string dvAudia1,"'SET 2 RTRMUTEXP 14 1 2 1',10"
	send_string dvAudia1,"'SET 2 RTRMUTEXP 14 1 3 1',10"
	send_string dvAudia1,"'SET 2 RTRMUTEXP 12 1 3 0',10"
	send_string dvAudia1,"'SET 2 RTRMUTEXP 15 1 2 0',10"
	send_string dvAudia1,"'SET 2 RTRMUTEXP 16 1 3 0',10"
    }
}
BUTTON_EVENT[dvTp612,43]	//612 wants to override the Expanded mode
{
    Push:
    {
	RoomCombineMode = 0
	SEND_COMMAND dvTp614,"'PPON-Room combine override'"
	SEND_COMMAND dvTp612,"'PPOF-Room in use'"
	send_string dvAudia1,"'SET 2 RTRMUTEXP 14 1 2 1',10"
	send_string dvAudia1,"'SET 2 RTRMUTEXP 14 1 3 0',10"
	send_string dvAudia1,"'SET 2 RTRMUTEXP 12 1 3 1',10"
	send_string dvAudia1,"'SET 2 RTRMUTEXP 15 1 2 1',10"
	send_string dvAudia1,"'SET 2 RTRMUTEXP 16 1 3 1',10"
    }
}

(*-- Level 1 ----------------------------------------------*)

BUTTON_EVENT[dvTp614,204]        // Vol Up
BUTTON_EVENT[dvTp614,205]        // Vol Down
BUTTON_EVENT[dvTp614,206]        // Vol Mute
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
		{
		    AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE_OFF)
		}
		ELSE
		{
		    AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_UP)
		}
	    }
	    CASE 205 :    // Vol Down
	    {
		IF(uAudiaVol[nVolChn].nMute)
		{
		    AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE_OFF)
		}
		ELSE
		{
		    AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_DOWN)
		}
	    }
	    CASE 206 :    // Vol Mute
	    {
		IF(uAudiaVol[nVolChn].nMute)
		{
		    AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE_OFF)
		}
		ELSE
		{
		    AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE)
		}
	    }
	}
	AUDIA_MatchVolumeLvl (5,1)      // Example: If this was a stereo pair
    }
    RELEASE :
    {
	AUDIA_SetVolumeFn (1, AUDIA_VOL_STOP)
    }
    HOLD[3,REPEAT] :
    {
	AUDIA_MatchVolumeLvl (5,1)      // Example: If this was a stereo pair
    }
}


BUTTON_EVENT[dvTp612,214]        // Vol Up
BUTTON_EVENT[dvTp612,215]        // Vol Down
BUTTON_EVENT[dvTp612,216]        // Vol Mute
{
  PUSH :
  { 
    STACK_VAR INTEGER nVolChn
    nVolChn = 2
    SWITCH(BUTTON.INPUT.CHANNEL)
    {
      CASE 214 :    // Vol Up
      {
        IF(uAudiaVol[nVolChn].nMute)
	{
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE_OFF)
	}
        ELSE
	{
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_UP)
	}
      }
      CASE 215 :    // Vol Down
      {
        IF(uAudiaVol[nVolChn].nMute)
	{
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE_OFF)
	}
        ELSE
	{
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_DOWN)
	}
      }
      CASE 216 :    // Vol Mute
      {
        IF(uAudiaVol[nVolChn].nMute)
	{
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE_OFF)
	}
        ELSE
	{
          AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE)
	}
      }
    }
	AUDIA_MatchVolumeLvl (6,2)      // Example: If this was a stereo pair
    }
    RELEASE :
    {
	AUDIA_SetVolumeFn (2, AUDIA_VOL_STOP)
    }
    HOLD[3,REPEAT] :
    {
	AUDIA_MatchVolumeLvl (6,2)      // Example: If this was a stereo pair
    }
}






TIMELINE_EVENT[TL1] // capture all events for Timeline 1 
{ 
    send_string 0:1:0,"itoa(OffTime-timeline.sequence),13,10"
    send_command dvTp612,"'@TXT',2,itoa(OffTime-timeline.sequence)"
    send_command dvTp614,"'@TXT',2,itoa(OffTime-timeline.sequence)"
    Send_command dvTp612,"'beep'"
    Send_command dvTp614,"'beep'"
    switch(Timeline.Sequence) // which time was it? 
    { 
	case 1: 
	    {
		SEND_COMMAND dvTp612,"'Wake'"
		SEND_COMMAND dvTp614,"'Wake'"
		SEND_COMMAND dvTp612,"'PPON-Shutdown Warning'"
		SEND_COMMAND dvTp614,"'PPON-Shutdown Warning'"
	    } 
	case 2: { } 
	case 3: { } 
	case 4: { } 
	case 60: 
		{
		    timeline_kill(tl1)
		    Call 'System Off' ('612')
		    Call 'System Off' ('614')
		    SEND_COMMAND dvTp612,"'PPOF-Shutdown Warning'"
		    SEND_COMMAND dvTp614,"'PPOF-Shutdown Warning'"
		    SEND_COMMAND dvTp612,"'Page-Splash'"
		    SEND_COMMAND dvTp614,"'Page-Splash'"
		    SEND_COMMAND dvTp612,"'Sleep'"
		    SEND_COMMAND dvTp614,"'Sleep'"
		 } 
	
    } 
} 

TIMELINE_EVENT[TL2] // capture all events for Timeline 2
{ 
    switch(Timeline.Sequence) // which time was it? 
    { 
	case 1: 
	    {
		nCheckPwr[1] = 1
		SEND_STRING dvProj612,"'(PWR?)'"
	    } 
	case 2: { } 
	case 3:
	    {
		nCheckPwr[2] = 1
		SEND_STRING dvProj614Lt,"'(PWR?)'"
	    } 
	case 4:
	    {
		nCheckPwr[3] = 1
		SEND_STRING dvProj614Rt,"'(PWR?)'"
	    } 
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

SYSTEM_CALL [1]'VCR1'(dvCombo612,dvTp612Combo,1,2,3,4,5,6,7,0,0)
SYSTEM_CALL [2]'VCR1'(dvCombo614,dvTp614Combo,1,2,3,4,5,6,7,0,0)

[dvTp612,214] = (uAudiaVol[2].nVolRamp = AUDIA_VOL_UP)
[dvTp612,215] = (uAudiaVol[2].nVolRamp = AUDIA_VOL_DOWN)
[dvTp612,216] = (uAudiaVol[2].nMute)
[dvTp614,204] = (uAudiaVol[1].nVolRamp = AUDIA_VOL_UP)
[dvTp614,205] = (uAudiaVol[1].nVolRamp = AUDIA_VOL_DOWN)
[dvTp614,206] = (uAudiaVol[1].nMute)
SEND_LEVEL dvTp614,1,AUDIA_GetBgLvl(1)
SEND_LEVEL dvTp612,2,AUDIA_GetBgLvl(2)
 

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

