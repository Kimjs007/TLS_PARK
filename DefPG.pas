unit DefPG;

interface
{$I Common.inc}

uses Windows, Messages,
SysUtils;

//##############################################################################
//##############################################################################
//###                                                                        ###
//###                        COMMON (PG_AF9 + PG_DP860)                      ###
//###                                                                        ###
//##############################################################################
//##############################################################################

const
  //============================================================================
  // 
  //============================================================================

	//-------------------------------------------------------- PG Type
  PG_TYPE_DP860 = 0;
  PG_TYPE_AF9   = 1;

	//-------------------------------------------------------- PG Cyclic Timer
  PG_CMD_WAITACK_DEF         = 200;  //msec //TBD:DP860?

	PG_CONNCHECK_INTERVAL      = 2000; //msec

	PG_PWRMEASURE_INTERVAL_DEF = 2000; //msec //TBD:DP860?
	PG_PWRMEASURE_INTERVAL_MIN = 1000; //msec //TBD:DP860?
	PG_PWRMEASURE_WAITACK_DEF  = 500;  //msec //TBD:DP860?

	//-------------------------------------------------------- PG Command Paratemer
  // General
  PG_CMDID_UNKNOWN  = 0;
  PG_CMDSTR_UNKNOWN = 'UnknownPgCommand';

  // Power On/Off
	CMD_POWER_OFF = 0;
	CMD_POWER_ON  = 1;
  // Display On/Off
  CMD_DISPLAY_OFF = 0;
  CMD_DISPLAY_ON  = 1;

  // Flash-related
  MAX_FLASH_SIZE_BYTE         = 1600*1024*1024; // 1600M //ITOLED (PANEL-dependent)
  MAX_FLASH_GAMMA_SIZE_BYTE   = 1*1024*1024;  // 1M  //ITOLED (PANEL-dependent)
  MAX_FLASH_PUCPARA_SIZE_BYTE = 1*1024*1024;  // 1M  //ITOLED (PANEL-dependent)
  MAX_FLASH_PUCDATA_SIZE_BYTE = 8*1024*1024;  // 8M  //ITOLED (PANEL-dependent)

  //
  FLASH_ERASE_WAITMS_MINIMUM  = 5*1000;  //  5 sec
  FLASH_READ_WAITMS_MINIMUM   = 5*1000;  //  5 sec
  FLASH_WRITE_WAITMS_MINIMUM  = 10*1000; // 10 sec

  FLASH_SIZE_KB_DEF        = 8192; // 8 MB (ITOLED)
  FLASH_READ_KBperSEC_DEF  = 80;   // 80 KB/sec for read (default) //TBD?
  FLASH_WRITE_KBperSEC_DEF =  7;   //  7 KB/sec for erase/write/read/verify (default) //TBD?
  FLASH_ERASE_KBperSEC_DEF =  20;  // 20 KB/sec for erase/write/read/verify (default) //TBD?

  {$IFDEF SIMULATOR_PANEL}
  SIM_TCON_SIZE   = 1024*64;
  SIM_APSREG_SIZE = 1024*64;
  {$ENDIF}

  MAX_FRAME_SIZE          = 1116; // 31 x 18 x 2 = 1116 ==> 여유 버퍼 1200.

  MAX_FRAME_COUNT         = 60; // 2016 10 25 현재 Max 50 Frame. 여유 버퍼 10만 더주자.

  UDP_DEFAULT_PORT        = 6889;

	//-------------------------------------------------------- Power Items
  // Power Setting/Limit
  PWR_VDD1 = 0;  PWR_VCC = PWR_VDD1;
  PWR_VDD2 = 1;  PWR_VIN = PWR_VDD2;
  PWR_VDD3 = 2;
  PWR_VDD4 = 3;
  PWR_VDD5 = 4;
  PWR_MAX = PWR_VDD5;
  // Power Sequence
  PWR_SEQ_MAX = 2;

	//-------------------------------------------------------- //TBD:DP860?
  PG_CMDSTATE_NONE       = 0;
  PG_CMDSTATE_TX_NOACK   = 1;
  PG_CMDSTATE_TX_WAITACK = 2;
  PG_CMDSTATE_RX_ACK     = 3; //TBD:DP860?

  PG_CMDRESULT_NONE = 0;
  PG_CMDRESULT_OK   = 1;
  PG_CMDRESULT_NG   = 2;

	//-------------------------------------------------------- //TBD:DP860?
  MAX_FLASHSIZE_BYTE = 4*1024*1024; // 8M //TBD:ITOLED? (PANEL-dependent)

	//--------------------------------------------------------
  TCON_REG_DEVICE  = $A0; //Temporary values for I2C (for TCON R/W, no need DevAddr)

