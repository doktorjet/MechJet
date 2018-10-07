# MechJet
## Scripts for kOS, partially repeating MechJeb functionality.

***
### deorbit.ks (%L)
_No compilation needed._  
**Dependencies:** `lib.ks`

Deorbits from LKO at L longitude (default 174.7) and stage till stage 0 when in atmosphere.

***
### exec.ks (%THR)
_Compilation recommended._  
**Dependencies:** `lib.ks` _(GUI/stat.ks removed for now)_

Program to execute the next maneuer node. Optional parameter sets threshold for maneuer dV (default 0.1 m/s).

***
### launch.ks (%ORB, %INC, %TSH, %PLM, %DN)
_Compilation recommended._  
**Dependencies:** `lib.ks` _(GUI/stat.ks removed for now)_

Launch to orbit program with "MechJeb Classic" trajectory. Will also autostage boosters (but not droptanks), jettison fairings and open solar panels when needed.  
Launch to target orbital plane is only possible now via _GUI/gui_launch.ks_.

**Parameters:**  
:   `ORB` - Wanted orbit height (km), default 90.  
`INC` - Wanted orbit incination, default  0.  
`TSH` - Trajectory Sharpness, default 0.5 (it is MechJeb's 50).  
`PLM` - Final pitch limiter, default 0.  
`DN` - Start at Descending Node, default False.  

***
### lib.ks
_No compilation needed.  
No dependencies._

**Functions:**  
:   `POP(STRING)` - wrapper for standard HUD message.  
`MSG(STRING)` - standard HUD message with console echo.  
`WRN(STRING)` - HUD warning with console echo.  
`ERR(STRING)` - HUD error with console echo.  
`HMS(TIME)` - returns H:M:S string.  
`OrbN(ORBIT)` - returns normalized normal vector to orbit.  
`RInc(Orbitable,Orbitable)` - returns relative inclination (°).  
`TTLng(Longitude)`- returns time to longitude (s).  
`VNODE**(Vector,Seconds)` - creates a maneuver node with DeltaV = Vector in set Seconds from now.  
`BURN(VectorFunction,%Threshold)` - burns along Vector returned by VectorFunction until it's magnitude is less than Threshold (optional, default 0.1). (Causes unexpected bugs sometime).

***
### prepare_to.ks (MODE)
_No compilation needed.  
No dependencies._

Makeshift mission manager. Will clean vessel disk and load files needed.  
`MODE` is either *"launch_rocket"* or *"orbital_stuff"* for now.

***
### rndzvs.ks (%DST)
_No compilation needed.  
No dependencies._

Mostly a wrapper around other programs to perform a rendevzous sequence. Does not use iterative calculations like "Lambert solver".
Parameter `DST` is wanted final distance from target, defaults to 80 (though it's most likely to end at 100-160).

***
### GUI/gui_launch.ks
_Compilation needed?  
No dependencies._

Pre-launch GUI for selecting MechJeb-like launch parameters.

**GUI elements:**  
:   `ORB` - Wanted orbit height (km), defaults to 90.  
`INCL` - Wanted orbit inclination(°), defaults to 0.  
`TS` - trajectory steepness, defaults to 0.5.  
`FPit` - pitch at final part of pseudo-GT, defaults to 0.  
`DN` - checkbox for the case of launching at DN of target.  

***
### GUI/stat_gui.ks
_Compilation needed?  
No dependencies._

Supplementary GUI to be runned from _launch.ks_ and _exec.ks_. Shows some flight parameters. 
Removed from code temporarily. MJ or KER are much better as displaing things.

***
### MP/mp_altin.ks (ALT, T)
_No compilation needed.  
No dependencies._

Creates a maneuver node in T seconds fron now, setting an ALT orbital height in opposite node.

**Examples:**
:   `run mp_altin(SHIP:APOAPSIS,ETA:APOAPSIS).` - Circularize at Apoapsis.  
`run mp_altin(SHIP:PERIAPSIS,ETA:PERIAPSIS).` - Circularize at Periapsis.  
`run mp_altin(20000,TTLng(174.7)).` - Deorbit trajectory to start over 174.7 longitude and land near KSC. (Start longitude may vary, depending on vessel used).  

***
### MP/mp_hoh.ks (%PE)
_Compilation recommended.  
No dependencies._

Creates a Hohmann maneuver node to reach target in coplanar circular orbit.  
`PE` is optional parameter to aim radius + periapsis "under" the center of target body, defaults to 0.

***
### MP/mp_inc.ks (%INC)
_No compilation needed._  
**Dependencies:** _lib.ks_

If target selected - creates a maneuver node to match target inclination.  
In taget is not selected - must set `INC` parameter for inclination wanted.

**Examples:**
:   `RUN mp_inc(90).` - Create a node to make a polar orbit.  
`RUN ONCE lib. IF HASTARGET AND RInc(SHIP,TARGET)>0.5 {RUN mp_inc.}` - Load a lib for RInc function. If relative inclination is more than 0.5° - create a node to match inclination.

***
### MP/mp_preland.ks (TLAT, TLNG, %PE)
_Compilation needed?  
No dependencies._

Creates a maneuer node for bringind orbit periapsis over the landing site with `TLAT,TLNG` coordinates and lowering it to `PE` (default 20000 m).  
Idea of this maneuver © [TheGreatFez](https://github.com/TheGreatFez).