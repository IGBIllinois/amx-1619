PROGRAM_NAME='Director'
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE
dvAudia1 = 5001:1:0     //Biamp Nexia CS 
dvLcdRight = 5001:3:0   //Samsung LCD Right side of Room(I)
dvProj     = 5001:5:0   //Proxima Projector C450        (G)
dvLcdLeft  = 5001:4:0   //Samsung LCD Left side of Room (H)
dvRGBRtr   = 5001:2:0   //Extron 450 RGB Switcher       (F)

dvRackPower = 5001:8:0  //Relay 1 is for the Seq Power Strip

dvTp       = 10001:1:0  //MVP8400 Touchpanel

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT
PwrOff = 0 // Constants for TV signals
PwrOn = 1
Projector  = 1	//Destination
RightPanel = 2	//Destination
LeftPanel  = 3	//Destination
VTCDest	   = 4	//Destination
VTCSrc	   = 3
integer nOn = 1
integer nOff = 0

integer audiaMicVol = 14
integer audiaTableVol = 8
integer audiaPolyVol = 7
integer audiaCompVol = 13

integer mxVinComp = 1
integer mxVinPoly1 = 2
integer mxVinPoly2 = 3
integer mxVinCamFront = 4
integer mxVinCamRear = 5
integer mxVinTableFront = 6
integer mxVinTableMid = 7
integer mxVinTableRear = 8

integer mxVoutTVLeft = 1
integer mxVoutTVRight = 2
integer mxVoutProj = 3
integer mxVoutPolyCam = 4
integer mxVoutCompCam = 5

integer mxAoutTable = 1
integer mxAoutComp = 2

integer nLeft = 2	//Used for selecting Left Flat Panel
integer nRight = 1	//Used for selecting Right Flat Panel
integer TL1 = 1
//integer TL2 = 2
integer OffTime = 60	//Used to count down the time to turn the system off.

integer nRgbPortBtn[]=		//For selecting the RGB floor jacks// TODO update from new interface
{
    51,52,53
}
integer nCompPortBtn[] = {11}
integer nPolyPortBtn[] = {13}

integer nDestinationBtns[]= //Send to which Display? // TODO update from new interface
{
    16,	//Proj
    15,	//Right Flat Panel
    14	//Left Flat Panel
}

INTEGER nCamSelect[] = // TODO update from new interface
{
    105,	//Front Cam
    106		//Rear Cam
}

integer nBtnDisplayAdv[] = // TODO update from new interface
{
    120, // Left TV PON
    121, // Left TV POFF
    122, // Right TV PON
    123, // Right TV POFF
    124, // Proj PON
    125  // Proj POFF
}

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE
char TRACKPROJCONT[10]

integer x
SONCA000_CAM_ADDR	//This is used in SYSTEM_CALL SONCA00F.

integer nScalerIn
integer nSourceDevice
integer nRgbRouterIn
integer nRgbRouterOut
integer nRgbRouterAout
integer nVidDestination
integer Count

integer nTimeBlock
LONG TimeArray[100] 
integer nVolChn = 3
integer CurrentBg = 3
integer nCheckPwr[3]
char CodecCommand[20]
integer nPipLocation
integer Pip_On
char cTpBuffer[100]
integer nTrash
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

DEFINE_CALL 'Rack Power'(integer nStat)
{
    If(nStat = 0)	//Wants to turn power off
    {
	If([dvRackPower,1])
	{
	    Wait 20
	    {
		Off[dvRackPower,1]
		Off[dvRackPower,2]
	    }
	}
    }
    If(nStat = 1)	//Wants to turn power on
    {
	If(![dvRackPower,1])
	{
	    Call 'QUEUE BYPASS ON'(dvRGBRtr)
	    Wait 30
	    {
		Call 'QUEUE BYPASS OFF'(dvRGBRtr)
	    }
	    
	    On[dvRackPower,1]
	    On[dvRackPower,2]
	    
	}
    }
}