type

  //------------------------------------------ Temporary (for OC T/T Test)
  TTconRWCnt = record //2023-03-28 jhhwang (for T/T Test)
    TconReadDllCall  : Integer;
    TconWriteDllCall : Integer;
    TconReadTX       : Integer;
    TConWriteTX      : Integer;
    TConOcWriteTX    : Integer;
    //
    ContTConOcWrite  : Integer;
  end;

	//------------------------------------- PG TX/RX Data
  PPgTxRxData = ^TPgTxRxData;
  TPgTxRxData = record
		CmdState  : Integer;
		CmdResult : Integer;
		// TX
    TxCmdId   : Integer;
    TxCmdStr  : string;
    TxDataLen : Integer; //TBD:DP860?
    TxData    : array [0..256*1024] of Byte; //TBD:DP860?
		// RX
    RxCmdId   : Integer; //TBD:DP860?
    RxAckStr  : string;
    RxDataLen : Integer; //TBD:DP860?
    RxData    : array [0..256*1024] of Byte; //TBD:DP860?
    //
    RxPrevStr : string;
	end;

	//------------------------------------- PG Version
  TPgVer = record
    VerAll    : string;    //AF9(MCS%0.3d_API%0.3d) //DP860(HW_1.3_APP_1.0.2_FW_1.02_FPGA_10105(1.6.0)_PWR_1.0)
	  {$IFDEF PG_DP860}
    HW     : string;
    FW     : string;
    SubFW  : string;
    FPGA   : string;
    PWR    : string;
    //
    VerScript : string;    //DP860-only
		{$ENDIF}
	end;

	//------------------------------------- PG ModelInfo
  // DP860: model.config <Link rate> <lane> <H width> <H bporch> <H active> <H fporch> <V width> <V bporch> <V active> <V fporch> <Vsync> <Format> <ALPM set> <vfb_offset>
  // DP860: alpm.config <h_fdp> <h_sdp> <h_pcnt> <vb_n5b> <vb_n7> <vb_n5a> <vb_sleep> <vb_n2> <vb_n3> <vb_n4>
  //                    <m_vid> <n_vid> <misc_0> <misc_1> <xpol> <xdelay>  <h_mg> <NoAux_Sel> <NoAux_active> <NoAux_Sleep>
  //                    <Critical_section> <tps> <v_blank> <chop_enable> <chop_interval> <chop_size>
  TPgModelConf = record  // Resolution - DP860(model.config), AF9
    // Resolution
    H_Active	: Word;
    H_BP      : Word;
    H_SA      : Word; //Width
    H_FP      : Word;
    V_Active  : Word;
    V_BP      : Word;
    V_SA      : Word; //Width
    V_FP      : Word;
    {$IFDEF PG_DP860}
    // Timing
		link_rate     : Longword;
		lane			    : Integer;
		Vsync			    : Integer;
		RGBFormat     : string;
		ALPM_Mode	    : Integer;
		vfb_offset    : Integer;
    // ALPDP
    h_fdp         : Integer;
    h_sdp         : Integer;
    h_pcnt        : Integer;
    vb_n5b        : Integer;
    vb_n7         : Integer;
    vb_n5a        : Integer;
    vb_sleep      : Integer;
    vb_n2         : Integer;
    vb_n3         : Integer;
    vb_n4         : Integer;
    m_vid         : Integer;
    n_vid         : Integer;
    misc_0        : Integer;
    misc_1        : Integer;
    xpol          : Integer;
    xdelay        : Integer;
    h_mg          : Integer;
    NoAux_Sel     : Integer;
    NoAux_Active  : Integer;
    NoAux_Sleep   : Integer;
    //
    critical_section : Integer;
    tps           : Integer;
    v_blank       : Integer;
    chop_enable   : Integer;
    chop_interval : Integer;
    chop_size     : Integer;
    {$ENDIF}
	end;

  {$IFDEF PG_DP860}	//TBD:DP860?
  //obsoleted!!! power.open,<channel>,<VCC_voltage_value>,<VIN_voltage_value>,<VDD3_voltage_value>,<VDD4_voltage_value>,<VDD5_voltage_value>
  //obsoleted!!! power.limit,<VCC_highlimit_value>,<VIN_highlimit_value>,<VCC_lowlimit_value>,<VIN_lowlimit_value>,<IVCC_highlimit_value>,<IVIN_highlimit_value>,<IVCC_lowlimit_value>,<IVIN_lowlimit_value>
  // power.open <channel> <VCC_voltage_value> <VIN_voltage_value> <VDD3_voltage_value> <VDD4_voltage_value> <VDD5_voltage_value>
  //                         <slope_set> <I_VCC_high_limit_value> <I_VIN_high_limit_value>  <VCC_high_limit_value> <VIN_high_limit_value>
  TPgModelPwrData = record
    PWR_SLOPE   : Integer;  // slope_set
    PWR_NAME    : array[0..PWR_MAX] of String;
		//
    PWR_VOL     : array[0..PWR_MAX] of UInt32; //1=1mV  // Voltage Setting - DP860(power.open)
		//
    PWR_VOL_LL  : array[0..PWR_MAX] of UInt32; //1=1mV  // Power Limit - DP860(power.limit)
    PWR_VOL_HL  : array[0..PWR_MAX] of UInt32; //1=1mV
    PWR_CUR_LL  : array[0..PWR_MAX] of UInt32; //1=1mA
    PWR_CUR_HL  : array[0..PWR_MAX] of UInt32; //1=1mA
	end;

  //obsoleted!!! power.sequence,<sequence_value>,<ON_parameter0_value>,<ON_parameter1_value>,<ON_parameter2_value>,<OFF_parameter0_value>,<OFF_parameter1_value>,<OFF_parameter2_value>
  // power.seq <ON_parameter1_value> <ON_parameter2_value> <OFF_parameter1_value> <OFF_parameter2_value>
  TPgModelPwrSeq = record 	// Power Sequence
    //obsoleted!!! SeqType : integer;
    SeqOn   : array[0..PWR_SEQ_MAX] of Integer;
    SeqOff  : array[0..PWR_SEQ_MAX] of Integer;
	end;
  {$ENDIF}

	//------------------------------------- PG Status
	// AF9  : (pgDisconn) -> (Call Start_Connection) -> pgConnect -> (Call Conn_Status:OK) -> (Call SW_Revision) -> pgReady
  // DP860: (pgDisconn) -> Rcv (1st ConnCheckAck or pg.init) -> (pgConnect) -> Send version.all -> (pgGetPgVer) -> Send ModelInfo -> (pgModelDown) -> (pgReady)
  enumPgStatus = (pgDisconn=0,
                  pgConnect=1,     //Rcv (first ConnCheckAck or pg.init)
                  pgGetPgVer=2,    //Sending version.all
                  pgModelDown=3,   //Sending model info
                  pgReady=4,
                  pgWait=5,        //TBD:DP860?
                  pgDone=6,        //TBD:DP860?
                  pgForceStop=7);  //TBD:DP860?

	//------------------------------------- Power Read
  PPwrData = ^TPwrData;
  TPwrData = record //VCC~VDD5:1=1mV, IVCC~iVDD5:1=1mA //#ReadVoltCurr
    // Voltage (mV)
    VCC   : UInt32;
    VIN   : UInt32;
    VDD3  : UInt32; //TBD:DP860?
    VDD4  : UInt32; //TBD:DP860?
    VDD5  : UInt32; //TBD:DP860?
    // Current (mA)
    IVCC  : UInt32;
    IVIN  : UInt32;
    IVDD3 : UInt32; //TBD:DP860?
    IVDD4 : UInt32; //TBD:DP860?
    IVDD5 : UInt32; //TBD:DP860?
  end;

  PRxPwrData = ^TRxPwrData;
  TRxPwrData = record //VCC~VDD5:1=1mV, IVCC~iVDD5:1=1uA //#PReadVoltC,RealVoltC
    // Voltage (mV)
    VCC   : UInt32;
    VIN   : UInt32;
    VDD3  : UInt32; //TBD:DP860?
    VDD4  : UInt32; //TBD:DP860?
    VDD5  : UInt32; //TBD:DP860?
    // Current (uA)
    IVCC  : UInt32; //TBD:DP860?
    IVIN  : UInt32; //TBD:DP860?
    IVDD3 : UInt32; //TBD:DP860?
    IVDD4 : UInt32; //TBD:DP860?
    IVDD5 : UInt32; //TBD:DP860?
  end;

	//------------------------------------- Flash R/W and Data
	// Flash Access/Read Status
  enumPgFlashAccSt  = (flashAccUnknown=0, flashAccDisabled=1, flashAccEnabled=2);
  enumFlashReadType = (flashReadNone=0, flashReadUnit=1, flashReadGamma=2, flashReadAll=2);
  TFlashRead = record 
    FlashAccSt     : enumPgFlashAccSt;
		//
    ReadType       : enumFlashReadType;
    ReadSize       : Integer;
    RxSize         : Integer;
    RxData         : array[0..(DefPG.MAX_FLASH_SIZE_BYTE-1)] of Byte;
    ChecksumRx     : UInt32;
    ChecksumCalc   : UInt32;
    //
    bReadDone      : Boolean;
    SaveFilePath   : string;
    SaveFileName   : string;
  end;
	// Flash R/W and Data (inspector-specific)
  PFlashData = ^TFlashData;
  TFlashData = record    //TBD:ITOLED?
    StartAddr      : Integer;   //TBD:ITOLED?
    Size           : Integer;
    Data           : array[0..(DefPG.MAX_FLASH_SIZE_BYTE-1)] of Byte;
    Checksum       : UInt32;
    //
    bValid         : Boolean;
  //SaveFilePath   : string;
  //SaveFileName   : string;
  end;

	//-------------------------------------------------------- PG XXXXXX

