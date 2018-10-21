RUN ONCE LIB.
PARAMETER LAT IS 12.53, LNG IS 39.01, LZH IS 12500.
LOCAL LSG IS LATLNG(LAT,LNG).
LOCAL LSV IS LSG:POSITION - BODY:POSITION.
LOCAL MODE IS 0.

FUNCTION V2MI {PARAMETER T, G. LOCAL P IS POSITIONAT(SHIP,UT(T))-BODY:position. LOCAL O IS OrbN(G). LOCAL CV IS VELOCITYAT(SHIP,UT(T)):ORBIT. RETURN CV:MAG*(ANGLEAXIS(90-VANG(CV,P),O)*VCRS(P,O)):NORMALIZED - CV.}
FUNCTION R2TA {PARAMETER R. RETURN ARCCOS(CLAMP((-OBT:SEMIMAJORAXIS * OBT:ECCENTRICITY^2 + OBT:SEMIMAJORAXIS - R) / (OBT:ECCENTRICITY * R),-1,1)).} // True anomaly at radius


FUNCTION SBC {
IF PERIAPSIS > 0 RETURN 0.
LOCAL AFH IS CLAMP(90 - VANG(VELOCITY:SURFACE,BODY:POSITION),0,90). // Angle from horisontal.
LOCAL g is BODY:MU/(BODY:RADIUS + ALTITUDE)^2. // Gravity
LOCAL S IS 2*g*SIN(AFH).
LOCAL D IS AVAILABLETHRUST/MASS.	// Deceleration
LOCAL EDC IS (SQRT(S*S + 4*(D*D-g*g))-S)/2. //Effective deceleration (multiplying instead of ^2)
LOCAL DT IS VELOCITY:SURFACE:MAG/EDC.	//Deceleration time
LOCAL ELS IS BODY:GEOPOSITIONOF(DT/2 * VELOCITY:SURFACE).// Estimated landing site
LOCAL TAL IS R2TA(BODY:RADIUS + ELS:TERRAINHEIGHT).	// True Anomaly at landing site
LOCAL IMP IS MIN(ETA_TA(TAL),ETA_TA(360-TAL)).	// Time to impact when landing.
RETURN LEXICON("ETA_Imp",IMP,"ETA_SB",IMP - DT/2,"GP_Land",ELS).	// ETA to impact and suicide burn start, Geoposition at estimated landing site.
}
Function DrawCross {
PARAMETER GP, CLR.
LOCAL GV IS GP:ALTITUDEPOSITION(GP:TerrainHeight+0.5).
LOCAL GVN IS (GV-BODY:POSITION):NORMALIZED.
SET V1 TO VECDRAW(GV,GVN + GVN:DIRECTION:STARVECTOR*2,CLR,"",1,TRUE,0.2).
SET V2 TO VECDRAW(GV,GVN - GVN:DIRECTION:STARVECTOR*2,CLR,"",1,TRUE,0.2).
SET V3 TO VECDRAW(GV,GVN + GVN:DIRECTION:TOPVECTOR*2,CLR,"",1,TRUE,0.2).
SET V4 TO VECDRAW(GV,GVN - GVN:DIRECTION:TOPVECTOR*2,CLR,"",1,TRUE,0.2).
}
FUNCTION USCALE {
SET S TO MAX(1,EST["GP_Land"]:POSITION:MAG/40).
SET V1:SCALE TO S.
SET V2:SCALE TO S.
SET V3:SCALE TO S.
SET V4:SCALE TO S.
SET TGV:SCALE TO S.
}