DEFINE_CALL 'Proj Control'(integer Proj_Num, char Proj_Control[10]) //Projector Control Sub. // TODO remove unneccessary input cases
{
LOCAL_VAR
sProjCmd[10],nProjDelay
	if(Proj_Control = 'PON') //Turn Proj ON
	{ 	
	    Call 'Rack Power'(1)
	   // on[dvRackPower,1]
	   // on[dvRackPower,2]
	    //send_string dvProj,"'(PWR1)'"
	    //send_string dvProj,"'PWR ON',$0D"
	    sProjCmd = "'PWR ON',$0D"
	    nProjDelay = 1
	}
	if(Proj_Control = 'POF')//Turn Proj OFF
	{
	    //send_string dvProj,"'PWR OFF',$0D"
	    sProjCmd = "'PWR OFF',$0D"
	    nProjDelay = 1
	}
	if(Proj_Control = 'VID1') //Select Vid input. 
	{
	   // send_string dvProj,"'(SRC2)'"
	    sProjCmd = '(SRC2)'
	    nProjDelay = 50
	}
	if(Proj_Control = 'VID2') //Select Vid input. 
	{
	    //send_string dvProj,"'(SRC3)'"
	    sProjCmd = '(SRC3)'
	    nProjDelay = 50
	}
	if(Proj_Control = 'VID3') //Select Vid input. 
	{
	    //send_string dvProj,"'(SRC4)'"
	    sProjCmd = '(SRC4)'
	    nProjDelay = 50
	}
	if(Proj_Control = 'RGB1') //Select RGB1. 
	{
	    //send_string dvProj,"'(SRC0)'"
	    sProjCmd = '(SRC0)'
	    nProjDelay = 50
	}
	if(Proj_Control = 'RGB2') //Select RGB2. 
	{
	    //send_string dvProj,"'(SRC1)'"
	    sProjCmd = '(SRC1)'
	    nProjDelay = 50
	}
	if(Proj_Control = 'RGB3') //Select RGB3.This is the one that is used.
	{
	    send_string dvProj,"'(SRC5)'"
	    sProjCmd = '(SRC5)'
	    nProjDelay = 50
	}
	if(Proj_Control = 'HDMI')
	{
	    sProjCmd = 'SOURCE 30'
	    nProjDelay = 50
	}
	Call 'QUEUE ADD'(dvProj,sProjCmd,nProjDelay,0)
	send_string 0:1:0,"'sent ',sprojcmd,' to the Projector',13,10"
	TRACKPROJCONT = sProjCmd
	Proj_Control = ''
	sProjCmd = ''
}


DEFINE_CALL 'Plasma Control'(integer nFunc, integer nSide)
{
    SEND_STRING 0:1:0,"'Nside = ',itoa(nSide),' nFunc = ',itoa(nFunc),13,10"
    SWITCH (nFunc)
    {
	Case PwrOff:
	{
	    if(nSide=nLeft)
	    {
		SEND_STRING dvLcdLeft,"$08,$22,$00,$00,$00,$01,$D5"
	    }
	    if(nSide=nRight)
	    {
		SEND_STRING dvLcdRight,"$08,$22,$00,$00,$00,$01,$D5"
	    }
	}
	Case PwrOn:
	{
	    Call 'Rack Power'(1)
	    if(nSide=nLeft)
	    {
		SEND_STRING dvLcdLeft,"$08,$22,$00,$00,$00,$02,$D6"
	    }
	    if(nSide=nRight)
	    {
		SEND_STRING dvLcdRight,"$08,$22,$00,$00,$00,$02,$D6"
	    }
	}
    }
}

DEFINE_CALL 'Switch RGB'(integer nIn,integer nOut,char SigType) // TODO verify with new matrix
{
    If(SigType = 'A')	//Audio Only
    {
	Call 'QUEUE ADD'(dvRGBRtr,"itoa(nIn),'*',itoa(nOut),'$'",5,0)
    }
    If(SigType = 'B')	//Both Audio and Video
    {
	Call 'QUEUE ADD'(dvRGBRtr,"itoa(nIn),'*',itoa(nOut),'!'",5,0)
    }
    If(SigType = 'V')	//Video Only
    {
	Call 'QUEUE ADD'(dvRGBRtr,"itoa(nIn),'*',itoa(nOut),'%'",5,0)
    }
    //Call 'QUEUE ADD'(dvRGBRtr,"itoa(nIn),'*',itoa(nOut),'!'",5,0)
    //SEND_STRING 0:1:0,"'RGB Sw In ',itoa(nIn),' to ',itoa(nOut),13"
}


