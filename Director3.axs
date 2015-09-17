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
dvCodec1 = 5001:1:0     //Polycom VSX7000e              
dvAudia1 = 5001:2:0     //Biamp Nexia CS 
dvLcdRight = 5001:3:0   //Samsung LCD Right side of Room(I)
dvProj     = 5001:5:0   //Proxima Projector C450        (G)
dvLcdLeft  = 5001:6:0   //Samsung LCD Left side of Room (H)
dvRGBRtr   = 5001:7:0   //Extron 450 RGB Switcher       (F)

dvCam    = 5001:3:2     //Sony BCR300                   (A)<--dwg reference
dvQuad   = 5001:4:2     //RGB Quadview                  (B)
dvVideoRtr = 5001:5:2   //Extron MAV 84 Video Switcher  (D)
//dvLights = 5001:3:2     //Might be a Lutron GraphicEye
dvRackPower = 5001:8:0  //Relay 1 is for the Seq Power Strip

dvScaler   = 5001:1:2   //Extron DVS304 Video Scaler    (E)

dvTp       = 10001:1:0  //MVP8400 Touchpanel

dvTpCodec  = 10001:4:0  //Port 4 is for the Polycom codec
dvTP_qv    = 10001:3:0  //Quad Buttons
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT
dev dvPanelD[]=	//This could be numerous panels. Used in the Polycom file.
{
    dvTpCodec
}
PLR = 21	//Pan Left
PRB = 22	//Pan Right
TUB = 23	//Tilt Up
TDB = 24	//Tilt Down
ZTB = 25	//Zoom Tight
ZWB = 26	//Zoom Wide
FNB = 27	//Focus Near
FFB = 28	//Focus Far
AFB = 29	//Auto Focus
MFB = 30	//Manual Focus
PwrOff = 0
PwrOn = 1
RGB1 = 2
RGB2 = 3
RGB3 = 4
VID1 = 5
VID2 = 6
SVID = 7
Projector  = 1	//Destination
RightPanel = 2	//Destination
LeftPanel  = 3	//Destination
VTCDest	   = 4	//Destination
VTCSrc	   = 3
integer nOn = 1
integer nOff = 0

integer nLeft = 2	//Used for selecting Left Flat Panel
integer nRight = 1	//Used for selecting Right Flat Panel
integer TL1 = 1
//integer TL2 = 2
integer OffTime = 60	//Used to count down the time to turn the system off.
devchan dvch_Quad_Misc[] = 
{
    {dvTP_qv,60},	//Full Screen
    {dvTP_qv,61},	//Quad View
    {dvTP_qv,62},
    {dvTP_qv,63},
    {dvTP_qv,64},
    {dvTP_qv,65},
    {dvTP_qv,66}
}
devchan dvch_QuadView_Inputs[] = 
{
	{dvTP_qv,71},
	{dvTP_qv,72},
	{dvTP_qv,73},
	{dvTP_qv,74},
	{dvTP_qv,75},
	{dvTP_qv,76},
	{dvTP_qv,77},
	{dvTP_qv,78},
	{dvTP_qv,79},
	{dvTP_qv,80},
	{dvTP_qv,81},
	{dvTP_qv,82}
}      

devchan dvch_QuadView_Ouputs[] = 
{
	{dvTP_qv,91},
	{dvTP_qv,92},
	{dvTP_qv,93},
	{dvTP_qv,94}
}          

devchan dvch_QuadView_Window[] = 
{
	{dvTP_qv,95},
	{dvTP_qv,96},
	{dvTP_qv,97},
	{dvTP_qv,98}
}          

devchan dvch_QuadViewPresets[] = 
{
	{dvTP_qv,101},
	{dvTP_qv,102},
	{dvTP_qv,103},
	{dvTP_qv,104},
	{dvTP_qv,105},
	{dvTP_qv,106}
}          
devchan dvch_LightingPresets[] = 
{
    {dvTp,40},
    {dvTp,41},
    {dvTp,42},
    {dvTp,43},
    {dvTp,44},
    {dvTp,45},	//External Button on MVP
    {dvTp,46},	//External Button on MVP
    {dvTp,47},	//External Button on MVP
    {dvTp,48}	//External Button on MVP
}
integer nRgbPortBtn[]=		//For selecting the RGB floor jacks
{
    50,51,52,53
}
integer nVideoPortBtn[]=	//For selecting the Video floor jacks
{
    54,55,56,57
}
integer nDestinationBtns[]= //Send to which Display?
{
    7,	//Proj
    8,	//Right Flat Panel
    9,	//Left Flat Panel
    10	//VTC
}
INTEGER nSrcSelects[] = 
{
    91,	//DVD
    92,	//VCR
    93,	//VTC
    94,	//Cameras
    95,	//RGB Ports
    96,	//Video Ports
    97	//Lighting
}
INTEGER nCamSelect[] =
{
    105,	//Front Cam
    106,	//Rear Cam
    107,	//Left Cam
    108		//Right Cam
}

