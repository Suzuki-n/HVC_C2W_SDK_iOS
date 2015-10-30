/*
 * Copyright (C) 2014-2015 OMRON Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  OpeningViewController.m
//  StandardDemo
//

#import "AppDelegate.h"
#import "OpeningViewController.h"
#import "RunningViewController.h"
#import "SettingTableViewController.h"
#import "LoginContentsViewController.h"
#import "HVCWebAPIManager.h"

typedef NS_ENUM(NSInteger,STATUS) {
    STATUS_NON,
    STATUS_DISCONNECTING,
    STATUS_CONNECTING,
    STATUS_CONNECTED,
};

@interface OpeningViewController ()

@property (weak, nonatomic) IBOutlet UIButton           *StartButton;
@property (weak, nonatomic) IBOutlet UIButton           *ConnectButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem    *SettingButton;
@property (strong, nonatomic) IBOutlet UILabel          *label_status;
@property (strong, nonatomic) IBOutlet UILabel          *label_type;
@property (strong, nonatomic) IBOutlet UILabel          *label_version;

@property (nonatomic)        STATUS                      Status;
@property (nonatomic,strong) RunningViewController      *RunningViewController;
@property (nonatomic,strong) SettingTableViewController *SettingView;

@end

@implementation OpeningViewController

@synthesize hHVC;
@synthesize disconnectFlag;

- (void)viewDidLoad {
    // AppDelegateオブジェクトからhHVCの取得
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    hHVC = appDelegate.hHVC;
    
    NSLog( @"Get hHVC= %p", hHVC );
    
    [super viewDidLoad];
    
    _StartButton.enabled = NO;
    _StartButton.layer.borderWidth = 2.0f;
    _StartButton.layer.borderColor = [[UIColor blueColor] CGColor];

    _ConnectButton.layer.borderWidth = 2.0f;
    _ConnectButton.layer.borderColor = [[UIColor blueColor] CGColor];

    disconnectFlag = 0;
    _Status = STATUS_NON;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"viewDidAppear %p", hHVC);
    
    if( disconnectFlag == 1 )
    {
        if( _Status == STATUS_CONNECTED )
        {
            [self disconnectCamera];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _StartButton.enabled = NO;
                [_ConnectButton setTitle:@"Connect" forState:UIControlStateNormal];
            });
            
            _Status = STATUS_NON;
        }
        
        disconnectFlag = 0;
    }
    
    HVCCameraInfo*  info = [HVCWebAPIManager sharedInstance].selectedCameraInfo;
    NSString *cameraId = info.cameraId;
    
    if( (_Status == STATUS_NON) && (cameraId.length > 0) )
    {
        _Status = STATUS_CONNECTING;
        
        [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
            [self connectCamera:cameraId];
        }];
    }
    else if( cameraId.length == 0 )
    {
        //接続を解除する
        if( _Status == STATUS_CONNECTED )
        {
            [self disconnectCamera];
        }
        
        _Status = STATUS_NON;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setStatusLabel:@"Logout"];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)connectCamera:(NSString*)cameraId {
    HVCW_INT32              result;
    HVCW_CONNECTION_TYPE    type;
    HVCW_UINT8              cameraVersion[128];
    HVCW_UINT8              cameraMacAddress[32];
    
    NSLog(@"connectCamera cameraId= %@", cameraId);
    NSLog(@"connectCamera accessToken= %@", [HVCWebAPIManager sharedInstance].accessToken);
    
    if( (_Status != STATUS_CONNECTED) && (cameraId.length > 0) )
    {
        // カメラ接続
        
        [self setStatusLabel:@"Connecting"];
        
        result = HVCW_Connect( hHVC, (HVCW_UINT8*)[cameraId UTF8String], (HVCW_UINT8*)[[HVCWebAPIManager sharedInstance].accessToken UTF8String] );
        NSLog(@"HVCW_Connect result= %d", result);
        
        if( result == HVCW_SUCCESS )
        {
            _Status = STATUS_CONNECTED;
            
            /* 接続種別の取得 */
            result = HVCW_GetConnectionType( hHVC, &type );
            NSLog(@"HVCW_GetConnectionType result= %d type= %d", result, type);
            
            if( result == HVCW_SUCCESS ) {
                
                [self setStatusLabel:@"Connected"];
                
                switch( type )
                {
                    case HVCW_ConnectionType_Disconnect:
                        [self setTypeLabel:@"Dissconnect"];
                        break;
                    case HVCW_ConnectionType_Local:
                        [self setTypeLabel:@"Local"];
                        break;
                    case HVCW_ConnectionType_P2P:
                        [self setTypeLabel:@"P2P"];
                        break;
                    case HVCW_ConnectionType_Relay:
                        [self setTypeLabel:@"Relay"];
                        break;
                }
            }
            else if( result == HVCW_DISCONNECTED )
            {
                _Status = STATUS_NON;
                
                [self setStatusLabel:@"Failed"];
                NSLog(@"ConnectionType Disconnected");
                return NO;
            }
            else
            {
                [self setStatusLabel:@"Failed"];
                NSLog(@"ConnectionType Failed");
            }
            
            /* カメラ・ファームウェアバージョンの取得 */
            result = HVCW_GetCameraVersion( hHVC, cameraVersion );
            NSLog(@"HVCW_GetCameraVersion result= %d cameraVersion= %s", result, cameraVersion);
            
            if( result == HVCW_SUCCESS )
            {
                [self setVersionLabel:[NSString stringWithUTF8String:(char*)cameraVersion]];
            }
            else
            {
                [self setStatusLabel:@"Failed"];
                NSLog(@"GetCameraVersion Failed");
            }
            
            /* カメラ・Macアドレスの取得 */
            result = HVCW_GetCameraMacAddress( hHVC, cameraMacAddress );
            NSLog(@"HVCW_GetCameraMacAddress result= %d cameraMacAddress= %s", result, cameraMacAddress);
            
            if( result == HVCW_SUCCESS )
            {
                //[self setMacAddressLabel:[NSString stringWithUTF8String:(char*)cameraMacAddress]];
            }
            else
            {
                //[self setStatusLabel:@"Failed"];
                NSLog(@"GetCameraMacAddress Failed");
            }
        }
        else
        {
            _Status = STATUS_NON;
            
            [self setStatusLabel:@"Failed"];
            NSLog(@"Connection Failed");
            return NO;
        }
        
        HVCW_UINT8  returnStatus;
        NSString    *rtn_str;
        
        HVCW_INT32  nAppID = 100;
        
        result = HVCW_SetAppID( hHVC, nAppID, &returnStatus );
        
        rtn_str = [NSString stringWithFormat:@"%d %X" , result, returnStatus];
        NSLog( @"HVCW_SetAppID return= %@", rtn_str );
        
        if( (result != 1) || (returnStatus != 0) )
        {
            NSLog( @"失敗" );
        }
        else
        {
            NSLog( @"成功" );
        }
        
        HVCW_BOOL   bOkaoMode = 1;
        
        result = HVCW_SetOkaoMode( hHVC, bOkaoMode, &returnStatus );
        
        rtn_str = [NSString stringWithFormat:@"%d %X" , result, returnStatus];
        NSLog( @"HVCW_SetOkaoMode return= %@", rtn_str );
        
        if( (result != 1) || (returnStatus != 0) )
        {
            NSLog( @"失敗" );
        }
        else
        {
            NSLog( @"成功" );
        }
    }
    else
    {
        return NO;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _StartButton.enabled = YES;
        [_ConnectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    });
    
    return YES;
}

