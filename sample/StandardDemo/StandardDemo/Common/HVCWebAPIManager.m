//
//  HVCWebAPIManager.m
//  
//
//  Copyright (C) 2014-2015 OMRON Corporation
//

#import "HVCWebAPIManager.h"
#import <sys/utsname.h>

#define kUDKey_AccessToken @"kUDKey_AccessToken"
#define kUDKey_EmailAddress @"kUDKey_EmailAddress"
#define kUDKey_Password @"kUDKey_Password"
#define kUDKey_LoginType @"kUDKey_LoginType"
#define kUDKey_SelectedCameraInfo @"kUDKey_SelectedCameraInfo"

@implementation HVCCameraInfo

-(id)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    if(self)
    {
        if( dic )
        {
            self.cameraId = dic[@"cameraId"];
            self.cameraName = dic[@"cameraName"];
            self.cameraMacAddr = dic[@"cameraMacAddr"];
            self.appId = dic[@"appId"];
            self.ownerType = dic[@"ownerType"];
            self.ownerEmail = dic[@"ownerEmail"];
        }
    }
    
    return self;
}

-(NSDictionary*)dictionary
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    if(_cameraId) dic[@"cameraId"] = _cameraId;
    if(_cameraName) dic[@"cameraName"] = _cameraName;
    if(_cameraMacAddr) dic[@"cameraMacAddr"] = _cameraMacAddr;
    if(_appId) dic[@"appId"] = _appId;
    if(_ownerType) dic[@"ownerType"] = _ownerType;
    if(_ownerEmail) dic[@"ownerEmail"] = _ownerEmail;
    
    return dic;
}

@end

@implementation HVCNotificationInfo

-(id)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if(self){
        self.motion = nil;
        self.sound = nil;
        self.timer = nil;
        if(dic){
            if(dic[@"enableMotion"])    self.motion = @([dic[@"enableMotion"] isEqualToString:@"true"]);
            if(dic[@"enableSound"])     self.sound = @([dic[@"enableSound"] isEqualToString:@"true"]);
            if(dic[@"enableTimer"])     self.timer = @([dic[@"enableTimer"] isEqualToString:@"true"]);
        }
    }
    return self;
}

-(NSDictionary*)dictionary
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if(_motion) dic[@"enableMotion"] = _motion;
    if(_sound)  dic[@"enableSound"] = _sound;
    if(_timer)  dic[@"enableTimer"] = _timer;
    return dic;
}

@end

typedef void (^baseCallback)(BOOL isSuccess, enum eHVCWebAPIManagerError response);
typedef void (^baseWithTokenCallback)(BOOL isSuccess, enum eHVCWebAPIManagerError response, NSString* accessToken);
typedef void (^baseWithArrayCallback)(BOOL isSuccess, enum eHVCWebAPIManagerError response, NSArray* cameraInfos);
typedef void (^notificationCallback)(BOOL isSuccess, enum eHVCWebAPIManagerError response, HVCNotificationInfo* notificationInfo);

//@interface HVCWebAPIManager() <UIAlertViewDelegate>
@interface HVCWebAPIManager()
{
    enum eHVCWebAPIManagerError lastError;
    NSString* loginRequestEmail;
    NSString* loginRequestPassword;
    enum eHVCWebAPIManager_LoginType loginRequestLoginType;
}

@property (strong, nonatomic) NSMutableDictionary *responseData;
@property (strong, nonatomic) NSMutableDictionary *callbacks;
@property (strong, nonatomic) Reachability *reachability;
@property (assign, nonatomic) BOOL isAlertShow;

@property (assign, nonatomic) int activeIndicatorCount;

@end

@implementation HVCWebAPIManager

// シングルトン化
// ※ インスタンスにnilをセットしないでください。
static HVCWebAPIManager* sharedInstance;
+(HVCWebAPIManager*)sharedInstance{
    static dispatch_once_t once;
    dispatch_once( &once, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.responseData = [NSMutableDictionary dictionary];
        sharedInstance.callbacks = [NSMutableDictionary dictionary];
        sharedInstance.activeIndicatorCount = 0;
        sharedInstance.reachability = [Reachability reachabilityForInternetConnection];
        [sharedInstance.reachability startNotifier];
    });
    return sharedInstance;
}

+(id)allocWithZone:(NSZone *)zone{
    __block id ret = nil;
    static dispatch_once_t once;
    dispatch_once( &once, ^{
        sharedInstance = [super allocWithZone:zone];
        ret = sharedInstance;
    });
    return  ret;
}

-(id)copyWithZone:(NSZone *)zone{
    return self;
}

