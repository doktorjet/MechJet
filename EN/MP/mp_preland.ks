// Pre-land orbit tuning. (Start from circular equatorial orbit only.)
// MechJet © Dr.Jet CC BY-NC 3.0
parameter TLat is 20, TLng IS 100, PE is 20000.
for n in ALLNODES { remove n.}
RUN ONCE lib.
function LOM_Vec {	// Landing Orbit Maneur idea © TheGreatFez, https://github.com/TheGreatFez
parameter INC, PE, T.
local VV to velocityat(ship,time:seconds + T):orbit.
local PV to positionat(ship,time:seconds + T).
local BV to POSITIONAT(ship,time:seconds + T)-BODY:POSITION.
local VC to VV*ANGLEAXIS(-INC,BV).
local Rp to body:radius + PE.
local Ra to 2*OBT:Semimajoraxis - Rp.
local RD to ARCCOS(sqrt(OBT:Semimajoraxis*body:mu*(1-((Ra - Rp)/(Ra + Rp))^2))/(velocity:orbit:mag*body:position:mag)).
RETURN VC*ANGLEAXIS(RD,VCRS(BV,VC)).}
LOCAL TT IS TTLng(Tlng-90).
VNODE((LOM_Vec(TLat,PE,TT) - velocityat(ship,time:seconds + TT):orbit),TT).