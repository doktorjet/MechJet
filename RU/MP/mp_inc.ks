@lazyglobal OFF.
RUN ONCE lib.
PARAMETER INC is FALSE.
function mft {parameter a. LOCAL e IS OBT:eccentricity. if e < 0.001 return a. if e >= 1 { ERR("meanFromTrue("+round(a,2)+") with e=" + round(e,5)). return a.} set a to a*.5. set a to 2*arctan2(sqrt(1-e)*sin(a),sqrt(1+e)*cos(a)). return a - e * sin(a) * 180/constant:pi.}
LOCAL TA IS 0. LOCAL DI IS 0.
IF HASTARGET {local sp is ship:position-body:position. local sn is OrbN(SHIP). local ln is vcrs(OrbN(TARGET),sn). SET di TO Rinc(SHIP,TARGET). SET ta TO vang(sp, ln). if vang(vcrs(sp,ln),sn) < 90 set ta to -ta. SET ta TO ta + OBT:trueAnomaly.}
ELSE IF INC {SET di TO INC-OBT:INCLINATION. SET ta TO -OBT:argumentOfPeriapsis.}
IF ABS(di) > 0.05 {set ta to MOD(360+ta,360). if ta < OBT:trueAnomaly { set ta to ta+180. set di to -di.}	
local dt is MOD(360 + mft(ta) - mft(OBT:trueAnomaly),360) / 360 * OBT:period.
local t1 is time:seconds+dt. local v is velocityAt(ship, t1):OBT:mag.
add node(t1, 0, v * sin(di), v *(cos(di)-1)).
}
ELSE MSG("Угловое отклонение ничтожно мало.").