// WebApiにリクエストをPOSTする
-(void)webApiRequestWithURL:(NSURL*)url token:(NSString*)token body:(NSString*)body
{
    //インターネット接続チェック
    if (self.reachability.currentReachabilityStatus == NotReachable) {
        NSString *key = url.absoluteString.lastPathComponent;
        [self.callbacks removeObjectForKey:key];
        [self.responseData removeObjectForKey:key];
        
        //ローディングしてるかもしれんので、消す
        #if 0
        
        [[HVCLoadingView shared] hide];
        
        AlertView *alert = [AlertView alertViewWithMessage:kLSTR(@"通信環境がありません。通信が可能な環境で再度お試しください")];
        [alert addButtonWithTitle:kLSTR(@"OK") callback:nil];
        [alert show];
        
        #else
        
        NSLog( @"通信環境がありません。通信が可能な環境で再度お試しください" );
        
        #endif
        
        return;
    }
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    request.HTTPMethod = @"POST";
    if(token){
        // アクセストークンをセット
        [request addValue:token forHTTPHeaderField:@"Authorization"];
    }
    
    if(body){
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    request.timeoutInterval = 30.0f;
    
//    NSURLConnection* requestConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSURLConnection* requestConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:FALSE];
    if(requestConnection){
        // リクエストに成功
        [requestConnection start];
        if (self.activeIndicatorCount == 0) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
        }
        self.activeIndicatorCount++;
    }else{
        // 失敗？
        [self cleanupNetworkActivityIndicatorVisible];
    }
}

// エラー文字列をenum定義に変換する
-(enum eHVCWebAPIManagerError)errorCodeWithString:(NSString*)str
{
    enum eHVCWebAPIManagerError res = eHVCWebAPIManagerError_OtherError;
    
    if(str){
        // HTTP
        if([str isEqualToString:@"200"]){
            res = eHVCWebAPIManagerError_HTTPResponse_200;
        }else if([str isEqualToString:@"400"]){
            res = eHVCWebAPIManagerError_HTTPResponse_400;
        }else if([str isEqualToString:@"401"]){
            res = eHVCWebAPIManagerError_HTTPResponse_401;
        }else if([str isEqualToString:@"404"]){
            res = eHVCWebAPIManagerError_HTTPResponse_404;
        }else if([str isEqualToString:@"500"]){
            res = eHVCWebAPIManagerError_HTTPResponse_500;
        }
        
        // HVC
        else if([str isEqualToString:@"W2C00000"]){
            res = eHVCWebAPIManagerError_HVCResultCode_W2C00000;
        }else if([str isEqualToString:@"W2C00001"]){
            res = eHVCWebAPIManagerError_HVCResultCode_W2C00001;
        }else if([str isEqualToString:@"W2C00002"]){
            res = eHVCWebAPIManagerError_HVCResultCode_W2C00002;
        }else if([str isEqualToString:@"W2C00003"]){
            res = eHVCWebAPIManagerError_HVCResultCode_W2C00003;
        }else if([str isEqualToString:@"W2C00011"]){
            res = eHVCWebAPIManagerError_HVCResultCode_W2C00011;
        }else if([str isEqualToString:@"W2C00012"]){
            res = eHVCWebAPIManagerError_HVCResultCode_W2C00012;
        }else if([str isEqualToString:@"W2C00013"]){
            res = eHVCWebAPIManagerError_HVCResultCode_W2C00013;
        }else if([str isEqualToString:@"W2C00014"]){
            res = eHVCWebAPIManagerError_HVCResultCode_W2C00014;
        }else if([str isEqualToString:@"W2C00015"]){
            res = eHVCWebAPIManagerError_HVCResultCode_W2C00015;
        }else if([str isEqualToString:@"W2C00101"]){
            res = eHVCWebAPIManagerError_HVCResultCode_W2C00101;
        }else if([str isEqualToString:@"W2C00104"]){
            res = eHVCWebAPIManagerError_HVCResultCode_W2C00401;
        }else if([str isEqualToString:@"W2C99999"]){
            res = eHVCWebAPIManagerError_HVCResultCode_W2C99999;
        }else{
            res = eHVCWebAPIManagerError_OtherError;
        }
    }
    
    return res;
}

#pragma mark Setter/Getter
// アクセストークン
-(NSString*)accessToken
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUDKey_AccessToken];
}

// Emailアドレス
-(NSString*)emailAddress
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUDKey_EmailAddress];
}

// パスワード
-(NSString*)password
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUDKey_Password];
}

// ログインタイプ
-(enum eHVCWebAPIManager_LoginType)loginType
{
    return (enum eHVCWebAPIManager_LoginType)[[NSUserDefaults standardUserDefaults] integerForKey:kUDKey_LoginType];
}

