LOCAL DONE IS FALSE.
//CLEARSCREEN.
PRINT "CPU:" + core:element:name.
PRINT "MechJet at kOS:" + core:version.

SWITCH TO 1. LIST FILES IN FL. FOR F IN FL {IF F:ISFILE AND F:NAME <> "STATE" OR (NOT F:ISFILE AND F:NAME <> "BOOT")DELETEPATH(F:NAME).}	// Cleaning disk.
SWITCH TO 0. CD("MechJet").
//COPYPATH("0:/BOOT/MechJet.ks","1:/BOOT").
COMPILE "lib.ks" TO "1:/lib.ksm".
RUN ONCE "1:/lib".
LOCAL MODE IS RSTATE().	// Read vessel state. 
LOCAL CMPL IS LIST().
LOCAL CPL IS LIST().
FUNCTION PREP {
PARAMETER CMPL, CPL.
FOR I in CMPL {COMPILE I TO "1:/"+PATH(I):name+".ksm".}
FOR I in CPL COPYPATH(I,"1:").
SWITCH TO 1.
}

IF MODE = -1 {
//CLEARSCREEN.
PRINT "*************** MechJet Menu ***************".
PRINT "Select a state to prepare youer vessel for.".
PRINT "********************************************".
PRINT "1) Launch (GUI)".
PRINT "2) Orbital maneuvers (no GUI)".
PRINT "3) Docking maneuvers (no GUI)".
PRINT "4) Landing (no GUI)".
LOCAL N IS -1.
UNTIL N > 0 AND N < 5{
SET N to TERMINAL:Input:GETCHAR():TONUMBER(-1).
}
SSTATE(N). // Save choice.
REBOOT.
}
ELSE IF MODE = 1{
MSG("Preparing files for launching...").
SET CMPL TO LIST(
"launch"
).
SET CPL TO LIST(
"exec",
"MP/mp_altin",
"MP/mp_inc"
).
PREP(CMPL,CPL).
RUNPATH("0:/MechJet/GUI/gui_launch").
}
ELSE IF MODE = 2 {
MSG("Preparing files for orbital maneuvers...").
SET CMPL TO LIST(
).
SET CPL TO LIST(
"exec",
"MP/mp_altin",
"MP/mp_inc",
"MP/mp_matchinc",
"MP/mp_hoh",
"deorbit",
"rndzvs"
).
PREP(CMPL,CPL).
IF HASTARGET RUNPATH("1:/rndzvs").
}
ELSE IF MODE = 3 {
MSG("Preparing files for docking maneuvers...").
SET CMPL TO LIST(
).
SET CPL TO LIST(
"dock",
"undock"
).
PREP(CMPL,CPL).
IF HASTARGET RUNPATH("1:/dock").
}
ELSE IF MODE = 4 {
MSG("Preparing files for landing...").
SET CMPL TO LIST(
).
SET CPL TO LIST(
"exec",
"MP/mp_altin",
"land"
).
PREP(CMPL,CPL).
}
ELSE PRINT "SOME WEIRD SHIT".
SWITCH TO 1.
MSG("Loading complete.").
LIST.