- (BOOL)disconnectCamera {
    HVCW_INT32  result;
    
    // カメラ切断
    
    [self setStatusLabel:@"Disconnecting"];
    
    result = HVCW_Disconnect( hHVC );
    NSLog(@"HVCW_Disconnect result= %d", result);
    
    if( result != HVCW_SUCCESS )
    {
        NSLog(@"Disconnection Failed");
        return NO;
    }
    else
    {
        _Status = STATUS_NON;
        
        [self setStatusLabel:@"Disconnected"];
        [self setTypeLabel:@""];
        [self setVersionLabel:@""];
        //[self setMacAddressLabel:@""];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _StartButton.enabled = NO;
        [_ConnectButton setTitle:@"Connect" forState:UIControlStateNormal];
    });
    
    return YES;
}

#pragma mark - button action

- (IBAction)PushConnectButton:(id)sender {
    HVCCameraInfo*  info;
    NSString*       cameraId;
    
    switch( _Status )
    {
        case STATUS_NON:
            info = [HVCWebAPIManager sharedInstance].selectedCameraInfo;
            cameraId = info.cameraId;
            
            if( cameraId.length > 0 )
            {
                _Status = STATUS_CONNECTING;
                
                [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                    [self connectCamera:cameraId];
                }];
            }
            else
            {
                [self setStatusLabel:@"Logout"];
            }
            break;
            
        case STATUS_CONNECTED:
            //接続を解除する
            _Status = STATUS_DISCONNECTING;
            
            {
                [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                    [self disconnectCamera];
                }];
            }
            break;

        default:
            break;
    }
}