// 選択中のカメラ情報
-(void)setSelectedCameraInfo:(HVCCameraInfo *)selectedCameraInfo
{
    if( selectedCameraInfo )
    {
        // 格納する
        [[NSUserDefaults standardUserDefaults] setObject:[selectedCameraInfo dictionary] forKey:kUDKey_SelectedCameraInfo];
        
        // DBにも設定する
        //[DBManager shearedInstance].currentCameraIdStr = selectedCameraInfo.cameraId;
    }
    else
    {
        // 選択を解除
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUDKey_SelectedCameraInfo];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(HVCCameraInfo*)selectedCameraInfo
{
    HVCCameraInfo* info = nil;
    
    NSDictionary*   dic = [[NSUserDefaults standardUserDefaults] objectForKey:kUDKey_SelectedCameraInfo];
    
    if( dic )
    {
        info = [[HVCCameraInfo alloc] initWithDictionary:dic];
    }
    
    return info;
}

#pragma mark - API Access
// アカウント作成
-(void)signupWithEmail:(NSString*)email completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed
{
    if([self.callbacks objectForKey:kHVCWebAPIManager_API_signup.lastPathComponent])
    {
        // コマンド送信中のため、処理しない
        completed(NO, eHVCWebAPIManagerError_AlreadyProcessing);
        return;
    }
    
    [self.callbacks setObject:completed forKey:kHVCWebAPIManager_API_signup.lastPathComponent];

    //リクエスト用のパラメータを設定
    NSURL *url = [NSURL URLWithString:kHVCWebAPIManager_API_signup];
    NSString *body = [NSString stringWithFormat:@"apiKey=%@&appId=%@&email=%@", kHVCWebAPIManager_ApiKey, kHVCWebAPIManager_AppId, email];
    
    [self webApiRequestWithURL:url token:nil body:body];
}

// ログイン(Email)
-(void)loginWithEmail:(NSString*)email
             password:(NSString*)password
            completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response, NSString* accessToken))completed
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSString* deviceOSVersion = [[UIDevice currentDevice] systemVersion];
    NSString* lang = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];

    
    if( [self.callbacks objectForKey:kHVCWebAPIManager_API_login.lastPathComponent] || [self.callbacks objectForKey:kHVCWebAPIManager_API_snsLogin.lastPathComponent] )
    {
        // コマンド送信中のため、処理しない
        completed(NO, eHVCWebAPIManagerError_AlreadyProcessing, nil);
        return;
    }
    
    [self.callbacks setObject:completed forKey:kHVCWebAPIManager_API_login.lastPathComponent];
    
    // アクセストークン情報の破棄
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUDKey_AccessToken];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUDKey_EmailAddress];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUDKey_Password];
    
    //リクエスト用のパラメータを設定
#ifdef DEBUG
    NSURL *url = [NSURL URLWithString:kHVCWebAPIManager_API_login];
    NSString *body = [NSString stringWithFormat:@"apiKey=%@&appId=%@&deviceId=%@&osType=%@&email=%@&password=%@&releaseType=1&deviceModel=%@&deviceOSVersion=%@&lang=%@",
                      kHVCWebAPIManager_ApiKey, kHVCWebAPIManager_AppId, kHVCWebAPIManager_DeviceId, kHVCWebAPIManager_OSType, email, password, deviceModel, deviceOSVersion, lang];
    NSLog(@"%@", body);
#else
    NSURL *url = [NSURL URLWithString:kHVCWebAPIManager_API_login];
    NSString *body = [NSString stringWithFormat:@"apiKey=%@&appId=%@&deviceId=%@&osType=%@&email=%@&password=%@&deviceModel=%@&deviceOSVersion=%@&lang=%@",
                      kHVCWebAPIManager_ApiKey, kHVCWebAPIManager_AppId, kHVCWebAPIManager_DeviceId, kHVCWebAPIManager_OSType, email, password, deviceModel, deviceOSVersion, lang];
#endif
    
#if 0
    // Push通知デバイストークンをチェック
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.pushNotificationDeviceToken){
        // Push通知デバイストークンを追記する
        body = [NSString stringWithFormat:@"%@&notificationId=%@", body, appDelegate.pushNotificationDeviceToken];
        NSLog(@"loginWithEmail appDelegate.pushNotificationDeviceToken:%@", appDelegate.pushNotificationDeviceToken);
    }else{
        // デバイストークン未取得
        NSLog(@"loginWithEmail デバイストークン未取得");
    }
#endif
    
    // Emailアドレスバックアップ
    loginRequestEmail = email;
    loginRequestPassword = password;
    loginRequestLoginType = eHVCWebAPIManager_LoginType_Email;
    
    [self webApiRequestWithURL:url token:nil body:body];
}

// ログイン(SNS)
-(void)loginWithSNSInfo:(NSDictionary*)snsInfo completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response, NSString* accessToken))completed
{
    if([self.callbacks objectForKey:kHVCWebAPIManager_API_login.lastPathComponent] || [self.callbacks objectForKey:kHVCWebAPIManager_API_snsLogin.lastPathComponent]){
        // コマンド送信中のため、処理しない
        completed(NO, eHVCWebAPIManagerError_AlreadyProcessing, nil);
        return;
    }
    
    // SNS情報の取得
    enum eHVCWebAPIManager_SNSType snsType = (snsInfo[@"snsType"] ? (enum eHVCWebAPIManager_SNSType)[snsInfo[@"snsType"] intValue] : eHVCWebAPIManager_SNSType_Other);
    NSString* email = snsInfo[@"email"];
    NSString* snsAccessToken = snsInfo[@"snsAccessToken"];
    NSString* snsAccessTokenSecret = snsInfo[@"snsAccessTokenSecret"];
    
    if(!email || !snsAccessToken){
        // パラメータ不足
        completed(NO, eHVCWebAPIManagerError_ArgumentError, nil);
        return;
    }
    if(snsType == eHVCWebAPIManager_SNSType_Twitter && !snsAccessTokenSecret){
        // Twitter時はsnsAccessTokenSecretが必須
        completed(NO, eHVCWebAPIManagerError_ArgumentError, nil);
        return;
    }

    [self.callbacks setObject:completed forKey:kHVCWebAPIManager_API_snsLogin.lastPathComponent];
    
    // 各種端末情報の取得
    NSString* language = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];

    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSString* deviceOSVersion = [[UIDevice currentDevice] systemVersion];
    
    // アクセストークン情報の破棄
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUDKey_AccessToken];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUDKey_EmailAddress];
    
    //リクエスト用のパラメータを設定
