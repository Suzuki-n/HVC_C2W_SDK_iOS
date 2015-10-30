//
//  HVCWebAPIManager.h
//  
//
//  Copyright (C) 2014-2015 OMRON Corporation
//

#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import "Reachability.h"

#define kHVCWebAPIManager_ApiKey @"APIキー"    // 取得したAPIキーに置き換える
#define kHVCWebAPIManager_AppId @"0"
#define kHVCWebAPIManager_DeviceId ([[[UIDevice currentDevice] identifierForVendor] UUIDString])
#define kHVCWebAPIManager_OSType @"0"

#define kHVCWebAPIManager_Protocol @"https"

#define kHVCWebAPIManager_Host @"developer.hvc.omron.com"

#define kHVCWebAPIManager_MakeAPIURL(str) [NSString stringWithFormat:@"%@://%@/c2w/api/v1/%@", kHVCWebAPIManager_Protocol, kHVCWebAPIManager_Host, str]

#define kHVCWebAPIManager_API_signup kHVCWebAPIManager_MakeAPIURL(@"signup.php")
#define kHVCWebAPIManager_API_login kHVCWebAPIManager_MakeAPIURL(@"login.php")
#define kHVCWebAPIManager_API_snsLogin kHVCWebAPIManager_MakeAPIURL(@"snsLogin.php")
#define kHVCWebAPIManager_API_logout kHVCWebAPIManager_MakeAPIURL(@"logout.php")
#define kHVCWebAPIManager_API_updateNotificationId kHVCWebAPIManager_MakeAPIURL(@"updateNotificationId.php")

#define kHVCWebAPIManager_API_getCameraList kHVCWebAPIManager_MakeAPIURL(@"getCameraList.php")
#define kHVCWebAPIManager_API_renameCamera kHVCWebAPIManager_MakeAPIURL(@"renameCamera.php")
#define kHVCWebAPIManager_API_removeCamera kHVCWebAPIManager_MakeAPIURL(@"removeCamera.php")

#define kHVCWebAPIManager_API_getNotification kHVCWebAPIManager_MakeAPIURL(@"getNotification.php")
#define kHVCWebAPIManager_API_setNotification kHVCWebAPIManager_MakeAPIURL(@"setNotification.php")

#define kHVCWebAPIManager_API_shareCamera kHVCWebAPIManager_MakeAPIURL(@"shareCamera.php")
#define kHVCWebAPIManager_API_getSharedUserList kHVCWebAPIManager_MakeAPIURL(@"getSharedUserList.php")
#define kHVCWebAPIManager_API_removeShare kHVCWebAPIManager_MakeAPIURL(@"removeShare.php")

#define kHVCWebAPIManager_API_forgetPassword kHVCWebAPIManager_MakeAPIURL(@"forgetPassword.php")
#define kHVCWebAPIManager_API_changePassword kHVCWebAPIManager_MakeAPIURL(@"changePassword.php")


// エラーコード定義
enum eHVCWebAPIManagerError
{
    eHVCWebAPIManagerError_NoError,
    eHVCWebAPIManagerError_AlreadyProcessing,
    eHVCWebAPIManagerError_AccessTokenError,
    eHVCWebAPIManagerError_ArgumentError,

    eHVCWebAPIManagerError_HTTPResponse_200,
    eHVCWebAPIManagerError_HTTPResponse_400,
    eHVCWebAPIManagerError_HTTPResponse_401,
    eHVCWebAPIManagerError_HTTPResponse_404,
    eHVCWebAPIManagerError_HTTPResponse_500,
    
    eHVCWebAPIManagerError_HVCResultCode_W2C00000,
    eHVCWebAPIManagerError_HVCResultCode_W2C00001,
    eHVCWebAPIManagerError_HVCResultCode_W2C00002,
    eHVCWebAPIManagerError_HVCResultCode_W2C00003,
    eHVCWebAPIManagerError_HVCResultCode_W2C00011,
    eHVCWebAPIManagerError_HVCResultCode_W2C00012,
    eHVCWebAPIManagerError_HVCResultCode_W2C00013,
    eHVCWebAPIManagerError_HVCResultCode_W2C00014,
    eHVCWebAPIManagerError_HVCResultCode_W2C00015,
    eHVCWebAPIManagerError_HVCResultCode_W2C00101,
    eHVCWebAPIManagerError_HVCResultCode_W2C00401,
    eHVCWebAPIManagerError_HVCResultCode_W2C99999,

