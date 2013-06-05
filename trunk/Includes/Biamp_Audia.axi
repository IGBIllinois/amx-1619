PROGRAM_NAME='Biamp_Audia'
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(*  - Version 1.30 (04-24-2006) CWR                        *)
(*    -Fixed buffer parsing with GET/GETL, so user can     *)
(*     now ask for status and synchronization.             *)
(*                                                         *)
(*  - Version 1.20 (02-05-2004) CWR                        *)
(*    -Slowed down baud rate from 38400 to 9600.  The Audia*)
(*     was missing commands and the lower baud rates       *)
(*     helped eliminate this problem.                      *)
(*                                                         *)
(*  - Version 1.10 (01-08-2004) CWR                        *)
(*    -Increased AUDIA_VOL_MAX to 1150 (+15dB).            *)
(*     Found that "EQ Band Levels" can go as high as +15dB.*)
(*    -Set volume level to minimum when level is assigned  *)
(*     and it was previously out of range.                 *)
(*                                                         *)
(*  - Version 1.00 (12-08-2003) CWR                        *)
(*    -Original release.                                   *)
(*    -Requires AMX_ArrayLib.axi library file.             *)
(*    -Requires nAMX_QUEUE.axi library file.               *)
(***********************************************************)
(*
--------------------------------------------------
-Subroutines typically used by caller:
--------------------------------------------------
-DEFINE_FUNCTION INTEGER AUDIA_AssignVolumeParms (INTEGER nLvl, DEV dvCard, CHAR strVolCmd[], CHAR strMuteCmd[], INTEGER nVolMin, INTEGER nVolMax)
-DEFINE_FUNCTION INTEGER AUDIA_AssignVolumeLvl   (INTEGER nLvl, INTEGER nLvlValue)
-DEFINE_FUNCTION INTEGER AUDIA_SetVolumeLvl      (INTEGER nLvl, INTEGER nLvlValue)
-DEFINE_FUNCTION INTEGER AUDIA_MatchVolumeLvl    (INTEGER nLvl, INTEGER nLvl2)
-DEFINE_FUNCTION INTEGER AUDIA_SetVolumeFn       (INTEGER nLvl, INTEGER nFn)
-DEFINE_FUNCTION INTEGER AUDIA_GetBgLvl          (INTEGER nLvl)


--------------------------------------------------
-Subroutines defined by caller and called from include:
--------------------------------------------------


--------------------------------------------------
-Subroutines not typically used by caller:
--------------------------------------------------
-DEFINE_FUNCTION AUDIA_Init        (DEV dvCard, INTEGER nDevIdx)
-DEFINE_FUNCTION AUDIA_ParseBuffer (DEV dvCard, INTEGER nDevIdx)
-DEFINE_FUNCTION CHAR[6] AUDIA_GetTableLvlText (INTEGER nLvlValue)


*)


INCLUDE 'AMX_ArrayLib.axi'
INCLUDE 'nAMX_QUEUE.axi'


