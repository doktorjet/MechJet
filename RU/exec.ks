// MechJet Maneuer Executor for KOS 1.1.5.2
// © Dr.Jet CC BY-NC 3.0
@lazyglobal OFF.
RUN ONCE lib.
PARAMETER THR IS 0.1.
IF HASNODE {
	IF SHIP:AVAILABLETHRUST > 0 {
		SAS OFF.
		LOCAL ND to NEXTNODE.
		LOCAL BT to ND:DELTAV:MAG*MASS/SHIP:AVAILABLETHRUST/2 +2.	// Половина предполагаемого времени прожига + 2s
		MSG("Выполняю манёвр на " + ROUND(ND:DELTAV:MAG,1) + "м/с dV через: " + HMS(ND:ETA) + "с.").
		LOCK steering to ND:DELTAV.
		POP("Выравниваюсь по манёвру.").
		WAIT UNTIL VANG(ND:DELTAV, FACING:VECTOR) < 1.
		POP("Ожидаю начало манёвра.").
		WARPTO (TIME:SECONDS + ND:ETA - BT - 10). WAIT UNTIL ND:ETA <= BT.
		BURN({Return ND:DELTAV.}).
		WAIT 1.
		MSG("Манёвр выполнен!").
		REMOVE ND.
		SAS ON.
		}
	ELSE {ERR("У аппарата нет тяги!").}
	}
ELSE {ERR("Нет запланированных узлов манёвра!").}