//##############################################################################

//##############################################################################
{$IFDEF PG_DP860} //############################################################
//##############################################################################
//###                                                                        ###
//###                              PG_DP860                                  ###   
//###                                                                        ###
//##############################################################################
//##############################################################################

const
	//-------------------------------------------------------- PG IPADDR/PORT
  // ch#        PC(SW)               PG
  // ---- ------------------  -------------------
  // CH1  169.254.199.10/any  169.254.199.11/8001
  // CH2  169.254.199.10/any  169.254.199.12/8002
  // CH3  169.254.199.10/any  169.254.199.12/8003
  // CH4  169.254.199.10/any  169.254.199.12/8004
{$IFDEF SIMULATOR_PG}
  CommPG_NETWORK_PREFIX = '169.254.200'; //for PG Simulator
{$ELSE}
  CommPG_NETWORK_PREFIX = '169.254.199';
//  CommPG_NETWORK_PREFIX = '169.254.200'; //for PG Simulator
{$ENDIF}
  CommPG_PC_IPADDR      = CommPG_NETWORK_PREFIX+'.10';
  CommPG_PC_PORT_BASE   = 8000;  //TBD?
  CommPG_PC_PORT_STATIC = False; //TBD:DP860?

  CommPG_PG_IPADDR_BASE = 11;
  CommPG_PG_PORT_BASE   = 8001;

	//-------------------------------------------------------- PG Username/Password for file Upload/Download
  DP860_FTP_USERNAME      = 'upload';
  DP860_FTP_PASSWORD      = 'upload';
  DP860_FTP_PATH_UPLOAD   = '/home/upload';
  DP860_FTP_PATH_DOWNLOAD = '/home/upload';

  DP860_ROOT_USERNAME     = 'root';
  DP860_ROOT_PASSWORD     = 'insta';

	//-------------------------------------------------------- PG Commands
