wait until ship:loaded.
wait until ship:unpacked.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET TERMINAL:WIDTH TO 60.
SET TERMINAL:HEIGHT TO 40.

IF HOMECONNECTION:ISCONNECTED{
IF (ship:status = "PRELAUNCH") or (ship:status = "LANDED") {
RUNPATH("0:/MechJet/prepare_to","launch_rocket").
RUNPATH("0:/MechJet/GUI/gui_launch").
WAIT 5.
REBOOT.
}
ELSE {
RUNPATH("0:/MechJet/prepare_to","orbital_stuff").
IF HASTARGET {
switch to 1. 
run rndzvs. 
}
}
}
ELSE {RUN ONCE "0:/MECHJET/lib". ERR("No connection with KSC!").}