(*
A [scene][Control Units]
scene - scene to select (0 to G)
Control Units - Control Units to select scene on
Examples: :A21 select scene 2 on Control Unit A1
:AG78 select scene 16 on Control Units A7 & A8
*)


DEFINE_CALL 'System Off'
{
    Call 'Proj Control'(1,'POF')
    Call 'Plasma Control'(PwrOff,nLeft)
    Call 'Plasma Control'(PwrOff,nRight)
    //Call 'Rack Power'(0)
    AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE)
    Send_string 0:1:0,"'Need to MUTE the AUDIO',13,10"
    wait 30
	SEND_COMMAND dvTp,"'PAGE-Splash'"
    
}

DEFINE_CALL 'AUDIO_MUTE'(integer audio_channel) {
    IF(uAudiaVol[audio_channel].nMute)
	{
          AUDIA_SetVolumeFn (audio_channel, AUDIA_VOL_MUTE_OFF)
	}
        ELSE
	{
          AUDIA_SetVolumeFn (audio_channel, AUDIA_VOL_MUTE)
	}


}
DEFINE_CALL 'AUDIO_UP'(integer audio_channel) {
    IF(uAudiaVol[audio_channel].nMute)
	{
          AUDIA_SetVolumeFn (audio_channel, AUDIA_VOL_MUTE_OFF)
	}
        ELSE
	{
          AUDIA_SetVolumeFn (audio_channel, AUDIA_VOL_UP)
	}
}

