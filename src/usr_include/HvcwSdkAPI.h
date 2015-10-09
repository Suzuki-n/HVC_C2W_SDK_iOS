/*-------------------------------------------------------------------*/
/*  Copyright(C) 2015 by OMRON Corporation                           */
/*  All Rights Reserved.                                             */
/*                                                                   */
/*   This source code is the Confidential and Proprietary Property   */
/*   of OMRON Corporation.  Any unauthorized use, reproduction or    */
/*   transfer of this software is strictly prohibited.               */
/*                                                                   */
/*-------------------------------------------------------------------*/

#ifndef __HVCWSDKAPI_H
#define __HVCWSDKAPI_H

#define HVC_API

#ifdef __cplusplus
extern "C" {
#endif

#include "HvcwTypedef.h"

/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                                 DEFINES                                     */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

/* HVC Handle */
#ifndef SDK_DEF_HHVC
#define SDK_DEF_HHVC
    typedef HVCW_VOID*   HHVC;
#endif /* SDK_DEF_HHVC */

/* Roll Angle Definitions. */
#define HVCW_ROLL_ANGLE_0             (0x00001001)     /* Up            0 degree */
#define HVCW_ROLL_ANGLE_1             (0x00002002)     /* Upper Right  30 degree */
#define HVCW_ROLL_ANGLE_2             (0x00004004)     /* Upper Right  60 degree */
#define HVCW_ROLL_ANGLE_3             (0x00008008)     /* Right        90 degree */
#define HVCW_ROLL_ANGLE_4             (0x00010010)     /* Lower Right 120 degree */
#define HVCW_ROLL_ANGLE_5             (0x00020020)     /* Lower Right 150 degree */
#define HVCW_ROLL_ANGLE_6             (0x00040040)     /* Down        180 degree */
#define HVCW_ROLL_ANGLE_7             (0x00080080)     /* Lower Left  210 degree */
#define HVCW_ROLL_ANGLE_8             (0x00100100)     /* Lower Left  240 degree */
#define HVCW_ROLL_ANGLE_9             (0x00200200)     /* Left        270 degree */
#define HVCW_ROLL_ANGLE_10            (0x00400400)     /* Upper Left  300 degree */
#define HVCW_ROLL_ANGLE_11            (0x00800800)     /* Upper Left  330 degree */

#define HVCW_ROLL_ANGLE_UP            (ROLL_ANGLE_0)   /* Up    +/- 15 degree only will be detected */
#define HVCW_ROLL_ANGLE_RIGHT         (ROLL_ANGLE_3)   /* Right +/- 15 degree only will be detected */
#define HVCW_ROLL_ANGLE_DOWN          (ROLL_ANGLE_6)   /* Down  +/- 15 degree only will be detected */
#define HVCW_ROLL_ANGLE_LEFT          (ROLL_ANGLE_9)   /* Left  +/- 15 degree only will be detected */

/* Pose Angle Definitions. */
#define HVCW_POSE_ANGLE_FRONT         (0)              /* Front        */
#define HVCW_POSE_ANGLE_HALF_PROFILE  (1)              /* Half Profile */
#define HVCW_POSE_ANGLE_PROFILE       (2)              /* Profile      */

/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                                 ENUM DEFINES                                */
/*                                                                             */
/*-----------------------------------------------------------------------------*/
/**
 * @enum HVCW_VideoResolution
 * ライブストリーミングビデオ解像度
 */
typedef enum HVCW_VideoResolution {
    HVCW_VideoResolution_High = 0,        /* 1280x720 */
    HVCW_VideoResolution_Middle,          /*  864x480 */
    HVCW_VideoResolution_Low              /*  432x240 */
} HVCW_VIDEO_RESOLUTION;

/**
 * @enum HVCW_NightVisionMode
 * NightVisionモード
 */
typedef enum HVCW_NightVisionMode {
    HVCW_NightVisionMode_Auto = 0,        /* NightVisionの有効・無効を周囲の明るさによって自動制御するモード */
    HVCW_NightVisionMode_Manual           /* NightVisionの有効・無効を手動設定するモード                     */
} HVCW_NIGHT_VISION_MODE;

/**
 * @enum HVCW_NightVisionStatus
 * NightVisionステータス
 */
typedef enum HVCW_NightVisionStatus {
    HVCW_NightVisionStatus_Off = 0,       /* NightVision無効 */
    HVCW_NightVisionStatus_On             /* NightVision有効 */
} HVCW_NIGHT_VISION_STATUS;

/**
 * @enum HVCW_Event
 * イベント
 */
typedef enum HVCW_Event{
    HVCW_Event_ConnectionNum   = 0,       /* カメラへの接続数が変更された場合に通知する。               */
    HVCW_Event_StreamingNum,              /* カメラのライブストリーミング数が変更された場合に通知する。 */
    HVCW_Event_NightVisionMode = 6,       /* NightVisionモードが変更された場合に通知する。              */
    HVCW_Event_NightVisionStatus,         /* NightVisionステータスが変更された場合に通知する。          */
    HVCW_Event_SpeakerVolume   = 9,       /* カメラのスピーカーボリュームが変更された場合に通知する。   */
    HVCW_Event_Disconnected    = 13,      /* カメラとの接続が切断した場合に通知する。                   */
    HVCW_Event_Reconnected,               /* 切断されたカメラとの接続が回復した場合に通知する。         */
    HVCW_Event_StorageStatus   = 18       /* カメラのストレージステータスが変更された場合に通知する。   */
}HVCW_EVENT;

/**
 * @enum HVCW_StorageStatus
 * ストレージステータス
 */
typedef enum HVCW_StorageStatus{
    HVCW_StorageStatus_NotInsert = 0,     /* ストレージ未検出                                                                           */
    HVCW_StorageStatus_NotReady,          /* ストレージ検出済みだが使用不可状態（マウント処理中、ストレージ確認中など）                 */
    HVCW_StorageStatus_NeedFormat,        /* ストレージはフォーマットが必要な状態で使用不可能。ユーザーにフォーマットを促す必要がある。 */
    HVCW_StorageStatus_Normal,            /* ストレージ使用可能                                                                         */
    HVCW_StorageStatus_Error,             /* ストレージにエラーが発生し使用不可能状態                                                   */
    HVCW_StorageStatus_Formatting = 6,    /* ストレージフォーマット中                                                                   */
    HVCW_StorageStatus_NotSupport         /* サポート対象外ストレージ                                                                   */
} HVCW_STORAGE_STATUS;

/**
 * @enum HVCW_StorageFormatResultCode
 * ストレージフォーマット結果
 */
typedef enum HVCW_StorageFormatResultCode {
    HVCW_StorageFormatResultCode_Success = 0,        /* フォーマット成功                     */
    HVCW_StorageFormatResultCode_RemovedStorage,     /* フォーマット中にストレージが抜かれた */
    HVCW_StorageFormatResultCode_NotSupportStorage,  /* サポートしていないストレージ         */
    HVCW_StorageFormatResultCode_Timeout,            /* フォーマット中にタイムアウトが発生   */
    HVCW_StorageFormatResultCode_AlreadyRunning,     /* 既にフォーマットを実行中             */
    HVCW_StorageFormatResultCode_CheckDisk,          /* チェックディスク実行中               */
    HVCW_StorageFormatResultCode_FatalError          /* 上記以外のエラー                     */
} HVCW_STORAGE_FORMAT_RESULT_CODE;

/**
 * @enum HVCW_ConnectionType
 * 接続種別
 */
typedef enum HVCW_ConnectionType {
    HVCW_ConnectionType_Disconnect = 0,   /* 未接続    */
    HVCW_ConnectionType_P2P,              /* P2P接続   */
    HVCW_ConnectionType_Relay,            /* Relay接続 */
    HVCW_ConnectionType_Local             /* Local接続 */
} HVCW_CONNECTION_TYPE;

/**
 * @enum HVCW_LiveEvent
 * ライブイベント
 */
typedef enum HVCW_LiveEvent{
    HVCW_LiveEvent_Started = 0,           /* ライブストリーミング開始後、ビデオのデコードを開始したタイミングで通知する。                                                     */
    HVCW_LiveEvent_Stopped,               /* ライブストリーミング停止時に通知する。                                                                                           */
    HVCW_LiveEvent_Disconnected,          /* カメラとの接続が切断された場合に通知する。C2W_StopLive()を使用してライブストリーミングを停止する必要がある。                     */
    HVCW_LiveEvent_Error,                 /* ライブストリーミング継続不能なエラーが発生した場合に通知する。C2W_StopLive()を使用してライブストリーミングを停止する必要がある。 */
    HVCW_LiveEvent_FPS,                   /* FPS情報を通知する。                                                                                                              */
    HVCW_LiveEvent_ChangeResolution       /* ライブストリーミングの解像度が変更された場合に通知する。                                                                         */
}HVCW_LIVE_EVENT;

/* スケジューラタイプ */
typedef enum HVCW_ScheduleType{
    HVCW_ScheduleType_OneTime = 0,        /* 0=onetime（一回実行）  */
    HVCW_ScheduleType_Repeat,             /* 1=Repeat（一期間実行） */
    HVCW_ScheduleType_Max
} HVCW_SCHEDULER_TYPE;

/* イベントタイプ */
typedef enum HVCW_EventProgramType{
    HVCW_EventProgramType_Sound = 0,      /* 0=sound */
    HVCW_EventProgramType_Motion,         /* 1=motion */
    HVCW_EventProgramType_Timer,          /* 2=timer */
    HVCW_EventProgramType_Max
} HVCW_EVENT_PROGRAM_TYPE;

typedef enum HVCW_ImageSize {
    HVCW_ImageSize_FullHD = 0,            /* 0=画像サイズFullHD(1920x1080) */
    HVCW_ImageSize_HD,                    /* 1=画像サイズHD(1280x720)      */
    HVCW_ImageSize_WVGA,                  /* 2=画像サイズWVGA(864x480)     */
    HVCW_ImageSize_WQVGA,                 /* 3=画像サイズWQVGA(432x480)    */
    HVCW_ImageSize_Max
} HVCW_IMAGE_SIZE;

typedef enum HVCW_ScheduleFrequency{
    HVCW_ScheduleFrequency_Once = 0,      /* 0=スケジュール一回実行     */
    HVCW_ScheduleFrequency_Daily,         /* 1=スケジュール毎日実行     */
    HVCW_ScheduleFrequency_Weekday,       /* 2=スケジュール指定曜日実行 */
    HVCW_ScheduleFrequency_Max
} HVCW_SCHEDULE_FREQUENCY;

typedef enum HVCW_SaveResult{
   HVCW_SaveResult_None = 0,              /* 0=保存なし         */
   HVCW_SaveResult_All,                   /* 1=すべて保存       */
   HVCW_SaveResult_Detection,             /* 2=OKAOの結果で保存 */
   HVCW_SaveResult_Max
} HVCW_SAVE_RESULT;

typedef enum HVCW_FRSaveResult{
    HVCW_FRSaveResult_None = 0,           /* 0=保存なし       */
    HVCW_FRSaveResult_All,                /* 1=すべて保存     */
    HVCW_FRSaveResult_Known,              /* 2=本人の場合保存 */
    HVCW_FRSaveResult_Unknown,            /* 3=他人の場合保存 */
    HVCW_FRSaveResult_Max
} HVCW_FR_SAVE_RESULT;

typedef enum HVCW_FileExt {
    HVCW_FileExt_Log               = 2,   /* ログファイル(log)               */
    HVCW_FileExt_MessageText       = 3,   /* メッセージテキストファイル(txt) */
    HVCW_FileExt_Sound             = 4,   /* 音声ファイル(wav)               */
    HVCW_FileExt_JpgImage          = 6,   /* 画像ファイル(jpg)               */
    HVCW_FileExt_YUVImage          = 7,   /* 画像ファイル(yuv)               */
    HVCW_FileExt_ThumbnailJpgImage = 8    /* サムネイル画像ファイル(jpg)     */
} HVCW_FILE_EXT;

typedef enum HVCW_OkaoFunction{
    HVCW_OkaoFunction_Body = 0,           /* 0=人体検出     */
    HVCW_OkaoFunction_Hand,               /* 1=手検出       */
    HVCW_OkaoFunction_Pet,                /* 2=ペット検出   */
    HVCW_OkaoFunction_Face,               /* 3=顔検出       */
    HVCW_OkaoFunction_Direction,          /* 4=顔向き推定   */
    HVCW_OkaoFunction_Age,                /* 5=年齢推定     */
    HVCW_OkaoFunction_Gender,             /* 6=性別推定     */
    HVCW_OkaoFunction_Gaze,               /* 7=視線推定     */
    HVCW_OkaoFunction_Blink,              /* 8=目つむり推定 */
    HVCW_OkaoFunction_Expression,         /* 9=表情推定     */
    HVCW_OkaoFunction_Recognition,        /* 10=顔認証      */
    HVCW_OkaoFunction_Max
} HVCW_OKAO_FUNCTION;

/* 表情 */
typedef enum HVCW_Expression {
    HVCW_Expression_Ignore = -1,          /* -1=無視        */
    HVCW_Expression_Neutral = 0,          /* 0=表情：無表情 */
    HVCW_Expression_Happiness,            /* 1=表情：喜び   */
    HVCW_Expression_Surprise,             /* 2=表情：驚き   */
    HVCW_Expression_Anger,                /* 3=表情：怒り   */
    HVCW_Expression_Sadness,              /* 4=表情：悲しみ */
    HVCW_Expression_Max
} HVCW_EXPRESSION;


/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                              STRUCTURE DEFINES                              */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

/**
 * HVCW ハンドル
 */
#ifndef HVCW_HANDLE
#define HVCW_HANDLE
    typedef HVCW_VOID* HHVC;
#endif /* HVCW_HANDLE */

#ifndef HVCW_C2W_HANDLE
#define HVCW_C2W_HANDLE
    typedef HVCW_VOID* C2W_HANDLE;
#endif /* HVCW_C2W_HANDLE */

/**
 * @struct HVCW_VideoFrame
 * YUV420Pビデオフレーム格納構造体
 */
typedef struct{
    HVCW_BYTE         *buffer[3];              /* 輝度情報、色差情報を格納       */
    HVCW_UINT32        stride[3];              /* 各bufferのストライド情報を格納 */
    HVCW_UINT32        width;                  /* 横幅                           */
    HVCW_UINT32        height;                 /* 縦幅                           */
} HVCW_VIDEOFRAME;

typedef struct {
    HVCW_INT32 nX;                             /* X座標       */
    HVCW_INT32 nY;                             /* Y座標       */
} HVCW_POINT;

/**
 * @struct HVCW_Rect
 * 矩形表現構造体
 */
typedef struct {
    HVCW_INT32  nX;                            /* 起点x座標 */
    HVCW_INT32  nY;                            /* 起点y座標 */
    HVCW_INT32  nWidth;                        /* 横幅      */
    HVCW_INT32  nHeight;                       /* 縦幅      */
} HVCW_RECT;

/**
 * @struct HVCW_Rect
 * 動体検知パラメータ構造体
 */
typedef struct {
    HVCW_RECT   rect;                          /* 矩形 */
    HVCW_UINT8  sensitivity;                   /* 感度 */
} HVCW_DETECTIONPARAM;

typedef struct {
    HVCW_INT32 nYear;                          /* 年(4ケタ) */
    HVCW_INT32 nMonth;                         /* 月        */
    HVCW_INT32 nDay;                           /* 日        */
    HVCW_INT32 nHour;                          /* 時        */
    HVCW_INT32 nMinute;                        /* 分        */
} HVCW_SCHEDULE_TIME;

typedef struct {
    HVCW_INT32 nIndex;                           /* Onetimeのインデックス（Onetimeの場合のみ）*/
    HVCW_SCHEDULE_FREQUENCY frequency;           /* スケジュールのサイクル                    */
    HVCW_BOOL bWeekday[7];                       /* frequencyが"Weekday"の場合、設定が有効    */
    HVCW_SCHEDULE_TIME startTime;                /* 開始時間                                  */
    HVCW_SCHEDULE_TIME endTime;                  /* 終了時間                                  */
    HVCW_INT32 nInterval;                        /* 処理のインターバル                        */
    HVCW_BOOL abFunction[HVCW_OkaoFunction_Max]; /* OKAOの使用機能フラグ                      */
    HVCW_SAVE_RESULT saveLog;                    /* ログの保存方法                            */
    HVCW_SAVE_RESULT saveImage;                  /* 画像の保存方法                            */
} HVCW_SCHEDULE_INFO;

typedef struct {
    HVCW_INT32  nBody;                         /* 人体検出のしきい値   */
    HVCW_INT32  nHand;                         /* 手検出のしきい値     */
    HVCW_INT32  nPet;                          /* ペット検出のしきい値 */
    HVCW_INT32  nFace;                         /* 顔検出のしきい値     */
    HVCW_INT32  nRecognition;                  /* 認証のしきい値       */
} HVCW_OKAO_THRESHOLD;

typedef struct {
    HVCW_INT32  nMin;                          /* 最小値 */
    HVCW_INT32  nMax;                          /* 最大値 */
} HVCW_RANGE;

typedef struct {
    HVCW_RANGE  body;                          /* 人体検出の検出サイズ   */
    HVCW_RANGE  hand;                          /* 手検出の検出サイズ     */
    HVCW_RANGE  pet;                           /* ペット検出の検出サイズ */
    HVCW_RANGE  face;                          /* 顔検出の検出サイズ     */
} HVCW_OKAO_SIZE_RANGE;

typedef struct {
    HVCW_UINT32  nPose;                        /* 顔の方向 */
    HVCW_UINT32  nAngle;                       /* 顔角度   */
} HVCW_OKAO_DETECTION_ANGLE_FACE;

typedef struct {
    HVCW_UINT32  nBody;                        /* 人体検出の検出角度   */
    HVCW_UINT32  nHand;                        /* 手検出の検出角度     */
    HVCW_UINT32  nPet;                         /* ペット検出の検出角度 */
    HVCW_OKAO_DETECTION_ANGLE_FACE face;       /* 顔検出の検出角度     */
} HVCW_OKAO_DETECTION_ANGLE;

typedef struct {
    HVCW_INT32  nLR;                           /* 左右角度   */
    HVCW_INT32  nUD;                           /* 上下角度   */
    HVCW_INT32  nRoll;                         /* ロール角度 */
} HVCW_OKAO_RESULT_DIRECTION;

typedef struct {
    HVCW_INT32  nAge;                          /* 年齢   */
    HVCW_INT32  nConfidence;                   /* 信頼度 */
} HVCW_OKAO_RESULT_AEG;

typedef struct {
    HVCW_INT32  nGender;                       /* 性別   */
    HVCW_INT32  nConfidence;                   /* 信頼度 */
} HVCW_OKAO_RESULT_GENDER;

typedef struct {
    HVCW_INT32  nLR;                           /* 左右     */
    HVCW_INT32  nUD;                           /* 上下角度 */
} HVCW_OKAO_RESULT_GAZE;

typedef struct {
    HVCW_INT32  nLeftEye;                      /* 左目の目つむり度合 */
    HVCW_INT32  nRightEye;                     /* 右目の目つむり度合 */
} HVCW_OKAO_RESULT_BLINK;

typedef struct {
    HVCW_INT32  anScore[HVCW_Expression_Max];  /* 表情ごとのスコア          */
    HVCW_INT32  nDegree;                       /* ネガティブ/ポジティブ度合 */
} HVCW_OKAO_RESULT_EXPRESSION;

typedef struct {
    HVCW_INT32  nUID;                          /* ユーザID */
    HVCW_INT32  nScore;                        /* スコア   */
} HVCW_OKAO_RESULT_RECOGNITION;

typedef struct {
    HVCW_POINT  ptCenter;                      /* 中心点       */
    HVCW_INT32  nSize;                         /* サイズ       */
    HVCW_INT32  nConfidence;                   /* 信頼度       */
    HVCW_INT32  nPetType;                      /* ペットの種類 */
} HVCW_OKAO_RESULT_PET;

typedef struct {
    HVCW_POINT                   center;       /* 中心点           */
    HVCW_INT32                   nSize;        /* サイズ           */
    HVCW_INT32                   nConfidence;  /* 信頼度           */
    HVCW_OKAO_RESULT_DIRECTION   direction;    /* 顔向き推定結果   */
    HVCW_OKAO_RESULT_AEG         age;          /* 年齢推定結果     */
    HVCW_OKAO_RESULT_GENDER      gender;       /* 性別推定結果     */
    HVCW_OKAO_RESULT_GAZE        gaze;         /* 視線推定結果     */
    HVCW_OKAO_RESULT_BLINK       blink;        /* 目つむり推定結果 */
    HVCW_OKAO_RESULT_EXPRESSION  expression;   /* 表情推定結果     */
    HVCW_OKAO_RESULT_RECOGNITION recognition;  /* 顔認証結果       */
} HVCW_OKAO_RESULT_FACE;

typedef struct {
    HVCW_POINT  center;                        /* 中心点 */
    HVCW_INT32  nSize;                         /* サイズ */
    HVCW_INT32  nConfidence;                   /* 信頼度 */
} HVCW_OKAO_RESULT_DETECTION;

typedef struct {
    HVCW_INT32    nCount;                      /* 人体検出数 */
    HVCW_OKAO_RESULT_DETECTION  body[35];      /* 人体の結果 */
} HVCW_OKAO_RESULT_BODYS;

typedef struct {
    HVCW_INT32    nCount;                      /* 手検出数 */
    HVCW_OKAO_RESULT_DETECTION  hand[35];      /* 手の結果 */
} HVCW_OKAO_RESULT_HANDS;

typedef struct {
    HVCW_INT32    nCount;                      /* ペット検出数 */
    HVCW_OKAO_RESULT_PET    pet[10];           /* ペットの結果 */
} HVCW_OKAO_RESULT_PETS;

typedef struct {
    HVCW_INT32    nCount;                      /* 顔検出数 */
    HVCW_OKAO_RESULT_FACE   face[35];          /* 顔の結果 */
} HVCW_OKAO_RESULT_FACES;

typedef struct {
    HVCW_OKAO_RESULT_BODYS  bodys;             /* 人体の結果   */
    HVCW_OKAO_RESULT_HANDS  hands;             /* 手の結果     */
    HVCW_OKAO_RESULT_PETS   pets;              /* ペットの結果 */
    HVCW_OKAO_RESULT_FACES  faces;             /* 顔の結果     */
} HVCW_OKAO_RESULT;

typedef struct {
    HVCW_CHAR   acName[40];                    /* ファイル名称                */
    HVCW_INT32  nSize;                         /* ファイルのサイズ            */
    HVCW_UINT32 Reserved;                      /* Reserved (実際はファイルID) */
} HVCW_FILEINFO;

typedef struct {
    HVCW_RECT area;             /* 動体検知エリア         */
    HVCW_INT32 nSensitivity;    /* 動体検知感度           */
    HVCW_UINT32 unDuration;     /* 動体検知時間           */
    HVCW_UINT32 unRatio;        /* 動体検知時間の割合     */
    HVCW_UINT32 unOffPeriod;    /* イベントのインターバル */
} HVCW_EP_MOTION_EVENT;

typedef struct {
    HVCW_INT32  nSensitivity;   /* 音声検知感度 */
    HVCW_UINT32 unDuration;     /* 音声検知時間 */
    HVCW_UINT32 unRatio;        /* 音声検知時間の割合 */
    HVCW_UINT32 unOffPeriod;    /* イベントのインターバル */
} HVCW_EP_SOUND_EVENT;

typedef struct {
    HVCW_UINT32 unInterval;     /* イベント間隔 */
} HVCW_EP_TIMER_EVENT;

typedef struct {
    HVCW_BOOL bEnable;          /* 人体検出の実行フラグ */
    HVCW_INT32 nCount;          /* 検出数の判定値 */
} HVCW_EP_BODY;

typedef struct {
    HVCW_BOOL bEnable;          /* ペット検出の実行フラグ */
    HVCW_INT32 nCount;          /* 検出数の判定値 */
} HVCW_EP_PET;

typedef struct {
    HVCW_BOOL bEnable;          /* 顔検出の実行フラグ */
    HVCW_INT32 nCount;          /* 検出数の判定値 */
} HVCW_EP_FACE;

typedef struct {
    HVCW_BOOL bEnable;          /* 年齢推定の実行フラグ */
    HVCW_RANGE stAgeRange;      /* 年齢の判定値 */
    HVCW_INT32 nConfidence;     /* 信頼度しきい値 */
} HVCW_EP_AGE;

typedef struct {
    HVCW_BOOL bEnable;          /* 性別推定の実行フラグ */
    HVCW_INT32 nGender;         /* 性別の判定値 */
    HVCW_INT32 nConfidence;     /* 信頼度しきい値 */
} HVCW_EP_GENDER;

typedef struct {
    HVCW_BOOL bEnable;          /* 表情推定の実行フラグ */
    HVCW_EXPRESSION expression; /* 表情の判定 */
    HVCW_INT32 nScore;          /* スコアの判定しきい値 */
    HVCW_RANGE degreeRange;     /* ネガポジの判定値 */
} HVCW_EP_EXPRESSION;

typedef struct {
    HVCW_BOOL bEnable;          /* 顔認証の実行フラグ  */
} HVCW_EP_RECOGNITION;

typedef struct {
    HVCW_BOOL bEnable;          /* プッシュ通知フラグ */
    HVCW_FILEINFO fileInfo;     /* プッシュ通知のメッセージファイル */
} HVCW_EP_PUSH_ALERT;

typedef struct {
    HVCW_BOOL bEnable;          /* 音声出力フラグ */
    HVCW_FILEINFO fileInfo;     /* 音声出力の音声ファイル */
} HVCW_EP_SOUND;

typedef struct {
    HVCW_EP_PUSH_ALERT pushAlert; /* プッシュ通知設定 */
    HVCW_EP_SOUND sound;          /* 音声出力設定 */
} HVCW_EP_NOTIFICATION;

typedef struct {
    HVCW_EP_BODY        body;           /* 人体の判定値 */
    HVCW_EP_PET         pet;            /* ペットの判定値 */
    HVCW_EP_FACE        face;           /* 顔の判定値 */
    HVCW_EP_AGE         age;            /* 年齢の判定値 */
    HVCW_EP_GENDER      gender;         /* 性別の判定値 */
    HVCW_EP_EXPRESSION  expression;     /* 表情の判定値 */
    HVCW_EP_RECOGNITION recognition;    /* 認証の判定値 */
} HVCW_EP_OKAO_PROCESS;

typedef struct {
    HVCW_SAVE_RESULT     saveLog;       /* ログの保存 */
    HVCW_SAVE_RESULT     saveImage;     /* 画像の保存 */
    HVCW_EP_NOTIFICATION notification;  /* 通知設定 */
} HVCW_EP_POST_PROCESS;

typedef struct {
    HVCW_INT32 nUserID;                     /*  */
    HVCW_FILEINFO fileInfo;                 /*  */
} HVCW_EP_KNOWNUSER;

typedef struct {
    HVCW_EP_KNOWNUSER knownUser[20];        /*  */
    HVCW_EP_PUSH_ALERT unknownUser;         /*  */
} HVCW_EP_FR_PUSH_ALERT;

typedef struct {
    HVCW_EP_KNOWNUSER knownUser[20];        /*  */
    HVCW_EP_SOUND unknownUser;              /*  */
} HVCW_EP_FR_SOUND;

typedef struct {
    HVCW_EP_FR_PUSH_ALERT pushAlert;        /*  */
    HVCW_EP_FR_SOUND      sound;            /*  */
} HVCW_EP_FR_NOTIFICATION;

typedef struct {
    HVCW_FR_SAVE_RESULT     saveImage;      /*  */
    HVCW_EP_FR_NOTIFICATION notification;   /*  */
} HVCW_EP_FR_POST_PROCESS;

typedef struct {
    HVCW_INT32 nIndex;                      /* 動体検知イベントのインデックス（動体検知の場合のみ）*/
    HVCW_VOID* eventProgram;                /* イベント設定 */
} HVCW_EVENT_PROGRAM;

typedef struct {
    HVCW_EP_MOTION_EVENT motionEvent;       /* 動体検知イベント設定 */
    HVCW_EP_OKAO_PROCESS okaoProcess;       /* OKAO処理設定 */
    HVCW_EP_POST_PROCESS postProcess;       /* 通知処理設定 */
    HVCW_EP_FR_POST_PROCESS frPostProcess;  /* FR専用通知処理設定 */
} HVCW_EVENT_PROGRAM_MOTION;

typedef struct {
    HVCW_EP_SOUND_EVENT soundEvent;         /* 音声検知イベント設定 */
    HVCW_EP_OKAO_PROCESS okaoProcess;       /* OKAO処理設定 */
    HVCW_EP_POST_PROCESS postProcess;       /* 通知処理設定 */
    HVCW_EP_FR_POST_PROCESS frPostProcess;  /* FR専用通知処理設定 */
} HVCW_EVENT_PROGRAM_SOUND;

typedef struct {
    HVCW_EP_TIMER_EVENT timerEvent;         /* タイマーイベント設定 */
    HVCW_EP_OKAO_PROCESS okaoProcess;       /* OKAO処理設定 */
    HVCW_EP_POST_PROCESS postProcess;       /* 通知処理設定 */
    HVCW_EP_FR_POST_PROCESS frPostProcess;  /* FR専用通知処理設定 */
} HVCW_EVENT_PROGRAM_TIMER;

typedef struct {
    HVCW_UINT32          ucTotalSize;       /* total_size ストレージ総容量（単位:Kバイト）                              */
    HVCW_UINT32          ucUsedSize;        /* used_size 使用済みストレージ容量（単位:Kバイト）                         */
    HVCW_UINT32          ucFreeSize;        /* free_size 空きストレージ容量（単位:Kバイト）                             */
    HVCW_STORAGE_STATUS  storageStatus;     /* storage_status ストレージステータス（ストレージステータス列挙型を参照） */
} HVCW_STORAGEINFO;

/**********************************************************/
/* Callback API                                           */
/**********************************************************/
/* レンダリング要求コールバック関数 */
typedef HVCW_INT32 (*HVCW_RequestRenderingCallback)(HVCW_BOOL bVideo, HVCW_VOID *pUserParam, 
                                                    HVCW_VOID *pRenderInfo, HVCW_UINT32 unInfoLen, HVCW_UINT32 unTimeStamp);

/* ライブイベント通知コールバック関数 */
typedef HVCW_INT32 (*HVCW_LiveEventCallback)(HVCW_INT32 nEventId, HVCW_VOID *pUserParam, HVCW_VOID *pEventInfo);

/* イベント通知コールバック関数 */
typedef HVCW_INT32 (*HVCW_EventCallback)(HVCW_INT32 nEventId, HVCW_VOID *pUserParam, HVCW_VOID *pEventInfo);


/**********************************************************/
/* HVCW SDK API                                           */
/**********************************************************/
/* SDKバージョン取得関数 */
HVC_API HVCW_INT32 HVCW_GetVersion(HVCW_UINT8 *pucMajor, HVCW_UINT8 *pucMinor, HVCW_UINT8 *pucRelease);

/* カメラ接続関数 */
HVC_API HVCW_INT32 HVCW_Connect(HHVC hHVC, HVCW_UINT8 *pucCameraId, HVCW_UINT8 *pucAccessToken);
/* カメラ切断関数 */
HVC_API HVCW_INT32 HVCW_Disconnect(HHVC hHVC);

/* カメラハンドルの設定 */
HVC_API HVCW_INT32 HVCW_SetCameraHandle(HHVC hHVC, C2W_HANDLE hCameraHandle);

/* カメラファームウェアバージョン取得関数 */
HVC_API HVCW_INT32 HVCW_GetCameraVersion(HHVC hHVC, HVCW_UINT8 aucVersion[128]);

/* カメラファームウェアアップデート要求関数 */
HVC_API HVCW_INT32 HVCW_UpdateFirmware(HHVC hHVC);

/* NightVisionモード設定関数 */
HVC_API HVCW_INT32 HVCW_SetNightVisionMode(HHVC hHVC, HVCW_NIGHT_VISION_MODE mode);
/* NightVisionモード取得関数 */
HVC_API HVCW_INT32 HVCW_GetNightVisionMode(HHVC hHVC, HVCW_NIGHT_VISION_MODE *pMode);

/* NightVisionステータス設定関数 */
HVC_API HVCW_INT32 HVCW_SetNightVisionStatus(HHVC hHVC, HVCW_NIGHT_VISION_STATUS status);
/* NightVisionステータス取得関数 */
HVC_API HVCW_INT32 HVCW_GetNightVisionStatus(HHVC hHVC, HVCW_NIGHT_VISION_STATUS *pStatus);

/* イベント受信設定関数 */
HVC_API HVCW_INT32 HVCW_EnableEventMonitor(HHVC hHVC, HVCW_VOID *pUserParam, HVCW_EventCallback callbackFunc);
/* イベント受信解除関数 */
HVC_API HVCW_INT32 HVCW_DisableEventMonitor(HHVC hHVC);

/* スピーカーボリューム設定関数 */
HVC_API HVCW_INT32 HVCW_SetSpeakerVolume(HHVC hHVC, HVCW_UINT32 unVolume);
/* スピーカーボリューム取得関数 */
HVC_API HVCW_INT32 HVCW_GetSpeakerVolume(HHVC hHVC, HVCW_UINT32 *punVolume);

/* マイク感度設定関数 */
HVC_API HVCW_INT32 HVCW_SetMicSensitivity(HHVC hHVC, HVCW_UINT32 unSensitivity);
/* マイク感度取得関数 */
HVC_API HVCW_INT32 HVCW_GetMicSensitivity(HHVC hHVC, HVCW_UINT32 *punSensitivity);

/* カメラWiFi-RSSI値取得関数 */
HVC_API HVCW_INT32 HVCW_GetWiFiRSSI(HHVC hHVC, HVCW_INT32 *plWifiRssi);

/* ネットワーク設定用音声ファイル作成関数 */
HVC_API HVCW_INT32 HVCW_GenerateDataSoundFile(HVCW_UINT8 *pucTargetFile, HVCW_UINT8 *pucSSID, HVCW_UINT8 *pucPassword, HVCW_UINT8 *pusAccessToken);

/* ストレージフォーマット関数 */
HVC_API HVCW_INT32 HVCW_RequestStorageFormat(HHVC hHVC, HVCW_STORAGE_FORMAT_RESULT_CODE *pResultCode);

/* 接続種別取得関数 */
HVC_API HVCW_INT32 HVCW_GetConnectionType(HHVC hHVC, HVCW_CONNECTION_TYPE *pConnType);

/* ライブストリーミング開始関数 */
HVC_API HVCW_INT32 HVCW_StartLive(HHVC hHVC,
                                  HVCW_VOID *pUserParam, 
                                  HVCW_VIDEO_RESOLUTION videoResolution, 
                                  HVCW_RequestRenderingCallback renderingCallback, 
                                  HVCW_LiveEventCallback eventCallback);
/* ライブストリーミング停止関数 */
HVC_API HVCW_INT32 HVCW_StopLive(HHVC hHVC);

/* ビデオフレームデータ解放関数 */
HVC_API HVCW_INT32 HVCW_FreeDecodedVideoBuffer(HHVC hHVC, const HVCW_VOID **pBuffer);

/* 音声データ解放関数 */
HVC_API HVCW_INT32 HVCW_FreeDecodedAudioBuffer(HHVC hHVC, const HVCW_VOID **pBuffer);

/* トークモード開始関数 */
HVC_API HVCW_INT32 HVCW_EnterTalkMode(HHVC hHVC);
/* トークモード終了関数 */
HVC_API HVCW_INT32 HVCW_ExitTalkMode(HHVC hHVC);

/* 音声データ転送関数 */
HVC_API HVCW_INT32 HVCW_TransferSoundData(HHVC hHVC, HVCW_BYTE *pucSoundData, HVCW_UINT32 ulSoundLen);

/* ライブ解像度変更関数 */
HVC_API HVCW_INT32 HVCW_SetVideoResolution(HHVC hHVC, HVCW_VIDEO_RESOLUTION videoResolution);
/* ライブ解像度取得関数 */
HVC_API HVCW_INT32 HVCW_GetVideoResolution(HHVC hHVC, HVCW_VIDEO_RESOLUTION *pVideoResolution);

/* 音声検知開始関数 */
HVC_API HVCW_INT32 HVCW_EnableSoundDetection(HHVC hHVC, HVCW_UINT32 unSensitivity);
/* 音声検知停止関数 */
HVC_API HVCW_INT32 HVCW_DisableSoundDetection(HHVC hHVC);

/* 音声検知設定取得関数 */
HVC_API HVCW_INT32 HVCW_GetSoundDetection(HHVC hHVC, HVCW_BOOL *pbOn, HVCW_UINT32 *punSensitivity);

/* 動体検知開始関数 */
HVC_API HVCW_INT32 HVCW_EnableMotionDetection(HHVC hHVC, HVCW_UINT32 unDetectionParamCount, const HVCW_DETECTIONPARAM aDetectionParams[10]);
/* 動体検知停止関数 */
HVC_API HVCW_INT32 HVCW_DisableMotionDetection(HHVC hHVC);

/* 動体検知設定取得関数 */
HVC_API HVCW_INT32 HVCW_GetMotionDetection(HHVC hHVC,
                                           HVCW_BOOL *pbOn,
                                           HVCW_UINT32 *punDetectionParamCount,
                                           HVCW_DETECTIONPARAM aDetectionParams[10]);

/* カメラMACアドレス取得関数 */
HVC_API HVCW_INT32 HVCW_GetCameraMacAddress(HHVC hHVC, HVCW_UINT8 aucMACAddress[32]);

/* カメラFWアップデート確認関数 */
HVC_API HVCW_INT32 HVCW_CheckNewFirmware(HHVC hHVC, HVCW_UINT8 aucVersion[128]);

/* ストレージ情報取得関数 */
HVC_API HVCW_INT32 HVCW_GetStorageInfo(HHVC hHVC, HVCW_STORAGEINFO *pStorageInfo);


/*--------------------------------------------------------*/
/* HVCW SDK OKAO API                                      */
/*--------------------------------------------------------*/
/* HVCWハンドル作成 */
HVC_API HHVC HVCW_CreateHandle(void);
/* HVCWハンドル削除 */
HVC_API HVCW_INT32 HVCW_DeleteHandle(HHVC hHVC);

/* アプリケーションID設定 */
HVC_API HVCW_INT32 HVCW_SetAppID(HHVC hHVC, HVCW_INT32 nAppID, HVCW_UINT8 *pucReturnStatus);
/* アプリケーションID取得 */
HVC_API HVCW_INT32 HVCW_GetAppID(HHVC hHVC, HVCW_INT32 *pnAppID, HVCW_UINT8 *pucReturnStatus);

/* OKAOモード設定 */
HVC_API HVCW_INT32 HVCW_SetOkaoMode(HHVC hHVC, HVCW_BOOL bOkaoMode, HVCW_UINT8 *pucReturnStatus);
/* OKAOモード取得 */
HVC_API HVCW_INT32 HVCW_GetOkaoMode(HHVC hHVC, HVCW_BOOL *pbOkaoMode, HVCW_UINT8 *pucReturnStatus);

/* ファイル数取得 */
HVC_API HVCW_INT32 HVCW_GetFileCount(HHVC hHVC, HVCW_FILE_EXT fileExt, HVCW_UINT32 *pnFileCount, HVCW_UINT8 *pucReturnStatus);

/* ファイル情報取得 */
HVC_API HVCW_INT32 HVCW_GetFileInfo(HHVC hHVC, HVCW_FILE_EXT fileExt, HVCW_UINT32 nFileIndex, HVCW_FILEINFO *pFileInfo, HVCW_UINT8 *pucReturnStatus);

/* ファイルダウンロード */
HVC_API HVCW_INT32 HVCW_DownloadFile(HHVC hHVC, const HVCW_FILEINFO *pFileInfo, HVCW_UINT8 *pucBuffer, HVCW_UINT8 *pucReturnStatus);
/* ファイルアップロード */
HVC_API HVCW_INT32 HVCW_UploadFile(HHVC hHVC, HVCW_CHAR acFileName[40], HVCW_INT32 nBufferSize, const HVCW_UINT8 *pucBuffer, HVCW_UINT8 *pucReturnStatus);

/* ファイルの削除 */
HVC_API HVCW_INT32 HVCW_DeleteFile(HHVC hHVC, const HVCW_FILEINFO *pFileInfo, HVCW_UINT8 *pucReturnStatus);

/* 保存画像サイズ設定 */
HVC_API HVCW_INT32 HVCW_SetSaveImageSize(HHVC hHVC, HVCW_IMAGE_SIZE imageSize, HVCW_UINT8 *pucReturnStatus);
/* 保存画像サイズ取得 */
HVC_API HVCW_INT32 HVCW_GetSaveImageSize(HHVC hHVC, HVCW_IMAGE_SIZE *pimageSize, HVCW_UINT8 *pucReturnStatus);

/* OKAO実行画像サイズ取得 */
HVC_API HVCW_INT32 HVCW_GetLastOkaoImageSize(HHVC hHVC, HVCW_INT32 *pnImgBufSize, HVCW_UINT8 *pucReturnStatus);

/* OKAO実行画像の取得 */
HVC_API HVCW_INT32 HVCW_GetLastOkaoImage(HHVC hHVC, HVCW_INT32 nImgBufSize, HVCW_UINT8 *pucImage, HVCW_UINT8 *pucReturnStatus);

/* 撮影 */
HVC_API HVCW_INT32 HVCW_TakePicture(HHVC hHVC, HVCW_FILEINFO *pFileInfo, HVCW_UINT8 *pucReturnStatus);

/* しきい値設定 */
HVC_API HVCW_INT32 HVCW_OKAO_SetThreshold(HHVC hHVC, const HVCW_OKAO_THRESHOLD *pThreshold, HVCW_UINT8 *pucReturnStatus);
/* しきい値取得 */
HVC_API HVCW_INT32 HVCW_OKAO_GetThreshold(HHVC hHVC, HVCW_OKAO_THRESHOLD *pThreshold, HVCW_UINT8 *pucReturnStatus);

/* 検出サイズ設定 */
HVC_API HVCW_INT32 HVCW_OKAO_SetSizeRange(HHVC hHVC, const HVCW_OKAO_SIZE_RANGE *pSizeRange, HVCW_UINT8 *pucReturnStatus);
/* 検出サイズ取得 */
HVC_API HVCW_INT32 HVCW_OKAO_GetSizeRange(HHVC hHVC, HVCW_OKAO_SIZE_RANGE *pSizeRange, HVCW_UINT8 *pucReturnStatus);

/* 検出角度の設定 */
HVC_API HVCW_INT32 HVCW_OKAO_SetDetectionAngle(HHVC hHVC, const HVCW_OKAO_DETECTION_ANGLE *pDetectionAngle, HVCW_UINT8 *pucReturnStatus);
/* 検出角度の取得 */
HVC_API HVCW_INT32 HVCW_OKAO_GetDetectionAngle(HHVC hHVC, HVCW_OKAO_DETECTION_ANGLE *pDetectionAngle, HVCW_UINT8 *pucReturnStatus);

/* OKAO実行 */
HVC_API HVCW_INT32 HVCW_OKAO_Execute(HHVC hHVC, HVCW_BOOL abUseFunction[HVCW_OkaoFunction_Max], HVCW_OKAO_RESULT *pResult, HVCW_UINT8 *pucReturnStatus);

/* アルバム登録 */
HVC_API HVCW_INT32 HVCW_ALBUM_Register(HHVC hHVC, HVCW_INT32 nUserID, HVCW_INT32 nDataID, HVCW_OKAO_RESULT_DETECTION *pFaceResult, HVCW_FILEINFO *pFileInfo, HVCW_UINT8 *pucReturnStatus);

/* 登録者名変更 */
HVC_API HVCW_INT32 HVCW_ALBUM_SetUserName(HHVC hHVC, HVCW_INT32 nUserID, const HVCW_CHAR acName[44], HVCW_UINT8 *pucReturnStatus);

/* 登録者名取得 */
HVC_API HVCW_INT32 HVCW_ALBUM_GetUserName(HHVC hHVC, HVCW_INT32 nUserID, HVCW_CHAR acName[44], HVCW_UINT8 *pucReturnStatus);

/* 登録データ削除 */
HVC_API HVCW_INT32 HVCW_ALBUM_DeleteData(HHVC hHVC, HVCW_INT32 nUserID, HVCW_INT32 nDataID, HVCW_UINT8 *pucReturnStatus);

/* すべての登録情報をクリア */
HVC_API HVCW_INT32 HVCW_ALBUM_DeleteAllData(HHVC hHVC, HVCW_UINT8 *pucReturnStatus);

/* 登録状態取得 */
HVC_API HVCW_INT32 HVCW_ALBUM_GetRegistrationStatus (HHVC hHVC, HVCW_INT32 nUserID, HVCW_BOOL abExist[10], HVCW_UINT8 *pucReturnStatus);

/* アルバムサイズ取得 */
HVC_API HVCW_INT32 HVCW_ALBUM_GetSize(HHVC hHVC, HVCW_INT32 *nAlbumSize, HVCW_UINT8 *pucReturnStatus);

/* アルバムのダウンロード */
HVC_API HVCW_INT32 HVCW_ALBUM_Download(HHVC hHVC, HVCW_UINT8 *pucAlbum, HVCW_UINT8 *pucReturnStatus);
/* アルバムのアップロード */
HVC_API HVCW_INT32 HVCW_ALBUM_Upload(HHVC hHVC, HVCW_INT32 nAlbumSize, const HVCW_UINT8 *pucAlbum, HVCW_UINT8 *pucReturnStatus);

/* アルバムのFlash書き込み */
HVC_API HVCW_INT32 HVCW_ALBUM_Save(HHVC hHVC, HVCW_UINT8 *pucReturnStatus);

/* スケジュール設定 */
HVC_API HVCW_INT32 HVCW_SetScheduler(HHVC hHVC, HVCW_SCHEDULER_TYPE schedulerType, HVCW_BOOL bEnable, const HVCW_SCHEDULE_INFO *pSchedule, HVCW_UINT8 *pucReturnStatus);
/* スケジュール取得 */
HVC_API HVCW_INT32 HVCW_GetScheduler(HHVC hHVC, HVCW_SCHEDULER_TYPE schedulerType, HVCW_BOOL *pbEnable, HVCW_SCHEDULE_INFO *pSchedule, HVCW_UINT8 *pucReturnStatus);

/* イベントプログラム設定 */
HVC_API HVCW_INT32 HVCW_SetEventProgram(HHVC hHVC, HVCW_EVENT_PROGRAM_TYPE eventProgramType, HVCW_BOOL bEnable, const HVCW_EVENT_PROGRAM *pEventProgram, HVCW_UINT8 *pucReturnStatus);
/* イベントプログラム取得 */
HVC_API HVCW_INT32 HVCW_GetEventProgram(HHVC hHVC, HVCW_EVENT_PROGRAM_TYPE eventProgramType, HVCW_BOOL *pbEnable, HVCW_EVENT_PROGRAM *pEventProgram, HVCW_UINT8 *pucReturnStatus);


#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif

#endif /* __HVCWSDKAPI_H */
