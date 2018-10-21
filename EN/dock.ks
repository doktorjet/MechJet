PARAMETER R_Angle is 0.
RUN ONCE LIB.
FUNCTION FindBestDP{
PARAMETER LocalDP.
LOCAL TDP is FALSE.
IF HASTARGET AND TARGET:ISTYPE("Vessel") AND TARGET:DOCKINGPORTS:LENGTH >0 {
LOCAL DPS IS LIST(). 
FOR D IN TARGET:DOCKINGPORTS {IF D:STATE="Ready" and D:NODETYPE=DP:NODETYPE DPS:ADD(D).}
MSG("Found "+DPS:LENGTH+" viable docking ports on target vessel.").
LOCAL A is 0.
FOR D in DPS {IF VANG(TARGET:POSITION,D:PORTFACING:VECTOR) >= A {SET A TO VANG(TARGET:POSITION,D:PORTFACING:VECTOR). SET TDP TO D.}}
MSG("Chosen "+TDP:NAME+" with tag "+TDP:TAG+" (rel.incl. is "+ROUND(180-A,1)+"°).").
}
RETURN TDP.
}
FUNCTION TVEC{	// Translation vector
PARAMETER M,SR IS 25.
IF M = 1 RETURN TDP:NODEPOSITION+VXCL(TDP:PORTFACING:FOREVECTOR,-TDP:NODEPOSITION):NORMALIZED*SR*1.5-DP:NODEPOSITION. // Closest safe approach to the side of target DP (1.5*SafeRadius)
IF M = 2 RETURN TDP:NODEPOSITION+TDP:PORTFACING:VECTOR:NORMALIZED*SR-DP:NODEPOSITION.	// SafeRadius meters in front of target DP
IF M = 3 RETURN TDP:NODEPOSITION+TDP:PORTFACING:VECTOR:NORMALIZED*0.15-DP:NODEPOSITION.	// 15cm in front of target DP
RETURN V(0,0,0).
}
FUNCTION TRANSLATE {
PARAMETER M, S IS 1, SD IS 25.	// S is safe axis speed. Real speed will vary from S to 1.7*S
clearvecdraws().
LOCAL RV IS 0. LOCAL TGV IS V(1,1,1).
RCS ON.
UNTIL TGV:MAG < 0.6/M {
SET TGV TO TVEC(M,SD).
SET RV TO VELOCITY:ORBIT - TARGET:VELOCITY:ORBIT.
SET Fv to -VDOT(DP:PORTFACING:vector,RV).
SET Sv to -VDOT(DP:PORTFACING:starvector,RV).
SET Tv to -VDOT(DP:PORTFACING:topvector,RV).
SET Fw TO CLAMP(-VDOT(DP:PORTFACING:vector,TGV)/5,-S,S). // divide by 5 is to start breaking in 5 m from target
SET Sw TO CLAMP(-VDOT(DP:PORTFACING:starvector,TGV)/5,-S,S).
SET Tw TO CLAMP(-VDOT(DP:PORTFACING:topvector,TGV)/5,-S,S).
SET VTGT1 TO VECDRAW(TDP:NODEPOSITION,TGV+DP:NODEPOSITION-TDP:NODEPOSITION,YELLOW,"Target",1,TRUE,0.2).
SET VTGT TO VECDRAW(DP:NODEPOSITION,TGV,WHITE,"Translate to",1,TRUE,0.2).
set ship:control:fore to Fv-Fw.	// Reverse
set ship:control:starboard to Sw-Sv.
set ship:control:top to Tw-Tv.
}
clearvecdraws().
RCS OFF.
}
CLEARSCREEN.
clearvecdraws().
SAS OFF.
RCS OFF.
LOCAL SEL IS SHIP:ELEMENTS:LENGTH. 
MSG("Docking sequence initiated.").
LOCAL DP IS SHIP:DOCKINGPORTS[0].
IF DP:STATE = "Disabled" {LOCAL MD IS DP:GETMODULE("ModuleAnimateGeneric"). MD:DOEVENT(MD:ALLEVENTNAMES[0]).}	// Open port
LOCAL TDP IS FindBestDP(DP).
IF TDP:ISTYPE("DockingPort"){
MSG("Aligning to docking port").
LOCK STEERING to lookdirup(-TDP:PORTFACING:VECTOR, TDP:PORTFACING:topvector)+R(0,0,R_Angle).
WAIT UNTIL VANG(DP:PORTFACING:VECTOR,-TDP:PORTFACING:VECTOR)<5.
PRINT "Aligned.".
IF VANG(TARGET:POSITION,TDP:PORTFACING:VECTOR)< 90 {MSG("We are at the wrong side. Avoiding collision."). TRANSLATE(1). WAIT 1.}
MSG("Translating to the safe docking vector start.").
TRANSLATE(2,2).
WAIT 1.
MSG("We are in safe docking position. Start docking.").
TRANSLATE(3).
UNLOCK ALL.
UNTIL SHIP:ELEMENTS:LENGTH > SEL WAIT 0.2.
MSG("Docking complete!").
}
ELSE ERR("Not found suitable docking ports on target.").