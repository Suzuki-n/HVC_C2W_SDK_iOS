//
//  LoginContentsViewController.m
//
//  Copyright (C) 2014-2015 OMRON Corporation
//

#import "LoginContentsViewController.h"
#import "HVCWebAPIManager.h"
#import "PCMPlayer.h"


#define kUDKey_SSID @"kUDKey_SSID"
#define kUDKey_SSIDPassword @"kUDKey_SSIDPassword"

#define kViewHeight (548)
#define kStr_forgetPassword @"パスワードを忘れた方はこちら"
#define kStr_login @"ログイン"

@interface LoginContentsViewController () <UITextFieldDelegate, UIActionSheetDelegate>
{
    IBOutlet UITextField *mailTxtF;
    IBOutlet UITextField *passwordTxtF;
    IBOutlet UIButton *tabLoginPty;
    IBOutlet UIButton *tabNewLoginPty;
    IBOutlet UIButton *loginPty;
    IBOutlet UITextField *ssidTxtF;
    IBOutlet UITextField *ssidPasswordTxtF;
    __weak IBOutlet UILabel *cameraIdLabel;
    
    NSArray* cameraInfoArray;
}

- (IBAction)tabLoginBtn:(UIButton *)sender;
- (IBAction)tabNewLoginBtn:(UIButton *)sender;
- (IBAction)loginBtn:(UIButton *)sender;
- (IBAction)logoutBtn:(UIButton *)sender;
- (IBAction)cameraConnectBtn:(UIButton *)sender;
- (IBAction)cameraSelectBtn:(UIButton *)sender;

@end

@implementation LoginContentsViewController

@synthesize openingViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 各種レイアウト設定
    mailTxtF.returnKeyType = UIReturnKeyDone;
    mailTxtF.delegate = self;
    
    passwordTxtF.returnKeyType = UIReturnKeyDone;
    passwordTxtF.delegate = self;
    passwordTxtF.secureTextEntry = YES;
    
    ssidTxtF.returnKeyType = UIReturnKeyDone;
    ssidTxtF.delegate = self;
    
    ssidPasswordTxtF.returnKeyType = UIReturnKeyDone;
    ssidPasswordTxtF.delegate = self;
    ssidPasswordTxtF.secureTextEntry = YES;
    
    passwordTxtF.hidden = NO;
    tabLoginPty.selected = YES;
    tabNewLoginPty.selected = NO;
    [loginPty setTitle:@"ログイン" forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated
{
    HVCCameraInfo*  info = [HVCWebAPIManager sharedInstance].selectedCameraInfo;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if( info.cameraId.length == 0 )
        {
            cameraIdLabel.text = @"なし";
        }
        else
        {
            cameraIdLabel.text = info.cameraId;
        }
        
        mailTxtF.text = [HVCWebAPIManager sharedInstance].emailAddress;
        passwordTxtF.text = [HVCWebAPIManager sharedInstance].password;
        
        ssidTxtF.text = [[NSUserDefaults standardUserDefaults] stringForKey:kUDKey_SSID];
        ssidPasswordTxtF.text = [[NSUserDefaults standardUserDefaults] stringForKey:kUDKey_SSIDPassword];
    });
}

+(CGFloat)viewHeight{
    return kViewHeight;
}