//PG_CMDID_UNKNOWN = 0;
	//------------------------------------------ //TBD:DP860?
  PG_CMDID_CONNCHECK            =   1;	PG_CMDSTR_CONNCHECK            = 'pg.status';
  PG_CMDID_PG_INIT              =   2;	PG_CMDSTR_PG_INIT              = 'pg.init';
	//------------------------------------------ Read Version Information
  PG_CMDID_VERSION_ALL          =   3;  PG_CMDSTR_VERSION_ALL          = 'version.all';   //Insta HW+FW (e.g., "ITO_HW_1.3_APP_1.0.2_FW_1.02_FPGA_10105(1.6.0)_PWR_1.0")
//PG_CMDID_VERSION_HW           =   4;	PG_CMDSTR_VERSION_HW           = 'version.hw';    //Insta HW    (e.g., "1.3")
//PG_CMDID_VERSION_FW           =   5;  PG_CMDSTR_VERSION_FW           = 'version.fw';    //Insta FW    (e.g., "APP_1.0.2_FW_1.02")
//PG_CMDID_VERSION_PWR          =   6;  PG_CMDSTR_VERSION_PWR          = 'version.pwr';   //Insta POWER (e.g., "HW_1.0_FW_1.0")
//PG_CMDID_VERSION_FPGA         =   7;  PG_CMDSTR_VERSION_FPGA         = 'version.fpga';  //Insta FPGA  (e.g., "FPGA_10105(1.6.0)")
  PG_CMDID_MODEL_VERSION        =   8;  PG_CMDSTR_MODEL_VERSION        = 'model.version'; //Insta Script(e.g., "ITO_DP860__v0002_20221206")
	//------------------------------------------ Module selection and identity
  PG_CMDID_POWER_OPEN           =  10;  PG_CMDSTR_POWER_OPEN           = 'power.open';
  PG_CMDID_POWER_SEQ            =  11;  PG_CMDSTR_POWER_SEQ            = 'power.seq';
  PG_CMDID_MODEL_CONFIG         =  12;  PG_CMDSTR_MODEL_CONFIG         = 'model.config';
  PG_CMDID_ALPM_CONFIG          =  13;  PG_CMDSTR_ALPM_CONFIG          = 'alpm.config';
	//
  PG_CMDID_SET_MODEL_FILE       =  15;  PG_CMDSTR_SET_MODEL_FILE       = 'model.file';    //TBD:DP860?
  PG_CMDID_GET_MODEL            =  16;  PG_CMDSTR_GET_MODEL            = 'model';         //TBD:DP860?
  PG_CMDID_GET_MODEL_LIST       =  17;  PG_CMDSTR_GET_MODEL_LIST       = 'model.list';    //TBD:DP860?
	//------------------------------------------ Power On/Off
  PG_CMDID_POWER_ON             =  20;  PG_CMDSTR_POWER_ON             = 'power.on';          // PowerOn : interposer.init -> power.on
  PG_CMDID_POWER_OFF            =  21;  PG_CMDSTR_POWER_OFF            = 'power.off';         // PowerOff: power.off -> interposer.deinit
  PG_CMDID_INTERPOSER_ON        =  22;  PG_CMDSTR_INTERPOSER_ON        = 'interposer.init';
  PG_CMDID_INTERPOSER_OFF       =  23;  PG_CMDSTR_INTERPOSER_OFF       = 'interposer.deinit';
  PG_CMDID_DUT_DETECT           =  24;  PG_CMDSTR_DUT_DETECT           = 'dut.detect';
  PG_CMDID_TCON_INFO            =  25;  PG_CMDSTR_TCON_INFO            = 'tcon.info';
  PG_CMDID_POWER_BIST_ON        =  26;  PG_CMDSTR_POWER_BIST_ON        = 'power.bist.on'; // PreOC 및 OC는bist on,off로 전원 제어
  PG_CMDID_POWER_BIST_OFF       =  27;  PG_CMDSTR_POWER_BIST_OFF       = 'power.bist.off'; // PreOC 및 OC는bist on,off로 전원 제어
  PG_CMDID_BIST_RGB             =  28;  PG_CMDSTR_BIST_RGB             = 'bist.rgb'; // PreOC 및 OC RGB 패턴 출력
  PG_CMDID_BIST_RGB_9BIT        =  29;  PG_CMDSTR_BIST_RGB_9BIT        = 'bist.9bit'; // PreOC 및 OC RGB 패턴 출력
	//------------------------------------------ Power measurement
  PG_CMDID_POWER_READ           =  30;  PG_CMDSTR_POWER_READ           = 'power.read';    //voltage+current
  //
  PG_CMDID_POWER_VOLTAGE        =  31;  PG_CMDSTR_POWER_VOLTAGE        = 'power.voltage'; //voltage(specific rail)
  PG_CMDID_POWER_CURRENT        =  32;  PG_CMDSTR_POWER_CURRENT        = 'power.current'; //current(specific rail)
     	PGSIG_POWER_RAIL_VDD1 = 'VCC';  //TBD:DP860?
     	PGSIG_POWER_RAIL_VDD2 = 'VIN';  //TBD:DP860?
     	PGSIG_POWER_RAIL_VDD3 = 'VDD3';
     	PGSIG_POWER_RAIL_VDD4 = 'VDD4';
     	PGSIG_POWER_RAIL_VDD5 = 'VDD5';
	//------------------------------------------ TCON R/W
  PG_CMDID_TCON_READ            =  40;  PG_CMDSTR_TCON_READ            = 'tcon.read';
  PG_CMDID_TCON_WRITE           =  41;  PG_CMDSTR_TCON_WRITE           = 'tcon.write';
  PG_CMDID_TCON_OCWRITE         =  42;  PG_CMDSTR_TCON_OCWRITE         = 'tcon.ocwrite';
	//------------------------------------------ NVM(FLASH) R/W
  PG_CMDID_NVM_INIT             =  50;  PG_CMDSTR_NVM_INIT             = 'nvm.init';        //TBD:DP860?  //SPI Speed and Init 
  PG_CMDID_NVM_ERASE            =  51;  PG_CMDSTR_NVM_ERASE            = 'nvm.erase';       //TBD:DP860?
  PG_CMDID_NVM_READ             =  52;  PG_CMDSTR_NVM_READ             = 'nvm.read';