- (IBAction)PushStartButton:(id)sender {
    switch( _Status )
    {
        case STATUS_NON:
            break;
            
        case STATUS_CONNECTED :
            //実行画面に移行
            //ストーリーボードから次の画面を呼び出す
            _RunningViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RunningView"];
            _RunningViewController.hHVC = self.hHVC;
            _RunningViewController.openingViewController = self;
            [self.navigationController pushViewController:_RunningViewController animated:YES];
   
            break;
        default:
            break;
    }
}

//設定ボタンの押下
- (IBAction)PushSettingButton:(id)sender {
    _SettingView = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingView"];
    _SettingView.hHVC = self.hHVC;
    [self.navigationController pushViewController:_SettingView animated:YES];
}

- (void)setStatusLabel:(NSString*)value
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _label_status.text = value;
    });
}

- (void)setTypeLabel:(NSString*)value
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _label_type.text = value;
    });
}

- (void)setVersionLabel:(NSString*)value
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _label_version.text = value;
    });
}

- (IBAction)loginBtn:(UIButton *)sender {
    LoginContentsViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginContentsView"];
    vc.openingViewController = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)registrationBtn:(UIButton *)sender {
    HVCW_INT32                  rtn;
    NSString                    *rtn_str;
    HVCW_UINT8                  returnStatus;
    HVCW_INT32                  nUserID;
    HVCW_INT32                  nDataID;
    HVCW_OKAO_RESULT_DETECTION  getFaceResult;
    HVCW_FILEINFO               getFileInfo;
    
    NSLog( @"***** SHORT START 2sec before *****" );
    sleep( 1 );
    NSLog( @"***** SHORT START 1sec before *****" );
    sleep( 1 );
    
    nUserID = 0;
    nDataID = 0;
    
    rtn = HVCW_ALBUM_Register( hHVC, nUserID, nDataID, &getFaceResult, &getFileInfo, &returnStatus );
    
    NSLog( @"Register nX= %d nY= %d nSize= %d nConfidence= %d", getFaceResult.center.nX, getFaceResult.center.nY, getFaceResult.nSize, getFaceResult.nConfidence );
    NSLog( @"File %s %d %X" , getFileInfo.acName, getFileInfo.nSize, getFileInfo.Reserved );
    
    rtn_str = [NSString stringWithFormat:@"%d %X" , rtn, returnStatus];
    NSLog( @"return= %@", rtn_str );
    
    if( (rtn != 1) || (returnStatus != 0) )
    {
        NSLog( @"失敗" );
    }
    else
    {
        NSLog( @"成功" );
    }
    
    rtn = HVCW_ALBUM_Save( hHVC, &returnStatus );
    
    rtn_str = [NSString stringWithFormat:@"%d %X" , rtn, returnStatus];
    NSLog( @"ALBUM Save return= %@", rtn_str );
    
    if( (rtn != 1) || (returnStatus != 0) )
    {
        NSLog( @"失敗" );
    }
    else
    {
        NSLog( @"成功" );
    }
}

@end