// ログイン
-(void)login
{
    [[HVCWebAPIManager sharedInstance] loginWithEmail:mailTxtF.text
                                             password:passwordTxtF.text
                                            completed:^(BOOL isSuccess, enum eHVCWebAPIManagerError response, NSString *accessToken)
    {
        if( isSuccess )
        {
            // ログイン成功、カメラリストの取得
            [self getCameraList];
        }
        else
        {
            // ログイン失敗
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                            message:@"ログインに失敗"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

// カメラリストの取得
-(void)getCameraList
{
    [[HVCWebAPIManager sharedInstance] getCameraListCompleted:^(BOOL isSuccess, enum eHVCWebAPIManagerError response, NSArray *cameraInfos) {
        if( isSuccess )
        {
            // リスト取得成功
            cameraInfoArray = cameraInfos;
            
            if( cameraInfos.count <= 0 )
            {
                openingViewController.disconnectFlag = 0;
                
                // 登録カメラなし
                [HVCWebAPIManager sharedInstance].selectedCameraInfo = nil;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    cameraIdLabel.text = @"なし";
                });
                
                HVCCameraInfo*  info = [HVCWebAPIManager sharedInstance].selectedCameraInfo;
                NSLog(@"登録カメラなし 選択中のカメラID: %@", info.cameraId);
            }
            else if( cameraInfos.count == 1 )
            {
                openingViewController.disconnectFlag = 1;
                
                // 登録カメラが１つ
                [HVCWebAPIManager sharedInstance].selectedCameraInfo = cameraInfos[0];
                
                HVCCameraInfo*  info = [HVCWebAPIManager sharedInstance].selectedCameraInfo;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    cameraIdLabel.text = info.cameraId;
                });
                
                NSLog(@"登録カメラが１つ 選択中のカメラID: %@", info.cameraId);
            }
            else
            {
                openingViewController.disconnectFlag = 1;
                
                // 登録カメラが複数
                UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"カメラの選択"
                                                                         delegate:self
                                                                cancelButtonTitle:nil
                                                           destructiveButtonTitle:nil
                                                                otherButtonTitles:nil];
                for( HVCCameraInfo* cameraInfo in cameraInfos )
                {
//                    [actionSheet addButtonWithTitle:cameraInfo.cameraName];
                    [actionSheet addButtonWithTitle:cameraInfo.cameraId];
                }
                
                [actionSheet addButtonWithTitle:@"キャンセル"];
                [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons - 1];
                [actionSheet showInView:self.view];
                
                HVCCameraInfo*  info = [HVCWebAPIManager sharedInstance].selectedCameraInfo;
                NSLog(@"登録カメラが複数 選択中のカメラID: %@", info.cameraId);
            }
        }
        else
        {
            
        }
    }];
    
    HVCCameraInfo*  info = [HVCWebAPIManager sharedInstance].selectedCameraInfo;
    NSLog(@"カメラリストの取得出口 選択中のカメラID: %@", info.cameraId);
}

// 新規登録
-(void)signup
{
    [[HVCWebAPIManager sharedInstance] signupWithEmail:mailTxtF.text completed:^(BOOL isSuccess, enum eHVCWebAPIManagerError response) {
        NSString* title = nil;
        NSString* message = nil;
        
        NSLog( @"isSuccess= %d response= %d", isSuccess, response );
        
        if( isSuccess )
        {
            title = @"成功";
            message = @"アカウントを作成しました。メールで送られてくるパスワードでログインしてください。";
            
            passwordTxtF.hidden = NO;
            tabLoginPty.selected = YES;
            tabNewLoginPty.selected = NO;
            [loginPty setTitle:@"ログイン" forState:UIControlStateNormal];
        }
        else
        {
            title = @"エラー";
            message = @"アカウントの作成に失敗しました。";
        }

        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }];
}


#pragma mark - UIButton

- (IBAction)tabLoginBtn:(UIButton *)sender {
    passwordTxtF.hidden = NO;
    tabLoginPty.selected = YES;
    tabNewLoginPty.selected = NO;
    [loginPty setTitle:@"ログイン" forState:UIControlStateNormal];
}

- (IBAction)tabNewLoginBtn:(UIButton *)sender {
    passwordTxtF.hidden = YES;
    tabLoginPty.selected = NO;
    tabNewLoginPty.selected = YES;
    [loginPty setTitle:@"新規登録" forState:UIControlStateNormal];
}

- (IBAction)loginBtn:(UIButton *)sender {
    if( tabLoginPty.selected )
    {
        // 通常ログイン
        [self login];
    }
    else if( tabNewLoginPty.selected )
    {
        // 新規登録
        [self signup];
    }
    else
    {
        NSLog(@"不明なタグボタンが選択されている");
    }
}

