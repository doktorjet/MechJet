PARAMETER MODE.
LOCAL DONE IS FALSE.
CLEARSCREEN.
PRINT "CPU:" + core:element:name.
PRINT "kOS:" + core:version.
WAIT 1.

// В любом случае:
SWITCH TO 1. LIST FILES IN FL. FOR F IN FL {IF F:ISFILE OR (NOT F:ISFILE AND F:NAME <> "BOOT")DELETEPATH(F:NAME).}	// Чистим диск.
SWITCH TO 0. CD("MechJet").
COPYPATH(lib,"1:").
RUN ONCE "1:/lib".

LOCAL CMPL IS LIST().
LOCAL CPL IS LIST().

IF MODE = "launch_rocket" {
MSG("Готовлю файлы к запуску ракеты...").
SET CMPL TO LIST(
"exec"
).
SET CPL TO LIST(
"launch",
"MP/mp_altin",
"MP/mp_inc"
).
}
ELSE IF MODE = "orbital_stuff" {
MSG("Готовлю файлы к орбитальным манёврам...").
SET CMPL TO LIST(
"MP/mp_hoh"
).
SET CPL TO LIST(
"MP/mp_altin",
"MP/mp_inc",
"deorbit",
"exec",
"rndzvs"
).
}
FOR I in CMPL {COMPILE I TO "1:/"+PATH(I):name+".ksm".}
FOR I in CPL COPYPATH(I,"1:").
SWITCH TO 1.
MSG("Загрузка окончена.").
LIST.