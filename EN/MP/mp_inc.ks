PARAMETER I,T IS FALSE.
RUN ONCE LIB.
for n in ALLNODES {remove n.}
FUNCTION V2I {
PARAMETER I,T.
LOCAL P IS POSITIONAT(SHIP,UT(T)). 
LOCAL U IS (P-BODY:position):NORMALIZED.
LOCAL L IS BODY:GEOPOSITIONOF(P):LAT.
LOCAL D IS HFI(I,L).
LOCAL AHV IS VXCL(U,VELOCITYAT(SHIP,UT(T)):ORBIT).
LOCAL N IS VXCL(U, v(0,1,0)).
LOCAL E IS VCRS(U,N).
LOCAL NHV IS COS(D) * N.
LOCAL EHV IS SIN(D) * E.
IF VDOT(AHV,NHV) < 0 SET NHV to -NHV. IF D180(I) < 0 SET NHV to -NHV.
LOCAL WHV IS AHV:MAG*(NHV+EHV):NORMALIZED.
RETURN WHV - AHV.
}
IF T <> FALSE VNODE(V2I(I,T),T).
ELSE IF OBT:ECCENTRICITY<1{SET A TO ETA_AN(). SET D TO ETA_DN(). SET VA TO V2I(I,A). SET VD TO V2I(I,D). IF VA:MAG < VD:MAG VNODE(VA,A). ELSE VNODE(VD,D).} ELSE ERR("Must set time for this maneuver in hyperbolic trajectory.").