    eHVCWebAPIManagerError_OtherError,
};

enum eHVCWebAPIManager_SNSType
{
    eHVCWebAPIManager_SNSType_Facebook = 1,
    eHVCWebAPIManager_SNSType_Twitter,
    eHVCWebAPIManager_SNSType_GooglePlus,
    eHVCWebAPIManager_SNSType_Other = 99,
};

enum eHVCWebAPIManager_LoginType
{
    eHVCWebAPIManager_LoginType_None,
    eHVCWebAPIManager_LoginType_Facebook,
    eHVCWebAPIManager_LoginType_Twitter,
    eHVCWebAPIManager_LoginType_GooglePlus,
    eHVCWebAPIManager_LoginType_Email,
    eHVCWebAPIManager_LoginType_Other = 99,
};

// カメラ情報用オブジェクト
@interface HVCCameraInfo : NSObject

@property (nonatomic, strong) NSString* cameraId;
@property (nonatomic, strong) NSString* cameraName;
@property (nonatomic, strong) NSString* cameraMacAddr;
@property (nonatomic, strong) NSString* appId;
@property (nonatomic, strong) NSString* ownerType;
@property (nonatomic, strong) NSString* ownerEmail;
-(id)initWithDictionary:(NSDictionary*)dic;
-(NSDictionary*)dictionary;

@end

// 通知設定情報用オブジェクト
@interface HVCNotificationInfo : NSObject

@property (nonatomic, strong) NSNumber* motion;
@property (nonatomic, strong) NSNumber* sound;
@property (nonatomic, strong) NSNumber* timer;
-(id)initWithDictionary:(NSDictionary*)dic;
-(NSDictionary*)dictionary;

@end


@interface HVCWebAPIManager : NSObject

@property (nonatomic, weak, readonly) NSString* accessToken;
@property (nonatomic, weak, readonly) NSString* emailAddress;
@property (nonatomic, weak, readonly) NSString* password;
@property (nonatomic, readonly) enum eHVCWebAPIManager_LoginType loginType;
@property (nonatomic, weak) HVCCameraInfo* selectedCameraInfo;

@property (readonly, nonatomic) Reachability *reachability;
@property (readonly, nonatomic) BOOL isNetworkReachable;
@property (readonly, nonatomic) BOOL isNetworkReachableWithAlert;

// インスタンスの取得（シングルトン）
// ※ インスタンスにnilなどをセットしないでください。
+ (HVCWebAPIManager*)sharedInstance;

// APIアクセス
// アカウント作成
-(void)signupWithEmail:(NSString*)email completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed;
// ログイン(Email)
-(void)loginWithEmail:(NSString*)email password:(NSString*)password completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response, NSString* accessToken))completed;
// ログイン(SNS)
-(void)loginWithSNSInfo:(NSDictionary*)snsInfo completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response, NSString* accessToken))completed;
// ログアウト
-(void)logoutWithCompleted:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed;
//ログイン情報の破棄
- (void)destroyAccountInfo;
// Push通知デバイストークンを更新する
-(void)updateNotificationId:(NSString*)notificationId;

// パスワードのリセット（パスワードの再発行）
-(void)forgetPasswordWithEmail:(NSString*)email completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed;
// パスワードの変更
-(void)changePasswordWithNewPassword:(NSString*)newPassword completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed;

// カメラリストの取得
-(void)getCameraListCompleted:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response, NSArray* cameraInfos))completed;
// カメラ名の編集
-(void)renameCameraWithCameraInfo:(HVCCameraInfo*)cameraInfo completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed;
// カメラの登録解除
-(void)removeCameraWithCameraInfo:(HVCCameraInfo*)cameraInfo completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed;

// 通知設定の取得
-(void)getNotificationCompleted:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response, HVCNotificationInfo* notificationInfo))completed;
// 通知の設定の更新
- (void)notificationSettings:(HVCNotificationInfo*)settings completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed;

// 共有ユーザーの追加
-(void)addShareUserWithEmail:(NSString*)email completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed;
// 共有ユーザーリストの取得
-(void)getSharedUserListCompleted:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response, NSArray* shareUserList))completed;
// 共有ユーザーリストの取得
-(void)removeSharedUserWithEmail:(NSString*)email completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed;

//utils
//ネットワークエラー
- (BOOL)isNetworkReachableWithCallback:(void(^)())callback;

@end
