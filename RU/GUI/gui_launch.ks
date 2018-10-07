@lazyglobal OFF.
LOCAL GL IS GUI(200).
LOCAL LW IS FALSE.
// GLOBAL LP IS LIST(90,0,0.5,0).

FUNCTION ETA_AN_DN	// Idea by ElWanderer, https://github.com/ElWanderer/kOS_scripts/
{
PARAMETER TGT, AN IS TRUE.
LOCAL RL IS ARCSIN(MAX(-1,MIN(1,TAN(LATITUDE)/TAN(TGT:OBT:INCLINATION)))).
IF NOT AN {SET RL TO 180 - RL.}
RETURN MOD(MOD(TGT:OBT:LAN + RL - BODY:ROTATIONANGLE+360,360) - LONGITUDE+360,360) / 360 * BODY:ROTATIONPERIOD.
}

LOCAL ttl IS GL:addlabel("<size=16><b>MechJet: Запуск</b></size>").
SET ttl:style:align to "center".
LOCAL H1 IS GL:ADDHLAYOUT().
LOCAL V1 IS H1:ADDVLAYOUT().
LOCAL V2 IS H1:ADDVLAYOUT().
LOCAL OL IS V1:addlabel("<b>ORB (км):</b>").
LOCAL IL IS V1:addlabel("<b>INCL (°):</b>").
LOCAL TL IS V1:addlabel("<b>TS: 0.5</b>").
LOCAL FL IS V1:addlabel("<b>FPit (°):</b>").
LOCAL DN TO V1:ADDCHECKBOX("DN",FALSE).

LOCAL GL_OR TO V2:ADDTEXTFIELD("90").
LOCAL GL_IN TO V2:ADDTEXTFIELD("0").
LOCAL GL_TS TO V2:ADDHSLIDER(0.5,0.1,0.9).
LOCAL GL_FP TO V2:ADDTEXTFIELD("0").
LOCAL GL_LB IS GL:ADDBUTTON("Запуск").

// Tooltips do not work. =( 
//SET GL_OR:TOOLTIP TO "Желаемая высота орбиты.".
//SET GL_IN:TOOLTIP TO "Желаемое наклонение орбиты.".
//SET TL:TOOLTIP TO "Кривизна траектории запуска зависит от начальной TWR. Оставьте 0.5, если не знаете, что делаете.".
//SET GL_FP:TOOLTIP TO "Угол тангажа в конце траектории. Рекомендуется 0.".

SET GL_TS:ONCHANGE TO {PARAMETER A. SET TL:TEXT TO "TS: "+ROUND(A,2):TOSTRING. }.

SET GL_LB:ONCLICK TO { SET LW TO TRUE. }.

WHEN HASTARGET THEN {
LOCAL GL_LR IS GL:ADDBUTTON("Запуск в орбитальную плоскость цели").

SET GL_LR:ONCLICK TO {	// Launch to target plane.
SET GL_IN:TEXT TO ROUND(TARGET:OBT:INCLINATION,2):TOSTRING.
GL_LB:HIDE().
LOCAL ETA_AN TO ETA_AN_DN(TARGET).
LOCAL ETA_DN TO ETA_AN_DN(TARGET,FALSE).
LOCAL LT TO 0.
IF ETA_DN > 0 AND ETA_DN < ETA_AN {SET DN:PRESSED TO TRUE. SET LT TO ETA_DN. MSG("Ближайшее окно запуска в НУ(DN) цели через "+(TIME-TIME+LT):CLOCK).}
ELSE IF ETA_AN > 0 AND ETA_AN <= ETA_DN {SET LT TO ETA_AN. MSG("Ближайшее окно запуска в ВУ(AN) цели через "+(TIME-TIME+LT):CLOCK)..}
WAIT 2.
IF LT > 0{
GL_LR:HIDE().
MSG("Ожидаю окно запуска...").
SET LT TO TIME:SECONDS+LT-180.	// -180
WARPTO(LT).
UNTIL (TIME:SECONDS > LT+1) {}.
SET MAPVIEW TO FALSE.
MSG("Окно запуска достигнуто!").
SET LW TO TRUE.
}
ELSE {GL_LR:HIDE(). ERR("Ошибка! Не могу вычислить окно запуска."). MSG("Рекомендую сменить точку запуска или задать орбиту вручную.").}
}.
}.
GL:SHOW().
UNTIL LW {}.
GL:HIDE().
run launch(GL_OR:TEXT:TOSCALAR,GL_IN:TEXT:TOSCALAR,ROUND(GL_TS:VALUE,2),GL_FP:TEXT:TOSCALAR,DN:PRESSED).
CLEARGUIS().