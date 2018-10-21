//HUD
FUNCTION POP{PARAMETER T. HUDTEXT(T, 5, 2, 20, GREEN, FALSE).}
FUNCTION MSG{PARAMETER T. HUDTEXT(T, 5, 2, 20, GREEN, FALSE). PRINT "MSG: "+T.}
FUNCTION ERR{PARAMETER T IS "ERR". HUDTEXT(T, 10, 4, 20, RED, FALSE). PRINT "ERR: "+T.}
FUNCTION WRN{PARAMETER T IS "WRN". HUDTEXT(T, 10, 4, 20, RGB(255,140,0), FALSE). PRINT "WRN: "+T.}
FUNCTION HMS{PARAMETER T. RETURN (TIME-TIME+T):CLOCK.}
FUNCTION DMS {PARAMETER A. LOCAL AA IS ABS(A). LOCAL D IS FLOOR(AA). LOCAL M IS FLOOR(60*(AA-D)). RETURN SIGN(A)*D+"°"+DIG(M)+"'"+DIG(FLOOR(3600*(AA-D-M/60)))+CHAR(34).}
FUNCTION DIG {PARAMETER N, D IS 2. LOCAL R is ABS(ROUND(N)):TOSTRING. UNTIL R:LENGTH >= D SET R TO "0" + R. RETURN R.}
//Math
FUNCTION IIF {PARAMETER c, t, f. IF c RETURN t. RETURN f.}
FUNCTION SIGN{PARAMETER X. IF X<0 RETURN -1. IF X > 0 RETURN 1. RETURN 0.}
FUNCTION CLAMP{PARAMETER A,X,Y. IF A < X RETURN X. IF A > Y RETURN Y. RETURN A.}
FUNCTION D360 {PARAMETER A. RETURN MOD(3600+A,360).}
FUNCTION D180 {PARAMETER A. RETURN -180*FLOOR(MOD(360+A,360)/180)+MOD(360+A,180).}
GLOBAL r2d IS 180/constant:pi.
//Orbital math
FUNCTION HFI{PARAMETER I,L. LOCAL C TO COS(I)/COS(L). IF ABS(C)>1 {IF ABS(D180(I)) < 90 RETURN 90. ELSE RETURN 270.} ELSE {LOCAL A TO ARCCOS(C). IF I<0 SET A TO -A. RETURN D360(90-A).}}
function OrbN{PARAMETER O IS SHIP. RETURN VCRS(O:BODY:POSITION - O:POSITION, O:VELOCITY:ORBIT):NORMALIZED.}
function RInc{parameter A, B. RETURN VANG(OrbN(A), OrbN(B)).}
function TTLng{PARAMETER L. LOCAL AS IS (360/OBT:PERIOD) - 360/BODY:ROTATIONPERIOD. LOCAL DL IS MOD(L + 360 - LONGITUDE, 360). IF DL < 0 {SET DL to DL + 360.} RETURN DL/AS.}
function ANDIR {parameter RN. LOCAL NV IS vcrs(body:position-orbit:position,velocity:orbit). return lookdirup(VCRS(NV,RN),NV).} // direction with vector=AN vector, up=normal
function ETA_TA {parameter ta, O IS OBT. local CTA to O:trueanomaly. local OE to O:eccentricity. local EF to sqrt( (1-OE) / (1+OE) ). local CE to 2*arctan( EF * tan(CTA / 2) ). local NE to 2*arctan( EF * tan(ta / 2) ). local dt to sqrt( O:semimajoraxis^3 / O:body:mu ) * ((NE - CE)*constant:degtorad - OE * (sin(NE) - sin(CE))). until dt > 0 { set dt to dt + O:period. } return dt. }
function ETA_AN {parameter RN IS V(0,1,0). local AN_NRM to ANDIR(RN). local ANvec to AN_NRM:vector. local taAN to arctan2( vdot(AN_NRM:upvector, vcrs(body:position, ANvec)), -vdot(body:position, ANvec) ) + orbit:trueanomaly. return ETA_TA(taAN).}
function ETA_DN {parameter RN IS V(0,1,0). local DN_NRM to ANDIR(RN). local DNvec to -DN_NRM:vector. local taDN to arctan2( vdot(DN_NRM:upvector, vcrs(body:position, DNvec)), -vdot(body:position, DNvec) ) + orbit:trueanomaly. return ETA_TA(taDN).}
//Utils
FUNCTION UT{PARAMETER T IS 0. RETURN TIME:SECONDS+T.}
FUNCTION VNODE{Parameter VC,T. SET T TO UT(T). local P is velocityat(ship,T):orbit. local N is vcrs(P,positionat(ship,T)-BODY:POSITION). ADD NODE(T,vdot(VC,vcrs(N,P):normalized), vdot(VC,N:normalized), vdot(VC,P:normalized)).}
FUNCTION BURN{PARAMETER BV, THR IS 0.1. SAS OFF.
LOCK steering to BV(). WAIT UNTIL VANG(BV(), FACING:VECTOR) < 0.5.
LOCK THROTTLE to (1/(1+VANG(BV(),FACING:VECTOR)^2))*max(0.01,min(1,BV():MAG*MASS/SHIP:AVAILABLETHRUST)).
WAIT UNTIL BV():MAG <= THR. UNLOCK THROTTLE. UNLOCK STEERING.}
FUNCTION SSTATE {PARAMETER S. LOCAL FN IS "1:/state". IF EXISTS(FN) SET F TO OPEN(FN). ELSE SET F TO CREATE(FN). F:CLEAR().F:WRITE(S:TOSTRING()).}
FUNCTION RSTATE {LOCAL FN IS "1:/state". IF EXISTS(FN) {SET F TO OPEN(FN). RETURN F:READALL():STRING:TONUMBER(-1).} ELSE RETURN -1.}