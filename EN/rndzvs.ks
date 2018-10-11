@lazyglobal OFF.
PARAMETER DST is 70.
RUN ONCE lib.
SAS OFF.
for n in ALLNODES {remove n.}
FUNCTION RVAT{PARAMETER T IS 0. SET T TO TIME:SECONDS+T. RETURN VELOCITYAT(TARGET,T):ORBIT-VELOCITYAT(SHIP,T):ORBIT.}
Function DAT {Parameter T IS 0. SET T TO TIME:SECONDS+T. Return (positionat(ship,T) - positionat(TARGET,T)):mag.}
Function CAT {Parameter L,R,P. until false { if abs(R - L) < P RETURN (L + R)/2. local LT is L+(R-L)/3. local RT is R-(R-L)/3. if DAT(LT) > DAT(RT) set L to LT. else set R to RT.}}
FUNCTION SS {Parameter T IS 0. RETURN VCRS(VCRS(POSITIONAT(ship,T):normalized,VELOCITYAT(ship,T):orbit),POSITIONAT(ship,T):normalized):normalized.}
IF HASTARGET {
IF DAT() >= 10000 { // Do Hohmann
LOCAL ST IS 0.
IF ABS(rinc(SHIP,TARGET)) > 0.05 {MSG("Leveling relative inclination.").RUN mp_inc. RUN exec.}
MSG("Planning intercept.").
RUN mp_hoh.
RUN exec.
MSG("Planning braking."). 
LOCAL XT IS CAT(ETA:APOAPSIS - 300, ETA:APOAPSIS + 300, 1).
VNODE(RVAT(XT),XT).
RUN exec.
MSG("We are at "+ROUND(DAT())+"m from target").
WAIT 1.
}
IF DAT() >= DST and DAT() < 10000 { // Get closer
MSG("Getting closer.").
LOCAL dV IS TARGET:POSITION:MAG/120.
VNODE(RVAT(7)+dV*(TARGET:POSITION - SS()*(VDOT(SS(),RVAT())/4)):NORMALIZED,7).
RUN exec.
LOCAL XT IS CAT(0, 600, 1).
IF DAT(XT)<DST SET XT TO XT - DST/RVAT():MAG.
VNODE(RVAT(XT),XT).
RUN exec.
MSG("Finally at "+ROUND(DAT())+"m from target. Zeroing remaining relative speed.").
BURN({return RVAT().}).
SAS ON.
WAIT 2.
}
IF DAT() < DST+30 { IF HOMECONNECTION:ISCONNECTED {MSG("Ready for docking."). RUNPATH("0:/MechJet/prepare_to","docking"). WAIT 2. RUN dock.}}
}
ELSE {ERR("There is no target for rendevous.").}