//PG_CMDID_NVM_WRITE            =  53;  PG_CMDSTR_NVM_WRITE            = 'nvm.write';       //TBD:DP860?
  PG_CMDID_NVM_READFILE         =  54;  PG_CMDSTR_NVM_READFILE         = 'nvm.readfile';
  PG_CMDID_NVM_WRITEFILE        =  55;  PG_CMDSTR_NVM_WRITEFILE        = 'nvm.writefile';
  PG_CMDID_NVM_READASCII        =  56;  PG_CMDSTR_NVM_READASCII        = 'nvm.read_ascii'; 
//PG_CMDID_NVM_WRITEASCII       =  57;  PG_CMDSTR_NVM_WRITEASCII       = 'nvm.write2ascii'; //TBD:DP860?
//PG_CMDID_DYNAMIC_LOAD         =  58;  PG_CMDSTR_DYNAMIC_LOAD         = 'dynamic.load';    //TBD:DP860?
	//------------------------------------------ Pattern Display
  // RGB
  PG_CMDID_IMAGE_RGB            =  70;  PG_CMDSTR_IMAGE_RGB            = 'image.rgb';           //Full Display Color(RGB)
//PG_CMDID_IMAGE_APL            =  71;  PG_CMDSTR_IMAGE_APL            = 'image.apl';           //TBD:DP860?
	// BMP
  PG_CMDID_IMAGE_FILE           =  72;  PG_CMDSTR_IMAGE_FILE           = 'image.file';
