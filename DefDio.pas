unit DefDio;

interface


const

  // DAE DIO 사용.
  MAX_IO_CNT = 40;
  MAX_IN_CNT = 40;
  MAX_OUT_CNT = 40;

  DAE_IO_DEVICE_IP = '192.168.0.99';
  DAE_IO_DEVICE_PORT = 6989;
  DAE_IO_DEVICE_INTERVAL = 200;

  DAE_IO_DEVICE_COUNT = 5;

  TYPE_NORMAL = 0;
  TYPE_GIB = 1;

  PROBE_CH1 = 0;
  PROBE_CH2 = 1;
  PROBE_CH3 = 2;
  ALL_CH = 3;
  // for TLS.
  // IN SIGNAL
  IN_FAN_1         = 0; // FAN 1 신호 구동 High -> 정지 Low
  IN_FAN_2         = 1;  // FAN 2 신호 구동 High -> 정지 Low
  IN_FAN_3         = 2; // FAN 3 신호 구동 High -> 정지 Low
  IN_FAN_4         = 3;  // FAN 4 신호 구동 High -> 정지 Low
  IN_TEMP          = 4;
  IN_MC_MONITOR    = 5;
  IN_EMO_FRONT     = 6;
  IN_EMO_BACK      = 7;

  IN_X_AXIS_SEN1    = 8;
  IN_X_AXIS_SEN2    = 9;
  IN_X_AXIS_SEN3    = 10;
  IN_X_AXIS_SEN4    = 11;
  IN_Z_UP_SEN       = 12;
  IN_Z_DOWN_SEN     = 13;
  IN_DOOR_OPEN_FR   = 14;
  IN_DOOR_OPEN_FL   = 15;

  IN_DOOR_OPEN_RR   = 16;
  IN_DOOR_OPEN_RL   = 17;
  IN_SW_ON_CH1      = 18;
  IN_SW_OFF_CH1     = 19;
  IN_SW_ON_CH2      = 20;
  IN_SW_OFF_CH2     = 21;
  IN_SW_ON_CH3      = 22;
  IN_SW_OFF_CH3     = 23;

  IN_SW_ON_ALLCH    = 24;
  IN_SW_OFF_ALLCH   = 25;
  IN_MAIN_AIR_PRES  = 26;
  IN_HC_PLATE_READY = 27;
  IN_HC_PLATE_RUN   = 28;
  IN_HC_PLATE_ALARM = 29;
  IN_WATER_PRES_LOW1 = 30;
  IN_WATER_PRES_HIGH1 = 31;

  IN_WATER_PRES_LOW2 = 32;
  IN_WATER_PRES_HIGH2 = 33;
  IN_WATER_LEAK_SEN1  = 34;
  IN_WATER_LEAK_SEN2  = 35;
  IN_WATER_LEAK_SEN3  = 36;
  IN_MAX = IN_WATER_LEAK_SEN3;

  // OUT SIGNAL
  OUT_LAMP_RED          = 0;
  OUT_LAMP_YELLOW       = 1;
  OUT_LAMP_GREEN        = 2;
  OUT_MELODY_1          = 3;
  OUT_MELODY_2          = 4;
  OUT_MELODY_3          = 5;
  OUT_MELODY_4          = 6;
  OUT_LAMP_WORKER_OFF   = 7;

  OUT_X_POSITION_1      = 8;
  OUT_X_POSITION_2      = 9;
  OUT_X_POSITION_3      = 10;
  OUT_X_POSITION_4      = 11;
  OUT_Z_POSITION_UP     = 12;
  OUT_Z_POSITION_DN     = 13;
  OUT_DOOR_UNLOCK_FR    = 14;
  OUT_DOOR_UNLOCK_FL    = 15;

  OUT_DOOR_UNLOCK_RR    = 16;
  OUT_DOOR_UNLOCK_RL    = 17;
  OUT_PAT_ON_CH1        = 18;
  OUT_PAT_OFF_CH1       = 19;
  OUT_PAT_ON_CH2        = 20;
  OUT_PAT_OFF_CH2       = 21;
  OUT_PAT_ON_CH3        = 22;
  OUT_PAT_OFF_CH3       = 23;

  OUT_PAT_ON_START      = 24;
  OUT_PAT_OFF_STOP      = 25;
  OUT_PG_PWR_OFF_CH1    = 26;
  OUT_PG_PWR_OFF_CH2    = 27;
  OUT_PG_PWR_OFF_CH3    = 28;
  OUT_IR_SENSOR_OFF_CH1 = 29;
  OUT_IR_SENSOR_OFF_CH2 = 30;
  OUT_IR_SENSOR_OFF_CH3 = 31;

  OUT_INSPECTION_DONE   = 32;
  OUT_MAX               = OUT_INSPECTION_DONE;


  // ErrList.
  ERR_LIST_START                  = IN_MAX + 1;
  ERR_LIST_IONIZER_STATUS_NG_CH1  = ERR_LIST_START + 1;
  ERR_LIST_IONIZER_STATUS_NG_CH2  = ERR_LIST_START + 2;
  ERR_LIST_IONIZER_STATUS_NG_CH3  = ERR_LIST_START + 3;
  ERR_LIST_DIO_CARD_DISCONNECTED  = ERR_LIST_START + 4;
  ERR_LIST_TEMP_SENSOR1_NG        = ERR_LIST_START + 5;
  ERR_LIST_TEMP_SENSOR2_NG        = ERR_LIST_START + 6;
  ERR_LIST_TEMP_SENSOR3_NG        = ERR_LIST_START + 7;
  ERR_LIST_TEMP_PLATE_1_NG        = ERR_LIST_START + 8;
  ERR_LIST_TEMP_PLATE_2_NG        = ERR_LIST_START + 9;
  ERR_LIST_TEMP_PLATE_3_NG        = ERR_LIST_START + 10;
  ERR_LIST_OUT_UNLOCK_DOOR1       = ERR_LIST_START + 11;
  ERR_LIST_OUT_UNLOCK_DOOR2       = ERR_LIST_START + 12;
  ERR_LIST_OUT_UNLOCK_DOOR3       = ERR_LIST_START + 13;
  ERR_LIST_OUT_UNLOCK_DOOR4       = ERR_LIST_START + 14;
  ERR_LIST_MAX                    = ERR_LIST_OUT_UNLOCK_DOOR4;

  // DIO List.
  asDioIn : array[0..Pred(DefDio.MAX_IN_CNT)] of string
  = ('Bottom Right FAN Run(FAN1)      '
    ,'Top Right FAN Run(FAN2)        '
    ,'Bottom Left FAN Run(FAN3)      '
    ,'Top Left FAN Run(FAN4)         '
    ,'Teperatutre Alarm              '
    ,'M/C Monitoring                 '
    ,'Front EMO(EMO1) Push           '
    ,'Rear EMO(EMO2) Push            '
    ,'X Axis Sen1 Detacting          '
    ,'X Axis Sen2 Detacting          '
    ,'X Axis Sen3 Detacting          '
    ,'X Axis Sen4 Detacting          '
    ,'Z Axis Up Sen                  '
    ,'Z Axis Down Sen                '
    ,'Front Right Door Open(LK1)     '
    ,'Front Left Door Open(LK2)      '
    ,'Rear Right Door Open(LK3)      '
    ,'Rear Left Door Open(LK4)       '
    ,'1CH Pattern On Switch Push     '
    ,'1CH Pattern Off Switch Push    '
    ,'2CH Pattern On Switch Push     '
    ,'2CH Pattern Off Switch Push    '
    ,'3CH Pattern On Switch Push     '
    ,'3CH Pattern Off Switch Push    '
    ,'Start Switch Push              '
    ,'Stop Switch Push               '
    ,'Main Air Pressure Alram        '
    ,'Hot&Cold Plate Controller Ready'
    ,'Hot&Cold Plate Controller Run  '
    ,'Hot&Cold Plate System Alarm    '
    ,'IN Water Pressure Sensor (Low) '
    ,'IN Water Pressure Sensor (High)'
    ,'OUT Water Pressure Sensor (Low)'
    ,'OUT Water Pressure Sensor (High)'
    ,'Water Leakage Sensor1(Top)     '
    ,'Water Leakage Sensor2(Inner) '
    ,'Water Leakage Sensor3(Bottom)'
    ,'                               '
    ,'                               '
    ,'                               ');
  asDioOut : array[0..Pred(DefDio.MAX_OUT_CNT)] of string
  = ('RED LAMP'
    ,'YELLOW LAMP'
    ,'GREEN LAMP'
    ,'MELODY#1'
    ,'MELODY#2'
    ,'MELODY#3'
    ,'MELODY#4'
    ,'Worker Lamp Off'
    ,'XAxis Position1(Sol1)'
    ,'XAxis Position2(So2)'
    ,'XAxis Position3(Sol3)'
    ,'XAxis Position4(Sol4)'
    ,'Z Axis Up Sol5'
    ,'Z Axis Down Sol6'
    ,'Front Right Door Unlock(LK1)'
    ,'Front Left Door Unlock(LK2)'
    ,'Rear Right Door Unlock(LK3)'
    ,'Rear Left Door Unlock(LK4)'
    ,'1CH Pattern On Switch LEDOn'
    ,'1CH Pattern Off Switch LEDOn'
    ,'2CH Pattern On Switch LEDOn'
    ,'2CH Pattern Off Switch LEDOn'
    ,'3CH Pattern On Switch LEDOn'
    ,'3CH Pattern Off Switch LEDOn'
    ,'Start Switch LEDOn'
    ,'Stop Switch LEDOn'
    ,'1CH PG Power Off'
    ,'2CH PG Power Off'
    ,'3CH PG Power Off'
    ,'1CH IRSensor RaserOff'
    ,'2CH IRSensor RaserOff'
    ,'3CH IRSensor RaserOff'
    ,'Muting','','','','','','','');

  asDioInShort : array[0..Pred(DefDio.MAX_IN_CNT)] of string
  = ('Btm Right FAN Run(FAN1)      '
    ,'Top Right FAN Run(FAN2)        '
    ,'Btm Left FAN Run(FAN3)      '
    ,'Top Left FAN Run(FAN4)         '
    ,'Teperatutre Alarm              '
    ,'M/C Monitoring                 '
    ,'Front EMO(EMO1) Push           '
    ,'Rear EMO(EMO2) Push            '
    ,'X Axis Sen1 Detacting          '
    ,'X Axis Sen2 Detacting          '
    ,'X Axis Sen3 Detacting          '
    ,'X Axis Sen4 Detacting          '
    ,'Z Axis Up Sen                  '
    ,'Z Axis Down Sen                '
    ,'FR Door Open(LK1)     '
    ,'FL Door Open(LK2)      '
    ,'RR Door Open(LK3)      '
    ,'RL Door Open(LK4)       '
    ,'1CH Pat On Switch     '
    ,'1CH Pat Off Switch    '
    ,'2CH Pat On Switch     '
    ,'2CH Pat Off Switch    '
    ,'3CH Pat On Switch     '
    ,'3CH Pat Off Switch    '
    ,'Start Switch Push              '
    ,'Stop Switch Push               '
    ,'Main Air Pressure        '
    ,'Hot&Cold Plate Ready'
    ,'Hot&Cold Plate  Run  '
    ,'Hot&Cold Plate System  '
    ,'IN Water Pressure Sensor (Low)                 '
    ,'IN Water Pressure Sensor (High)                '
    ,'OUT Water Pressure Sensor (Low)                 '
    ,'OUT Water Pressure Sensor (High)                '
    ,'Water Leakage Sensor1                     '
    ,'Water Leakage Sensor2                     '
    ,'Water Leakage Sensor3                     '
    ,'                               '
    ,'                               '
    ,'                               ');
  asDioOutShort : array[0..Pred(DefDio.MAX_OUT_CNT)] of string
  = ('RED LAMP'
    ,'YELLOW LAMP'
    ,'GREEN LAMP'
    ,'MELODY#1'
    ,'MELODY#2'
    ,'MELODY#3'
    ,'MELODY#4'
    ,'Worker Lamp Off'
    ,'XAxis Position1(Sol1)'
    ,'XAxis Position2(So2)'
    ,'XAxis Position3(Sol3)'
    ,'XAxis Position4(Sol4)'
    ,'Z Axis Up Sol5'
    ,'Z Axis Down Sol6'
    ,'Fornt Right Door Unlock(LK1)'
    ,'Fornt Left Door Unlock(LK2)'
    ,'Rear Right Door Unlock(LK3)'
    ,'Rear Left Door Unlock(LK4)'
    ,'1CH Pat On Switch LEDOn'
    ,'1CH Pat Off Switch LEDOn'
    ,'2CH Pat On Switch LEDOn'
    ,'2CH Pat Off Switch LEDOn'
    ,'3CH Pat On Switch LEDOn'
    ,'3CH Pat Off Switch LEDOn'
    ,'Start Switch LEDOn'
    ,'Stop Switch LEDOn'
    ,'1CH PG Power Off'
    ,'2CH PG Power Off'
    ,'3CH PG Power Off'
    ,'1CH IRSensor RaserOff'
    ,'2CH IRSensor RaserOff'
    ,'3CH IRSensor RaserOff'
    ,'검사완료','','','','','','','');

  // MAX_ALARM_DATA_SIZE = 10;
//  MAX_ALARM_DATA_SIZE = ERR_LIST_MAX div 8;
//
  LAMP_STATE_NONE     = 0;
  LAMP_STATE_MANUAL   = LAMP_STATE_NONE + 2;
  LAMP_STATE_PAUSE    = LAMP_STATE_NONE + 4;
  LAMP_STATE_AUTO     = LAMP_STATE_NONE + 8;
  LAMP_STATE_REQUEST  = LAMP_STATE_NONE + 16;
  LAMP_STATE_ERROR    = LAMP_STATE_NONE + 32;
  LAMP_STATE_EMEGENCY = LAMP_STATE_NONE + 64;
implementation

end.