integer nBtnDisplayAdv[] = 
{
    120,
    121,
    122,
    123,
    124,
    125
}
integer nCodecBtns[] = 
{
    170,
    171,
    172,
    173,
    174,
    175,
    176,
    177,
    178,
    179,
    180,
    181,
    182,
    183,
    184,
    185,
    186,
    187,
    188,
    189,
    190
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
integer nVideoRouterIn
integer nVideoRouterOut
integer nVidDestination
integer Count

volatile integer nQUAD_SOURCE
volatile integer nQUAD_DEST
volatile integer nQUAD_PRESET
volatile integer nQUAD_WIN[4]
integer nTimeBlock
LONG TimeArray[100] 
integer nVolChn = 3
integer nMuteChan	//This is the Nexia channel that need to be muted. Either VCR or DVD.
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
INCLUDE'Polycom VS4000'

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
	    Call 'QUEUE BYPASS ON'(dvScaler)
	    Call 'QUEUE BYPASS ON'(dvVideoRtr)
	    Call 'QUEUE BYPASS ON'(dvRGBRtr)
	    Wait 30
	    {
		Call 'QUEUE BYPASS OFF'(dvScaler)
		Call 'QUEUE BYPASS OFF'(dvVideoRtr)
		Call 'QUEUE BYPASS OFF'(dvRGBRtr)
	    }
	    
	    On[dvRackPower,1]
	    On[dvRackPower,2]
	    
	}
    }
}

DEFINE_CALL 'Proj Control'(integer Proj_Num, char Proj_Control[10]) //Projector Control Sub.
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
	Call 'QUEUE ADD'(dvProj,sProjCmd,nProjDelay,0)
	send_string 0:1:0,"'sent ',sprojcmd,' to the Projector',13,10"
	TRACKPROJCONT = sProjCmd
	Proj_Control = ''
	sProjCmd = ''
}


DEFINE_CALL 'Plasma Control'(integer nFunc, integer nSide)
{
LOCAL_VAR LCD_String[15],Header,sCommand,sId,sDataLength,sData,Chksum,TempChksm
    SEND_STRING 0:1:0,"'Nside = ',itoa(nSide),' nFunc = ',itoa(nFunc),13,10"
    SWITCH (nFunc)
    {
	Case PwrOff:
	{
	    LCD_STRING = "$30,$30,$22,$0d"
	    Header = $aa
	    sCommand = $11
	    sDataLength = $01
	    sData = $00
	}
	Case PwrOn:
	{
	    Call 'Rack Power'(1)
	    //on[dvRackPower,1]
	    //on[dvRackPower,2]
	    LCD_STRING = "$30,$30,$21,$0d"
	}
	Case VID1:
	{
	    LCD_STRING = "$30,$30,$5f,$76,$31,$0d"	
	}
	Case VID2:
	{
	
	}
	Case SVID:
	{
	    LCD_STRING = "$30,$30,$5f,$76,$33,$0d"
	    SEND_STRING 0:1:0,"'Sent SVID to Plasma',13,10"
	}
	Case RGB1:
	{
	    LCD_STRING = "$30,$30,$5f,$72,$31,$0d"
	}
	Case RGB2:
	{
	    LCD_STRING = "$30,$30,$5f,$72,$32,$0d"
	}
	Case RGB3:
	{
	    LCD_STRING = "$30,$30,$5f,$72,$33,$0d"
	}
    }
    if(nSide = nLeft)
    {
	Call 'QUEUE ADD'(dvLcdLeft,LCD_STRING,20,0)
    }
    if(nSide = nRight)
    {
	Call 'QUEUE ADD'(dvLcdRight,LCD_STRING,20,0)
    }
}