#ifdef DEBUG
    NSURL *url = [NSURL URLWithString:kHVCWebAPIManager_API_snsLogin];
    NSString *body = [NSString stringWithFormat:@"apiKey=%@&appId=%@&deviceId=%@&osType=%@&email=%@&snsType=%@&snsAccessToken=%@&lang=%@&releaseType=1&deviceModel=%@&deviceOSVersion=%@",
                      kHVCWebAPIManager_ApiKey, kHVCWebAPIManager_AppId, kHVCWebAPIManager_DeviceId, kHVCWebAPIManager_OSType, email, @(snsType), snsAccessToken, language, deviceModel, deviceOSVersion];
    NSLog(@"%@", body);
#else
    NSURL *url = [NSURL URLWithString:kHVCWebAPIManager_API_snsLogin];
    NSString *body = [NSString stringWithFormat:@"apiKey=%@&appId=%@&deviceId=%@&osType=%@&email=%@&snsType=%@&snsAccessToken=%@&lang=%@&deviceModel=%@&deviceOSVersion=%@",
                      kHVCWebAPIManager_ApiKey, kHVCWebAPIManager_AppId, kHVCWebAPIManager_DeviceId, kHVCWebAPIManager_OSType, email, @(snsType), snsAccessToken, language, deviceModel, deviceOSVersion];
#endif

    // Push通知デバイストークンをチェック
    if(snsAccessTokenSecret){
        // Push通知デバイストークンを追記する
        body = [NSString stringWithFormat:@"%@&snsAccessTokenSecret=%@", body, snsAccessTokenSecret];
    }
    
    if(deviceModel){
        // 端末のモデル名を追記する
        body = [NSString stringWithFormat:@"%@&deviceModel=%@", body, deviceModel];
    }
    
    if(deviceOSVersion){
        // 端末のOSバージョンを追記する
        body = [NSString stringWithFormat:@"%@&deviceOSVersion=%@", body, deviceOSVersion];
    }
    
    // Emailアドレスバックアップ
    loginRequestEmail = email;
    switch (snsType) {
        case eHVCWebAPIManager_SNSType_Facebook:
            loginRequestLoginType = eHVCWebAPIManager_LoginType_Facebook;
            break;
        case eHVCWebAPIManager_SNSType_Twitter:
            loginRequestLoginType = eHVCWebAPIManager_LoginType_Twitter;
            break;
        case eHVCWebAPIManager_SNSType_GooglePlus:
            loginRequestLoginType = eHVCWebAPIManager_LoginType_GooglePlus;
            break;
            
        default:
            loginRequestLoginType = eHVCWebAPIManager_LoginType_Other;
            break;
    }
    
    [self webApiRequestWithURL:url token:nil body:body];
    
}

// ログアウト
-(void)logoutWithCompleted:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed
{
    if( [self.callbacks objectForKey:kHVCWebAPIManager_API_logout.lastPathComponent] )
    {
        // コマンド送信中のため、処理しない
        completed(NO, eHVCWebAPIManagerError_AlreadyProcessing);
        return;
    }
    
    if( self.accessToken )
    {
        [self.callbacks setObject:completed forKey:kHVCWebAPIManager_API_logout.lastPathComponent];
        
        //リクエスト用のパラメータを設定
        NSURL *url = [NSURL URLWithString:kHVCWebAPIManager_API_logout];
        [self webApiRequestWithURL:url token:self.accessToken body:nil];
    }
}

- (void)destroyAccountInfo
{
    // カメラ情報の破棄
    self.selectedCameraInfo = nil;
    
    // アクセストークン情報の破棄
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUDKey_AccessToken];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:kUDKey_EmailAddress];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// Push通知デバイストークンを更新する
-(void)updateNotificationId:(NSString*)notificationId
{
    // リクエスト用のパラメータを設定
    if(self.accessToken){
        NSURL *url = [NSURL URLWithString:kHVCWebAPIManager_API_updateNotificationId];
        NSString *body = [NSString stringWithFormat:@"notificationId=%@", notificationId];
        
        [self webApiRequestWithURL:url token:self.accessToken body:body];
    }
}

