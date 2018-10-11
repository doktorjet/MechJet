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
FOR D in DPS {IF VANG(DP:PORTFACING:VECTOR,D:PORTFACING:VECTOR) > A {SET A TO VANG(TARGET:POSITION,D:PORTFACING:VECTOR). SET TDP TO D.}}
MSG("Chosen "+TDP:NAME+" with tag "+TDP:TAG+" (rel.incl. is "+ROUND(180-A,1)+"°).").
}
RETURN TDP.
}
FUNCTION TVEC{	// Translation vector
PARAMETER M,S IS 25.
IF M = 1 RETURN TDP:NODEPOSITION+TDP:PORTFACING:STARVECTOR:NORMALIZED*S*1.5-DP:NODEPOSITION.	// 1.5*SafeRadius meters to the side of target DP
IF M = 2 RETURN TDP:NODEPOSITION+TDP:PORTFACING:VECTOR:NORMALIZED*S-DP:NODEPOSITION.	// SafeRadius meters in front of target DP
IF M = 3 RETURN TDP:NODEPOSITION+TDP:PORTFACING:VECTOR:NORMALIZED*0.15-DP:NODEPOSITION.	// 15cm in front of target DP
RETURN V(0,0,0).
}
FUNCTION TRANSLATE {
PARAMETER M,S IS 25.
clearvecdraws().
LOCAL Kp IS 1. LOCAL Ki IS 0. LOCAL Kd IS 5.
LOCAL PID_s IS PIDloop(Kp,Ki,Kd,-1,1). SET PID_s:setpoint TO 0.
LOCAL PID_t IS PIDloop(Kp,Ki,Kd,-1,1). SET PID_t:setpoint TO 0.
LOCAL PID_f IS PIDloop(Kp,Ki,Kd,-1,1). SET PID_f:setpoint TO 0.
LOCAL RV IS 0.
RCS ON.
UNTIL TVEC(M,S):MAG < 0.2 {
SET TGV TO TVEC(M,S).
SET RV TO VELOCITY:ORBIT - TARGET:VELOCITY:ORBIT.
SET VTGT1 TO VECDRAW(TDP:NODEPOSITION,TDP:PORTFACING:VECTOR:NORMALIZED*S,YELLOW,"Current target",1,TRUE,0.2).
SET VTGT TO VECDRAW(DP:NODEPOSITION,TGV,WHITE,"To target",1,TRUE,0.2).
SET f_err to -VDOT(DP:PORTFACING:vector,TGV).
SET s_err to -VDOT(DP:PORTFACING:starvector,TGV).
SET t_err to -VDOT(DP:PORTFACING:topvector,TGV).
set ship:control:fore to PID_f:update(time:seconds,f_err).
set ship:control:top to -PID_t:update(time:seconds,t_err).
set ship:control:starboard to -PID_s:update(time:seconds,s_err).
}
clearvecdraws().
UNLOCK ALL.
RCS OFF.
}
CLEARSCREEN.
clearvecdraws().
SAS OFF.
RCS OFF.
LOCAL SEL IS SHIP:ELEMENTS:LENGTH. 
MSG("Docking sequence initiated.").
LOCAL DP IS SHIP:DOCKINGPORTS[0].
LOCAL TDP IS FindBestDP(DP).
DP:CONTROLFROM().
MSG("Aligning to docking port").
LOCK STEERING to lookdirup(-TDP:PORTFACING:VECTOR, TDP:PORTFACING:topvector)+R(0,0,R_Angle).
WAIT UNTIL VANG(DP:PORTFACING:VECTOR,-TDP:PORTFACING:VECTOR)<5.
PRINT "Aligned.".
IF VANG(TARGET:POSITION,TDP:PORTFACING:VECTOR)< 90 {MSG("We are at the wrong side. Avoiding collision."). TRANSLATE(1). WAIT 2.}
MSG("Translating to the safe docking vector start.").
TRANSLATE(2).
WAIT 2.
MSG("We are in safe docking position. Start docking.").
TRANSLATE(3).
WAIT UNTIL SHIP:ELEMENTS:LENGTH > SEL.
MSG("Docking complete!").