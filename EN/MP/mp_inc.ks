@lazyglobal OFF.
RUN ONCE lib.
PARAMETER INC is FALSE.
for n in ALLNODES {remove n.}
function mft {parameter a. LOCAL e IS OBT:eccentricity. if e < 0.001 return a. if e >= 1 { ERR("meanFromTrue("+round(a,2)+") with e=" + round(e,5)). return a.} set a to a*.5. set a to 2*arctan2(sqrt(1-e)*sin(a),sqrt(1+e)*cos(a)). return a - e * sin(a) * 180/constant:pi.}

LOCAL TA IS 0. LOCAL DI IS 0.
IF HASTARGET {local sp is ship:position-body:position. local sn is OrbN(SHIP). local ln is vcrs(OrbN(TARGET),sn). SET di TO Rinc(SHIP,TARGET). SET ta TO vang(sp, ln). if vang(vcrs(sp,ln),sn) < 90 set ta to -ta. SET ta TO ta + OBT:trueAnomaly.}
ELSE IF INC {
SET di TO INC-OBT:INCLINATION. 
SET ta TO -OBT:argumentOfPeriapsis.}
IF ABS(di) > 0.05 {
set ta to MOD(360+ta,360). 
LOCAL FUNCTION TTA {PARAMETER TA. RETURN TIME:SECONDS+MOD(360 + mft(ta) - mft(OBT:trueAnomaly),360) / 360 * OBT:period.}
local v1 is velocityAt(ship,TTA(TA)):OBT:mag.
LOCAL TT IS MOD(180+TA,360).
LOCAL v2 is velocityAt(ship,TTA(TT)):OBT:mag.
LOCAL T1 IS TTA(TA).
IF v1 > V2 {SET V1 to V2. SET T1 to TTA(TT). SET di to -di.}
add node(t1, 0, v1 * sin(di), v1 *(cos(di)-1)).
}
ELSE MSG("Relative angle is negligibly small.").