// パスワードのリセット（パスワードの再発行）
-(void)forgetPasswordWithEmail:(NSString*)email completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed
{
    if([self.callbacks objectForKey:kHVCWebAPIManager_API_forgetPassword.lastPathComponent]){
        // コマンド送信中のため、処理しない
        completed(NO, eHVCWebAPIManagerError_AlreadyProcessing);
        return;
    }
    [self.callbacks setObject:completed forKey:kHVCWebAPIManager_API_forgetPassword.lastPathComponent];

    //リクエスト用のパラメータを設定
    NSURL *url = [NSURL URLWithString:kHVCWebAPIManager_API_forgetPassword];
    NSString *body = [NSString stringWithFormat:@"apiKey=%@&email=%@", kHVCWebAPIManager_ApiKey, email];
    
    [self webApiRequestWithURL:url token:nil body:body];

}

// パスワードの変更
-(void)changePasswordWithNewPassword:(NSString*)newPassword completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed
{
    if([self.callbacks objectForKey:kHVCWebAPIManager_API_changePassword.lastPathComponent]){
        // コマンド送信中のため、処理しない
        completed(NO, eHVCWebAPIManagerError_AlreadyProcessing);
        return;
    }
    
    if(self.accessToken){
        [self.callbacks setObject:completed forKey:kHVCWebAPIManager_API_changePassword.lastPathComponent];
        
        //リクエスト用のパラメータを設定
        NSURL *url = [NSURL URLWithString:kHVCWebAPIManager_API_changePassword];
        NSString *body = [NSString stringWithFormat:@"newPassword=%@", newPassword];
        
        [self webApiRequestWithURL:url token:self.accessToken body:body];
    }
    
}

// カメラリストの取得
-(void)getCameraListCompleted:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response, NSArray* cameraInfos))completed
{
    if( [self.callbacks objectForKey:kHVCWebAPIManager_API_getCameraList.lastPathComponent] )
    {
        // コマンド送信中のため、処理しない
        completed(NO, eHVCWebAPIManagerError_AlreadyProcessing, nil);
        return;
    }

    if( self.accessToken )
    {
        [self.callbacks setObject:completed forKey:kHVCWebAPIManager_API_getCameraList.lastPathComponent];

        NSURL *url = [NSURL URLWithString:kHVCWebAPIManager_API_getCameraList];
        [self webApiRequestWithURL:url token:self.accessToken body:nil];
    }
    else
    {
        NSLog(@"アクセストークンが未取得");
        completed(NO, eHVCWebAPIManagerError_AccessTokenError, nil);
    }
}

// カメラ名の編集
-(void)renameCameraWithCameraInfo:(HVCCameraInfo*)cameraInfo completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed
{
    if([self.callbacks objectForKey:kHVCWebAPIManager_API_renameCamera.lastPathComponent]){
        // コマンド送信中のため、処理しない
        completed(NO, eHVCWebAPIManagerError_AlreadyProcessing);
        return;
    }
    
    
    if(self.accessToken){
        [self.callbacks setObject:completed forKey:kHVCWebAPIManager_API_renameCamera.lastPathComponent];
        
        NSURL *url = [NSURL URLWithString:kHVCWebAPIManager_API_renameCamera];
        NSString *body = [NSString stringWithFormat:@"cameraId=%@&newName=%@", cameraInfo.cameraId, cameraInfo.cameraName];
        [self webApiRequestWithURL:url token:self.accessToken body:body];
    }else{
        NSLog(@"アクセストークンが未取得");
        completed(NO, eHVCWebAPIManagerError_AccessTokenError);
    }
    
}

// カメラの登録解除
-(void)removeCameraWithCameraInfo:(HVCCameraInfo*)cameraInfo completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed
{
    if([self.callbacks objectForKey:kHVCWebAPIManager_API_removeCamera.lastPathComponent]){
        // コマンド送信中のため、処理しない
        completed(NO, eHVCWebAPIManagerError_AlreadyProcessing);
        return;
    }
    
    
    if(self.accessToken){
        [self.callbacks setObject:completed forKey:kHVCWebAPIManager_API_removeCamera.lastPathComponent];
        
        NSURL *url = [NSURL URLWithString:kHVCWebAPIManager_API_removeCamera];
        NSString *body = [NSString stringWithFormat:@"cameraId=%@", cameraInfo.cameraId];
        [self webApiRequestWithURL:url token:self.accessToken body:body];
    }else{
        NSLog(@"アクセストークンが未取得");
        completed(NO, eHVCWebAPIManagerError_AccessTokenError);
    }
    
}

// 通知設定の取得
-(void)getNotificationCompleted:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response, HVCNotificationInfo* notificationInfo))completed
{
    if([self.callbacks objectForKey:kHVCWebAPIManager_API_getNotification.lastPathComponent]){
        // コマンド送信中のため、処理しない
        NSLog(@"getNotificationCompletedHundle処理中のためパスする");
        completed(NO, eHVCWebAPIManagerError_AlreadyProcessing, nil);
        return;
    }


    if(self.accessToken){
        [self.callbacks setObject:completed forKey:kHVCWebAPIManager_API_getNotification.lastPathComponent];

        NSURL *url = [NSURL URLWithString:kHVCWebAPIManager_API_getNotification];
        [self webApiRequestWithURL:url token:self.accessToken body:nil];
    }else{
        NSLog(@"アクセストークンが未取得");
        completed(NO, eHVCWebAPIManagerError_AccessTokenError, nil);
    }
    
}

