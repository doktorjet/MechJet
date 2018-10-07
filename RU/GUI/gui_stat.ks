// Scalar to string, maintaining 1 decimal position.
FUNCTION R {
PARAMETER N.
LOCAL S TO ROUND(N,1):TOSTRING.
IF NOT S:CONTAINS(".") { SET S TO S + ".0".	}
RETURN S.
}

// Show parameters GUI
FUNCTION SHOWSTATS {
GLOBAL SSG IS GUI(340).
LOCAL ttl IS SSG:addlabel("<size=16><b>MechJet: Данные</b></size>").
SET ttl:style:align to "center".
LOCAL H1 IS SSG:ADDHLAYOUT().
LOCAL V1 IS H1:ADDVLAYOUT().
LOCAL V2 IS H1:ADDVLAYOUT().
LOCAL V3 IS H1:ADDVLAYOUT().
LOCAL V4 IS H1:ADDVLAYOUT().
V1:addlabel("<b>OSpd (м/с):</b>").
V1:addlabel("<b>AP (км):</b>").
V1:addlabel("<b>PE (км):</b>").
V1:addlabel("<b>INC:</b>").
V3:addlabel("<b>SSpd (м/с):</b>").
V3:addlabel("<b>Pitch:</b>").
V3:addlabel("<b>Lat:</b>").
V3:addlabel("<b>Long:</b>").
GLOBAL SL_OS IS V2:addlabel("-").
GLOBAL SL_AP IS V2:addlabel("-").
GLOBAL SL_PE IS V2:addlabel("-").
GLOBAL SL_IN IS V2:addlabel("-").
GLOBAL SL_SS IS V4:addlabel("-").
GLOBAL SL_PI IS V4:addlabel("-").
GLOBAL SL_LA IS V4:addlabel("-").
GLOBAL SL_LO IS V4:addlabel("-").
LOCAL SS_HD IS SSG:ADDBUTTON("Скрыть").
SET SS_HD:ONCLICK TO {SSG:HIDE().}.
SSG:SHOW().
USTATS().
}

// Show Parameters update
FUNCTION USTATS {	// Show Parameters update
SET SL_OS:TEXT TO R(ORBIT:VELOCITY:ORBIT:MAG).
SET SL_AP:TEXT TO R(ORBIT:APOAPSIS/1000).
SET SL_PE:TEXT TO R(ORBIT:PERIAPSIS/1000).
SET SL_IN:TEXT TO R(ORBIT:INCLINATION)+"°".
SET SL_SS:TEXT TO R(ORBIT:VELOCITY:SURFACE:MAG).
SET SL_PI:TEXT TO R(90 - VANG(FACING:FOREVECTOR, ship:up:FOREVECTOR))+"°".
SET SL_LA:TEXT TO R(LATITUDE)+"°".
SET SL_LO:TEXT TO R(LONGITUDE)+"°".
}