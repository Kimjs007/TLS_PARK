unit DefScript;


interface

const
    // Sequence ID.
  SEQ_STOP      = 0;
  SEQ_KEY_START = 1;
  SEQ_KEY_STOP  = 2;
  SEQ_KEY_1     = 3;
  SEQ_KEY_2     = 4;
  SEQ_KEY_3     = 5;
  SEQ_KEY_4     = 6;
  SEQ_KEY_5     = 7;
  SEQ_KEY_6     = 8;
  SEQ_KEY_7     = 9;
  SEQ_KEY_8     = 10;
  SEQ_KEY_9     = 11;
  SEQ_KEY_SCAN  = 12;
  SEQ_KEY_PWR1_ON   = 13;
  SEQ_KEY_PWR2_ON   = 14;
  SEQ_KEY_PWR3_ON   = 15;
  SEQ_KEY_PWR1_OFF  = 16;
  SEQ_KEY_PWR2_OFF  = 17;
  SEQ_KEY_PWR3_OFF  = 18;

  SEQ_PRE_STOP  = 21;
  SEQ_REPORT    = 22;
  SEQ_1         = 23;
  SEQ_2         = 24;
  SEQ_3         = 25;
  SEQ_4         = 26;
  SEQ_5         = 27;
  SEQ_6         = 28;
  SEQ_7         = 29;
  SEQ_8         = 30;
  SEQ_9         = 31;
  SEQ_MAX       = SEQ_9;

  SEQ_ERR_NONE      = 0;
  SEQ_ERR_RUNNING   = 1;

  DAYA_NONE         = 0;
  DATA_TYPE_HEX     = 1;
  DATA_TYPE_DEC     = 2;
  DATA_TYPE_REAL    = 3;
  DATA_TYPE_STR     = 6;
//  DATA_TYPE_MODE1   = 8;

  REF_IDX_NONE      = 0;
  REF_IDX_MAX       = 1;
  REF_IDX_MIN       = 2;
  REF_IDX_DIFF      = 3;
  REF_IDX_AVR       = 4;
  REF_IDX_DIFF_P2P2 = 5;
  REF_IDX_AVR_JITER = 6;
  REF_IDX_SLOPE_ROW = 7;
  REF_IDX_SLOPE_COL = 8;
  REF_IDX_JIT_DELTA = 9;
  REF_IDX_RAWCS_OPEN  = 11;
  REF_IDX_RAWCS_OPEN2 = 12;
//  REF_IDX_CV5A_OPEN   = 15;
  REF_IDX_GET_CAL     = 20; // frame AIEA Average¡ÍiiAC ¨Ï©ª¢®i¡Ë?e AU¡Íi¡Ë? ¢®¨¡e¢®ieEA ¨Ïoo¡§¢®U¡Ë?¡Ë¢ç AuAa.
  REF_IDX_DOWN_FW     = 30;
  REF_IDX_ID_UPDATE   = 31;
//  REF_IDX_Y3_FLASH_WR = 32;
  REF_IDX_RTY_MODIFY  = 300;

  LIMIT_TYPE_NG           = 0;
  LIMIT_TYPE_IS           = 1;
  LIMIT_TYPE_ISNOT        = 2;
  LIMIT_TYPE_MIN          = 3;
  LIMIT_TYPE_MAX          = 4;
  LIMIT_TYPE_MAXMIN       = 5;
  LIMIT_TYPE_MAXMIN_FLOAT = 6;
  LIMIT_TYPE_MAX_SUB_MIN  = 7;
  LIMIT_TYPE_STR          = 8;
  LIMIT_TYPE_LOG          = 9;
  LIMIT_TYPE_FWVER        = 10;
  // for PG To Comm.
  // Pascal Script SIG ID.
  PP_SIGID_1        = 1;    // Power
  PP_SIGID_2        = 2;    // Pattern Display
  PP_SIGID_3        = 3;

  // Pascal Script Command - 4th param.
  PP_COMMAD_PWR_OFF = 0;
  PP_COMMAD_PWR_ON  = 1;
  PP_COMMAD_PWR_ON_AUTOCODE  = 2;

  PP_COMMAD_MES_OFF = 0;
  PP_COMMAD_MES_ON  = 1;
  PP_COMMAD_PAT_GRP = 0;
  PP_COMMAD_PAT_SNG = 1;

  end_func          = '}_end_func';

  ERR_ST_NONE       = 0;
  ERR_ST_SEME       = 1;
implementation

end.
