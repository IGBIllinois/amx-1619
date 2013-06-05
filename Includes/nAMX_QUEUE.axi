PROGRAM_NAME='nAMX_QUEUE'
(***********************************************************)
(* System Type : Netlinx                                   *)
(***********************************************************)
(***********************************************************)
(* REV HISTORY:                                            *)
(*  - Version 1.44 (10-24-2004)                            *)
(*    --Added new 'QUEUE ADD QUERY' routine similar to     *)
(*      'QUEUE ADD', except that this new one will not     *)
(*      queue up the command if it is already there.  This *)
(*      is to keep repeating query messages from getting   *)
(*      stacked multiple times during long delays, such    *)
(*      as proj on/off.                                    *)
(*    --Added new QueueCmdStacked(DEV,STR[]) routine to    *)
(*      see if STR is on the stack.  This is useful to     *)
(*      keep repeating query commands from being stacked   *)
(*      up during long delays, such as proj on/off.        *)
(*  - Version 1.43 (04-30-2004)                            *)
(*    --Expanded queue timeline events from 20 to 50 so the*)
(*      new "potential" queue max is 50 device queues.     *)
(*  - Version 1.42 (08-28-2003)                            *)
(*    --Added these functions:                             *)
(*        QueueHasItems(DEV)                               *)
(*        QueueIsBusy(DEV)                                 *)
(*        QueueIsBypassed(DEV)                             *)
(*    --Added routines that pend up commands.  This works  *)
(*      good for IP devices that require negotiation for   *)
(*      ONLINE before sending the commands.                *)
(*      These routines include:                            *)
(*        'QUEUE ADD PENDING'    (DEV, STR[], DELAY)       *)
(*        'QUEUE REMOVE PENDING' (DEV)                     *)
(*  - Version 1.41 (07-21-2003)                            *)
(*    --Added QueueGetLast function so a buffer parsing    *)
(*      routine can get the last command sent.             *)
(*    --'QUEUE ADVANCE' is now always compiled.  It used to*)
(*      only be compiled with #DEFINE AMX_QUEUE_NAVIGATION.*)
(*      This way a buffer parsing routine can always flush *)
(*      the queue.                                         *)
(*  - Version 1.40 (07-16-2003)                            *)
(*    --Added 'QUEUE ADD FN'                               *)
(*    --Added 'QUEUE SET FN'                               *)
(*    --Added 'QUEUE CLEAR FN'                             *)
(*    --Added QueueGetFnDelay                              *)
(*    --Added Queue Functions, where an integer function is*)
(*      associated with a string.  Used mainly for modules *)
(*      where string functions can be set in startup.      *)
(*    --Added PrintVersion.                                *)
(*    --Now requires AMX_ArrayLib.axi!                     *)
(*  - Version 1.30 (05-16-2003)                            *)
(*    --Added tweaks to adjust size to be used in modules. *)
(*  - Version 1.20 (10-17-2002)                            *)
(*    --Added queue navigation.                            *)
(***********************************************************)
(*
--------------------------------------------------
-Subroutines typically used by caller:
--------------------------------------------------
'QUEUE CLEAR'               (DEV)
'QUEUE RESET'               (DEV)
'QUEUE BYPASS ON'           (DEV)
'QUEUE BYPASS OFF'          (DEV)
'QUEUE ADVANCE'             (DEV)
'QUEUE NAME'                (DEV, NAME[])
'QUEUE ADD'                 (DEV, STR[], DELAY_TIME, RETRY_COUNT)
'QUEUE ADD QUERY'           (DEV, STR[], DELAY_TIME, RETRY_COUNT)
'QUEUE ADD CMD'             (DEV, CMD[], DELAY_TIME, RETRY_COUNT)
'QUEUE DEBUG HEX'           (DEV)
'QUEUE DEBUG ASCII'         (DEV)
'QUEUE DEBUG OFF'           (DEV)

'QUEUE SET FN'              (DEV, FN, STR[], DELAY_TIME)    **Done in startup OR read from DOC**
'QUEUE ADD FN'              (DEV, FN)                       **Done at runtime**
'QUEUE CLEAR FN'            (DEV, FN)                       **Use FN=0 to clear all**
QueueGetFnDelay             (DEV, FN)                       **Available for dynamic function changing**

QueueGetLast                (DEV)                           **Get last string sent to device
QueueHasItems               (DEV)                           **Get this boolean value**
QueueIsBusy                 (DEV)                           **Get this boolean value**
QueueIsBypassed             (DEV)                           **Get this boolean value**

QueueCmdStacked             (DEV, STR[])                    **Get this boolean value**

#IF_DEFINED AMX_QUEUE_EVENTS
  'QUEUE SET EVENT'         (DEV, STR[], EVENT_NUM)
#END_IF


--------------------------------------------------
-Subroutines defined by caller and called from include:
--------------------------------------------------
#IF_DEFINED AMX_QUEUE_EVENTS
  'QUEUE EVENT'               (DEV, EVENT_NUM)
  'QUEUE EVENT TIMEOUT'       (DEV, EVENT_NUM)
#END_IF

#IF_DEFINED AMX_QUEUE_NAVIGATION
  CALL 'QUEUE LAST ITEM SENT' (DEV, CMD)
#END_IF


--------------------------------------------------
-Subroutines not typically used by caller:
--------------------------------------------------
'QUEUE INIT'                (PTR)   // Caller would use 'QUEUE RESET' for initialization
'QUEUE CHECK'               (PTR)   // Queue is being flushed out
'QUEUE SEND'                (PTR)   // Queue sending
'QUEUE DEBUG MSG'           (MSG[]) // All debug data is filtered here for send_string 0
                                    // except errors.  They are sent regardless of debug state!
#IF_DEFINED AMX_QUEUE_EVENTS
  'QUEUE GET EVENT'           (DEV, PTR, STR[])
  'QUEUE GET EVENT TIMEOUT'   (DEV, PTR, STR[])
#END_IF
*)

INCLUDE 'AMX_ArrayLib.axi'

#IF_NOT_DEFINED AMX_QueueLib    // !!1.30
#DEFINE AMX_QueueLib
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT


(* Version For Code *)
CHAR __QUEUE_LIB_VERSION__[]    = '1.44'


(*** CONFIG - SIZE LIMITS (FUNCTIONS) ***)
#IF_NOT_DEFINED QUEUE_MAX_FN
    QUEUE_MAX_FN = 30                     // Max number of string functions to store
#END_IF

#IF_NOT_DEFINED QUEUE_MAX_FN_LEN
    QUEUE_MAX_FN_LEN = 64                 // Max number of string characters
#END_IF

(*** CONFIG - SIZE LIMITS ***)
#IF_NOT_DEFINED QUEUE_MAX_DATA_ITEM
    QUEUE_MAX_DATA_ITEM   = 200           // SUPPORT FOR THIS MANY QUEUED STRINGS/COMMANDS
#END_IF

#IF_NOT_DEFINED QUEUE_MAX_DATA_SIZE
    QUEUE_MAX_DATA_SIZE   = 64            // EACH COMMAND CAN BE THIS WIDE
#END_IF


(*** CONFIG - LIMITS ***)
#IF_NOT_DEFINED QUEUE_RETRY_MAX
    QUEUE_RETRY_MAX       = 3             // MAXIMUM NUMBER OF COMMAND RETRIES
#END_IF

#IF_NOT_DEFINED QUEUE_DELAY_MAX
    QUEUE_DELAY_MAX       = 36000         // MAXIMUM DELAY IS 60 MINUTES (1 HOUR)
#END_IF

#IF_NOT_DEFINED QUEUE_STR_DELAY_DEFAULT
    QUEUE_STR_DELAY_DEFAULT   = 5         // IF NOT SPECIFIED, USE THIS DELAY FOR STRINGS
#END_IF

#IF_NOT_DEFINED QUEUE_CMD_DELAY_DEFAULT
    QUEUE_CMD_DELAY_DEFAULT   = 1         // IF NOT SPECIFIED, USE THIS DELAY FOR COMMANDS
#END_IF

#IF_NOT_DEFINED QUEUE_EVENT_MAX
    QUEUE_EVENT_MAX       = 10            // MAXIMUM NUMBER OF STRING/COMMAND EVENTS
#END_IF


(*** CONFIG - TIMELINES and QUEUE COUNT ***)
#IF_NOT_DEFINED QUEUE_MAX_COUNT
    QUEUE_MAX_COUNT   = 20                // SUPPORT FOR THIS MANY DEVICE QUEUES
    QUEUE_TL_OFFSET   = 1200              // TIMELINES FOR QUEUES START HERE
    QUEUE_TL1         = 1201              // YOU NEED TO ADD EACH QUEUE_TLx
    QUEUE_TL2         = 1202
    QUEUE_TL3         = 1203
    QUEUE_TL4         = 1204
    QUEUE_TL5         = 1205
    QUEUE_TL6         = 1206
    QUEUE_TL7         = 1207
    QUEUE_TL8         = 1208
    QUEUE_TL9         = 1209
    QUEUE_TL10        = 1210
    QUEUE_TL11        = 1211
    QUEUE_TL12        = 1212
    QUEUE_TL13        = 1213
    QUEUE_TL14        = 1214
    QUEUE_TL15        = 1215
    QUEUE_TL16        = 1216
    QUEUE_TL17        = 1217
    QUEUE_TL18        = 1218
    QUEUE_TL19        = 1219
    QUEUE_TL20        = 1220
#END_IF


(*** QUEUE ITEM TYPES ***)
QUEUE_ITEM_IS_STR     = 0             // THIS ITEM IS A STRING  (SEND_STRING)
QUEUE_ITEM_IS_CMD     = 1             // THIS ITEM IS A COMMAND (SEND_COMMAND)


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

STRUCTURE _sAMX_QUEUE
{
  DEV       DVC                                                // ACTUAL DEVICE TO USE FOR THIS QUEUE
  CHAR      NAME[50]                                           // FRIENDLY NAME OF THIS DEVICE

  CHAR      DATA[QUEUE_MAX_DATA_ITEM][QUEUE_MAX_DATA_SIZE]     // DATA ITEMS
  LONG      DATA_DELAY[QUEUE_MAX_DATA_ITEM]                    // DATA ITEM DELAY
  CHAR      DATA_TYPE[QUEUE_MAX_DATA_ITEM]                     // DATA ITEM TYPE (STRING or COMMAND)
  CHAR      DATA_RETRY[QUEUE_MAX_DATA_ITEM]                    // DATA ITEM RETRY COUNT
  CHAR      DATA_LAST_STRING[QUEUE_MAX_DATA_SIZE]              // DATA ITEM LAST STRING SENT

  CHAR      BUSY                                                // FLAG: QUEUE IS BUSY
  CHAR      BYPASS                                              // FLAG: QUEUE IS IN BYPASS BY CALLER

  CHAR      RETRY_COUNT                                         // RUNNING TALLY OF RETRY ATTEMPTS

  INTEGER   HEAD                                                // HEAD OF QUEUE
  INTEGER   TAIL                                                // TAIL OF QUEUE
  CHAR      HAS_ITEMS                                           // ITEMS TO PROCESS

  CHAR      EVENT_TABLE[QUEUE_EVENT_MAX][QUEUE_MAX_DATA_SIZE]   // EVENT TABLE OF STRINGS

  CHAR      DEBUG                                               // DEBUG: 0=OFF, 1=ASCII, 2=HEX
}


STRUCTURE _sAMX_QUEUE_FN_TABLE
{
  CHAR      DATA[QUEUE_MAX_FN][QUEUE_MAX_FN_LEN]
  INTEGER   DATA_DELAY[QUEUE_MAX_FN]
}


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE


(*** DEFINE FUNCTION TABLES FOR ALL DEVICE QUEUES ***)
VOLATILE _sAMX_QUEUE_FN_TABLE sAMX_QUEUE_FN_TABLE[QUEUE_MAX_COUNT]
VOLATILE INTEGER nAMX_QUEUE_FN_TABLE[QUEUE_MAX_COUNT][QUEUE_MAX_FN]


(*** DEFINE SOME DEVICE QUEUES ***)
VOLATILE _sAMX_QUEUE sAMX_QUEUE[QUEUE_MAX_COUNT]


(*** OCCURRANCE TABLES ***)
VOLATILE INTEGER AMX_QUEUE_OCC_LAST
VOLATILE INTEGER AMX_QUEUE_OCC_TABLE[QUEUE_MAX_COUNT][3]


(*** MISC ***)
VOLATILE LONG QUEUE_TL_TIMES[1]
VOLATILE INTEGER QUEUE_MY_SYS_NUM


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


(*---------------------------------------------------------*)
(* This include file will initialize this queue whenever it*)
(* has an occurrance added to our lookup table.            *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE INIT' (INTEGER OCC)
{
  IF(OCC && (OCC <= QUEUE_MAX_COUNT))
  {
    sAMX_QUEUE[OCC].BYPASS = 0

    sAMX_QUEUE[OCC].BUSY = 0
    IF(TIMELINE_ACTIVE(QUEUE_TL_OFFSET+OCC))
      TIMELINE_KILL(QUEUE_TL_OFFSET+OCC)

    sAMX_QUEUE[OCC].HEAD = 1
    sAMX_QUEUE[OCC].TAIL = 1
    sAMX_QUEUE[OCC].HAS_ITEMS = 0

    sAMX_QUEUE[OCC].RETRY_COUNT = 0

    IF(sAMX_QUEUE[OCC].DEBUG)
      SEND_STRING 0,"sAMX_QUEUE[OCC].NAME,': QUEUE HAS BEEN INITIALIZED'"
  }
}


(*---------------------------------------------------------*)
(* Provide an OCC lookup value for this CARD.              *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE GET INDEX' (DEV CARD, INTEGER OCC)
STACK_VAR
  INTEGER LOOP
  INTEGER SYS_NUM
{
(*** LOOK FOR AN EXPLICIT SYSTEM NUMBER TO MATCH MINE ***)
(*** THIS WILL HAPPEN WHEN USING CHANNEL.DEVICE,      ***)
(*** DATA.DEVICE, ETC.                                ***)
  IF(CARD.SYSTEM = QUEUE_MY_SYS_NUM)
    SYS_NUM = 0
  ELSE
    SYS_NUM = CARD.SYSTEM


(*** LOOKUP THIS DEVICE ***)
  FOR(LOOP=1; LOOP<=AMX_QUEUE_OCC_LAST; LOOP++)
  {
    IF((AMX_QUEUE_OCC_TABLE[LOOP][1] = CARD.NUMBER) &&
       (AMX_QUEUE_OCC_TABLE[LOOP][2] = CARD.PORT)   &&
       (AMX_QUEUE_OCC_TABLE[LOOP][3] = SYS_NUM))
    {
      OCC = LOOP
      BREAK
    }
  }

(*** DIDN'T FIND IT IN OUR TABLE, SO ADD IT (IF THERE IS ROOM) ***)
  IF((OCC = 0) && (AMX_QUEUE_OCC_LAST < QUEUE_MAX_COUNT))
  {
    AMX_QUEUE_OCC_LAST++
    OCC = AMX_QUEUE_OCC_LAST

    AMX_QUEUE_OCC_TABLE[OCC][1] = CARD.NUMBER
    AMX_QUEUE_OCC_TABLE[OCC][2] = CARD.PORT
    AMX_QUEUE_OCC_TABLE[OCC][3] = SYS_NUM

    sAMX_QUEUE[OCC].DVC = CARD
    sAMX_QUEUE[OCC].NAME = "'QUEUE (',ITOA(CARD.NUMBER),':',ITOA(CARD.PORT),':',ITOA(SYS_NUM),')'"

    CALL 'QUEUE INIT' (OCC)
  }
  ELSE IF(OCC = 0)
  {
    OCC = QUEUE_MAX_COUNT
    SEND_STRING 0,"'ERROR (QUEUE GET INDEX): NO MORE ROOM IN QUEUE_OCC_TABLE!!'"
    SEND_STRING 0,"'                         YOU NEED TO DEFINE MORE QUEUES!!'"
  }
}


(*---------------------------------------------------------*)
(* Caller wants to name this queue (for debugging).        *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE NAME' (DEV CARD, CHAR NAME[])
STACK_VAR
  INTEGER OCC
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  sAMX_QUEUE[OCC].NAME = LEFT_STRING(NAME,50)
}


(*---------------------------------------------------------*)
(* Echo commands and strings to terminal here.             *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE DEBUG MSG' (INTEGER OCC, CHAR DATA[])
STACK_VAR
  LOOP
  COUNT
  TXT1[100]
  TXT2[100]
  TXT3[100]
{
  SELECT
  {
    ACTIVE(sAMX_QUEUE[OCC].DEBUG = 0) :   (* NONE *)
    {
    }
    ACTIVE(sAMX_QUEUE[OCC].DEBUG = 1) :   (* ASCII *)
    {
      SEND_STRING 0,"13,10,'--------- DATA (ASCII) -----------'"
      SEND_STRING 0,"sAMX_QUEUE[OCC].NAME"

      SEND_STRING 0,"DATA"
    }
    ACTIVE(sAMX_QUEUE[OCC].DEBUG = 2) :   (* HEX *)
    {
      SEND_STRING 0,"13,10,'--------- DATA (HEX) -------------'"
      SEND_STRING 0,"sAMX_QUEUE[OCC].NAME"

      TXT1 = ""
      TXT2 = ""
      TXT3 = ""
      LOOP = 1
      COUNT = 1
      WHILE (LOOP <= LENGTH_STRING(DATA))
      {
        TXT1 = "TXT1,RIGHT_STRING("'   ',ITOA(DATA[LOOP])",3),'/'"          (* DECIMAL *)
        TXT2 = "TXT2,'$',RIGHT_STRING("'00',ITOHEX(DATA[LOOP])",2),'/'"     (* HEX *)
        IF ((DATA[LOOP] >= 33) && (DATA[LOOP] <= 126))
          TXT3 = "TXT3,'  ',DATA[LOOP],' '"
        ELSE
          TXT3 = "TXT3,'    '"

        LOOP = LOOP + 1

        IF(COUNT = 10)
        {
          COUNT = 1
          SEND_STRING 0,"TXT1"
          SEND_STRING 0,"TXT2"
          SEND_STRING 0,"TXT3"
          TXT1 = ""
          TXT2 = ""
          TXT3 = ""
        }
        ELSE
          COUNT = COUNT + 1
      }

      SEND_STRING 0,"TXT1"
      SEND_STRING 0,"TXT2"
      SEND_STRING 0,"TXT3"
    }
  }
}


(*---------------------------------------------------------*)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE DEBUG HEX'   (DEV CARD)
STACK_VAR
  OCC
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  sAMX_QUEUE[OCC].DEBUG = 2
  SEND_STRING 0,"sAMX_QUEUE[OCC].NAME,': QUEUE DEBUG - HEX'"
}


(*---------------------------------------------------------*)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE DEBUG ASCII'   (DEV CARD)
STACK_VAR
  OCC
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  sAMX_QUEUE[OCC].DEBUG = 1
  SEND_STRING 0,"sAMX_QUEUE[OCC].NAME,': QUEUE DEBUG - ASCII'"
}


(*---------------------------------------------------------*)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE DEBUG OFF'   (DEV CARD)
STACK_VAR
  OCC
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  sAMX_QUEUE[OCC].DEBUG = 0
  SEND_STRING 0,"sAMX_QUEUE[OCC].NAME,': QUEUE DEBUG - OFF'"
}


(*---------------------------------------------------------*)
(* Caller wants to bypass this queue.  While bypassed, this*)
(* queue will continue to add commands, but will not send  *)
(* them until this bypass is turned OFF.  This could       *)
(* potentially lead to the queue overflowing.  Use care!!  *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE BYPASS ON' (DEV CARD)
STACK_VAR
  INTEGER OCC
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  sAMX_QUEUE[OCC].BYPASS = 1

  IF(sAMX_QUEUE[OCC].DEBUG)
    SEND_STRING 0,"sAMX_QUEUE[OCC].NAME,': QUEUE BYPASS ON'"
}


(*---------------------------------------------------------*)
(* Caller wants to set bypass OFF for this queue.          *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE BYPASS OFF' (DEV CARD)
STACK_VAR
  INTEGER OCC
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  sAMX_QUEUE[OCC].BYPASS = 0

  IF(sAMX_QUEUE[OCC].DEBUG)
    SEND_STRING 0,"sAMX_QUEUE[OCC].NAME,': QUEUE BYPASS OFF'"

  CALL 'QUEUE CHECK' (OCC)
}


(*---------------------------------------------------------*)
(* Caller wants to manually advance the queue to the next  *)
(* pending item.                                           *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE ADVANCE' (DEV CARD)
STACK_VAR
 INTEGER OCC
{
 CALL 'QUEUE GET INDEX' (CARD, OCC)

 sAMX_QUEUE[OCC].RETRY_COUNT = 0
 sAMX_QUEUE[OCC].BUSY = 0
 IF(TIMELINE_ACTIVE(QUEUE_TL_OFFSET+OCC))
   TIMELINE_KILL(QUEUE_TL_OFFSET+OCC)

 CALL 'QUEUE CHECK' (OCC)

 IF(sAMX_QUEUE[OCC].DEBUG)
   SEND_STRING 0,"sAMX_QUEUE[OCC].NAME,': QUEUE MANUALLY ADVANCED'"
}


(*---------------------------------------------------------*)
(* Caller wants to clear any pending commands, but keep the*)
(* pending delay for the last command sent.                *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE CLEAR' (DEV CARD)
STACK_VAR
  INTEGER OCC
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  sAMX_QUEUE[OCC].BYPASS = 0

  sAMX_QUEUE[OCC].HEAD = 1
  sAMX_QUEUE[OCC].TAIL = 1
  sAMX_QUEUE[OCC].HAS_ITEMS = 0

  sAMX_QUEUE[OCC].RETRY_COUNT = 0

  IF(sAMX_QUEUE[OCC].DEBUG)
    SEND_STRING 0,"sAMX_QUEUE[OCC].NAME,': QUEUE HAS BEEN CLEARED'"
}


(*---------------------------------------------------------*)
(* Caller wants to reset this queue which will clear all   *)
(* pending items.                                          *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE RESET' (DEV CARD)
STACK_VAR
  INTEGER OCC
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  IF(sAMX_QUEUE[OCC].DEBUG)
    SEND_STRING 0,"sAMX_QUEUE[OCC].NAME,': QUEUE HAS BEEN RESET'"

  CALL 'QUEUE INIT' (OCC)
}


(*---------------------------------------------------------*)
(* Caller wants to add a STRING to this queue.             *)
(*                                                         *)
(*    -If DELAY is 0, this item will use the default       *)
(*     delay (QUEUE_STR_DELAY_DEFAULT).                    *)
(*    -Delays are stored in 1/10 Second intervals.  So, the*)
(*     DELAY value of 1 is actually 0.1 Seconds.           *)
(*    -RETRY cannot exceed (QUEUE_RETRY_MAX).              *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE ADD' (DEV CARD, CHAR STR[], LONG DELAY, CHAR RETRY)
STACK_VAR
  INTEGER OCC
  INTEGER MISC_DELAY
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  SELECT
  {
    ACTIVE(LENGTH_STRING(STR) > QUEUE_MAX_DATA_SIZE) :
    {
      SEND_STRING 0,"'ERROR (QUEUE ADD): CMD LENGTH EXCEEDS MAX SIZE!!'"
      SEND_STRING 0,"'                   YOU SHOULD INCREASE QUEUE_MAX_DATA_SIZE!!'"
    }
    ACTIVE(sAMX_QUEUE[OCC].HAS_ITEMS && (sAMX_QUEUE[OCC].TAIL = sAMX_QUEUE[OCC].HEAD)) :
    {
      SEND_STRING 0,"'ERROR (QUEUE ADD): ITEM EXCEEDS QUEUE LIMITS!!'"
      SEND_STRING 0,"'                   YOU SHOULD INCREASE QUEUE_MAX_DATA_ITEM!!'"
    }
    ACTIVE(1) :
    {
      sAMX_QUEUE[OCC].HAS_ITEMS = 1

      sAMX_QUEUE[OCC].TAIL++
      IF(sAMX_QUEUE[OCC].TAIL > QUEUE_MAX_DATA_ITEM)
        sAMX_QUEUE[OCC].TAIL = 1

    (*** SET THE TYPE (STRING OR COMMAND) ***)
      sAMX_QUEUE[OCC].DATA_TYPE[sAMX_QUEUE[OCC].TAIL] = QUEUE_ITEM_IS_STR

    (*** SET THE DELAY OPTION FOR THIS COMMAND ***)
      IF(DELAY = 0)
      {
        MISC_DELAY = QUEUE_STR_DELAY_DEFAULT
        MISC_DELAY = MISC_DELAY * 100
        sAMX_QUEUE[OCC].DATA_DELAY[sAMX_QUEUE[OCC].TAIL] = MISC_DELAY
      }
      ELSE IF(DELAY <= QUEUE_DELAY_MAX)
      {
        sAMX_QUEUE[OCC].DATA_DELAY[sAMX_QUEUE[OCC].TAIL] = DELAY * 100
      }
      ELSE
      {
        sAMX_QUEUE[OCC].DATA_DELAY[sAMX_QUEUE[OCC].TAIL] = QUEUE_DELAY_MAX * 100
        SEND_STRING 0,"'ERROR (QUEUE ADD): DELAY EXCEEDS MAX!!'"
        SEND_STRING 0,"'                   YOU SHOULD INCREASE QUEUE_DELAY_MAX!!'"
      }

    (*** SET THE RETRY OPTION FOR THIS COMMAND ***)
      IF(RETRY <= QUEUE_RETRY_MAX)
        sAMX_QUEUE[OCC].DATA_RETRY[sAMX_QUEUE[OCC].TAIL] = RETRY
      ELSE
      {
        sAMX_QUEUE[OCC].DATA_RETRY[sAMX_QUEUE[OCC].TAIL] = QUEUE_RETRY_MAX
        SEND_STRING 0,"'ERROR (QUEUE ADD): RETRY COUNT EXCEEDS MAX!!'"
        SEND_STRING 0,"'                   YOU SHOULD INCREASE QUEUE_RETRY_MAX!!'"
      }

    (*** ADD THIS COMMAND TO THE QUEUE ***)
      sAMX_QUEUE[OCC].DATA[sAMX_QUEUE[OCC].TAIL] = STR

      CALL 'QUEUE CHECK' (OCC)
    }
  }
}


(*---------------------------------------------------------*)
(* Caller wants to add a query STRING to this queue.  This *)
(* differs in that it won't add the STRING to the queue if *)
(* it is already there.  Keeps repeating query STRINGs     *)
(* from stacking up during long delays (proj pwr).         *)
(*                                                         *)
(*    -If DELAY is 0, this item will use the default       *)
(*     delay (QUEUE_STR_DELAY_DEFAULT).                    *)
(*    -Delays are stored in 1/10 Second intervals.  So, the*)
(*     DELAY value of 1 is actually 0.1 Seconds.           *)
(*    -RETRY cannot exceed (QUEUE_RETRY_MAX).              *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE ADD QUERY' (DEV CARD, CHAR STR[], LONG DELAY, CHAR RETRY)  // !!1.44
STACK_VAR
  INTEGER OCC
  INTEGER MISC_DELAY
  INTEGER LOOP
  CHAR    FOUND
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

(*-- Check to see if it is already queued up --*)
  IF(sAMX_QUEUE[OCC].HAS_ITEMS)
  {
    IF(sAMX_QUEUE[OCC].HEAD < sAMX_QUEUE[OCC].TAIL)
    {
      FOR(LOOP=sAMX_QUEUE[OCC].HEAD; LOOP<=sAMX_QUEUE[OCC].TAIL; LOOP++)
      {
        IF(sAMX_QUEUE[OCC].DATA[LOOP] = STR)
        {
          FOUND = 1
          BREAK
        }
      }
    }
    ELSE
    {
      FOR(LOOP=sAMX_QUEUE[OCC].HEAD; LOOP<=QUEUE_MAX_DATA_ITEM; LOOP++)
      {
        IF(sAMX_QUEUE[OCC].DATA[LOOP] = STR)
        {
          FOUND = 1
          BREAK
        }
      }
      IF(FOUND = 0)
      {
        FOR(LOOP=1; LOOP<=sAMX_QUEUE[OCC].TAIL; LOOP++)
        {
          IF(sAMX_QUEUE[OCC].DATA[LOOP] = STR)
          {
            FOUND = 1
            BREAK
          }
        }
      }
    }
  }

  SELECT
  {
    ACTIVE(FOUND = 1) :
    { // STR is already in our stack, so ignore the rest of this..
    }
    ACTIVE(LENGTH_STRING(STR) > QUEUE_MAX_DATA_SIZE) :
    {
      SEND_STRING 0,"'ERROR (QUEUE ADD): CMD LENGTH EXCEEDS MAX SIZE!!'"
      SEND_STRING 0,"'                   YOU SHOULD INCREASE QUEUE_MAX_DATA_SIZE!!'"
    }
    ACTIVE(sAMX_QUEUE[OCC].HAS_ITEMS && (sAMX_QUEUE[OCC].TAIL = sAMX_QUEUE[OCC].HEAD)) :
    {
      SEND_STRING 0,"'ERROR (QUEUE ADD): ITEM EXCEEDS QUEUE LIMITS!!'"
      SEND_STRING 0,"'                   YOU SHOULD INCREASE QUEUE_MAX_DATA_ITEM!!'"
    }
    ACTIVE(1) :
    {
      sAMX_QUEUE[OCC].HAS_ITEMS = 1

      sAMX_QUEUE[OCC].TAIL++
      IF(sAMX_QUEUE[OCC].TAIL > QUEUE_MAX_DATA_ITEM)
        sAMX_QUEUE[OCC].TAIL = 1

    (*** SET THE TYPE (STRING OR COMMAND) ***)
      sAMX_QUEUE[OCC].DATA_TYPE[sAMX_QUEUE[OCC].TAIL] = QUEUE_ITEM_IS_STR

    (*** SET THE DELAY OPTION FOR THIS COMMAND ***)
      IF(DELAY = 0)
      {
        MISC_DELAY = QUEUE_STR_DELAY_DEFAULT
        MISC_DELAY = MISC_DELAY * 100
        sAMX_QUEUE[OCC].DATA_DELAY[sAMX_QUEUE[OCC].TAIL] = MISC_DELAY
      }
      ELSE IF(DELAY <= QUEUE_DELAY_MAX)
      {
        sAMX_QUEUE[OCC].DATA_DELAY[sAMX_QUEUE[OCC].TAIL] = DELAY * 100
      }
      ELSE
      {
        sAMX_QUEUE[OCC].DATA_DELAY[sAMX_QUEUE[OCC].TAIL] = QUEUE_DELAY_MAX * 100
        SEND_STRING 0,"'ERROR (QUEUE ADD): DELAY EXCEEDS MAX!!'"
        SEND_STRING 0,"'                   YOU SHOULD INCREASE QUEUE_DELAY_MAX!!'"
      }

    (*** SET THE RETRY OPTION FOR THIS COMMAND ***)
      IF(RETRY <= QUEUE_RETRY_MAX)
        sAMX_QUEUE[OCC].DATA_RETRY[sAMX_QUEUE[OCC].TAIL] = RETRY
      ELSE
      {
        sAMX_QUEUE[OCC].DATA_RETRY[sAMX_QUEUE[OCC].TAIL] = QUEUE_RETRY_MAX
        SEND_STRING 0,"'ERROR (QUEUE ADD): RETRY COUNT EXCEEDS MAX!!'"
        SEND_STRING 0,"'                   YOU SHOULD INCREASE QUEUE_RETRY_MAX!!'"
      }

    (*** ADD THIS COMMAND TO THE QUEUE ***)
      sAMX_QUEUE[OCC].DATA[sAMX_QUEUE[OCC].TAIL] = STR

      CALL 'QUEUE CHECK' (OCC)
    }
  }
}


(*---------------------------------------------------------*)
(* Caller wants to add a STRING to this queue and hang the *)
(* queue up until a REMOVE or timeout occurs.              *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE ADD PENDING' (DEV CARD, CHAR STR[], LONG DELAY)
STACK_VAR
  INTEGER OCC
  INTEGER MISC_DELAY
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  SELECT
  {
    ACTIVE(LENGTH_STRING(STR) > QUEUE_MAX_DATA_SIZE) :
    {
      SEND_STRING 0,"'ERROR (QUEUE ADD): CMD LENGTH EXCEEDS MAX SIZE!!'"
      SEND_STRING 0,"'                   YOU SHOULD INCREASE QUEUE_MAX_DATA_SIZE!!'"
    }
    ACTIVE(sAMX_QUEUE[OCC].HAS_ITEMS && (sAMX_QUEUE[OCC].TAIL = sAMX_QUEUE[OCC].HEAD)) :
    {
      SEND_STRING 0,"'ERROR (QUEUE ADD): ITEM EXCEEDS QUEUE LIMITS!!'"
      SEND_STRING 0,"'                   YOU SHOULD INCREASE QUEUE_MAX_DATA_ITEM!!'"
    }
    ACTIVE(1) :
    {
      sAMX_QUEUE[OCC].HAS_ITEMS = 1

      sAMX_QUEUE[OCC].TAIL++
      IF(sAMX_QUEUE[OCC].TAIL > QUEUE_MAX_DATA_ITEM)
        sAMX_QUEUE[OCC].TAIL = 1

    (*** SET THE TYPE (STRING OR COMMAND) ***)
      sAMX_QUEUE[OCC].DATA_TYPE[sAMX_QUEUE[OCC].TAIL] = QUEUE_ITEM_IS_STR

    (*** SET THE DELAY OPTION FOR THIS COMMAND ***)
      IF(DELAY = 0)
      {
        MISC_DELAY = QUEUE_STR_DELAY_DEFAULT
        MISC_DELAY = MISC_DELAY * 100
        sAMX_QUEUE[OCC].DATA_DELAY[sAMX_QUEUE[OCC].TAIL] = MISC_DELAY
      }
      ELSE IF(DELAY <= QUEUE_DELAY_MAX)
      {
        sAMX_QUEUE[OCC].DATA_DELAY[sAMX_QUEUE[OCC].TAIL] = DELAY * 100
      }
      ELSE
      {
        sAMX_QUEUE[OCC].DATA_DELAY[sAMX_QUEUE[OCC].TAIL] = QUEUE_DELAY_MAX * 100
        SEND_STRING 0,"'ERROR (QUEUE ADD): DELAY EXCEEDS MAX!!'"
        SEND_STRING 0,"'                   YOU SHOULD INCREASE QUEUE_DELAY_MAX!!'"
      }

    (*** SET THE RETRY OPTION FOR THIS COMMAND ***)
      sAMX_QUEUE[OCC].DATA_RETRY[sAMX_QUEUE[OCC].TAIL] = 0

    (*** ADD THIS COMMAND TO THE QUEUE ***)
      sAMX_QUEUE[OCC].DATA[sAMX_QUEUE[OCC].TAIL] = STR
    }
  }
}


(*---------------------------------------------------------*)
(* Caller wants to send the PENDING string from the queue. *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE REMOVE PENDING' (DEV CARD)
STACK_VAR
  INTEGER OCC
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  sAMX_QUEUE[OCC].BYPASS = 0
  sAMX_QUEUE[OCC].BUSY   = 0
  IF(TIMELINE_ACTIVE(QUEUE_TL_OFFSET+OCC))
    TIMELINE_KILL(QUEUE_TL_OFFSET+OCC)

  CALL 'QUEUE CHECK' (OCC)
}


(*---------------------------------------------------------*)
(* Caller wants to advance the PENDING queue.              *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE ADVANCE PENDING' (DEV CARD)
STACK_VAR
  INTEGER OCC
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  sAMX_QUEUE[OCC].BYPASS = 0
  sAMX_QUEUE[OCC].BUSY   = 0
  IF(TIMELINE_ACTIVE(QUEUE_TL_OFFSET+OCC))
    TIMELINE_KILL(QUEUE_TL_OFFSET+OCC)

  IF(sAMX_QUEUE[OCC].HAS_ITEMS)
  {
    sAMX_QUEUE[OCC].HEAD++
    IF(sAMX_QUEUE[OCC].HEAD > QUEUE_MAX_DATA_ITEM)
      sAMX_QUEUE[OCC].HEAD = 1

    sAMX_QUEUE[OCC].RETRY_COUNT = sAMX_QUEUE[OCC].DATA_RETRY[sAMX_QUEUE[OCC].HEAD]

    IF(sAMX_QUEUE[OCC].HEAD <> sAMX_QUEUE[OCC].TAIL)
      sAMX_QUEUE[OCC].HAS_ITEMS = 1
    ELSE
      sAMX_QUEUE[OCC].HAS_ITEMS = 0
  }
}


(*---------------------------------------------------------*)
(* Caller wants to add a COMMAND to this queue.            *)
(*                                                         *)
(*    -If DELAY is 0, this item will use the default       *)
(*     delay (QUEUE_CMD_DELAY_DEFAULT).                    *)
(*    -Delays are stored in 1/10 Second intervals.  So, the*)
(*     DELAY value of 1 is actually 0.1 Seconds.           *)
(*    -RETRY cannot exceed (QUEUE_RETRY_MAX).              *)
(*    -RETRY does not really apply when using SEND_COMMANDs*)
(*     and should probably be ignored (use 0).             *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE ADD CMD' (DEV CARD, CHAR CMD[], LONG DELAY, CHAR RETRY)
STACK_VAR
  INTEGER OCC
  INTEGER MISC_DELAY
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  SELECT
  {
    ACTIVE(LENGTH_STRING(CMD) > QUEUE_MAX_DATA_SIZE) :
    {
      SEND_STRING 0,"'ERROR (QUEUE ADD CMD): CMD LENGTH EXCEEDS MAX SIZE!!'"
      SEND_STRING 0,"'                       YOU SHOULD INCREASE QUEUE_MAX_DATA_SIZE!!'"
    }
    ACTIVE(sAMX_QUEUE[OCC].HAS_ITEMS && (sAMX_QUEUE[OCC].TAIL = sAMX_QUEUE[OCC].HEAD)) :
    {
      SEND_STRING 0,"'ERROR (QUEUE ADD CMD): ITEM EXCEEDS QUEUE LIMITS!!'"
      SEND_STRING 0,"'                       YOU SHOULD INCREASE QUEUE_MAX_DATA_ITEM!!'"
    }
    ACTIVE(1) :
    {
      sAMX_QUEUE[OCC].HAS_ITEMS = 1

      sAMX_QUEUE[OCC].TAIL++
      IF(sAMX_QUEUE[OCC].TAIL > QUEUE_MAX_DATA_ITEM)
        sAMX_QUEUE[OCC].TAIL = 1

    (*** SET THE TYPE (STRING OR COMMAND) ***)
      sAMX_QUEUE[OCC].DATA_TYPE[sAMX_QUEUE[OCC].TAIL] = QUEUE_ITEM_IS_CMD

    (*** SET THE DELAY OPTION FOR THIS COMMAND ***)
      IF(DELAY = 0)
      {
        MISC_DELAY = QUEUE_CMD_DELAY_DEFAULT
        MISC_DELAY = MISC_DELAY * 100
        sAMX_QUEUE[OCC].DATA_DELAY[sAMX_QUEUE[OCC].TAIL] = MISC_DELAY
      }
      ELSE IF(DELAY <= QUEUE_DELAY_MAX)
      {
        sAMX_QUEUE[OCC].DATA_DELAY[sAMX_QUEUE[OCC].TAIL] = DELAY * 100
      }
      ELSE
      {
        sAMX_QUEUE[OCC].DATA_DELAY[sAMX_QUEUE[OCC].TAIL] = QUEUE_DELAY_MAX * 100
        SEND_STRING 0,"'ERROR (QUEUE ADD): DELAY EXCEEDS MAX!!'"
        SEND_STRING 0,"'                   YOU SHOULD INCREASE QUEUE_DELAY_MAX!!'"
      }

    (*** SET THE RETRY OPTION FOR THIS COMMAND ***)
      IF(RETRY <= QUEUE_RETRY_MAX)
        sAMX_QUEUE[OCC].DATA_RETRY[sAMX_QUEUE[OCC].TAIL] = RETRY
      ELSE
      {
        sAMX_QUEUE[OCC].DATA_RETRY[sAMX_QUEUE[OCC].TAIL] = QUEUE_RETRY_MAX
        SEND_STRING 0,"'ERROR (QUEUE ADD CMD): RETRY COUNT EXCEEDS MAX!!'"
        SEND_STRING 0,"'                       YOU SHOULD INCREASE QUEUE_RETRY_MAX!!'"
      }

    (*** ADD THIS COMMAND TO THE QUEUE ***)
      sAMX_QUEUE[OCC].DATA[sAMX_QUEUE[OCC].TAIL] = CMD

      CALL 'QUEUE CHECK' (OCC)
    }
  }
}


(*---------------------------------------------------------*)
(* Assign a string/delay to an integer function.           *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE SET FN' (DEV CARD, INTEGER FN, CHAR STR[], INTEGER DELAY_TIME)
STACK_VAR
  INTEGER OCC
  INTEGER nFnOCC
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  nFnOCC = GET_INT_ARRAY_OCC(nAMX_QUEUE_FN_TABLE[OCC], FN)

  sAMX_QUEUE_FN_TABLE[OCC].DATA[nFnOCC]       = LEFT_STRING(STR, QUEUE_MAX_FN_LEN)

  IF(DELAY_TIME = 0)   sAMX_QUEUE_FN_TABLE[OCC].DATA_DELAY[nFnOCC] = QUEUE_STR_DELAY_DEFAULT
  ELSE                 sAMX_QUEUE_FN_TABLE[OCC].DATA_DELAY[nFnOCC] = DELAY_TIME
}


(*---------------------------------------------------------*)
(* Clears a string/delay function from the table.          *)
(*                                                         *)
(* NOTE: Use FN=0 to clear all.                            *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE CLEAR FN' (DEV CARD, INTEGER FN)
STACK_VAR
  INTEGER OCC
  INTEGER nFnOCC
  INTEGER nLoop
  INTEGER nLast
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

(*-- Clear all --*)
  IF(FN = 0)
  {
    SET_LENGTH_ARRAY(nAMX_QUEUE_FN_TABLE[OCC], 0)
  }
(*-- Clear and shift remainder of table up --*)
  ELSE
  {
    nFnOCC = FIND_INT_ARRAY(nAMX_QUEUE_FN_TABLE[OCC], FN, 1)

    IF(nFnOCC)
    {
      nLast = LENGTH_ARRAY(nAMX_QUEUE_FN_TABLE[OCC])
      FOR(nLoop = nFnOCC; nLoop < nLast; nLoop++)
      {
        nAMX_QUEUE_FN_TABLE[OCC][nLoop] = nAMX_QUEUE_FN_TABLE[OCC][nLoop+1]
        sAMX_QUEUE_FN_TABLE[OCC].DATA[nLoop]       = sAMX_QUEUE_FN_TABLE[OCC].DATA[nLoop+1]
        sAMX_QUEUE_FN_TABLE[OCC].DATA_DELAY[nLoop] = sAMX_QUEUE_FN_TABLE[OCC].DATA_DELAY[nLoop+1]
      }

      SET_LENGTH_ARRAY(nAMX_QUEUE_FN_TABLE[OCC], nLast-1)
    }
    ELSE
    {
      SEND_STRING 0,"'ERROR (QUEUE CLEAR FN): FN (',ITOA(FN),') NOT FOUND FOR ',sAMX_QUEUE[OCC].NAME,'!!'"
      SEND_STRING 0,"'                        YOU NEED TO ''QUEUE SET FN'' BEFORE USING IT!!'"
    }
  }
}


(*---------------------------------------------------------*)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER QueueGetFnDelay (DEV CARD, INTEGER FN)
STACK_VAR
  INTEGER OCC
  INTEGER nFnOCC
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  IF(FIND_INT_ARRAY(nAMX_QUEUE_FN_TABLE[OCC], FN, 1))
  {
    nFnOCC = GET_INT_ARRAY_OCC(nAMX_QUEUE_FN_TABLE[OCC], FN)
    RETURN(sAMX_QUEUE_FN_TABLE[OCC].DATA_DELAY[nFnOCC])
  }
  ELSE
    RETURN(0)
}


(*---------------------------------------------------------*)
(* Caller wants to add a STRING from a function that was   *)
(* previously assigned.                                    *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE ADD FN' (DEV CARD, INTEGER FN)
STACK_VAR
  INTEGER OCC
  INTEGER nFnOCC
  INTEGER MISC_DELAY
  CHAR    STR[QUEUE_MAX_FN_LEN]
  INTEGER DELAY
  CHAR    RETRY
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  nFnOCC = FIND_INT_ARRAY(nAMX_QUEUE_FN_TABLE[OCC], FN, 1)

  IF(nFnOCC)
  {
    STR   = sAMX_QUEUE_FN_TABLE[OCC].DATA[nFnOCC]
    DELAY = sAMX_QUEUE_FN_TABLE[OCC].DATA_DELAY[nFnOCC]
    RETRY = 0
  }

  SELECT
  {
    ACTIVE(nFnOCC = 0) :
    {
      SEND_STRING 0,"'ERROR (QUEUE ADD FN): FN (',ITOA(FN),') NOT FOUND FOR ',sAMX_QUEUE[OCC].NAME,'!!'"
      SEND_STRING 0,"'                      YOU NEED TO ''QUEUE SET FN'' BEFORE USING IT!!'"
    }
    ACTIVE(LENGTH_STRING(STR) > QUEUE_MAX_DATA_SIZE) :
    {
      SEND_STRING 0,"'ERROR (QUEUE ADD FN): CMD LENGTH EXCEEDS MAX SIZE!!'"
      SEND_STRING 0,"'                      YOU SHOULD INCREASE QUEUE_MAX_DATA_SIZE!!'"
    }
    ACTIVE(sAMX_QUEUE[OCC].HAS_ITEMS && (sAMX_QUEUE[OCC].TAIL = sAMX_QUEUE[OCC].HEAD)) :
    {
      SEND_STRING 0,"'ERROR (QUEUE ADD FN): ITEM EXCEEDS QUEUE LIMITS!!'"
      SEND_STRING 0,"'                      YOU SHOULD INCREASE QUEUE_MAX_DATA_ITEM!!'"
    }
    ACTIVE(1) :
    {
      sAMX_QUEUE[OCC].HAS_ITEMS = 1

      sAMX_QUEUE[OCC].TAIL++
      IF(sAMX_QUEUE[OCC].TAIL > QUEUE_MAX_DATA_ITEM)
        sAMX_QUEUE[OCC].TAIL = 1

    (*** SET THE TYPE (STRING OR COMMAND) ***)
      sAMX_QUEUE[OCC].DATA_TYPE[sAMX_QUEUE[OCC].TAIL] = QUEUE_ITEM_IS_STR

    (*** SET THE DELAY OPTION FOR THIS COMMAND ***)
      IF(DELAY = 0)
      {
        MISC_DELAY = QUEUE_STR_DELAY_DEFAULT
        MISC_DELAY = MISC_DELAY * 100
        sAMX_QUEUE[OCC].DATA_DELAY[sAMX_QUEUE[OCC].TAIL] = MISC_DELAY
      }
      ELSE IF(DELAY <= QUEUE_DELAY_MAX)
      {
        sAMX_QUEUE[OCC].DATA_DELAY[sAMX_QUEUE[OCC].TAIL] = DELAY * 100
      }
      ELSE
      {
        sAMX_QUEUE[OCC].DATA_DELAY[sAMX_QUEUE[OCC].TAIL] = QUEUE_DELAY_MAX * 100
        SEND_STRING 0,"'ERROR (QUEUE ADD FN): DELAY EXCEEDS MAX!!'"
        SEND_STRING 0,"'                      YOU SHOULD INCREASE QUEUE_DELAY_MAX!!'"
      }

    (*** SET THE RETRY OPTION FOR THIS COMMAND ***)
      IF(RETRY <= QUEUE_RETRY_MAX)
        sAMX_QUEUE[OCC].DATA_RETRY[sAMX_QUEUE[OCC].TAIL] = RETRY
      ELSE
      {
        sAMX_QUEUE[OCC].DATA_RETRY[sAMX_QUEUE[OCC].TAIL] = QUEUE_RETRY_MAX
        SEND_STRING 0,"'ERROR (QUEUE ADD FN): RETRY COUNT EXCEEDS MAX!!'"
        SEND_STRING 0,"'                      YOU SHOULD INCREASE QUEUE_RETRY_MAX!!'"
      }

    (*** ADD THIS COMMAND TO THE QUEUE ***)
      sAMX_QUEUE[OCC].DATA[sAMX_QUEUE[OCC].TAIL] = STR

      CALL 'QUEUE CHECK' (OCC)
    }
  }
}


#IF_DEFINED AMX_QUEUE_EVENTS
    (*---------------------------------------------------------*)
    (*---------------------------------------------------------*)
    DEFINE_CALL 'QUEUE SET EVENT' (DEV CARD, CHAR STR[], INTEGER EVENT_NUM)
    STACK_VAR
      INTEGER OCC
    {
      IF(EVENT_NUM && (EVENT_NUM <= QUEUE_EVENT_MAX))
      {
        CALL 'QUEUE GET INDEX' (CARD, OCC)

        sAMX_QUEUE[OCC].EVENT_TABLE[EVENT_NUM] = STR
      }
    }

    (*---------------------------------------------------------*)
    (*---------------------------------------------------------*)
    DEFINE_CALL 'QUEUE GET EVENT' (DEV CARD, INTEGER OCC, CHAR STR[])
    STACK_VAR
      LOOP
    {
      FOR(LOOP=1; LOOP<=QUEUE_EVENT_MAX; LOOP++)
      {
        IF(sAMX_QUEUE[OCC].EVENT_TABLE[LOOP] = STR)
        {
          CALL 'QUEUE EVENT' (CARD,LOOP)
          BREAK
        }
      }
    }

    (*---------------------------------------------------------*)
    (*---------------------------------------------------------*)
    DEFINE_CALL 'QUEUE GET EVENT TIMEOUT' (DEV CARD, INTEGER OCC, CHAR STR[])
    STACK_VAR
      LOOP
    {
      FOR(LOOP=1; LOOP<=QUEUE_EVENT_MAX; LOOP++)
      {
        IF(sAMX_QUEUE[OCC].EVENT_TABLE[LOOP] = STR)
        {
          CALL 'QUEUE EVENT TIMEOUT' (CARD,LOOP)
          BREAK
        }
      }
    }
#END_IF


(*---------------------------------------------------------*)
(* This include file wants to send this data item.         *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE SEND' (INTEGER OCC, THIS_ITEM)
STACK_VAR
  CHAR    CMD[QUEUE_MAX_DATA_SIZE]
{
  CMD = sAMX_QUEUE[OCC].DATA[THIS_ITEM]

  IF(sAMX_QUEUE[OCC].DATA_TYPE[THIS_ITEM] = QUEUE_ITEM_IS_STR)
  {
    sAMX_QUEUE[OCC].DATA_LAST_STRING = CMD
    SEND_STRING sAMX_QUEUE[OCC].DVC,"CMD"

#IF_DEFINED AMX_QUEUE_EVENTS
    CALL 'QUEUE GET EVENT' (sAMX_QUEUE[OCC].DVC, OCC, CMD)
#END_IF

#IF_DEFINED AMX_QUEUE_NAVIGATION
    CALL 'QUEUE LAST ITEM SENT' (sAMX_QUEUE[OCC].DVC, CMD)
#END_IF
  }
  ELSE IF(sAMX_QUEUE[OCC].DATA_TYPE[THIS_ITEM] = QUEUE_ITEM_IS_CMD)
  {
    sAMX_QUEUE[OCC].DATA_LAST_STRING = CMD
    SEND_COMMAND sAMX_QUEUE[OCC].DVC,"CMD"

#IF_DEFINED AMX_QUEUE_EVENTS
    CALL 'QUEUE GET EVENT' (sAMX_QUEUE[OCC].DVC, OCC, CMD)
#END_IF

#IF_DEFINED AMX_QUEUE_NAVIGATION
    CALL 'QUEUE LAST ITEM SENT' (sAMX_QUEUE[OCC].DVC, CMD)
#END_IF
  }

  IF(sAMX_QUEUE[OCC].DEBUG)
  {
    IF(sAMX_QUEUE[OCC].DATA_TYPE[THIS_ITEM] = QUEUE_ITEM_IS_STR)
      CALL 'QUEUE DEBUG MSG' (OCC, "'QUEUE STR=',CMD")
    ELSE IF(sAMX_QUEUE[OCC].DATA_TYPE[THIS_ITEM] = QUEUE_ITEM_IS_CMD)
      CALL 'QUEUE DEBUG MSG' (OCC, "'QUEUE CMD=',CMD")
  }

  sAMX_QUEUE[OCC].BUSY = 1
  IF(!TIMELINE_ACTIVE(QUEUE_TL_OFFSET+OCC))
  {
    QUEUE_TL_TIMES[1] = sAMX_QUEUE[OCC].DATA_DELAY[THIS_ITEM]
    TIMELINE_CREATE(QUEUE_TL_OFFSET+OCC,QUEUE_TL_TIMES,1,TIMELINE_RELATIVE,TIMELINE_ONCE)
  }
  ELSE
  {
    QUEUE_TL_TIMES[1] = sAMX_QUEUE[OCC].DATA_DELAY[THIS_ITEM]
    TIMELINE_RELOAD(QUEUE_TL_OFFSET+OCC,QUEUE_TL_TIMES,1)
  }
}


(*---------------------------------------------------------*)
(* This include file wants to check the queue to see about *)
(* sending another item.  This queue routine turns itself  *)
(* ON or OFF with timelines, so that when there are more   *)
(* items waiting to be send, the timeline will continue to *)
(* be active.  But, when there are no more items, the      *)
(* timeline will die and not restart until there is another*)
(* item ADDED to the queue.                                *)
(*---------------------------------------------------------*)
DEFINE_CALL 'QUEUE CHECK' (INTEGER OCC)
STACK_VAR
  INTEGER THIS_ITEM
{
  SELECT
  {
  (*** USER BYPASS (DO NOTHING) ***)
    ACTIVE(sAMX_QUEUE[OCC].BYPASS) :
    {
    }
  (*** QUEUE BUSY (DO NOTHING) ***)
    ACTIVE(sAMX_QUEUE[OCC].BUSY) :
    {
    }
  (*** THIS ITEM HAS RETRIES ***)
    ACTIVE(sAMX_QUEUE[OCC].RETRY_COUNT > 0) :
    {
      sAMX_QUEUE[OCC].RETRY_COUNT--

      CALL 'QUEUE SEND' (OCC, sAMX_QUEUE[OCC].HEAD)
    }
  (*** ADVANCE TO NEXT ITEM ***)
    ACTIVE(sAMX_QUEUE[OCC].HAS_ITEMS) : // && (sAMX_QUEUE[OCC].HEAD <> sAMX_QUEUE[OCC].TAIL)) :
    {
      sAMX_QUEUE[OCC].HEAD++
      IF(sAMX_QUEUE[OCC].HEAD > QUEUE_MAX_DATA_ITEM)
        sAMX_QUEUE[OCC].HEAD = 1

      sAMX_QUEUE[OCC].RETRY_COUNT = sAMX_QUEUE[OCC].DATA_RETRY[sAMX_QUEUE[OCC].HEAD]

      CALL 'QUEUE SEND' (OCC, sAMX_QUEUE[OCC].HEAD)

      IF(sAMX_QUEUE[OCC].HEAD <> sAMX_QUEUE[OCC].TAIL)
        sAMX_QUEUE[OCC].HAS_ITEMS = 1
      ELSE
        sAMX_QUEUE[OCC].HAS_ITEMS = 0
    }
    ACTIVE(1) :
    {
      sAMX_QUEUE[OCC].HAS_ITEMS = 0

      IF(TIMELINE_ACTIVE(QUEUE_TL_OFFSET+OCC))
        TIMELINE_KILL(QUEUE_TL_OFFSET+OCC)
    }
  }
}


(*---------------------------------------------------------*)
(* Function: QueueGetLast                                  *)
(* Purpose:  Caller wants last string sent to device.      *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION CHAR[QUEUE_MAX_DATA_SIZE] QueueGetLast(DEV CARD)
STACK_VAR
  INTEGER OCC
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  RETURN(sAMX_QUEUE[OCC].DATA_LAST_STRING)
}


(*---------------------------------------------------------*)
(* Function: QueueHasItems                                 *)
(* Purpose:  Caller wants this value.                      *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER QueueHasItems(DEV CARD)
STACK_VAR
  INTEGER OCC
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  RETURN(sAMX_QUEUE[OCC].HAS_ITEMS)
}


(*---------------------------------------------------------*)
(* Function: QueueIsBusy                                   *)
(* Purpose:  Caller wants this value.                      *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER QueueIsBusy(DEV CARD)
STACK_VAR
  INTEGER OCC
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  RETURN(sAMX_QUEUE[OCC].BUSY)
}


(*---------------------------------------------------------*)
(* Function: QueueIsBypassed                               *)
(* Purpose:  Caller wants this value.                      *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER QueueIsBypassed(DEV CARD)
STACK_VAR
  INTEGER OCC
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  RETURN(sAMX_QUEUE[OCC].BYPASS)
}


(*---------------------------------------------------------*)
(* Function: QueueCmdStacked                               *)
(* Purpose:  Caller wants to know if CMD is already queued.*)
(*---------------------------------------------------------*)
DEFINE_FUNCTION INTEGER QueueCmdStacked(DEV CARD, CHAR STR[])   // !!1.44
STACK_VAR
  INTEGER OCC
  INTEGER LOOP
  INTEGER FOUND
{
  CALL 'QUEUE GET INDEX' (CARD, OCC)

  IF(sAMX_QUEUE[OCC].HAS_ITEMS)
  {
    IF(sAMX_QUEUE[OCC].HEAD < sAMX_QUEUE[OCC].TAIL)
    {
      FOR(LOOP=sAMX_QUEUE[OCC].HEAD; LOOP<=sAMX_QUEUE[OCC].TAIL; LOOP++)
      {
        IF(sAMX_QUEUE[OCC].DATA[LOOP] = STR)
        {
          FOUND = 1
          BREAK
        }
      }
    }
    ELSE
    {
      FOR(LOOP=sAMX_QUEUE[OCC].HEAD; LOOP<=QUEUE_MAX_DATA_ITEM; LOOP++)
      {
        IF(sAMX_QUEUE[OCC].DATA[LOOP] = STR)
        {
          FOUND = 1
          BREAK
        }
      }
      IF(FOUND = 0)
      {
        FOR(LOOP=1; LOOP<=sAMX_QUEUE[OCC].TAIL; LOOP++)
        {
          IF(sAMX_QUEUE[OCC].DATA[LOOP] = STR)
          {
            FOUND = 1
            BREAK
          }
        }
      }
    }
  }

  RETURN(FOUND)
}


(*---------------------------------------------------------*)
(* Function: PrintVersion                                  *)
(* Purpose:  Print version                                 *)
(*---------------------------------------------------------*)
DEFINE_FUNCTION QueueLibPrintVersion()
{
  SEND_STRING 0,"'  Running nAMX_Queue.axi, v',__QUEUE_LIB_VERSION__"
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

(*** NEED TO KNOW MY SYSTEM FOR OCC LOOKUP ***)
QUEUE_MY_SYS_NUM = GET_SYSTEM_NUMBER()


(* What Version? *)
QueueLibPrintVersion()


(***********************************************************)
(*                THE EVENTS GOES BELOW                    *)
(***********************************************************)
DEFINE_EVENT


#IF_NOT_DEFINED AMX_QUEUE_TIMELINES
#DEFINE AMX_QUEUE_TIMELINES
     (*---------------------------------------------------------*)
     (* This is timing engine of all queue's.  This include file*)
     (* comes ready for 20 queues (or 20 devices).              *)
     (*                                                         *)
     (* If more queues are needed:                              *)
     (*   -you would need to stack more timeline events.        *)
     (*   -Add the constant values for timelines.               *)
     (*   -adjust the MAX_QUEUE_COUNT constant.                 *)
     (*---------------------------------------------------------*)
#IF_DEFINED QUEUE_TL1   TIMELINE_EVENT[QUEUE_TL1]   #END_IF   // !!1.30
#IF_DEFINED QUEUE_TL2   TIMELINE_EVENT[QUEUE_TL2]   #END_IF
#IF_DEFINED QUEUE_TL3   TIMELINE_EVENT[QUEUE_TL3]   #END_IF
#IF_DEFINED QUEUE_TL4   TIMELINE_EVENT[QUEUE_TL4]   #END_IF
#IF_DEFINED QUEUE_TL5   TIMELINE_EVENT[QUEUE_TL5]   #END_IF
#IF_DEFINED QUEUE_TL6   TIMELINE_EVENT[QUEUE_TL6]   #END_IF
#IF_DEFINED QUEUE_TL7   TIMELINE_EVENT[QUEUE_TL7]   #END_IF
#IF_DEFINED QUEUE_TL8   TIMELINE_EVENT[QUEUE_TL8]   #END_IF
#IF_DEFINED QUEUE_TL9   TIMELINE_EVENT[QUEUE_TL9]   #END_IF
#IF_DEFINED QUEUE_TL10  TIMELINE_EVENT[QUEUE_TL10]  #END_IF
#IF_DEFINED QUEUE_TL11  TIMELINE_EVENT[QUEUE_TL11]  #END_IF
#IF_DEFINED QUEUE_TL12  TIMELINE_EVENT[QUEUE_TL12]  #END_IF
#IF_DEFINED QUEUE_TL13  TIMELINE_EVENT[QUEUE_TL13]  #END_IF
#IF_DEFINED QUEUE_TL14  TIMELINE_EVENT[QUEUE_TL14]  #END_IF
#IF_DEFINED QUEUE_TL15  TIMELINE_EVENT[QUEUE_TL15]  #END_IF
#IF_DEFINED QUEUE_TL16  TIMELINE_EVENT[QUEUE_TL16]  #END_IF
#IF_DEFINED QUEUE_TL17  TIMELINE_EVENT[QUEUE_TL17]  #END_IF
#IF_DEFINED QUEUE_TL18  TIMELINE_EVENT[QUEUE_TL18]  #END_IF
#IF_DEFINED QUEUE_TL19  TIMELINE_EVENT[QUEUE_TL19]  #END_IF
#IF_DEFINED QUEUE_TL20  TIMELINE_EVENT[QUEUE_TL20]  #END_IF
#IF_DEFINED QUEUE_TL21  TIMELINE_EVENT[QUEUE_TL21]  #END_IF   // !!1.43
#IF_DEFINED QUEUE_TL22  TIMELINE_EVENT[QUEUE_TL22]  #END_IF
#IF_DEFINED QUEUE_TL23  TIMELINE_EVENT[QUEUE_TL23]  #END_IF
#IF_DEFINED QUEUE_TL24  TIMELINE_EVENT[QUEUE_TL24]  #END_IF
#IF_DEFINED QUEUE_TL25  TIMELINE_EVENT[QUEUE_TL25]  #END_IF
#IF_DEFINED QUEUE_TL26  TIMELINE_EVENT[QUEUE_TL26]  #END_IF
#IF_DEFINED QUEUE_TL27  TIMELINE_EVENT[QUEUE_TL27]  #END_IF
#IF_DEFINED QUEUE_TL28  TIMELINE_EVENT[QUEUE_TL28]  #END_IF
#IF_DEFINED QUEUE_TL29  TIMELINE_EVENT[QUEUE_TL29]  #END_IF
#IF_DEFINED QUEUE_TL30  TIMELINE_EVENT[QUEUE_TL30]  #END_IF
#IF_DEFINED QUEUE_TL31  TIMELINE_EVENT[QUEUE_TL31]  #END_IF
#IF_DEFINED QUEUE_TL32  TIMELINE_EVENT[QUEUE_TL32]  #END_IF
#IF_DEFINED QUEUE_TL33  TIMELINE_EVENT[QUEUE_TL33]  #END_IF
#IF_DEFINED QUEUE_TL34  TIMELINE_EVENT[QUEUE_TL34]  #END_IF
#IF_DEFINED QUEUE_TL35  TIMELINE_EVENT[QUEUE_TL35]  #END_IF
#IF_DEFINED QUEUE_TL36  TIMELINE_EVENT[QUEUE_TL36]  #END_IF
#IF_DEFINED QUEUE_TL37  TIMELINE_EVENT[QUEUE_TL37]  #END_IF
#IF_DEFINED QUEUE_TL38  TIMELINE_EVENT[QUEUE_TL38]  #END_IF
#IF_DEFINED QUEUE_TL39  TIMELINE_EVENT[QUEUE_TL39]  #END_IF
#IF_DEFINED QUEUE_TL40  TIMELINE_EVENT[QUEUE_TL40]  #END_IF
#IF_DEFINED QUEUE_TL41  TIMELINE_EVENT[QUEUE_TL41]  #END_IF
#IF_DEFINED QUEUE_TL42  TIMELINE_EVENT[QUEUE_TL42]  #END_IF
#IF_DEFINED QUEUE_TL43  TIMELINE_EVENT[QUEUE_TL43]  #END_IF
#IF_DEFINED QUEUE_TL44  TIMELINE_EVENT[QUEUE_TL44]  #END_IF
#IF_DEFINED QUEUE_TL45  TIMELINE_EVENT[QUEUE_TL45]  #END_IF
#IF_DEFINED QUEUE_TL46  TIMELINE_EVENT[QUEUE_TL46]  #END_IF
#IF_DEFINED QUEUE_TL47  TIMELINE_EVENT[QUEUE_TL47]  #END_IF
#IF_DEFINED QUEUE_TL48  TIMELINE_EVENT[QUEUE_TL48]  #END_IF
#IF_DEFINED QUEUE_TL49  TIMELINE_EVENT[QUEUE_TL49]  #END_IF
#IF_DEFINED QUEUE_TL50  TIMELINE_EVENT[QUEUE_TL50]  #END_IF
     {
       STACK_VAR
         OCC

       OCC = TIMELINE.ID - QUEUE_TL_OFFSET

#IF_DEFINED AMX_QUEUE_EVENTS
       CALL 'QUEUE GET EVENT TIMEOUT' (sAMX_QUEUE[OCC].DVC, OCC, sAMX_QUEUE[OCC].DATA_LAST_STRING)
#END_IF

       sAMX_QUEUE[OCC].BUSY = 0
       CALL 'QUEUE CHECK' (OCC)
     }
#END_IF


(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
#END_IF
