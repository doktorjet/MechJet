parameter ALT, T.
SET T TO TIME:SECONDS + T.
local r is BODY:RADIUS + ship:body:altitudeof(positionat(ship, T)).
local v2 is sqrt(SHIP:VELOCITY:ORBIT:mag*SHIP:VELOCITY:ORBIT:mag + (BODY:MU * (2/r - 2/(BODY:RADIUS + ALTITUDE) + 1/OBT:SEMIMAJORAXIS - 2/(ALT + BODY:RADIUS + r) ) ) ).
local dV is v2 - VELOCITYAT(SHIP,T):ORBIT:MAG.
local nd is node(T, 0, 0, dV).
add nd.