//PG_CMDID_IMAGE_APL_FILE       =  73;  PG_CMDSTR_IMAGE_APL_FILE       = 'image.apl_file';      //Dimming? Pwm? //TBD:DP860?
	// Lookup Table(pattern list)
  PG_CMDID_IMAGE_DISPLAY        =  74;  PG_CMDSTR_IMAGE_DISPLAY        = 'image.display';       //pattern#
//PG_CMDID_IMAGE_FIRST          =  75;  PG_CMDSTR_IMAGE_FIRST          = 'image.first';         //pattern#0
//PG_CMDID_IMAGE_NEXT           =  76;  PG_CMDSTR_IMAGE_NEXT           = 'image.next';          //next pattern#
//PG_CMDID_IMAGE_PREV           =  77;  PG_CMDSTR_IMAGE_PREV           = 'image.prev';          //prev pattern#
	// PATTERN TOOL
  PG_CMDID_IMAGE_BOX            =  80;  PG_CMDSTR_IMAGE_BOX            = 'image.box';       //Rectangle(RGB) with (Black|RGB) background
  PG_CMDID_IMAGE_EMPTYBOX       =  81;  PG_CMDSTR_IMAGE_EMPTYBOX       = 'image.emptybox';  //Empty box with Black background
  PG_CMDID_IMAGE_CIRCLE         =  82;  PG_CMDSTR_IMAGE_CIRCLE         = 'image.circle';    //Circle(RGB) with Black background
  PG_CMDID_IMAGE_LINE           =  83;  PG_CMDSTR_IMAGE_LINE           = 'image.line';      //Line(RGB) with Black background
  PG_CMDID_IMAGE_DOT            =  84;  PG_CMDSTR_IMAGE_DOT            = 'image.dot';       //Dot(RGB) with Black background
  PG_CMDID_IMAGE_HGRAY          =  85;  PG_CMDSTR_IMAGE_HGRAY          = 'image.hgray';     //H_Gradation(R|G|B|RG|RB\GB\RGB|W) with Black background
    	PGSIG_GRADATION_DIR_H_INC 	  = 0; //   0(left) ~ 255(right)
    	PGSIG_GRADATION_DIR_H_DEC 	  = 1; // 255(left) ~   0(right)
  PG_CMDID_IMAGE_VGRAY          =  86;  PG_CMDSTR_IMAGE_VGRAY          = 'image.vgray';     //V_Gradation(R|G|B|RG|RB\GB\RGB|W) with Black background
    	PGSIG_GRADATION_DIR_V_INC 	  = 0; //   0(top) ~ 255(bottom)
    	PGSIG_GRADATION_DIR_V_DEC 	  = 1; // 255(top) ~   0(bottom)
  PG_CMDID_IMAGE_CHECKER        =  87;  PG_CMDSTR_IMAGE_CHECKER        = 'image.checker';   //TBD:DP860?
  PG_CMDID_IMAGE_TILE           =  88;  PG_CMDSTR_IMAGE_TILE           = 'image.tile';      //TBD:DP860?
  PG_CMDID_IMAGE_TOOL           =  89;  PG_CMDSTR_IMAGE_TOOL           = 'image.tool';      //multiple boxes/shapes in a single image //TBD:DP860?
	// (Dynamic) FPGA generated pattern with frame rate(Hz) //TBD:DP860?