DEFINE_CALL 'Scaler'(integer nIn,integer nOut)
{
    Call 'QUEUE ADD'(dvScaler,"itoa(nIn),'&'",5,0)
    //send_string dvScaler,"itoa(nIn),'&'"	//Video Only
    SEND_STRING 0:1:0,"'Scaler in = ',itoa(nIn),13"
}
DEFINE_CALL 'Switch Video'(integer nIn,integer nOut,char SigType)
{
    If(SigType = 'A')	//Audio Only
    {
	Call 'QUEUE ADD'(dvVideoRtr,"itoa(nIn),'*',itoa(nOut),'$'",5,0)
    }
    If(SigType = 'B')	//Both Audio and Video
    {
	Call 'QUEUE ADD'(dvVideoRtr,"itoa(nIn),'*',itoa(nOut),'!'",5,0)
    }
    If(SigType = 'V')	//Video Only
    {
	Call 'QUEUE ADD'(dvVideoRtr,"itoa(nIn),'*',itoa(nOut),'%'",5,0)
    }
    //Call 'QUEUE ADD'(dvVideoRtr,"itoa(nIn),'*',itoa(nOut),'!'",5,0)
    //send_string dvVideoRtr,"itoa(nIn),'*',itoa(nOut),'!'"	//Audio and Video
    SEND_STRING 0:1:0,"'Video Sw In ',itoa(nIn),' to ',itoa(nOut),13"
}
DEFINE_CALL 'Switch RGB'(integer nIn,integer nOut,char SigType)
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
    Call 'QUEUE ADD'(dvRGBRtr,"itoa(nIn),'*',itoa(nOut),'!'",5,0)
    SEND_STRING 0:1:0,"'RGB Sw In ',itoa(nIn),' to ',itoa(nOut),13"
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
    Call 'Rack Power'(0)
    AUDIA_SetVolumeFn (nVolChn, AUDIA_VOL_MUTE)
    Send_string 0:1:0,"'Need to MUTE the AUDIO',13,10"
    wait 30
	SEND_COMMAND dvTp,"'PAGE-Splash'"
    
}
DEFINE_FUNCTION  QUAD_WINDOW_CONTROL(INTEGER nWIN, INTEGER nSTATE)
{
    If(nQUAD_WIN[nWIN] = nOff)
    {
	SEND_STRING dvQUAD, "'WIN ',ITOA(nWIN),' ON',13"
	nQUAD_WIN[nWIN] = nOn
    }
    Else
    {
	SEND_STRING dvQUAD, "'WIN ',ITOA(nWIN),' OFF',13"
	nQUAD_WIN[nWIN] = nOFF
    }
}
DEFINE_MODULE 'VS4000 Module' VTC1(dvCodec1,vdvCodec1,dvPanelD, nVTCControls1, nFarEndCamera1, nNearEndCamera1,nDialButtons,nKeyboardBtns,nKeyBoardMiscBtns)
(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START
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
DATA_EVENT[dvCodec1]
{
    ONLINE:
	SEND_COMMAND data.device,"'SET BAUD 9600,8,N,1'"
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
	    AUDIA_AssignVolumeParms (3, dvAUDIA1, 'SET 2 FDRLVL 8 1 ', 'SET 2 FDRMUTE 8 1 ', -500, 1200)
	    AUDIA_AssignVolumeParms (4, dvAUDIA1, 'SET 2 FDRLVL 7 1 ', 'SET 2 FDRMUTE 7 1 ', -500, 1200)
	    //AUDIA_AssignVolumeParms (1, dvAUDIA1, 'SETL 1 OUTLVL 1 1 ', '', 0, 1120)
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
DATA_EVENT[dvCam]
{
    ONLINE:
	SEND_COMMAND data.device,"'SET BAUD 9600,8,N,1'" 
}

DATA_EVENT[dvQuad]
{
    Online:
    {
	SEND_COMMAND data.device,"'SET BAUD 9600,8,N,1'"
	wait 20	//wait for set baud command to take effect.
	    SEND_COMMAND data.device,"'QuadView',13"
    }
}


DATA_EVENT[dvVideoRtr]
{
    Online:
    {
	send_command dvVideoRtr,"'SET BAUD 9600,8,N,1'"
    }
}

DATA_EVENT[dvScaler]
{
    Online:
    {
	SEND_COMMAND dvScaler,"'SET BAUD 9600,8,N,1'"
    }
}
DATA_EVENT[dvRackPower]
{
    online:
    {
	//ON[dvRackPower,1]
	//ON[dvRackPower,2]
    }
}
DATA_EVENT[dvTp]
{
    String:
    {
	If(find_string(data.text,'KEYP-1234',1))	//The Univ asked for this to be removed.
	{
	    Call 'Rack Power'(1)
	    SEND_COMMAND dvTp,"'Page-Top Level'"
	    send_command dvTp,"'PPON-Top Bar'"
	    send_string 0:1:0,"'Passcode is Correct',13,10"
	}
	If(find_string(data.text,'KEYB-',1))
	{
	    cTpBuffer = data.text
	    remove_string(cTpBuffer,'KEYB-',1)
	    send_command dvTpCodec,"'TEXT1-',cTpBuffer"
	    cTpBuffer = ""
	}
    }
    Online:
	send_command dvTp,"'Page-Splash'"
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

button_event[dvch_QuadView_Inputs] // Quadview window source select
{
	push:
	{
		nQUAD_SOURCE = get_last(dvch_QuadView_Inputs)
	}
}
button_event[dvch_QuadView_Window] // Quadview window on/off
{
	push:
	{
		//nQUAD_WIN[get_last(dvch_QuadView_Window)] = !nQUAD_WIN[get_last(dvch_QuadView_Window)]
		//QUAD_WINDOW_CONTROL(get_last(dvch_QuadView_Window),!nQUAD_WIN[get_last(dvch_QuadView_Window)])
		QUAD_WINDOW_CONTROL(get_last(dvch_QuadView_Window),1)
	}	
}


button_event[dvch_QuadViewPresets] // Quadview presets
{
	push:
	{
		nQUAD_PRESET = get_last(dvch_QuadViewPresets)
		SEND_STRING dvQUAD, "'WPLOAD ',ITOA(nQUAD_PRESET),13" 
	}
}
button_event[dvch_Quad_Misc]
{
    Push:
    {
	SWITCH (get_last(dvch_Quad_Misc))
	{
	    Case 1:
	    {
		SEND_STRING dvQuad,"'FullScreen ',itoa(nQUAD_DEST),13"
	    }
	    Case 2:
	    {
		SEND_STRING dvQuad,"'QuadView',13"
	    }
	    
	}
    }
}
button_event[dvch_QuadView_Ouputs] // Quadview output window select and route
{
	push:
	{
		nQUAD_DEST = get_last(dvch_QuadView_Ouputs)
	}
}

BUTTON_EVENT[dvTp,nRgbPortBtn]	//Select the Input on the RGB Router
{
    Push:
    {
	nRgbRouterIn = button.input.channel - 49
    }
}
BUTTON_EVENT[dvTp,nVideoPortBtn]
{
    Push:
    {
	nVideoRouterIn = button.input.channel - 53
	nVideoRouterOut = 1
	nScalerIn = 1
	nRgbRouterIn = 8	//Vid Sw to Scaler out to RGB Switch Input 8
    }
}


BUTTON_EVENT[dvTp,nSrcSelects]
{
    Push:
    {
	nSourceDevice = (get_last(nSrcSelects))
	SWITCH (nSourceDevice)
	{
	    
	    Case 3:	//VTC
	    {
		send_string dvCodec1,"'screen wake',10"
		send_string 0:1:0,"'SRC = VTC',13,10"
		SEND_COMMAND dvTp,"'PPON-Destinations'"
	    }
	    Case 4:	//Cameras
	    {
		nRgbRouterIn = 7
		send_string 0:1:0,"'SRC = CAM',13,10"
		SEND_COMMAND dvTp,"'PPON-Destinations'"
	    }
	    Case 5:	//RGB Ports
	    {
	    
	    }
	    Case 6:	//Video Ports
	    {
	    
	    }
	}
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
		nQUAD_DEST = get_last(nCamSelect)
	    }
	    Case 2:
	    {
		nQUAD_DEST = get_last(nCamSelect)
	    }
	    Case 3:
	    {
		nQUAD_DEST = get_last(nCamSelect)+1
	    }
	    Case 4:
	    {
		nQUAD_DEST = get_last(nCamSelect)-1
	    }
	}
	
	sonca000_cam_addr = get_last(nCamSelect)
	send_string 0:1:0,"'sonca000_cam_addr = ',itoa(sonca000_cam_addr),13,10"
	SEND_STRING dvQuad,"'FullScreen ',itoa(nQUAD_DEST),13"
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
		nRgbRouterOut = Projector
		
		If(nSourceDevice = VTCSrc)
		{
		    //SEND_COMMAND dvTp,"'PPON-VTC route issue'"
		}
		Else
		{
		    Call 'Proj Control'(1,'PON')
		}
	    }
	    Case LeftPanel:
	    {
		send_string 0:1:0,"'sent info to left Panel',13,10"
		nRgbRouterOut = LeftPanel
		CALL'Plasma Control'(PwrOn,nLeft)
		If(nSourceDevice = VTCSrc)
		{
		    
		    //SEND_COMMAND dvTp,"'PPON-VTC route issue'"
		   //Call 'Plasma Control'(SVID,nLeft)
		}
		ELSE
		{
		   Call 'Plasma Control'(RGB3,nLeft)
		}
	    }
	    Case RightPanel:
	    {
		send_string 0:1:0,"'sent info to Right Panel',13,10"
		nRgbRouterOut = RightPanel
		CALL 'Plasma Control'(PwrOn,nRight)
		If(nSourceDevice = VTCSrc)
		{
		    Call 'Plasma Control'(RGB3,nRight)
		    CALL 'Plasma Control'(PwrOn,nLeft)	//For Self view.
		    Call 'Plasma Control'(RGB3,nLeft)	//For Self view.
		    
		    
		}
		ELSE
		{
		    Call 'Plasma Control'(RGB3,nRight)
		}
	    }
	    Case VTCDest:	//For sending src to the VTC system.
	    {
		If(nSourceDevice = VTCSrc)
		{
		    //SEND_COMMAND dvTp,"'PPON-VTC route issue'"
		}
		Else
		{
		    nRgbRouterOut = VTCDest
		}
	    }
	}
	If(nRgbRouterIn = 8)
	{
	    If(nScalerIn = 1)
	    {
		Call 'Scaler'(1,1)
		Call 'Switch Video'(nVideoRouterIn,nVideoRouterOut,'B')
	    }
	    If(nScalerIn = 2)	//This is the DVD feed
	    {
		Call 'Scaler'(2,1)
	    }
	}
	If(nRgbRouterIn && nRgbRouterOut)
	{
	    Call 'Switch RGB'(nRgbRouterIn,nRgbRouterOut, 'V')
	    Call 'Switch RGB'(nRgbRouterIn,1,'A')
	}
	nVideoRouterIn = 0
	nRgbRouterIn = 0
	nScalerIn = 0

	If(nSourceDevice = 3)	//VTC
	{
	    nVolChn = 4
	    CurrentBg = 4
	    //AUDIA_SetVolumeFn (2, AUDIA_VOL_MUTE)	//Program Audio (Non Surround
	    //AUDIA_SetVolumeFn (3, AUDIA_VOL_MUTE)	//Mute Codec
	    SEND_COMMAND dvTp,"'Page-VTC Page'"
	    SEND_COMMAND dvTp,"'PPON-Top Bar'"
	    SEND_COMMAND dvTp,"'PPON-VTC Title'"
	    Call 'Switch RGB'(5,2, 'V')
	    Call 'Switch RGB'(6,3, 'V')
	}
	If(nSourceDevice = 4)	//Camera
	{
	
	}
	If(nSourceDevice = 5)	//RGB Ports
	{
	
	}
	If(nSourceDevice = 6)	//Video Ports
	{
	    nVolChn = 3
	    CurrentBg = 3
	}
	
	
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
BUTTON_EVENT[dvTp,33]        // Vol Up
BUTTON_EVENT[dvTp,34]        // Vol Down
BUTTON_EVENT[dvTp,35]        // Vol Mute
{
  PUSH :
  { 
    
    SWITCH(BUTTON.INPUT.CHANNEL)
    {
      CASE 33 :    // Vol Up
      {
        IF(uAudiaVol[nVolChn].nMute)
	{
          AUDIA_SetVolumeFn (CurrentBg, AUDIA_VOL_MUTE_OFF)
	  AUDIA_SetVolumeFn (3, AUDIA_VOL_MUTE_OFF)
	}
        ELSE
          AUDIA_SetVolumeFn (CurrentBg, AUDIA_VOL_UP)
	  AUDIA_SetVolumeFn (3, AUDIA_VOL_UP)
      }
      CASE 34 :    // Vol Down
      {
        IF(uAudiaVol[nVolChn].nMute)
	{
          AUDIA_SetVolumeFn (CurrentBg, AUDIA_VOL_MUTE_OFF)
	  AUDIA_SetVolumeFn (3, AUDIA_VOL_MUTE_OFF)
	}
        ELSE
	{
         AUDIA_SetVolumeFn (CurrentBg, AUDIA_VOL_DOWN)
	 AUDIA_SetVolumeFn (3, AUDIA_VOL_DOWN)
	}
      }
      CASE 35 :    // Vol Mute
      {
        IF(uAudiaVol[nVolChn].nMute)
	{
          AUDIA_SetVolumeFn (CurrentBg, AUDIA_VOL_MUTE_OFF)
	  AUDIA_SetVolumeFn (3, AUDIA_VOL_MUTE_OFF)
	}
        ELSE
	{
          AUDIA_SetVolumeFn (CurrentBg, AUDIA_VOL_MUTE)
	  AUDIA_SetVolumeFn (3, AUDIA_VOL_MUTE)
	}
      }
    }(*
    SWITCH(BUTTON.INPUT.CHANNEL)
    {
      CASE 33 :    // Vol Up
      {
        IF(uAudiaVol[nVolChn].nMute)
	{
          //AUDIA_SetVolumeFn (2, AUDIA_VOL_MUTE_OFF)
	  AUDIA_SetVolumeFn (CurrentBg, AUDIA_VOL_MUTE_OFF)
	}
        ELSE
          //AUDIA_SetVolumeFn (2, AUDIA_VOL_UP)
	  AUDIA_SetVolumeFn (CurrentBg, AUDIA_VOL_UP)
      }
      CASE 34 :    // Vol Down
      {
        IF(uAudiaVol[nVolChn].nMute)
	{
          //AUDIA_SetVolumeFn (2, AUDIA_VOL_MUTE_OFF)
	  AUDIA_SetVolumeFn (CurrentBg,AUDIA_VOL_MUTE_OFF)
	}
        ELSE
	{
         //AUDIA_SetVolumeFn (2, AUDIA_VOL_DOWN)
	 AUDIA_SetVolumeFn (CurrentBg, AUDIA_VOL_DOWN)
	}
      }
      CASE 35 :    // Vol Mute
      {
        IF(uAudiaVol[nVolChn].nMute)
	{
          //AUDIA_SetVolumeFn (2, AUDIA_VOL_MUTE_OFF)
	  AUDIA_SetVolumeFn (CurrentBg, AUDIA_VOL_MUTE_OFF)
	}
        ELSE
	{
          //AUDIA_SetVolumeFn (2, AUDIA_VOL_MUTE)
	  AUDIA_SetVolumeFn (CurrentBg, AUDIA_VOL_MUTE)
	}
      }
    }*)
    

//    AUDIA_MatchVolumeLvl (2,1)      // Example: If this was a stereo pair
  }
  RELEASE :
  {
    //If(CurrentBg = 2)
	//AUDIA_SetVolumeFn (2, AUDIA_VOL_STOP)
    If(CurrentBg = 3)
	AUDIA_SetVolumeFn (3, AUDIA_VOL_STOP)
    If(CurrentBg = 4)
	AUDIA_SetVolumeFn (4, AUDIA_VOL_STOP)
  }
  HOLD[3,REPEAT] :
  {
  
    SWITCH(BUTTON.INPUT.CHANNEL)
    {
      CASE 33 :    // Vol Up
      {
        AUDIA_SetVolumeFn (CurrentBg, AUDIA_VOL_UP)
	AUDIA_SetVolumeFn (3, AUDIA_VOL_UP)
      }
      CASE 34 :    // Vol Down
      {
        AUDIA_SetVolumeFn (CurrentBg, AUDIA_VOL_DOWN)
	AUDIA_SetVolumeFn (3, AUDIA_VOL_DOWN)
      }
    }
   
    SWITCH(BUTTON.INPUT.CHANNEL)
    {
      CASE 33 :    // Vol Up
      {
        //AUDIA_SetVolumeFn (2, AUDIA_VOL_UP)
	AUDIA_SetVolumeFn (CurrentBg, AUDIA_VOL_UP)
      }
      CASE 34 :    // Vol Down
      {
        //AUDIA_SetVolumeFn (2, AUDIA_VOL_DOWN)
	AUDIA_SetVolumeFn (CurrentBg, AUDIA_VOL_DOWN)
      }
    }
   
    //AUDIA_MatchVolumeLvl (2,3)      // Example: If this was a stereo pair
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
BUTTON_EVENT[dvTp,81]		//Codec Clear Button.
{
    Push:
    {
	Call 'QUEUE ADD'(dvCodec1,"'button right',10",1,0)	//Make sure that we are at the end of the digits.
	FOR (COUNT=0 ; COUNT<40 ; COUNT++)
	{
	    Call 'QUEUE ADD'(dvCodec1,"'button left',10",1,0)
	    SEND_COMMAND dvTp,"'TEXT1- '"
	    //send_string dvCodec1,"'button left',10"
	}
    }
}
BUTTON_EVENT[dvTp,nCodecBtns]
{
    Push:
    {
	SWITCH(button.input.channel)
	{
	    Case 170:	//PIP Button
	    {
		If(Pip_on = 1)
		{
		    If(nPipLocation < 4)
		    {
			CodecCommand = "'pip location ',itoa(nPipLocation)"
			nPipLocation = nPipLocation + 1
		    }
		    Else
		    {
		   
			nPipLocation = 0
			CodecCommand = 'pip off'
			Pip_On = 0
		    }
		}
		Else	//Pip is Off
		{
		    Pip_On = 1
		    CodecCommand = 'pip on'
		    
		}
	    }
	    Case 171:
	    {
		CodecCommand = 'pip off'
	    }
	    Case 172:
	    {
		CodecCommand = 'button call'
	    }
	    Case 173:
	    {
		CodecCommand = 'hangup video'
	    }
	    Case 174:
	    {
		CodecCommand = 'button directory'
	    }
	    Case 175:
	    {
		CodecCommand = 'button far'
	    }
	    Case 176:
	    {
		CodecCommand = 'button graphics'
	    }
	    Case 177:
	    {
		CodecCommand = 'button near'
	    }
	    Case 178:
	    {
		CodecCommand = 'button zoom+'
	    }
	    Case 179:
	    {
		CodecCommand = 'button zoom-'
	    }
	    Case 180:
	    {
		CodecCommand = 'button zoom+'
	    }
	    Case 181:
	    {
		CodecCommand = 'button zoom+'
	    }
	    Case 182:
	    {
		CodecCommand = 'button zoom+'
	    }
	    Case 183:
	    {
		CodecCommand = 'button zoom+'
	    }
	    Case 184:
	    {
		CodecCommand = 'button zoom+'
	    }
	    Case 185:
	    {
		CodecCommand = 'button zoom+'
	    }
	    Case 186:
	    {
		CodecCommand = 'button zoom+'
	    }
	    Case 187:
	    {
		CodecCommand = 'button zoom+'
	    }
	    Case 188:
	    {
		CodecCommand = 'button zoom+'
	    }
	}
	SEND_STRING dvCodec1,"CodecCommand,10"
    }
}



/*TIMELINE_EVENT[TL2] // capture all events for Timeline 2
{ 
    switch(Timeline.Sequence) // which time was it? 
    { 
	case 1: 
	    {
		nCheckPwr[1] = 1
		SEND_STRING dvProj,"'PWR?',$0D"
	    } 
	case 2: { } 
	case 3:
	    {
	    } 
	case 4:
	    {
		
	    } 
    }
}*/

DEFINE_PROGRAM
(**************************)
(* Shutdown system at 9pm *)
(**************************)
If((time_to_hour(time) = 21)&&(time_to_minute(time) = 00)&&(nTimeBlock = 0))
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
SEND_LEVEL dvTp,1,AUDIA_GetBgLvl(CurrentBG)
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
 DEFINE_PROGRAM

SYSTEM_CALL [1] 'SONCA001' (dvCam,dvTp,PLR,PRB,TUB,TDB,ZTB,ZWB,FNB,FFB,AFB,MFB)

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

