// MechJet Launcher v.1.0 of 2018.09.23 for KOS 1.1.5.2
// © Dr.Jet CC BY-NC 3.0
@lazyglobal OFF.
// Parameters: Target orbit height (km), Target orbit incination, Trajectory Sharpness (0.5 is MechJeb's 50), Final pitch limiter, Start at Descending Node (boolean).
PARAMETER ORB IS 90, INC IS 0, TSH IS 0.5, PLM IS 0, DN IS FALSE.
SET ORB to ORB*1000.	// km -> m

FUNCTION OGT {		// Calculating pseudo-gravity-turn parameters.
LOCAL GP TO LIST(200,5000). // Defaults for vacuum.
IF BODY:ATM:EXISTS {
	LOCAL X TO 0.
	UNTIL X > BODY:ATM:HEIGHT or BODY:ATM:ALTITUDEPRESSURE(x) < 0.93 { SET X TO X+50. }
	SET GP[0] TO ROUND(MAX(X,ALTITUDE+GP[0])).
	SET X TO BODY:ATM:HEIGHT.
	UNTIL BODY:ATM:ALTITUDEPRESSURE(x) > 0.0002 { SET X TO X-50. }
	SET GP[1] TO X.
	}
ELSE{
	MSG(BODY:NAME + " has no atmosphere. Standard trajectory.").
	}
RETURN GP.	
}

FUNCTION MJAZ {	// Compensed launch azimuth
PARAMETER I, AP, DN.
	FUNCTION IFL {	// Launch angle from Latitude
	PARAMETER I.
	LOCAL C TO COS(I)/COS(LATITUDE).
	IF ABS(C)>1 {WRN("Warning! Latitude of "+ROUND(LATITUDE,2)+"° is not optimal for launching to inclination of "+I+"°."). IF ABS(-180*FLOOR(MOD(360+I,360)/180)+MOD(360+I,180)) < 90 RETURN 90. ELSE RETURN 270.}
	ELSE {LOCAL A TO ARCCOS(C). IF I<0 SET A TO -A. RETURN MOD(450-A,360).}
	}
LOCAL A IS I.
IF DN SET A TO -I.
LOCAL H TO IFL(A).
LOCAL ov IS SQRT(BODY:MU/(BODY:RADIUS + AP)).	// Wanted orbital speed
LOCAL NRT IS NORTH:VECTOR.
LOCAL EST IS VCRS(UP:VECTOR, NRT).
LOCAL HV IS OV * (SIN(H)*EST+COS(H)*NRT).
LOCAL AHV IS VXCL(UP:VECTOR,ORBIT:VELOCITY:ORBIT).	// Horisontal drift vector from planet rotation. 
LOCAL DHV IS HV - AHV.
IF VDOT(HV:NORMALIZED,DHV:NORMALIZED) < 0.9 {RETURN MOD(360+ARCTAN2(VDOT(HV,EST),VDOT(HV,NRT)),360).}
RETURN MOD(360+ARCTAN2(VDOT(DHV,EST),VDOT(DHV,NRT)),360).
}

MSG("Calculating launch from " + BODY:NAME+ " to the circular orbit of "+ ORB/1000 + "km with " + INC +"° inclination.").
LOCAL LA TO MJAZ(INC,ORB,DN).
MSG("Launch azimuth is set to " + ROUND(LA,2) + "°.").
LOCAL GP TO OGT().
MSG("Pseudo-GT will start at " + ROUND(GP[0]/1000,2) + "km and end at  " + GP[1]/1000 + "km.").
MSG("Trajectory steepness set to " + TSH +".").
WAIT 1.
SAS OFF.
GLOBAL PIT IS 90.
LOCK PIT TO max(PLM, 90 - (max(0,((ALTITUDE - GP[0])/(GP[1] - GP[0])))^TSH * 90)).
LOCK LV TO HEADING(LA,PIT).
LOCK STEERING TO LV.
LOCK THROTTLE to MIN(1,(ORB-ALT:APOAPSIS)/5000+0.05).
MSG("Here we go!").
STAGE.

LOCAL PTR TO 0.8*AVAILABLETHRUST.
WHEN AVAILABLETHRUST < PTR THEN {	// Autostaging
WAIT UNTIL stage:ready.
MSG("Decoupling stage "+STAGE:NUMBER+".").
stage.
WAIT 1.
IF AVAILABLETHRUST > 0 set PTR TO 0.8*AVAILABLETHRUST.
preserve.
}
UNTIL (ALT:APOAPSIS >= ORB) {WAIT 0.1.}.

POP("Set apopapsis reached.").
SET THROTTLE TO 0.
UNLOCK PIT.
UNLOCK LV.
LOCK STEERING TO PROGRADE.

WHEN ALTITUDE > GP[1] THEN {IF ship:ModulesNamed("ModuleProceduralFairing"):LENGTH > 0 {LOCAL FRM IS ship:ModulesNamed("ModuleProceduralFairing")[0]. FRM:doevent(FRM:ALLEVENTNAMES[0]).}} 	// Decoupling a fairing if we have one.

IF BODY:ATM:EXISTS AND ALTITUDE < BODY:ATM:HEIGHT {	// Atmo exit.
	POP("Coasting to the edge of the atmosphere.").
	SET WARP TO 3.
	UNTIL ALTITUDE > BODY:ATM:HEIGHT { WAIT 0.1. }
	SET WARP TO 0.
	POP("Atmosphere exit.").
	WAIT 0.5.
	IF (ALT:APOAPSIS < ORB) {
		MSG("Correcting apoapsis.").
		UNTIL (ALT:APOAPSIS >= ORB) {
		SET THROTTLE TO 0.05.
		}
	SET THROTTLE TO 0.	
	}
}
// Stuff to do when reaching space.
WAIT 2.
PANELS ON. AG9 ON.
MSG("Circularizing.").
RUN mp_altin(ORB,eta:apoapsis).
WAIT 2.
UNLOCK STEERING.
run exec.
IF HASTARGET AND ABS(RiNC(SHIP,TARGET))>0.2 {MSG("Correcting inclination."). RUN mp_inc. WAIT 1. RUN exec.}
SAS ON.
MSG("Set orbit reached.").
CLEARGUIS().