(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT


(*-- Biamp Audia ------------------------------------------*)
CHAR __AUDIA_VERSION__[]    = '1.10'
CHAR __AUDIA_NAME__[]       = 'Biamp_Audia Library'


(*-- Biamp Audia (User defineable parameters) -------------*)
#IF_NOT_DEFINED AUDIA_MAX_LVL
AUDIA_MAX_LVL       = 100 // Max number of levels to track ***Across entire dvAudiaList***
#END_IF

#IF_NOT_DEFINED AUDIA_VOL_UP_STEP
AUDIA_VOL_UP_STEP   = 30  // Ramp by this step value (Each value of 10 is 1dB, so 30 is 3dB)
#END_IF

#IF_NOT_DEFINED AUDIA_VOL_DOWN_STEP
AUDIA_VOL_DOWN_STEP = 30  // Ramp by this step value (Each value of 10 is 1dB, so 30 is 3dB)
#END_IF

#IF_NOT_DEFINED AUDIA_VOL_DELAY_STEP
AUDIA_VOL_DELAY_STEP= 1   // Delay between ramp steps (in 1/10 seconds)
#END_IF

#IF_NOT_DEFINED AUDIA_VOL_MAX
AUDIA_VOL_MAX       = 1150// Max volume level (+15dB)  ***Not to exceed 1150***
#END_IF

#IF_NOT_DEFINED AUDIA_VOL_MIN
AUDIA_VOL_MIN       = 0   // Min volume level (-100dB) ***Not to exceed 0***
#END_IF


(*-- Biamp Audia (Vol functions) --------------------------*)
AUDIA_VOL_UP        = 24
AUDIA_VOL_DOWN      = 25
AUDIA_VOL_MUTE      = 26
AUDIA_VOL_STOP      = 24 + 256
AUDIA_VOL_STOP2     = 25 + 256
AUDIA_VOL_MUTE_OFF  = 26 + 256


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE


(*-- Biamp Audia (Mixer state) ----------------------------*)
STRUCTURE _uAudiaInfo
{
  CHAR         strBuff[300]        // Receive buffer
  INTEGER      nDebugTX            // Flag, echo commands
  INTEGER      nDebugRX            // Flag, echo receives
}


(*-- Biamp Audia (Generic volume levels) ------------------*)
STRUCTURE _uAudiaVol
{
  INTEGER nMute                 // Mute state
  INTEGER nLvlValue             // Current volume level (0-22)
  INTEGER nBgLvl                // Current volume bargraph (0-255)
  INTEGER nPrevLvlValue         // Previous level to return with un-mute
  INTEGER nVolRamp              // Current ramp state (up or down)
  INTEGER nDevIdx               // Volume parm: points into dvAudiaList
  CHAR    strVolCmd[30]         // Volume parm: Biamp ATP command for volume control
  CHAR    strMuteCmd[30]        // Volume parm: Biamp ATP command for mute control
  INTEGER nVolMin               // Volume parm: Minimum volume level (0-1120, See integer table in Biamp protocol)
  INTEGER nVolMax               // Volume parm: Maximum volume level (0-1120, See integer table in Biamp protocol)
}


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE


(*-- Biamp Audia (232 device list) ------------------------*)
#IF_NOT_DEFINED AUDIA_MAX_DEV
CONSTANT INTEGER AUDIA_MAX_DEV   = 5  // Keep track of this many Biamp Audia 232 devices (should not exceed length of list)
#END_IF

#IF_NOT_DEFINED dvAudiaList
CONSTANT DEV dvAudiaList[] = { dvAUDIA1 }
#END_IF


(*-- Biamp Audia (Mixer state) ----------------------------*)
VOLATILE _uAudiaInfo uAudiaInfo[AUDIA_MAX_DEV]


(*-- Biamp Audia (Generic volume levels) ------------------*)
PERSISTENT _uAudiaVol  uAudiaVol[AUDIA_MAX_LVL]


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


(*---------------------------------------------------------*)
(* Assign these parameters (dvCard,strVolCmd,strMuteCmd,   *)
(* nVolMin,nVolMax) to this generic nLvl, so that remainder*)
(* of volume calls only need to pass this generic nLvl.    *)
(*                                                         *)
(* NOTES:                                                  *)
(*  -The strVolCmd and strMuteCmd are actual commands      *)
(*   supported by the Biamp Audia for any DSP blocks with  *)
(*   attributes that provide level/gain/mute control       *)
(*   functionality.                                        *)
(*  -When identifying the strVolCmd and strMuteCmd, the    *)
(*   caller would include all parms up to Value (see the   *)
(*   ATP command structure).  Obviously this code will     *)
(*   ramp the Value up/down for level control, so Value    *)
(*   should be omitted in the assignment.                  *)
(*  -When strMuteCmd is a null string (''), the mute       *)
(*   functionality will toggle the volume level between    *)
(*   volume minimum (typically -100) and the previous lvl. *)
(*  -The ATP command structure is (spaces between parms):  *)
(*        Cmd DevID Attr InstID Index1 Index2 Value<LF>    *)
(*  -In the examples below, you'd omit anything between [] *)
(*   for the parm assignments of strVolCmd and strMuteCmd. *)
(*  -Some common LEVEL commands are:                       *)
(*        SETL 1 INPLVL 6 1 [1120<LF>] ***Use Table***     *)
(*        SET 1 INPLVL 6 1 [12<LF>]    ***Use dB value***  *)
(*        SETL 1 OUTLVL 6 1 [0<LF>]    ***Use Table***     *)
(*        SET 1 OUTLVL 6 1 [-100<LF>]  ***Use dB value***  *)
(*  -Some common MUTE commands are:                        *)
(*        SET 1 INPMUTE 6 1 [1<LF>]                        *)
(*        SET 1 OUTMUTE 6 1 [0<LF>]                        *)
(*  -When using the Table format (SETL), the actual table  *)
(*   value is (dbLVL+100)*10.                              *)
(*  -This code tracks the level values in the table format *)
(*   where a level value is 0-1120.                        *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER AUDIA_AssignVolumeParms (INTEGER nLvl, DEV dvCard, CHAR strVolCmd[], CHAR strMuteCmd[], INTEGER nVolMin, INTEGER nVolMax)
STACK_VAR
  INTEGER nDevIdx
  INTEGER nAddr
  CHAR    strCmd[30]
{
(*-- Verify device pointer --*)
  nDevIdx = FIND_DEV_ARRAY(dvAudiaList,dvCard,1)

  IF((nDevIdx = 0) || (nDevIdx > AUDIA_MAX_DEV))
  {
    SEND_STRING 0,"'ERROR:',__AUDIA_NAME__"
    SEND_STRING 0,"'      AUDIA_AssignVolumeParms [DevIdx out of range (1-AUDIA_MAX_DEV)]'"
    RETURN(0)
  }

(*-- Verify minimum volume level --*)
  IF(nVolMin > nVolMax)
  {
    SEND_STRING 0,"'ERROR:',__AUDIA_NAME__"
    SEND_STRING 0,"'      AUDIA_AssignVolumeParms [VolMin out of range (cannot exceed nVolMax)]'"
    RETURN(0)
  }

(*-- Verify maximum volume level --*)
  IF(nVolMax > AUDIA_VOL_MAX)
  {
    SEND_STRING 0,"'ERROR:',__AUDIA_NAME__"
    SEND_STRING 0,"'      AUDIA_AssignVolumeParms [VolMax out of range (1-AUDIA_VOL_MAX)]'"
    RETURN(0)
  }

  uAudiaVol[nLvl].strVolCmd  = strVolCmd
  uAudiaVol[nLvl].strMuteCmd = strMuteCmd
  uAudiaVol[nLvl].nDevIdx    = nDevIdx
  uAudiaVol[nLvl].nVolMin    = nVolMin
  uAudiaVol[nLvl].nVolMax    = nVolMax

  IF((uAudiaVol[nLvl].nLvlValue < nVolMin) || (uAudiaVol[nLvl].nLvlValue > nVolMax))
  {
    uAudiaVol[nLvl].nLvlValue = nVolMin
    uAudiaVol[nLvl].nBgLvl    = ((uAudiaVol[nLvl].nLvlValue-uAudiaVol[nLvl].nVolMin) * 255) / (uAudiaVol[nLvl].nVolMax-uAudiaVol[nLvl].nVolMin)
  }

  RETURN(1)
}


(*---------------------------------------------------------*)
(* Caller wants a bargraph level (0-255).                  *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER AUDIA_GetBgLvl (INTEGER nLvl)
{
(*-- Verify level --*)
  IF((nLvl = 0) || (nLvl > AUDIA_MAX_LVL))
  {
    SEND_STRING 0,"'ERROR:',__AUDIA_NAME__"
    SEND_STRING 0,"'      AUDIA_GetBgLvl [DevIdx out of range (1-AUDIA_MAX_LVL)]'"
    RETURN(0)
  }

(*-- Let the caller have it --*)
  IF(uAudiaVol[nLvl].nMute)   RETURN(0)
  ELSE                        RETURN(uAudiaVol[nLvl].nBgLvl)
}


(*---------------------------------------------------------*)
(* Caller set volume externally and wants this code to sync*)
(* up.  Level values range from 0-1120.                    *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER AUDIA_AssignVolumeLvl (INTEGER nLvl, INTEGER nLvlValue)
{
(*-- Verify level --*)
  IF((nLvl = 0) || (nLvl > AUDIA_MAX_LVL))
  {
    SEND_STRING 0,"'ERROR:',__AUDIA_NAME__"
    SEND_STRING 0,"'      AUDIA_AssignVolumeLvl [DevIdx out of range (1-AUDIA_MAX_LVL)]'"
    RETURN(0)
  }

(*-- Verify minimum volume level --*)
  IF(nLvlValue < uAudiaVol[nLvl].nVolMin)
  {
    SEND_STRING 0,"'ERROR:',__AUDIA_NAME__"
    SEND_STRING 0,"'      AUDIA_AssignVolumeLvl [Volume level out of range (0-uAudiaVol[nLvl].nVolMin)]'"
    RETURN(0)
  }

(*-- Verify maximum volume level --*)
  IF(nLvlValue > uAudiaVol[nLvl].nVolMax)
  {
    SEND_STRING 0,"'ERROR:',__AUDIA_NAME__"
    SEND_STRING 0,"'      AUDIA_AssignVolumeLvl [Volume level out of range (0-uAudiaVol[nLvl].nVolMax)]'"
    RETURN(0)
  }

(*-- If this level does not have a MUTE cmd (it sets it's level to 0 for mute) --*)
  IF(LENGTH_STRING(uAudiaVol[nLvl].strMuteCmd) = 0)
  {
    uAudiaVol[nLvl].nMute         = 0
    uAudiaVol[nLvl].nPrevLvlValue = 0
  }

  uAudiaVol[nLvl].nLvlValue = nLvlValue
  uAudiaVol[nLvl].nBgLvl    = ((nLvlValue-uAudiaVol[nLvl].nVolMin) * 255) / (uAudiaVol[nLvl].nVolMax-uAudiaVol[nLvl].nVolMin)

  RETURN(1)
}


(*---------------------------------------------------------*)
(* Caller wants to set an absolute volume level.  If this  *)
(* level's vol parm is table format (SETL), then the value *)
(* is 0-1120.  If this level's vol parm is not table format*)
(* (SET), then the value is -100 to 12.                    *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER AUDIA_SetVolumeLvl (INTEGER nLvl, INTEGER nLvlValue)
STACK_VAR
  DEV     dvCard
  INTEGER nAddr
  INTEGER nVolChn
{
(*-- Verify level --*)
  IF((nLvl = 0) || (nLvl > AUDIA_MAX_LVL))
  {
    SEND_STRING 0,"'ERROR:',__AUDIA_NAME__"
    SEND_STRING 0,"'      AUDIA_SetVolumeLvl [DevIdx out of range (1-AUDIA_MAX_LVL)]'"
    RETURN(0)
  }

(*-- Verify minimum volume level --*)
  IF((nLvlValue <> 0) && (nLvlValue < uAudiaVol[nLvl].nVolMin))
  {
    SEND_STRING 0,"'ERROR:',__AUDIA_NAME__"
    SEND_STRING 0,"'      AUDIA_SetVolumeLvl [Volume level out of range (0-uAudiaVol[nLvl].nVolMin)]'"
    RETURN(0)
  }

(*-- Verify maximum volume level --*)
  IF(nLvlValue > uAudiaVol[nLvl].nVolMax)
  {
    SEND_STRING 0,"'ERROR:',__AUDIA_NAME__"
    SEND_STRING 0,"'      AUDIA_SetVolumeLvl [Volume level out of range (0-uAudiaVol[nLvl].nVolMax)]'"
    RETURN(0)
  }

(*-- If this level does not have a MUTE cmd (it sets it's level to 0 for mute) --*)
  IF(LENGTH_STRING(uAudiaVol[nLvl].strMuteCmd) = 0)
  {
    IF(nLvlValue = 0)
    {
      uAudiaVol[nLvl].nMute         = 1
      IF(uAudiaVol[nLvl].nLvlValue)
        uAudiaVol[nLvl].nPrevLvlValue = uAudiaVol[nLvl].nLvlValue
    }
    ELSE
    {
      uAudiaVol[nLvl].nMute         = 0
      uAudiaVol[nLvl].nPrevLvlValue = 0
    }
  }

(*-- Build the level command and send it --*)
  dvCard = dvAudiaList[uAudiaVol[nLvl].nDevIdx]

  IF(FIND_STRING(uAudiaVol[nLvl].strVolCmd,"'SETL '",1))
    CALL 'QUEUE ADD' (dvCard, "uAudiaVol[nLvl].strVolCmd,ITOA(nLvlValue),10", AUDIA_VOL_DELAY_STEP, 0)
  ELSE
    CALL 'QUEUE ADD' (dvCard, "uAudiaVol[nLvl].strVolCmd,AUDIA_GetTableLvlText(nLvlValue),10", AUDIA_VOL_DELAY_STEP, 0)

  uAudiaVol[nLvl].nLvlValue = nLvlValue
  uAudiaVol[nLvl].nBgLvl    = ((nLvlValue-uAudiaVol[nLvl].nVolMin) * 255) / (uAudiaVol[nLvl].nVolMax-uAudiaVol[nLvl].nVolMin)

  RETURN(1)
}


(*---------------------------------------------------------*)
(* Caller wants to match 2 volume levels.  This is good    *)
(* for stereo pairs.                                       *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER AUDIA_MatchVolumeLvl (INTEGER nLvl, INTEGER nLvl2)
STACK_VAR
  DEV     dvCard
  INTEGER nAddr
  INTEGER nVolChn
{
(*-- Verify level --*)
  IF((nLvl = 0) || (nLvl > AUDIA_MAX_LVL))
  {
    SEND_STRING 0,"'ERROR:',__AUDIA_NAME__"
    SEND_STRING 0,"'      AUDIA_MatchVolumeLvl [DevIdx out of range (1-AUDIA_MAX_LVL)]'"
    RETURN(0)
  }

  IF((nLvl2 = 0) || (nLvl2 > AUDIA_MAX_LVL))
  {
    SEND_STRING 0,"'ERROR:',__AUDIA_NAME__"
    SEND_STRING 0,"'      AUDIA_MatchVolumeLvl [DevIdx out of range (1-AUDIA_MAX_LVL)]'"
    RETURN(0)
  }


(*-- Sync up nLvl to nLvl2 --*)
  IF(uAudiaVol[nLvl2].nMute)
  {
    uAudiaVol[nLvl].nMute         = 1
    uAudiaVol[nLvl].nLvlValue     = 0
    uAudiaVol[nLvl].nPrevLvlValue = uAudiaVol[nLvl2].nPrevLvlValue

    IF(LENGTH_STRING(uAudiaVol[nLvl].strMuteCmd))
      AUDIA_SetVolumeFn (nLvl, AUDIA_VOL_MUTE)
    ELSE
      AUDIA_SetVolumeLvl (nLvl, 0)
  }
  ELSE
  {
    uAudiaVol[nLvl].nLvlValue     = uAudiaVol[nLvl2].nLvlValue
    uAudiaVol[nLvl].nBgLvl        = ((uAudiaVol[nLvl].nLvlValue-uAudiaVol[nLvl].nVolMin) * 255) / (uAudiaVol[nLvl].nVolMax-uAudiaVol[nLvl].nVolMin)

    IF(LENGTH_STRING(uAudiaVol[nLvl].strMuteCmd) && uAudiaVol[nLvl].nMute)
      AUDIA_SetVolumeFn (nLvl, AUDIA_VOL_MUTE_OFF)

    AUDIA_SetVolumeLvl (nLvl, uAudiaVol[nLvl].nLvlValue)
  }

  RETURN(1)
}


(*---------------------------------------------------------*)
(* Caller wants to execute a volume function.              *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER AUDIA_SetVolumeFn (INTEGER nLvl, INTEGER nFn)
{
(*-- Verify level --*)
  IF((nLvl = 0) || (nLvl > AUDIA_MAX_LVL))
  {
    SEND_STRING 0,"'ERROR:',__AUDIA_NAME__"
    SEND_STRING 0,"'      AUDIA_SetVolumeLvl [DevIdx out of range (1-AUDIA_MAX_LVL)]'"
    RETURN(0)
  }


(*-- Volume Functions --*)
  SWITCH(nFn)
  {
  (*--------------------*)
  (*-- Volume Ramping --*)
  (*--------------------*)
    CASE AUDIA_VOL_UP :
    {
      uAudiaVol[nLvl].nVolRamp = AUDIA_VOL_UP

      uAudiaVol[nLvl].nLvlValue = uAudiaVol[nLvl].nLvlValue + AUDIA_VOL_UP_STEP

      IF(uAudiaVol[nLvl].nLvlValue >= uAudiaVol[nLvl].nVolMax)
      {
        uAudiaVol[nLvl].nLvlValue  = uAudiaVol[nLvl].nVolMax
        uAudiaVol[nLvl].nVolRamp = 0
      }

      AUDIA_SetVolumeLvl (nLvl, uAudiaVol[nLvl].nLvlValue)
    }
    CASE AUDIA_VOL_DOWN :
    {
      uAudiaVol[nLvl].nVolRamp = AUDIA_VOL_DOWN

      uAudiaVol[nLvl].nLvlValue = uAudiaVol[nLvl].nLvlValue - AUDIA_VOL_DOWN_STEP

      IF((uAudiaVol[nLvl].nLvlValue <= uAudiaVol[nLvl].nVolMin) ||
         (uAudiaVol[nLvl].nLvlValue >  uAudiaVol[nLvl].nVolMax))
      {
        uAudiaVol[nLvl].nLvlValue  = uAudiaVol[nLvl].nVolMin
        uAudiaVol[nLvl].nVolRamp = 0
      }

      AUDIA_SetVolumeLvl (nLvl, uAudiaVol[nLvl].nLvlValue)
    }
    CASE AUDIA_VOL_STOP :
    CASE AUDIA_VOL_STOP2 :
    {
      uAudiaVol[nLvl].nVolRamp = 0
    }
  (*-------------------*)
  (*-- Volume Muting --*)
  (*-------------------*)
    CASE AUDIA_VOL_MUTE :
    {
      IF(!uAudiaVol[nLvl].nMute)
        uAudiaVol[nLvl].nPrevLvlValue = uAudiaVol[nLvl].nLvlValue

      uAudiaVol[nLvl].nMute     = 1
      uAudiaVol[nLvl].nLvlValue = 0

      IF(LENGTH_STRING(uAudiaVol[nLvl].strMuteCmd))
        CALL 'QUEUE ADD' (dvAudiaList[uAudiaVol[nLvl].nDevIdx], "uAudiaVol[nLvl].strMuteCmd,'1',10", 5, 0)
      ELSE
        AUDIA_SetVolumeLvl (nLvl, uAudiaVol[nLvl].nLvlValue)
    }
    CASE AUDIA_VOL_MUTE_OFF :
    {
      IF(uAudiaVol[nLvl].nPrevLvlValue)
        uAudiaVol[nLvl].nLvlValue = uAudiaVol[nLvl].nPrevLvlValue

      uAudiaVol[nLvl].nMute   = 0
      uAudiaVol[nLvl].nPrevLvlValue = 0

      IF(LENGTH_STRING(uAudiaVol[nLvl].strMuteCmd))
        CALL 'QUEUE ADD' (dvAudiaList[uAudiaVol[nLvl].nDevIdx], "uAudiaVol[nLvl].strMuteCmd,'0',10", 5, 0)
      ELSE
        AUDIA_SetVolumeLvl (nLvl, uAudiaVol[nLvl].nLvlValue)
    }
  }
}


(*-------------------------------------------------------------------------------------*)
(*------------------------------ Internal Calls ---------------------------------------*)
(*-------------------------------------------------------------------------------------*)
(*---------------------------------------------------------*)
(* Initialize the device.                                  *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION AUDIA_Init (DEV dvCard, INTEGER nDevIdx)
{
  SEND_COMMAND dvCard,"'SET BAUD 38400,N,8,1 485 DISABLE'"
  SEND_COMMAND dvCard,"'HSOFF'"
}


(*---------------------------------------------------------*)
(* Caller wants the dB level text for this table value.    *)
(* Valid values are -100 to 12 with .1 resolution.         *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION CHAR[6] AUDIA_GetTableLvlText (INTEGER nLvlValue)
STACK_VAR
  FLOAT nValue
{
(*-- Verify maximum volume level --*)
  IF(nLvlValue > 1120)
  {
    SEND_STRING 0,"'ERROR:',__AUDIA_NAME__"
    SEND_STRING 0,"'      AUDIA_GetTableLvlText [Volume level out of range (0-1120)]'"
    RETURN(0)
  }

(*-- Had to copy to a Float to get the FTOA() to work, dunno why --*)
  nValue = TYPE_CAST(nLvlValue)
  RETURN (LEFT_STRING(FTOA((nValue/10)-100),6))
}


(*---------------------------------------------------------*)
(* Parse responses from an AUDIA unit.                     *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION AUDIA_ParseBuffer (DEV dvCard, INTEGER nDevIdx)
STACK_VAR
  CHAR strResponse[200]
  CHAR strCmd[100]
{
(*-- Look for terminator --*)
  strResponse = REMOVE_STRING(uAudiaInfo[nDevIdx].strBuff,"13,10",1)

(*-- Cleanup and echo --*)
  IF(LENGTH_STRING(strResponse))
  {
    SET_LENGTH_STRING(strResponse,LENGTH_STRING(strResponse)-2)

    IF(uAudiaInfo[nDevIdx].nDebugRX)
      SEND_STRING 0,"'Biamp Audia [',ITOA(nDevIdx),'] RESPONSE:',strResponse"
  }

(*-- Get the last command sent to device --*)
  strCmd = QueueGetLast(dvCard)

(*-- Parse this response --*)
  SELECT
  {
  (*----------------------------*)
  (* Incomplete response        *)
  (*----------------------------*)
    ACTIVE(LENGTH_STRING(strResponse) = 0) :
    {
    }
  (*----------------------------*)
  (* Acks                       *)
  (*----------------------------*)
    ACTIVE(FIND_STRING(strResponse,"'+OK'",1)) :
    {
      CALL 'QUEUE ADVANCE' (dvCard)
    }
  (*----------------------------*)
  (* Nacks                      *)
  (*----------------------------*)
    ACTIVE(FIND_STRING(strResponse,"'-ERR'",1)) :
    {
      SEND_STRING 0,"'Biamp Audia [',ITOA(nDevIdx),'] WARNING: ERROR Returned for LAST CMD'"
      SEND_STRING 0,"'   LAST CMD=',strCmd"

      CALL 'QUEUE ADVANCE' (dvCard)
    }
  (*----------------------------*)
  (* Responses                  *)
  (*----------------------------*)
    ACTIVE(1) :
    {
      SELECT
      {
  (*----------------------------*)
  (* Responses-Get Queries      *)
  (*----------------------------*)
        ACTIVE(FIND_STRING(strCmd,"'GETL '",1) || FIND_STRING(strCmd,"'GET '",1)) :
        {
          STACK_VAR INTEGER nLvl
          STACK_VAR CHAR    strTrash[200]

//----------------------------------
// Possible Get queries:
//----------------------------------
//  strCmd= %GET %[1 INPLVL 1 1]        // NOTE: Remove everything between %% which leaves us [] to search the Parms table
//  strCmd=%GETL %[1 INPLVL 1 1]        // NOTE: Remove everything between %% which leaves us [] to search the Parms table
//----------------------------------
// Possible Set Parms in our table:
//----------------------------------
//  strVolCmd= %SET %[1 INPLVL 1 1]     // NOTE: Search Parms table for everything between [] from strCmd
//  strVolCmd=%SETL %[1 INPLVL 1 1]     // NOTE: Search Parms table for everything between [] from strCmd
//----------------------------------
// Typical responses:
//----------------------------------
//        =1.0000

          strTrash = REMOVE_STRING(strCmd,"'GETL '",1)
          strTrash = REMOVE_STRING(strCmd,"'GET '",1)

        (*-- Look for matches in our Parms tables (vol and mute) --*)
          FOR(nLvl=1; nLvl<=AUDIA_MAX_LVL; nLvl++)
          {
            SELECT
            {
            (*-- Response may match a volume level from our Parms table --*)
              ACTIVE(FIND_STRING(uAudiaVol[nLvl].strVolCmd,"strCmd",1)) :
              {
                IF(uAudiaVol[nLvl].strVolCmd = "'SETL ',strCmd,10")
                {
                  uAudiaVol[nLvl].nLvlValue = ATOI(strResponse)
                  BREAK;
                }
                ELSE IF(uAudiaVol[nLvl].strVolCmd = "'SET ',strCmd,10")
                {
                  uAudiaVol[nLvl].nLvlValue = ATOI(strResponse)
                  BREAK;
                }
              }
            (*-- Response may match a mute from our Parms table --*)
              ACTIVE(FIND_STRING(uAudiaVol[nLvl].strMuteCmd,"strCmd",1)) :
              {
                IF(uAudiaVol[nLvl].strMuteCmd = "'SETL ',strCmd,10")
                {
                  uAudiaVol[nLvl].nMute = ATOI(strResponse)
                  BREAK;
                }
                ELSE IF(uAudiaVol[nLvl].strMuteCmd = "'SET ',strCmd,10")
                {
                  uAudiaVol[nLvl].nMute = ATOI(strResponse)
                  BREAK;
                }
              }
            }
          }

        (*-- WARNING: No match found in our Parms tables (vol and mute) --*)
          IF(nLvl > AUDIA_MAX_LVL)
          {
            SEND_STRING 0,"'Biamp Audia [',ITOA(nDevIdx),'] WARNING: GET query not found in parms table.'"
            SEND_STRING 0,"'                                          Query response will be ignored!.'"
            SEND_STRING 0,"'   LAST CMD=',QueueGetLast(dvCard)"
            SEND_STRING 0,"'   RESPONSE=',strResponse"
          }

          CALL 'QUEUE ADVANCE' (dvCard)
        }
  (*----------------------------*)
  (* Responses-Unhandled        *)
  (*----------------------------*)
        ACTIVE(1) :
        {
          SEND_STRING 0,"'Biamp Audia [',ITOA(nDevIdx),'] WARNING: Unhandled response'"
          SEND_STRING 0,"'   Response=',strResponse"
        }
      }
    }
  }
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START


(***********************************************************)
(*                THE EVENTS GOES BELOW                    *)
(***********************************************************)
DEFINE_EVENT


(*---------------------------------------------------------*)
(* Array of BIAMP mixers.                                  *)
(*---------------------------------------------------------*)
DATA_EVENT[dvAudiaList]
{
  ONLINE :
  {
    STACK_VAR INTEGER nDevIdx

    nDevIdx = GET_LAST(dvAudiaList)

    AUDIA_Init (DATA.DEVICE, nDevIdx)

  (*-- Need a queue --*)
    CALL 'QUEUE RESET' (DATA.DEVICE)

    IF(uAudiaInfo[nDevIdx].nDebugTX)
      CALL 'QUEUE DEBUG ASCII' (DATA.DEVICE)
    ELSE
      CALL 'QUEUE DEBUG OFF' (DATA.DEVICE)
  }
  STRING :
  {
    STACK_VAR INTEGER nDevIdx

    nDevIdx = GET_LAST(dvAudiaList)

    uAudiaInfo[nDevIdx].strBuff = "uAudiaInfo[nDevIdx].strBuff,DATA.TEXT"

    WHILE(FIND_STRING(uAudiaInfo[nDevIdx].strBuff,"13,10",1))
      AUDIA_ParseBuffer (DATA.DEVICE, nDevIdx)
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