//PG_CMDID_IMAGE_FLAME_XYTILE   =  90;  PG_CMDSTR_IMAGE_FLAME_XYTILE   = 'image.frame_xytile';  //4 frmae 4x4 pixel repeating tile pattern
//PG_CMDID_IMAGE_FLAME_CHUNKY6F	=  91;  PG_CMDSTR_IMAGE_FLAME_CHUNKY6F = 'image.chunky6f';      //6 frmae 32x48 pixel repeating tile pattern
//PG_CMDID_IMAGE_FLAME_CHUNKY2F =  92;  PG_CMDSTR_IMAGE_FLAME_CHUNKY2F = 'image.chunky2f';      //chunky 2FFR repeating tile pattern with PNGs
//PG_CMDID_IMAGE_FLAME_CHUNKY3F =  93;  PG_CMDSTR_IMAGE_FLAME_CHUNKY3F = 'image.chunky3f';      //
//PG_CMDID_IMAGE_FLAME_CHUNKY4F =  94;  PG_CMDSTR_IMAGE_FLAME_CHUNKY4F = 'image.chunky4f';      //
//PG_CMDID_IMAGE_FLAME_VRR      =  95;  PG_CMDSTR_IMAGE_FLAME_VRR      = 'image.vrr';           //Vaiable refresh rate solid pattern(RGB)
	// Set refresh rate
