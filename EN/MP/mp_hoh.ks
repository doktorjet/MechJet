PARAMETER PE IS 0.
RUN ONCE lib.
IF HASTARGET {
until not hasnode {	if hasnode { remove nextnode. }	}
LOCAL SSa is obt:semimajoraxis.
IF PE > 0 {SET PE TO PE + TARGET:RADIUS}.
local TSa is target:obt:semimajoraxis - PE.
local HSa is (SSa + TSa) / 2.
local TT is constant:pi * SQRT(HSa^3/body:mu).
local TrAn is 180 - (TT / target:obt:period * 360).
local PhR is constant:radToDeg*(SQRT(body:mu / TSa^3) - SQRT(body:mu / SSa^3)).
local SAng is mod(obt:LAN + obt:ArgumentOfPeriapsis + obt:trueanomaly, 360).
local TAng is mod(target:obt:LAN + target:obt:ArgumentOfPeriapsis + target:obt:trueanomaly, 360).
local dAng is MOD(360+TrAn - TAng + SAng,360).
IF PhR < 0 {SET dAng TO dAng - 360.}
local PhT is (dAng / PhR).
local dV is sqrt(body:mu * (2/SSa - 1/HSa)) - ship:velocity:obt:mag.
add node(TIME:SECONDS + PhT, 0, 0, dV).
LOCAL N IS NEXTNODE.
//IF TARGET:ISTYPE("BODY")AND N:OBT:HASNEXTPATCH{UNTIL ENCOUNTER:PERIAPSIS >= PE*1000 {SET N:PROGRADE TO N:PROGRADE - 0.02.}}
}