DEFINE_CALL 'AUDIO_DOWN'(integer audio_channel) {
    IF(uAudiaVol[audio_channel].nMute)
	{
          AUDIA_SetVolumeFn (audio_channel, AUDIA_VOL_MUTE_OFF)
	}
        ELSE
	{
          AUDIA_SetVolumeFn (audio_channel, AUDIA_VOL_DOWN)
	}
}
DEFINE_CALL 'MUTE_STATE_CHANGE' (integer audio_channel, integer button_channel) {
    IF(uAudiaVol[audio_channel].nMute){
	SEND_COMMAND dvTp,"'!T ',button_channel,' UNMUTE'"
    } ELSE {
	SEND_COMMAND dvTp,"'!T ',button_channel,' MUTE'"
    }
}
(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START
//SEND_COMMAND dvLcdLeft,"'SET BAUD 9600,N,8,1'"
//SEND_COMMAND dvLcdRight,"'SET BAUD 9600,N,8,1'"
nTimeBlock = 0
FOR (COUNT=0 ; COUNT<70 ; COUNT++)
{
    TimeArray[Count] = 1000
}
//TIMELINE_CREATE(TL2, TimeArray, 10, TIMELINE_RELATIVE, TIMELINE_REPEAT) 
//SYSTEM_CALL [1] 'SONCA000' (1)
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT
DATA_EVENT[dvRGBRtr]
{
    Online:
    {
	SEND_COMMAND data.device,"'SET BAUD 9600,N,8,1'"
    }
}
DATA_EVENT[dvLcdLeft]
{
    Online:
    {
	SEND_COMMAND dvLcdLeft,"'SET BAUD 9600,N,8,1'"
    }
}
DATA_EVENT[dvLcdRight]
{
    Online:
    {
	SEND_COMMAND dvLcdRight,"'SET BAUD 9600,N,8,1'"
    }
}
DATA_EVENT[dvAudia1]	
{
    Online:
    {
	SEND_COMMAND data.device,"'SET BAUD 38400,8,N,1'"
	Wait 10
	{
	    (*-- Biamp Parms (Lvl,Dev,VolCmd,MuteCmd,Min,Max) ---------*)
	    //AUDIA_AssignVolumeParms (1, dvAUDIA1, 'SET 1 INPLVL 81 2 ', 'SET 1 INPMUTE 81 2 ', 0, 1120)
	    //AUDIA_AssignVolumeParms (2, dvAUDIA1, 'SETL 1 OUTLVL 1 1 ', '', 0, 1120)
	    //AUDIA_AssignVolumeParms (2, dvAUDIA1, 'SET 2 FDRLVL 3 1 ', 'SET 2 FDRMUTE 3 1 ', 0, 1120)
	    //AUDIA_AssignVolumeParms (3, dvAUDIA1, 'SET 2 FDRLVL 8 1 ', 'SET 2 FDRMUTE 8 1 ', -500, 1200)
	    //AUDIA_AssignVolumeParms (4, dvAUDIA1, 'SET 2 FDRLVL 7 1 ', 'SET 2 FDRMUTE 7 1 ', -500, 1200)
	    //AUDIA_AssignVolumeParms (1, dvAUDIA1, 'SETL 1 OUTLVL 1 1 ', '', 0, 1120)
	    AUDIA_AssignVolumeParms (audiaMicVol, dvAUDIA1, 'SET 2 FDRLVL 14 1 ', 'SET 2 FDRMUTE 14 1 ', 820, 1120)
	    AUDIA_AssignVolumeParms (audiaTableVol, dvAUDIA1, 'SET 2 FDRLVL 8 1 ', 'SET 2 FDRMUTE 8 1 ', 820, 1120)
	    AUDIA_AssignVolumeParms (audiaPolyVol, dvAUDIA1, 'SET 2 FDRLVL 7 1 ', 'SET 2 FDRMUTE 7 1 ', 820, 1120)
	    AUDIA_AssignVolumeParms (audiaCompVol, dvAUDIA1, 'SET 2 FDRLVL 13 1 ', 'SET 2 FDRMUTE 13 1 ', 820, 1120)
	}
    }
    String:
    {
	If(find_string(data.text,'INFO:Audio Started',1))
	{
	    Wait 20
	    {
		SEND_STRING 0:1:0,"'Sent MUTE to Nexia',13"
		//AUDIA_SetVolumeFn (2, AUDIA_VOL_MUTE)
	    }
	}
    }
}

DATA_EVENT[dvRackPower] // TODO delete?
{
    online:
    {
	//ON[dvRackPower,1]
	//ON[dvRackPower,2]
    }
}

TIMELINE_EVENT[TL1] // capture all events for Timeline 1 
{ 
    send_string 0:1:0,"itoa(OffTime-timeline.sequence),13,10"
    send_command dvTp,"'@TXT',2,itoa(OffTime-timeline.sequence)"
    Send_command dvTp,"'beep'"
    switch(Timeline.Sequence) // which time was it? 
    { 
	case 1: 
	    {
		SEND_COMMAND dvTp,"'Wake'"
		SEND_COMMAND dvTp,"'PPON-Shutdown Warning'"
	    } 
	case 2: { } 
	case 3: { } 
	case 4: { } 
	case 60: 
		{
		    timeline_kill(tl1)
		    Call 'System Off'
		    
		    SEND_COMMAND dvTp,"'PPOF-Shutdown Warning'"
		    SEND_COMMAND dvtp,"'Page-Splash'"
		    SEND_COMMAND dvTp,"'Sleep'"
		 } 
	
    } 
} 
BUTTON_EVENT[dvTp,nRgbPortBtn]	//Select the Input on the RGB Router
{
    Push:
    {
	switch(button.input.channel)
	{
	    case 51:
	    {
		nRgbRouterIn = mxVinTableRear
	    }
	    case 52:
	    {
		nRgbRouterIn = mxVinTableFront
	    }
	    case 53:
	    {
		nRgbRouterIn = mxVinTableMid
	    }
	}
	nRgbRouterAout = mxAoutTable
    }
}
BUTTON_EVENT[dvTp,nCompPortBtn]
{
    Push:
    {
	nRgbRouterIn = mxVinComp
	nRgbRouterAout = mxAoutComp
    }
}
BUTTON_EVENT[dvTp,nPolyPortBtn]
{
    Push:
    {
	call 'Switch RGB'(mxVinPoly1,mxVoutTVLeft,'V')
	call 'Switch RGB'(mxVinPoly2,mxVoutTVRight,'V')
    }
}

BUTTON_EVENT[dvTp,nCamSelect]
{
    Push:
    {
	switch(get_last(nCamSelect))
	{
	    Case 1:
	    {
		call 'Switch RGB'(mxVinCamFront,mxVoutCompCam,'V')
		call 'Switch RGB'(mxVinCamFront,mxVoutPolyCam,'V')
	    }
	    Case 2:
	    {
		call 'Switch RGB'(mxVinCamRear,mxVoutCompCam,'V')
		call 'Switch RGB'(mxVinCamRear,mxVoutPolyCam,'V')
	    }
	}
    }
}
BUTTON_EVENT[dvTp,nDestinationBtns]
{
    Push:
    {
	nVidDestination = get_last(nDestinationBtns)
	SWITCH(nVidDestination)
	{
	    Case Projector:
	    {
		nRgbRouterOut = mxVoutProj
		Call 'Proj Control'(1,'PON')
	    }
	    Case LeftPanel:
	    {
		nRgbRouterOut = mxVoutTVLeft
		CALL'Plasma Control'(PwrOn,nLeft)
		// TODO if possible, set to HDMI1 Call 'Plasma Control'(RGB3,nLeft)
	    }
	    Case RightPanel:
	    {
		nRgbRouterOut = mxVoutTVRight
		CALL 'Plasma Control'(PwrOn,nRight)
		// TODO if possile, set to HDMI1 Call 'Plasma Control'(RGB3,nRight)
	    }
	}
	If(nRgbRouterIn && nRgbRouterOut)
	{
	    Call 'Switch RGB'(nRgbRouterIn,nRgbRouterOut, 'V')
	}
	If(nRgbRouterIn && nRgbRouterAout)
	{
	    Call 'Switch RGB'(nRgbRouterIn,nRgbRouterAout,'A')
	}
	nRgbRouterAout = 0
	nRgbRouterIn = 0
    }
}

BUTTON_EVENT[dvTp,4]	//This is the YES Button to turn the system off.
{
    Push:
    {
	Call 'System Off'
    }
}
BUTTON_EVENT[dvTp,5]	//This is the Splash screen.
{
    Push:
    {
	Call'Rack Power'(1)
    }
}
BUTTON_EVENT[dvTp,6]	//Stop the Shutdown sequence.
{
    Push:
    {
	TIMELINE_KILL(Tl1)
	SEND_COMMAND dvTp,"'PPOF-Shutdown Warning'"
    }
}

BUTTON_EVENT[dvTp,33]        // Mic Vol Up
{
    PUSH :
    { 
	Call 'AUDIO_UP'(audiaMicVol)
	SEND_LEVEL dvTp,1,AUDIA_GetBgLvl(audiaMicVol)
	Call 'MUTE_STATE_CHANGE'(audiaMicVol,35)
    }
}
BUTTON_EVENT[dvTp,34]        // Mic Vol Down
{
    PUSH :
    { 
	Call 'AUDIO_DOWN'(audiaMicVol)
	SEND_LEVEL dvTp,1,AUDIA_GetBgLvl(audiaMicVol)
	Call 'MUTE_STATE_CHANGE'(audiaMicVol,35)
    }
}
BUTTON_EVENT[dvTp,35]        // Mic Vol Mute
{
    PUSH :
    {
	CALL 'AUDIO_MUTE'(audiaMicVol)
	SEND_LEVEL dvTp,1,AUDIA_GetBgLvl(audiaMicVol)
	Call 'MUTE_STATE_CHANGE'(audiaMicVol,35)
    }
}
BUTTON_EVENT[dvTp,7]        // Laptop Vol Up
{
    PUSH :
    { 
	Call 'AUDIO_UP'(audiaTableVol)
	SEND_LEVEL dvTp,2,AUDIA_GetBgLvl(audiaTableVol)
	Call 'MUTE_STATE_CHANGE'(audiaTableVol,9)
    }
}
BUTTON_EVENT[dvTp,8]        // Laptop Vol Down
{
    PUSH :
    { 
	Call 'AUDIO_DOWN'(audiaTableVol)
	SEND_LEVEL dvTp,2,AUDIA_GetBgLvl(audiaTableVol)
	Call 'MUTE_STATE_CHANGE'(audiaTableVol,9)
    }
}
BUTTON_EVENT[dvTp,9]        // Laptop Vol Mute
{
    PUSH :
    {
	CALL 'AUDIO_MUTE'(audiaTableVol)
	SEND_LEVEL dvTp,2,AUDIA_GetBgLvl(audiaTableVol)
	Call 'MUTE_STATE_CHANGE'(audiaTableVol,9)
    }
}
BUTTON_EVENT[dvTp,17]        // Computer Vol Up
{
    PUSH :
    { 
	Call 'AUDIO_UP'(audiaCompVol)
	SEND_LEVEL dvTp,3,AUDIA_GetBgLvl(audiaCompVol)
	Call 'MUTE_STATE_CHANGE'(audiaCompVol,19)
    }
}
BUTTON_EVENT[dvTp,18]        // Computer Vol Down
{
    PUSH :
    { 
	Call 'AUDIO_DOWN'(audiaCompVol)
	SEND_LEVEL dvTp,3,AUDIA_GetBgLvl(audiaCompVol)
	Call 'MUTE_STATE_CHANGE'(audiaCompVol,19)
    }
}
BUTTON_EVENT[dvTp,19]        // Computer Vol Mute
{
    PUSH :
    {
	CALL 'AUDIO_MUTE'(audiaCompVol)
	SEND_LEVEL dvTp,3,AUDIA_GetBgLvl(audiaCompVol)
	Call 'MUTE_STATE_CHANGE'(audiaCompVol,19)
    }
}
BUTTON_EVENT[dvTp,20]        // Polycom Vol Up
{
    PUSH :
    { 
	Call 'AUDIO_UP'(audiaPolyVol)
	SEND_LEVEL dvTp,4,AUDIA_GetBgLvl(audiaPolyVol)
	Call 'MUTE_STATE_CHANGE'(audiaPolyVol,22)
    }
}
BUTTON_EVENT[dvTp,21]        // Polycom Vol Down
{
    PUSH :
    { 
	Call 'AUDIO_DOWN'(audiaPolyVol)
	SEND_LEVEL dvTp,4,AUDIA_GetBgLvl(audiaPolyVol)
	Call 'MUTE_STATE_CHANGE'(audiaPolyVol,22)
    }
}
BUTTON_EVENT[dvTp,22]        // Polycom Vol Mute
{
    PUSH :
    {
	CALL 'AUDIO_MUTE'(audiaPolyVol)
	SEND_LEVEL dvTp,4,AUDIA_GetBgLvl(audiaPolyVol)
	Call 'MUTE_STATE_CHANGE'(audiaPolyVol,22)
    }
}

BUTTON_EVENT[dvTP,nBtnDisplayAdv]
{
    Push:
    {
	SWITCH(button.input.channel)
	{
	    Case 120:{CALL'Plasma Control'(PwrOn,nLeft)}
	    Case 121:{CALL'Plasma Control'(PwrOff,nLeft)}
	    Case 122:{CALL'Plasma Control'(PwrOn,nRight)}
	    Case 123:{CALL'Plasma Control'(PwrOff,nRight)}
	    Case 124:{Call 'Proj Control'(1,'PON')}
	    Case 125:{Call 'Proj Control'(1,'POF')}	
	}
    }
}



DEFINE_PROGRAM
(**************************)
(* Shutdown system at 9pm *)
(**************************)
If((time_to_hour(time) = 22)&&(time_to_minute(time) = 00)&&(nTimeBlock = 0))
{
    send_string 0:1:0,"'the time is ',time,13,10"
    nTimeBlock = 1		//Keeps this from running over and over for the whole minute.
    TIMELINE_CREATE(TL1, TimeArray, 61, TIMELINE_RELATIVE, TIMELINE_ONCE) 
    wait 620			//Need to wait until the minute is over.
	nTimeBlock = 0	
}
[dvTp,33] = (uAudiaVol[CurrentBg].nVolRamp = AUDIA_VOL_UP)
[dvTp,34] = (uAudiaVol[CurrentBg].nVolRamp = AUDIA_VOL_DOWN)
[dvTp,35] = (uAudiaVol[CurrentBg].nMute)
SEND_LEVEL dvTp,1,AUDIA_GetBgLvl(audiaMicVol)
SEND_LEVEL dvTp,2,AUDIA_GetBgLvl(audiaTableVol)
SEND_LEVEL dvTp,3,AUDIA_GetBgLvl(audiaCompVol)
SEND_LEVEL dvTp,4,AUDIA_GetBgLvl(audiaPolyVol)
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
 DEFINE_PROGRAM

[dvProj,124] = nCheckPwr[1]
[dvProj,125] = !nCheckPwr[1]
 
 //SYSTEM_CALL [1] 'SONCA001' (1,dvTp,PLR,PRB,TUB,TDB,ZTB,ZWB,FNB,FFB,AFB,MFB)
// Basic camera control.  Parameters are:
// Pan Left, Pan Right, Tilt Up, Tilt Down, Zoom Tele, Zoom Wide,
// Focus Near, Focus Far, Auto Focus, Manual Focus.
 (***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