// 通知の設定の更新
- (void)notificationSettings:(HVCNotificationInfo*)settings completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed
{
    if([self.callbacks objectForKey:kHVCWebAPIManager_API_setNotification.lastPathComponent]){
        // コマンド送信中のため、処理しない
        NSLog(@"notificationSettingsCompletedHundle処理中のためパスする");
        completed(NO, eHVCWebAPIManagerError_AlreadyProcessing);
        return;
    }

    if(self.accessToken){
        [self.callbacks setObject:completed forKey:kHVCWebAPIManager_API_setNotification.lastPathComponent];
    }else{
        NSLog(@"アクセストークンが未取得");
        completed(NO, eHVCWebAPIManagerError_AccessTokenError);
    }
}

// 共有ユーザーの追加
-(void)addShareUserWithEmail:(NSString*)email completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed
{
    if([self.callbacks objectForKey:kHVCWebAPIManager_API_shareCamera.lastPathComponent]){
        // コマンド送信中のため、処理しない
        completed(NO, eHVCWebAPIManagerError_AlreadyProcessing);
        return;
    }
    
    
    if(self.accessToken && email && self.selectedCameraInfo.cameraId){
        [self.callbacks setObject:completed forKey:kHVCWebAPIManager_API_shareCamera.lastPathComponent];
        
        NSURL *url = [NSURL URLWithString:kHVCWebAPIManager_API_shareCamera];
        //リクエスト用のパラメータを設定
        NSString *body = [NSString stringWithFormat:@"shareUserEmail=%@&cameraId=%@&isShared=true", email, self.selectedCameraInfo.cameraId];
        [self webApiRequestWithURL:url token:self.accessToken body:body];
    }else{
        NSLog(@"アクセストークンが未取得");
        completed(NO, eHVCWebAPIManagerError_AccessTokenError);
    }
    
}

// 共有ユーザーリストの取得
-(void)getSharedUserListCompleted:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response, NSArray* shareUserList))completed
{
    if([self.callbacks objectForKey:kHVCWebAPIManager_API_getSharedUserList.lastPathComponent]){
        // コマンド送信中のため、処理しない
        completed(NO, eHVCWebAPIManagerError_AlreadyProcessing, nil);
        return;
    }
    
    
    if(self.accessToken){
        [self.callbacks setObject:completed forKey:kHVCWebAPIManager_API_getSharedUserList.lastPathComponent];
        
        NSURL *url = [NSURL URLWithString:kHVCWebAPIManager_API_getSharedUserList];
        //リクエスト用のパラメータを設定
        [self webApiRequestWithURL:url token:self.accessToken body:nil];
    }else{
        NSLog(@"アクセストークンが未取得");
        completed(NO, eHVCWebAPIManagerError_AccessTokenError, nil);
    }
    
}

// 共有ユーザーリストの削除
-(void)removeSharedUserWithEmail:(NSString*)email completed:(void (^)(BOOL isSuccess, enum eHVCWebAPIManagerError response))completed
{
    if([self.callbacks objectForKey:kHVCWebAPIManager_API_removeShare.lastPathComponent]){
        // コマンド送信中のため、処理しない
        completed(NO, eHVCWebAPIManagerError_AlreadyProcessing);
        return;
    }
    
    
    if(self.accessToken){
        [self.callbacks setObject:completed forKey:kHVCWebAPIManager_API_removeShare.lastPathComponent];
        
        NSURL *url = [NSURL URLWithString:kHVCWebAPIManager_API_removeShare];
        //リクエスト用のパラメータを設定
        NSString *body = [NSString stringWithFormat:@"shareUserEmail=%@", email];
        [self webApiRequestWithURL:url token:self.accessToken body:body];
    }else{
        NSLog(@"アクセストークンが未取得");
        completed(NO, eHVCWebAPIManagerError_AccessTokenError);
    }
    
}

#pragma mark - NSURLConnectionDelegate
// リクエストしたレスポンスを取得
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"func:%s, url: %@, size:%@", __func__, connection.originalRequest.URL.absoluteString.lastPathComponent, @(response.expectedContentLength));
    
    // HTTPレスポンスコード判定
    NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
    switch (statusCode) {
        case 200:   NSLog(@"%@ Web API を正常に呼び出した。", @(statusCode));    break;
        case 400:   NSLog(@"%@ 不正なリクエスト(リクエストフォーマットが仕様と異なるなど)がされた。", @(statusCode)); break;
        case 401:   NSLog(@"%@ リクエストは認証を必要とする。認証が失敗した時など。", @(statusCode));   break;
        case 404:   NSLog(@"%@ リクエストした WebAPI の URL が間違っている。", @(statusCode)); break;
        case 500:   NSLog(@"%@ クラウドサーバー側の問題が原因でリクエストに失敗した。", @(statusCode));    break;
        default:    NSLog(@"%@ 未知のコード", @(statusCode)); break;
    }
    lastError = [self errorCodeWithString:@(statusCode).stringValue];
    
    //各メソッドで処理中であれば、コールしないようなっているので、ここでは必ず新規作成
    [self.responseData setObject:[NSMutableData data] forKey:connection.originalRequest.URL.absoluteString.lastPathComponent];
}