CLEARSCREEN.
// Preparing the orbit.
MSG("Changing plane and deorbiting.").
LOCAL TT IS TTLNG(LNG-90).
//RUN MP_ALTIN(-1000,TT).
//LOCAL BV IS NEXTNODE:DeltaV+V2MI(TT,LATLNG(LAT,LNG + 90*NEXTNODE:ORBIT:PERIOD/BODY:ROTATIONPERIOD)).
//PRINT "Longitude correction is "+ROUND(90*NEXTNODE:ORBIT:PERIOD/BODY:ROTATIONPERIOD,2)+"°.".
//REMOVE NEXTNODE.
//VNODE(BV,TT).
VNODE(V2MI(TT,LATLNG(LAT,LNG + 90*OBT:PERIOD/BODY:ROTATIONPERIOD)),TT).
WAIT 1.
LOCAL N IS NEXTNODE.
LOCAL PH IS 99999.
// Lower height over landing zone.
UNTIL PH <= LZH{
LOCAL PP IS POSITIONAT(SHIP,UT(TT+ETA_TA(-90,NEXTNODE:ORBIT))).
SET PH TO (PP-BODY:POSITION):MAG - BODY:RADIUS - MAX(BODY:GEOPOSITIONOF(PP):TerrainHeight,LSG:TerrainHeight).
PRINT "Predicted height at landzone = "+ROUND(PH)+"m." AT(0,25).
PRINT "LNG at landzone = "+ROUND(BODY:GEOPOSITIONOF(PP):LNG,2)+"°." AT(0,26).
SET N:PROGRADE TO N:PROGRADE - 0.1.
WAIT 0.
}
run exec.
WARPTO(UT(ETA_TA(-90)-120)).
GLOBAL EST IS SBC().
CLEARVECDRAWS().
DRAWCROSS(EST["GP_Land"],BLUE).
SET TGV TO VECDRAW(LSG:POSITION,LSV:NORMALIZED*3,RED,"",1,TRUE,0.5).
SET TGV:STARTUPDATER TO {RETURN LSG:POSITION.}.
SET TGV:VECTORUPDATER TO {RETURN LSV:NORMALIZED*3.}.
SET V1:STARTUPDATER TO {RETURN EST["GP_Land"]:ALTITUDEPOSITION(EST["GP_Land"]:TerrainHeight+0.5).}.
SET V2:STARTUPDATER TO {RETURN EST["GP_Land"]:ALTITUDEPOSITION(EST["GP_Land"]:TerrainHeight+0.5).}.
SET V3:STARTUPDATER TO {RETURN EST["GP_Land"]:ALTITUDEPOSITION(EST["GP_Land"]:TerrainHeight+0.5).}.
SET V4:STARTUPDATER TO {RETURN EST["GP_Land"]:ALTITUDEPOSITION(EST["GP_Land"]:TerrainHeight+0.5).}.
SET V1:VECTORUPDATER TO {LOCAL GVN IS (V1:START-BODY:POSITION):NORMALIZED. RETURN GVN + GVN:DIRECTION:STARVECTOR*2.}.
SET V2:VECTORUPDATER TO {LOCAL GVN IS (V2:START-BODY:POSITION):NORMALIZED. RETURN GVN - GVN:DIRECTION:STARVECTOR*2.}.
SET V3:VECTORUPDATER TO {LOCAL GVN IS (V3:START-BODY:POSITION):NORMALIZED. RETURN GVN + GVN:DIRECTION:TOPVECTOR*2.}.
SET V4:VECTORUPDATER TO {LOCAL GVN IS (V4:START-BODY:POSITION):NORMALIZED. RETURN GVN - GVN:DIRECTION:TOPVECTOR*2.}.
//Correction
GLOBAL HERR IS SBC()["GP_Land"]:HEADING - LSG:HEADING.
GLOBAL dERR IS 30000.
LOCK STEERING TO SRFRETROGRADE*R(0,CLAMP(600*HERR,-90,90),0).
MSG("Correcting heading for landing.").
WAIT UNTIL VANG(STEERING:VECTOR,FACING:VECTOR)<5.
WAIT 1.
LOCK THROTTLE TO ABS(HERR).
UNTIL ABS(hErr) < 0.005 {
SET EST TO SBC().
SET hErr TO EST["GP_Land"]:HEADING - LSG:HEADING.
PRINT "hErr = "+ROUND(HERR,2)+"°.    " AT(0,9).
WAIT 0.
}
// Main landing
LOCAL PID IS PIDLOOP(0.04,0.001,0.01,-0.2,0.1).
WHEN HERR < 0.01 THEN LOCK STEERING TO SRFRETROGRADE*R(0,CLAMP(9*HERR,-MIN(VELOCITY:SURFACE:MAG/9,5),MIN(VELOCITY:SURFACE:MAG/9,5)),0).
LOCK THROTTLE TO MIN(VELOCITY:SURFACE:MAG/15,1)*IIF(dErr<10000,MIN(1,(10000-dErr)/10000)+PID:UPDATE(time:seconds,dErr),0).
UNTIL GROUNDSPEED < 1 OR EST["ETA_SB"]<1 {
SET EST TO SBC().
SET hErr TO SBC()["GP_Land"]:HEADING - LSG:HEADING.
PRINT "hErr = "+ROUND(HERR,2)+"°.   " AT(0,9).
SET dERR TO VDOT(LSG:POSITION-EST["GP_Land"]:POSITION,VXCL(-BODY:POSITION,VELOCITY:SURFACE):NORMALIZED).
PRINT "ETA Impact = "+IIF(EST["ETA_Imp"]>60,HMS(EST["ETA_Imp"]),ROUND(EST["ETA_Imp"],1)+"s.   ") AT(0,7).
PRINT "ETA Suicide Burn = "+IIF(EST["ETA_SB"]>60,HMS(EST["ETA_SB"]),ROUND(EST["ETA_SB"],1)+"s.   ") AT(0,8).
PRINT "dERR = "+ROUND(dERR)+"m.   " AT(0,10).
PRINT "Throttle = "+ROUND(THROTTLE*100)+"%.   " AT(0,11).
PRINT "PID = "+ROUND(PID:OUTPUT,4)+".   " AT(0,12).
USCALE().
WAIT 0.1.
}
//FINAL DROP
MSG("Final drop!").
LOCK STEERING TO SRFRETROGRADE.
LEGS ON. LIGHTS ON.
SET PID TO PIDLOOP(0.04,0.001,0.01,0,1).
local THR is 0.
lock THROTTLE TO -MIN(0,MAX(1,sqrt(MAX(0,ALT:RADAR-7)))+VERTICALSPEED).	// -1 м/с от 7 метров и ниже.

until status = "Landed" {

SET dERR TO (LSG:POSITION - SHIP:GEOPOSITION:POSITION):MAG.
PRINT "dERR = "+ROUND(dERR)+"m.   " AT(0,10).
PRINT "VSpeed = "+ROUND(VERTICALSPEED)+"m/s.    " AT(0,22).
PRINT "RadAlt = "+ROUND(ALT:RADAR)+"m.    " AT(0,23).
USCALE().
}
UNLOCK ALL.
SAS ON. LADDERS ON.
CLEARVECDRAWS().