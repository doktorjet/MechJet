// MechJet Maneuer Executor for KOS 1.1.5.2
// © Dr.Jet CC BY-NC 3.0
@lazyglobal OFF.
RUN ONCE lib.
PARAMETER THR IS 0.1.
IF HASNODE {
	IF SHIP:AVAILABLETHRUST > 0 {
		SAS OFF.
		LOCAL ND to NEXTNODE.
		LOCAL BT to ND:DELTAV:MAG*MASS/SHIP:AVAILABLETHRUST/2 +2.	// Half of estimated burn time + 2s
		MSG("Executing maneuver of " + ROUND(ND:DELTAV:MAG,1) + "m/s dV in: "+HMS(ND:ETA)+".").
		LOCK steering to ND:DELTAV:DIRECTION.
		POP("Aligning to maneuver.").
		WAIT UNTIL VANG(ND:DELTAV, FACING:VECTOR) < 1.
		POP("Waiting for maneuver start.").
		WARPTO (UT(ND:ETA) - BT - 10). WAIT UNTIL ND:ETA <= BT.
		BURN({Return ND:DELTAV.}).
		WAIT 1.
		MSG("Maneuer executed!").
		REMOVE ND.
		UNLOCK ALL.
		}
	ELSE {ERR("Vessel has no thrust!").}
	}
ELSE {ERR("There are no planned maneuer nodes!").}