//PG_CMDID_SET_REFRESHRATE      =  96;  PG_CMDSTR_SET_REFRESHRATE      = 'display.refreshrate';
	// Pulse Control
//PG_CMDID_BSYNC                =  97;  PG_CMDSTR_BSYNC                = 'bsync.out';
//PG_CMDID_BSYNC_DELAYED        =  98;  PG_CMDSTR_BSYNC_DELAYED        = 'bsyncvb.out';
//PG_CMDID_BSYNC_GET_FREQ       =  99;  PG_CMDSTR_BSYNC_GET_FREQ       = 'freq.read';
//PG_CMDID_BSYNC_GET_DUTY       = 100;  PG_CMDSTR_BSYNC_GET_DUTY       = 'duty.read';
   // DBV
  PG_CMDID_ALPDP_DBV            = 101;  PG_CMDSTR_ALPDP_DBV            = 'alpdp.dbv'; //TBD:DP860? TBD:2023-02-02? alpdp.dbv?
  PG_CMDID_BIST_DBV             = 102;  PG_CMDSTR_BIST_DBV             = 'bist.dbv'; //TBD:DP860? TBD:2023-02-02? alpdp.dbv?

	//------------------------------------------ System Commands
  // BMP list
  PG_CMDID_GET_BMP_LIST         = 110;  PG_CMDSTR_GET_BMP_LIST         = 'bmp'; //TBD:DP860?
  // Temperature
  // LED On/Off
  // Delay
//PG_CMDID_WAIT_MS              = 114;  PG_CMDSTR_WAIT_MS              = 'wait'; //TBD:DP860?
//PG_CMDID_DELAY_MS             = 115;  PG_CMDSTR_DELAY_MS             = 'delay.ms'; //TBD:DP860?
//PG_CMDID_DELAY_US             = 116;  PG_CMDSTR_DELAY_US             = 'delay.us'; //TBD:DP860?
  // NOP
//PG_CMDID_NOP                  = 117;  PG_CMDSTR_NOP                  = 'nop'; //TBD:DP860?
  // System
  PG_CMDID_RESET                = 119;  PG_CMDSTR_RESET                = 'reset';
  PG_CMDID_SYSTEM               = 120;  PG_CMDSTR_SYSTEM               = 'system'; //TBD:DP860?
  PG_CMDID_HELP                 = 121;  PG_CMDSTR_HELP                 = 'help'; //TBD:DP860?

	//------------------------------------------ Temporary (for OC T/T Test)
  PG_CMDID_OC_ONOFF             = 130;  PG_CMDSTR_OC_ONOFF             = 'oc.onoff';  //2023-03-30
  PG_CMDID_GPIO_READ            = 131;  PG_CMDSTR_GPIO_READ            = 'gpio.read'; // e.g., "gpio.read HPD" // 2023-03-30 jhhwang (for OC T/T Test)

  PG_PACKET_SIZE  = 1024; //TBD? DP860?

//##############################################################################
{$ENDIF} //PG_DP860 ############################################################
//##############################################################################

implementation

end.


