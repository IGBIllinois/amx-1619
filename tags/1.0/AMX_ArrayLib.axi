PROGRAM_NAME='AMX_ArrayLib'
(***********************************************************)
(* System Type : Netlinx                                   *)
(***********************************************************)
(*  - Version 1.33 (01-20-2004)                            *)
(*    - Changed pre-processor directives so they will work.*)
(*      The compiler does not use a function name as a pre-*)
(*      process declaration, so additional #DEFINEs are    *)
(*      required so that any single function call could    *)
(*      be used in other files without errors or warnings. *)
(*                                                         *)
(*  - Version 1.32 (07-18-2003)                            *)
(*    - Removed GET_XML_VALUE.  Now creating XML parsing   *)
(*      library include where this function is a more      *)
(*      suitable location.                                 *)
(*                                                         *)
(*  - Version 1.31 (07-17-2003)                            *)
(*    - Fixed bug in GET_xxx_ARRAY_OCC functions, where the*)
(*      parameter is appended at MAX_LENGTH_ARRAY.  This   *)
(*      way, when over-runs occur, the last array position *)
(*      will contain the last valid data for each of the   *)
(*      next get overruns.                                 *)
(*                                                         *)
(*  - Version 1.30 (07-16-2003)                            *)
(*    - Added GET_DEV_ARRAY_OCC                            *)
(*    - Added GET_INT_ARRAY_OCC                            *)
(*                                                         *)
(*  - Version 1.20 (07-01-2003)                            *)
(*    - Added STRING_REPLACE                               *)
(*    - Added GET_XML_VALUE                                *)
(*    - Added GET_LEFT_VALUE                               *)
(*    - Added GET_MID_VALUE                                *)
(*    - Added GET_RIGHT_VALUE                              *)
(*                                                         *)
(*  - Version 1.10 (05-01-2003)                            *)
(*    - Entire file wrapped around #IF_NOT_DEFINED.  This  *)
(*      way this file can be included from several other   *)
(*      includes, but only the first copy is used.         *)
(*                                                         *)
(*  - Version 1.00 (04-01-2003)                            *)
(*    - Original release.                                  *)
(***********************************************************)
#IF_NOT_DEFINED __AMX_ARRAY_LIB__
#DEFINE __AMX_ARRAY_LIB__

(*
-------------------------------
Common functions used:
-------------------------------
-DEFINE_FUNCTION INTEGER APPEND_DEV_ARRAY(DEV myArray[], DEV myDev)
-DEFINE_FUNCTION INTEGER FIND_DEV_ARRAY  (DEV myArray[], DEV myDev, INTEGER nStart)
-DEFINE_FUNCTION INTEGER REMOVE_DEV_ARRAY(DEV myArray[], DEV myDev, INTEGER nStart)
-DEFINE_FUNCTION INTEGER GET_DEV_ARRAY_PTR(DEV myArray[], DEV myDev)

-DEFINE_FUNCTION INTEGER APPEND_INT_ARRAY(INTEGER myArray[], INTEGER myInt)
-DEFINE_FUNCTION INTEGER FIND_INT_ARRAY  (INTEGER myArray[], INTEGER myInt, INTEGER nStart)
-DEFINE_FUNCTION INTEGER REMOVE_INT_ARRAY(INTEGER myArray[], INTEGER myInt, INTEGER nStart)
-DEFINE_FUNCTION INTEGER GET_INT_ARRAY_PTR(DEV myArray[], DEV myInt)

-DEFINE_FUNCTION CHAR[] STRING_REPLACE  (CHAR strTEXT[], CHAR strSEARCH[], CHAR strREPLACE[])

-DEFINE_FUNCTION CHAR[] GET_LEFT_VALUE  (CHAR strTEXT[], CHAR strLEFT[])
-DEFINE_FUNCTION CHAR[] GET_MID_VALUE   (CHAR strTEXT[], CHAR strSTART[], CHAR strEND)
-DEFINE_FUNCTION CHAR[] GET_RIGHT_VALUE (CHAR strTEXT[], CHAR strRIGHT[])

*)
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

(* Version For Code *)
CHAR __ARRAY_LIB_VERSION__[]    = '1.33'


#IF_NOT_DEFINED STRING_REPLACE_MAX_LEN
STRING_REPLACE_MAX_LEN  = 1024          // Max length of return value
#END_IF

#IF_NOT_DEFINED XML_MAX_LEN_RET
XML_MAX_LEN_RET       = 2048            // Max length of return value
#END_IF

#IF_NOT_DEFINED MID_MAX_LEN_RET
MID_MAX_LEN_RET       = 1024            // Max length of return value
#END_IF

#IF_NOT_DEFINED LEFT_MAX_LEN_RET
LEFT_MAX_LEN_RET      = 1024            // Max length of return value
#END_IF

#IF_NOT_DEFINED RIGHT_MAX_LEN_RET
RIGHT_MAX_LEN_RET     = 1024            // Max length of return value
#END_IF

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

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


#IF_NOT_DEFINED __APPEND_DEV_ARRAY__
#DEFINE __APPEND_DEV_ARRAY__
(*---------------------------------------------------------*)
(* Works like a string concatenation.                      *)
(* Returns the new length after the append.                *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER APPEND_DEV_ARRAY(DEV myArray[], DEV myDev)
STACK_VAR
  INTEGER nLoop
{
  FOR(nLoop=1; nLoop<=MAX_LENGTH_ARRAY(myArray); nLoop++)
  {
    IF(nLoop > LENGTH_ARRAY(myArray))
    {
      myArray[nLoop] = MyDev
      SET_LENGTH_ARRAY(myArray,nLoop)
      RETURN(nLoop)
    }
  }

  RETURN(0)
}
#END_IF


#IF_NOT_DEFINED __FIND_DEV_ARRAY__
#DEFINE __FIND_DEV_ARRAY__
(*---------------------------------------------------------*)
(* Works like a string find for a single DEV in an array.  *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER FIND_DEV_ARRAY(DEV myArray[], DEV myDev, INTEGER nStart)
STACK_VAR
  INTEGER nLoop
{
  FOR(nLoop=nStart; nLoop<=LENGTH_ARRAY(myArray); nLoop++)
  {
    IF(myDev = myArray[nLoop])
      RETURN(nLoop)
  }

  RETURN(0)
}
#END_IF


#IF_NOT_DEFINED __REMOVE_DEV_ARRAY__
#DEFINE __REMOVE_DEV_ARRAY__
(*---------------------------------------------------------*)
(* Does a DEV remove from the list and shifts all others.  *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER REMOVE_DEV_ARRAY(DEV myArray[], DEV myDev, INTEGER nStart)
STACK_VAR
  INTEGER nLoop
  INTEGER nLoop2
{
  FOR(nLoop=nStart; nLoop<=LENGTH_ARRAY(myArray); nLoop++)
  {
    IF(myDev = myArray[nLoop])
    {
    // Shift all array values left 1 position
      FOR(nLoop2=nLoop+1; nLoop2<=LENGTH_ARRAY(myArray); nLoop2++, nLoop++)
        myArray[nLoop] = myArray[nLoop2]

    // Reset length
      SET_LENGTH_ARRAY(myArray,LENGTH_ARRAY(myArray)-1)

      RETURN(LENGTH_ARRAY(myArray))
    }
  }

  RETURN(0)
}
#END_IF


#IF_NOT_DEFINED __GET_DEV_ARRAY_OCC__
#DEFINE __GET_DEV_ARRAY_OCC__
(*---------------------------------------------------------*)
(* Find an index, append it, or passback a max and notify. *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER GET_DEV_ARRAY_OCC(DEV myArray[], DEV myDev)
STACK_VAR
  INTEGER nOcc
{
// Find it
  nOcc = FIND_DEV_ARRAY(myArray, myDev, 1)

// Add it
  IF(nOcc = 0)
    nOcc = APPEND_DEV_ARRAY(myArray, myDev)

// Error..Notify and set to max
  IF(nOcc = 0)
  {
    nOcc = MAX_LENGTH_ARRAY(myArray)
    MyArray[nOcc] = myDev
    SEND_STRING 0,"'ERROR (GET_DEV_ARRAY_OCC)..exceeded max length, data WILL be lost!'"
    SEND_STRING 0,"'      You should increase the OCC table size!!'"
  }

  RETURN(nOcc)
}
#END_IF


#IF_NOT_DEFINED __APPEND_INT_ARRAY__
#DEFINE __APPEND_INT_ARRAY__
(*---------------------------------------------------------*)
(* Works like a string concatenation.                      *)
(* Returns the new length after the append.                *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER APPEND_INT_ARRAY(INTEGER myArray[], INTEGER myInt)
STACK_VAR
  INTEGER nLoop
{
  FOR(nLoop=1; nLoop<=MAX_LENGTH_ARRAY(myArray); nLoop++)
  {
    IF(nLoop > LENGTH_ARRAY(myArray))
    {
      myArray[nLoop] = myInt
      SET_LENGTH_ARRAY(myArray,nLoop)
      RETURN(nLoop)
    }
  }

  RETURN(0)
}
#END_IF


#IF_NOT_DEFINED __FIND_INT_ARRAY__
#DEFINE __FIND_INT_ARRAY__
(*---------------------------------------------------------*)
(* Works like a string find for a single INT in an array.  *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER FIND_INT_ARRAY(INTEGER myArray[], INTEGER myInt, INTEGER nStart)
STACK_VAR
  INTEGER nLoop
{
  FOR(nLoop=nStart; nLoop<=LENGTH_ARRAY(myArray); nLoop++)
  {
    IF(myInt = myArray[nLoop])
      RETURN(nLoop)
  }

  RETURN(0)
}
#END_IF


#IF_NOT_DEFINED __REMOVE_INT_ARRAY__
#DEFINE __REMOVE_INT_ARRAY__
(*---------------------------------------------------------*)
(* Does a INT remove from the list and shifts all others.  *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER REMOVE_INT_ARRAY(INTEGER myArray[], INTEGER myInt, INTEGER nStart)
STACK_VAR
  INTEGER nLoop
  INTEGER nLoop2
{
  FOR(nLoop=nStart; nLoop<=LENGTH_ARRAY(myArray); nLoop++)
  {
    IF(myInt = myArray[nLoop])
    {
    // Shift all array values left 1 position
      FOR(nLoop2=nLoop+1; nLoop2<=LENGTH_ARRAY(myArray); nLoop2++, nLoop++)
        myArray[nLoop] = myArray[nLoop2]

    // Reset length
      SET_LENGTH_ARRAY(myArray,LENGTH_ARRAY(myArray)-1)

      RETURN(LENGTH_ARRAY(myArray))
    }
  }

  RETURN(0)
}
#END_IF


#IF_NOT_DEFINED __GET_INT_ARRAY_OCC__
#DEFINE __GET_INT_ARRAY_OCC__
(*---------------------------------------------------------*)
(* Find an index, append it, or passback a max and notify. *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER GET_INT_ARRAY_OCC(INTEGER myArray[], INTEGER myInt)
STACK_VAR
  INTEGER nOcc
{
// Find it
  nOcc = FIND_INT_ARRAY(myArray, myInt, 1)

// Add it
  IF(nOcc = 0)
    nOcc = APPEND_INT_ARRAY(myArray, myInt)

// Error..Notify and set to max
  IF(nOcc = 0)
  {
    nOcc = MAX_LENGTH_ARRAY(myArray)
    MyArray[nOcc] = myInt
    SEND_STRING 0,"'ERROR (GET_INT_ARRAY_OCC)..exceeded max length, data WILL be lost!'"
    SEND_STRING 0,"'      You should increase the OCC table size!!'"
  }

  RETURN(nOcc)
}
#END_IF


#IF_NOT_DEFINED __STRING_REPLACE__
#DEFINE __STRING_REPLACE__
(*-----------------------*)
(* NAME: STRING_REPLACE  *)
(*---------------------------------------------------------*)
(*---------------------------------------------------------*)
DEFINE_FUNCTION CHAR[STRING_REPLACE_MAX_LEN] STRING_REPLACE(CHAR strSTR[],CHAR strSEARCH[],CHAR strREPLACE[])
STACK_VAR
INTEGER nPOS
CHAR strTRASH[STRING_REPLACE_MAX_LEN]
CHAR strTEMP_STR[STRING_REPLACE_MAX_LEN]
{
  (* QUICK OUT *)
  nPOS = FIND_STRING(strSTR, "strSEARCH", 1)
  IF (!nPOS)
    RETURN strSTR;

  (* LOOP AND REPLACE *)
  WHILE (nPOS)
  {
    (* REBUILD STRING AND REPLACE NEW CHARACTER *)
    strTEMP_STR = ""
    IF (nPOS > 1)
      strTEMP_STR = LEFT_STRING(strSTR, nPOS - 1)
    strTRASH = REMOVE_STRING(strSTR, "strTEMP_STR,strSEARCH", 1)
    strSTR = "strTEMP_STR,strREPLACE,strSTR"
    (* MAKE WE START AT nPOS + LEN OF REPLACE OR WE LOOP FOREVER *)
    (* AND BLOW THE STACK IF WE REPLACE WITH PORTION OF SEARCH! *)
    nPOS = FIND_STRING(strSTR, "strSEARCH", nPOS + LENGTH_STRING(strREPLACE))
  }
  RETURN strSTR;
}
#END_IF


#IF_NOT_DEFINED __GET_MID_VALUE__
#DEFINE __GET_MID_VALUE__
(*---------------------*)
(* NAME: GET_MID_VALUE *)
(*---------------------------------------------------------*)
(* Parses <Start>Value to return<End> and returns the      *)
(* value.  Looks alot like GET_XML_VALUE except caller can *)
(* pass in the start/end parameters.                       *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION CHAR[MID_MAX_LEN_RET] GET_MID_VALUE(CHAR strTEXT[],CHAR strSTART[], CHAR strEND[])
STACK_VAR
  INTEGER FIRST
  INTEGER LAST
  INTEGER COUNT
{
(*-- Look for it with a quick bail-out --*)
  FIRST = FIND_STRING(strTEXT,"strSTART",1)
  IF(FIRST)
    LAST  = FIND_STRING(strTEXT,"strEND",FIRST)

  IF((FIRST=0) || (LAST=0))
    RETURN ("");

(*-- Set the count (of value) --*)
  FIRST = FIRST + LENGTH_STRING(strSTART)
  COUNT = LAST - FIRST

(*-- Error check and return the value --*)
  IF(COUNT > MID_MAX_LEN_RET)
  {
    SEND_STRING 0,"'WARNING - AMX_ArrayLib (GET_MID_VALUE)..Max length exceeded, data WILL be lost..'"
    RETURN MID_STRING(strTEXT,FIRST,MID_MAX_LEN_RET)
  }
  ELSE
    RETURN MID_STRING(strTEXT,FIRST,COUNT)
}
#END_IF


#IF_NOT_DEFINED __GET_LEFT_VALUE__
#DEFINE __GET_LEFT_VALUE__
(*----------------------*)
(* NAME: GET_LEFT_VALUE *)
(*---------------------------------------------------------*)
(* Parses 'Value=Value to return' and returns everything   *)
(* that remains after 'Value='.                            *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION CHAR[LEFT_MAX_LEN_RET] GET_LEFT_VALUE(CHAR strTEXT[],CHAR strLEFT[])
STACK_VAR
  INTEGER FIRST
  INTEGER LAST
  INTEGER COUNT
{
(*-- Look for it with a quick bail-out --*)
  FIRST = FIND_STRING(strTEXT,"strLEFT",1)
  LAST  = LENGTH_STRING(strTEXT)

  IF((FIRST=0) || (LAST=0))
    RETURN ("");

(*-- Set the count (of value) --*)
  FIRST = FIRST + LENGTH_STRING(strLEFT)
  COUNT = LAST - FIRST + 1

(*-- Error check and return the value --*)
  IF(COUNT > LEFT_MAX_LEN_RET)
  {
    SEND_STRING 0,"'WARNING - AMX_ArrayLib (GET_LEFT_VALUE)..Max length exceeded, data WILL be lost..'"
    RETURN MID_STRING(strTEXT,FIRST,LEFT_MAX_LEN_RET)
  }
  ELSE
    RETURN MID_STRING(strTEXT,FIRST,COUNT)
}
#END_IF


#IF_NOT_DEFINED __GET_RIGHT_VALUE__
#DEFINE __GET_RIGHT_VALUE__
(*-----------------------*)
(* NAME: GET_RIGHT_VALUE *)
(*---------------------------------------------------------*)
(* Parses 'Value=Value to return' and returns everything   *)
(* that remains after 'Value='.                            *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION CHAR[RIGHT_MAX_LEN_RET] GET_RIGHT_VALUE(CHAR strTEXT[],CHAR strRIGHT[])
STACK_VAR
  INTEGER FIRST
  INTEGER LAST
  INTEGER COUNT
{
(*-- Look for it with a quick bail-out --*)
  FIRST = 1
  LAST  = FIND_STRING(strTEXT,"strRIGHT",1)

  IF((FIRST=0) || (LAST=0))
    RETURN ("");

(*-- Set the count (of value) --*)
  FIRST = 1
  COUNT = LENGTH_STRING(strTEXT) - LENGTH_STRING(strRIGHT)

(*-- Error check and return the value --*)
  IF(COUNT > RIGHT_MAX_LEN_RET)
  {
    SEND_STRING 0,"'WARNING - AMX_ArrayLib (GET_RIGHT_VALUE)..Max length exceeded, data WILL be lost..'"
    RETURN MID_STRING(strTEXT,FIRST,RIGHT_MAX_LEN_RET)
  }
  ELSE
    RETURN MID_STRING(strTEXT,FIRST,COUNT)
}
#END_IF


(*---------------------------------------------------------*)
(* Function: ListboxLibPrintVersion                       *)
(* Purpose:  Print version                                *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION AMX_ArrayLibPrintVersion()
{
  SEND_STRING 0,"'  Running AMX_ArrayLib.axi, v',__ARRAY_LIB_VERSION__"
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

(* What Version? *)
AMX_ArrayLibPrintVersion()

#END_IF
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