// データを受信
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"func:%s", __func__);
    
    NSMutableData *recevie = [self.responseData objectForKey:connection.originalRequest.URL.absoluteString.lastPathComponent];
    [recevie appendData:data];
}

// エラー時に呼び出される
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"func:%s, %d, error:%@", __func__, lastError, error);
    [self cleanupNetworkActivityIndicatorVisible];
    if (error.code == kCFURLErrorCancelled) {
        return;
    }
    
    lastError = (int)error.code;
    NSString *key = connection.originalRequest.URL.absoluteString.lastPathComponent;
    [self.responseData removeObjectForKey:key];
    
    NSArray *def = [self callbackAndTypeWithUrl:key];
    if(def){
        id callback = def[0];
        int callbackType = [def[1] intValue];
        
        if (callback) {
            switch (callbackType) {
                case 1:
                {
                    baseCallback cb = callback;
                    cb(NO, lastError);
                    break;
                }
                case 2:
                {
                    baseWithTokenCallback cb = callback;
                    cb(NO, lastError, nil);
                    break;
                }
                case 3:
                {
                    baseWithArrayCallback cb = callback;
                    cb(NO, lastError, nil);
                    break;
                }
                case 4:
                {
                    notificationCallback cb = callback;
                    cb(NO, lastError, nil);
                    break;
                }
            }
            
            callback = nil;
            [self.callbacks removeObjectForKey:key];
        }
    }
}

// データの受信が完全に終わった際に呼び出される
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"func:%s", __func__);
    
    [self cleanupNetworkActivityIndicatorVisible];
    NSString *key = connection.originalRequest.URL.absoluteString.lastPathComponent;
    NSMutableData *data = [self.responseData objectForKey:key];
    
    if( !data )
    {
        return;
    }
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    [self.responseData removeObjectForKey:key];
    NSLog(@"dic:%@", dic);
    NSArray *def = [self callbackAndTypeWithUrl:key];
    
    if( def )
    {
        id callback = def[0];
        int callbackType = [def[1] intValue];
        
        if( [dic isKindOfClass:[NSDictionary class]] )
        {
            // 成否判定
            lastError = [self errorCodeWithString:dic[@"result"][@"code"]];
            
            if( ![dic[@"result"][@"code"] isEqualToString:@"W2C00000"] )
            {
                //error
                if (callback) {
                    switch (callbackType) {
                        case 1:
                        {
                            baseCallback cb = callback;
                            cb(NO, lastError);
                            break;
                        }
                        case 2:
                        {
                            baseWithTokenCallback cb = callback;
                            cb(NO, lastError, nil);
                            break;
                        }
                        case 3:
                        {
                            baseWithArrayCallback cb = callback;
                            cb(NO, lastError, nil);
                            break;
                        }
                        case 4:
                        {
                            notificationCallback cb = callback;
                            cb(NO, lastError, nil);
                            break;
                        }
                    }
                    
                    callback = nil;
                    [self.callbacks removeObjectForKey:key];
                }
            }
            
            if( callback )
            {
                //Token
                if( callbackType == 2 )
                {
                    baseWithTokenCallback cb = callback;
                    
                    if( dic[@"access"] )
                    {
                        NSString* tempAccessToken = dic[@"access"][@"token"];
                        
                        if( tempAccessToken )
                        {
                            [[NSUserDefaults standardUserDefaults] setObject:tempAccessToken forKey:kUDKey_AccessToken];
                            cb(YES, eHVCWebAPIManagerError_NoError, tempAccessToken);
                        }
                        else
                        {
                            // アクセストークンが取得できない？
                            cb(NO, eHVCWebAPIManagerError_OtherError, nil);
                        }
                        
                        if( loginRequestEmail && loginRequestPassword )
                        {
                            // Emailアドレスバックアップ
                            [[NSUserDefaults standardUserDefaults] setObject:loginRequestEmail forKey:kUDKey_EmailAddress];
                            // パスワードバックアップ
                            [[NSUserDefaults standardUserDefaults] setObject:loginRequestPassword forKey:kUDKey_Password];
                        }
                        
                        // ログインタイプバックアップ
                        [[NSUserDefaults standardUserDefaults] setInteger:loginRequestLoginType forKey:kUDKey_LoginType];
                        [self.callbacks removeObjectForKey:key];
                        callback = nil;
                        loginRequestEmail = nil;
                    }
                }
                
                //配列
                if( callbackType == 3 )
                {
                    baseWithArrayCallback cb = callback;
                    NSMutableArray *responseArray = [NSMutableArray array];
                    
                    if( [kHVCWebAPIManager_API_getCameraList.lastPathComponent isEqualToString:key] && dic[@"cameraList"] )
                    {
                         
                        NSArray* tempCameraList = dic[@"cameraList"];
                        
                        // 取得データをHVCCameraInfoで格納し直す
                        NSMutableArray* newCameraList = [NSMutableArray array];
                        
                        for( NSDictionary* cameraDic in tempCameraList )
                        {
                            HVCCameraInfo* setCameraInfo = [[HVCCameraInfo alloc] initWithDictionary:cameraDic];
                            [newCameraList addObject:setCameraInfo];
                            [responseArray addObject:setCameraInfo];
                        }
                    }
                    else if ([kHVCWebAPIManager_API_getSharedUserList.lastPathComponent isEqualToString:key] && dic[@"sharedUserList"])
                    {
                        NSArray* tempUserList = dic[@"sharedUserList"];
                        
                        for(NSDictionary* userDic in tempUserList)
                        {
                            NSString* email = userDic[@"shareUserEmail"];
                            
                            if( email )
                            {
                                [responseArray addObject:email];
                            }
                        }
                    }
                    
                    cb(YES, eHVCWebAPIManagerError_NoError, responseArray);
                }
                
                if( callbackType == 1 )
                {
                    //baseCallback
                    baseCallback cb = callback;
                    cb((lastError == eHVCWebAPIManagerError_HVCResultCode_W2C00000 ? YES : NO), lastError);
                }
                
                if( callbackType == 4 )
                {
                    notificationCallback cb = callback;
                    HVCNotificationInfo* notInfo = [[HVCNotificationInfo alloc] initWithDictionary:dic[@"notification"]];
                    cb(YES, eHVCWebAPIManagerError_NoError, notInfo);
                }
                
                callback = nil;
                [self.callbacks removeObjectForKey:key];
            }
        }
        else
        {
            if( callback )
            {
                switch( callbackType )
                {
                    case 1:
                    {
                        baseCallback cb = callback;
                        cb(NO, lastError);
                        break;
                    }
                    case 2:
                    {
                        baseWithTokenCallback cb = callback;
                        cb(NO, lastError, nil);
                        break;
                    }
                    case 3:
                    {
                        baseWithArrayCallback cb = callback;
                        cb(NO, lastError, nil);
                        break;
                    }
                    case 4:
                    {
                        notificationCallback cb = callback;
                        cb(NO, lastError, nil);
                        break;
                    }
                }
                
                callback = nil;
                [self.callbacks removeObjectForKey:key];
            }
        }
    }
}


