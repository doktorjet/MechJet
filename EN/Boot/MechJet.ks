wait until ship:loaded. wait until ship:unpacked.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET TERMINAL:WIDTH TO 60. SET TERMINAL:HEIGHT TO 40.
IF HOMECONNECTION:ISCONNECTED{RUNPATH("0:/MechJet/prepare_to").}
ELSE {PRINT "No connection to KSC! Reboot manually when you have it".}