@lazyglobal OFF.
PARAMETER DST is 80.
RUN ONCE lib.
SAS OFF.
FUNCTION RV{RETURN TARGET:OBT:VELOCITY:ORBIT - OBT:VELOCITY:ORBIT.}
IF HASTARGET {
LOCAL ST IS 0.
IF ABS(rinc(SHIP,TARGET)) > 0.05 {MSG("Выравниваю относительное наклонение.").RUN mp_inc. RUN exec.}
MSG("Планирую сближение.").
RUN mp_hoh.
RUN exec.
MSG("Планирую торможение."). 
IF TARGET:ALTITUDE < ALTITUDE SET ST TO ETA:PERIAPSIS. ELSE SET ST TO ETA:APOAPSIS.
WARPTO(TIME:SECONDS+ST).
BURN(RV@).
PRINT "RV = "+(TARGET:OBT:VELOCITY:ORBIT - OBT:VELOCITY:ORBIT):MAG.
WAIT 3.
IF TARGET:POSITION:MAG > DST {
MSG("Сблизился с целью на "+ROUND(TARGET:POSITION:MAG)+". Планирую финальное сближение.").
LOCAL dV IS TARGET:POSITION:MAG/120.
VNODE(dV*TARGET:POSITION:NORMALIZED, 20).
RUN exec.
SET ST TO (TARGET:POSITION:MAG - DST)/dV-5.
WARPTO(TIME:SECONDS+ST).
BURN(RV@,0.05).
PRINT "RV = "+RV():MAG.
}
MSG("Цель достигнута. Расстояние до цели = " +ROUND(TARGET:POSITION:MAG)+ "м.").
SAS ON.
}
ELSE {ERR("Нет цели для рандеву.").}