#pragma mark - private getter

- (NSArray *)callbackAndTypeWithUrl:(NSString *)key
{
    id callback;
    int callbackType = 0;
    
    //callbackをURL単位で判別して定義する
    if( [@[kHVCWebAPIManager_API_login.lastPathComponent, kHVCWebAPIManager_API_snsLogin.lastPathComponent] containsObject:key] )
    {
        callback = [self.callbacks objectForKey:key];
        callbackType = 2;
    }
    
    if( [@[kHVCWebAPIManager_API_getCameraList.lastPathComponent, kHVCWebAPIManager_API_getSharedUserList.lastPathComponent] containsObject:key] )
    {
        callback = [self.callbacks objectForKey:key];
        callbackType = 3;
    }
    
    if( [@[kHVCWebAPIManager_API_signup.lastPathComponent, kHVCWebAPIManager_API_forgetPassword.lastPathComponent, kHVCWebAPIManager_API_changePassword.lastPathComponent, kHVCWebAPIManager_API_renameCamera.lastPathComponent, kHVCWebAPIManager_API_renameCamera.lastPathComponent, kHVCWebAPIManager_API_setNotification.lastPathComponent, kHVCWebAPIManager_API_shareCamera.lastPathComponent, kHVCWebAPIManager_API_removeShare.lastPathComponent, kHVCWebAPIManager_API_removeCamera.lastPathComponent, kHVCWebAPIManager_API_logout.lastPathComponent] containsObject:key] )
    {
        //baseCallback
        callback = [self.callbacks objectForKey:key];
        callbackType = 1;
    }
    
    if( [@[kHVCWebAPIManager_API_getNotification.lastPathComponent] containsObject:key] )
    {
        callback = [self.callbacks objectForKey:key];
        callbackType = 4;
    }
    
    return (callback ? @[callback, @(callbackType)] : nil);
}

- (void)cleanupNetworkActivityIndicatorVisible
{
    self.activeIndicatorCount--;
    
    if( self.activeIndicatorCount < 1 )
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        self.activeIndicatorCount = 0;
    }
}


#pragma mark - utils

- (BOOL)isNetworkReachable
{
    return self.reachability.currentReachabilityStatus != NotReachable;
}

- (BOOL)isNetworkReachableWithAlert
{
    return [self isNetworkReachableWithCallback:nil];
}

//utils
//ネットワークエラー
- (BOOL)isNetworkReachableWithCallback:(void(^)())callback
{
    //インターネット接続チェック
    if (self.reachability.currentReachabilityStatus == NotReachable) {
        #if 0
        
        AlertView *alert = [AlertView alertViewWithMessage:kLSTR(@"通信環境がありません。通信が可能な環境で再度お試しください")];
        [alert addButtonWithTitle:kLSTR(@"OK") callback:callback];
        [alert show];
        
        #else
        
        NSLog( @"通信環境がありません。通信が可能な環境で再度お試しください" );
        
        #endif
        return FALSE;
    }
    return TRUE;
}

@end