- (IBAction)logoutBtn:(UIButton *)sender {
    [[HVCWebAPIManager sharedInstance] logoutWithCompleted:^(BOOL isSuccess, enum eHVCWebAPIManagerError response) {
        if( isSuccess )
        {
            // カメラ情報の破棄
            [[HVCWebAPIManager sharedInstance] destroyAccountInfo];
            
            HVCCameraInfo*  info = [HVCWebAPIManager sharedInstance].selectedCameraInfo;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if( info.cameraId.length == 0 )
                {
                    cameraIdLabel.text = @"なし";
                }
                else
                {
                    cameraIdLabel.text = info.cameraId;
                }
            });
            
            NSLog(@"ログアウト成功");
        }
        else
        {
            NSLog(@"ログアウト失敗");
        }
    }];
}

// 音声によるカメラ接続
- (IBAction)cameraConnectBtn:(UIButton *)sender {
    [self createDOVFile];
    
    [self playDOVFile];
    
    // SSID、パスワードバックアップ
    [[NSUserDefaults standardUserDefaults] setObject:ssidTxtF.text forKey:kUDKey_SSID];
    [[NSUserDefaults standardUserDefaults] setObject:ssidPasswordTxtF.text forKey:kUDKey_SSIDPassword];
}

- (IBAction)cameraSelectBtn:(UIButton *)sender {
    // カメラリストの取得
    [self getCameraList];
}

- (void)createDOVFile {
    HVCW_INT32 result;
    NSString *ssid = ssidTxtF.text;
    NSString *password = ssidPasswordTxtF.text;
    NSString *userKey = [HVCWebAPIManager sharedInstance].accessToken;
    NSMutableString *savePath = [NSMutableString string];
    
    NSLog(@"userKey= %@", userKey);
          
    if( ssid == nil || ssid.length == 0 ||
       password == nil || password.length == 0 ||
       userKey == nil || userKey.length == 0)
    {
        NSLog(@"HVCW_GenerateDataSoundFile:パラメータエラー");
        return;
    }
    
    [savePath appendString:NSTemporaryDirectory()];
    [savePath appendString:@"/dov_sound.pcm"];
    
    NSLog( @"HVCW_GenerateDataSoundFile:音声生成の開始" );
    
    result = HVCW_GenerateDataSoundFile( (HVCW_UINT8*)[savePath UTF8String], (HVCW_UINT8*)[ssid UTF8String], (HVCW_UINT8*)[password UTF8String], (HVCW_UINT8*)[userKey UTF8String] );
    
    if( result != 1 )
    {
        NSLog( @"失敗" );
        return;
    }
    else
    {
        NSLog( @"成功" );
    }
}

- (void)playDOVFile {
    NSMutableString *filePath = [NSMutableString string];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    [filePath appendString:NSTemporaryDirectory()];
    [filePath appendString:@"/dov_sound.pcm"];
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] )
    {
        NSLog( @"音声ファイルあり" );
    }
    else
    {
        NSLog( @"音声ファイルが見つからない" );
    }
    
    PCMplayer*  player = [[PCMplayer alloc] init];
    
    if( player )
    {
        [player playPCMFileWithPath:filePath];
    }
    
    [fileManager removeItemAtPath:filePath error:&error];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [mailTxtF resignFirstResponder];
    [passwordTxtF resignFirstResponder];
    [ssidTxtF resignFirstResponder];
    [ssidPasswordTxtF resignFirstResponder];
    return YES;
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != actionSheet.cancelButtonIndex && cameraInfoArray.count > buttonIndex)
    {
        // カメラを選択
        HVCCameraInfo* info = (HVCCameraInfo*)cameraInfoArray[buttonIndex];
        [HVCWebAPIManager sharedInstance].selectedCameraInfo = info;
    }
    
    HVCCameraInfo*  info = [HVCWebAPIManager sharedInstance].selectedCameraInfo;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        cameraIdLabel.text = info.cameraId;
    });
    
    NSLog(@"選択中のカメラID: %@", info.cameraId);
}

@end
