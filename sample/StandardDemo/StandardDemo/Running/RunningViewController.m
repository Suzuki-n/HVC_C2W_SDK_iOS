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
//  RunningViewController.m
//  StandardDemo
//

#import "RunningViewController.h"
#import "AppSettingInfo.h"

#define PREVIEW_SIZE_WIDTH      1080
#define PREVIEW_SIZE_HEIGHT     1980

@interface RunningViewController ()

@property (weak, nonatomic) IBOutlet UIView  *ResultDispView;
@property (weak, nonatomic) IBOutlet UILabel *FaceDerectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *FaceDerectionLabel2;
@property (weak, nonatomic) IBOutlet UILabel *FaceDerectionLabel3;
@property (weak, nonatomic) IBOutlet UILabel *AgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *GenderLabel;
@property (weak, nonatomic) IBOutlet UILabel *EyeLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *EyeLineLabel2;
@property (weak, nonatomic) IBOutlet UILabel *EyeOpenLabel;
@property (weak, nonatomic) IBOutlet UILabel *EyeOpenLabel2;
@property (weak, nonatomic) IBOutlet UILabel *ExpressionLabel;
@property (weak, nonatomic) IBOutlet UILabel *RecognitionLabel;

@property (nonatomic,assign) CGFloat        BaseScale;
@property (nonatomic,assign) BOOL           ExecFlag;

@end

@implementation RunningViewController

@synthesize hHVC;
@synthesize openingViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the

    _ResultDispView.layer.borderWidth  = 1.0f;
    _ResultDispView.layer.borderColor  = [[UIColor blueColor] CGColor];
    
    _BaseScale = [self GetPreviewScale:_ResultDispView.bounds];
    NSLog(@"BaseScale= %f", _BaseScale);
    
    _FaceDerectionLabel.text  = @"";
    _FaceDerectionLabel2.text = @"";
    _FaceDerectionLabel3.text = @"";
    _AgeLabel.text            = @"";
    _GenderLabel.text         = @"";
    _EyeLineLabel.text        = @"";
    _EyeLineLabel2.text       = @"";
    _EyeOpenLabel.text        = @"";
    _EyeOpenLabel2.text       = @"";
    _ExpressionLabel.text     = @"";
    _RecognitionLabel.text    = @"";
    
    _ExecFlag = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"RunningViewController viewDidAppear");

    if( _ExecFlag != YES )
    {
        _ExecFlag = YES;
        
        //ループ実行
        [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
            [self OKAO_Execute];
        }];
    }
    
    NSLog(@"RunningViewController viewDidAppear Terminal");
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"RunningViewController viewDidDisappear");
    
    [super viewDidDisappear:animated];
    
    _ExecFlag = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//矩形を表示するViewのサイズに合わせた倍率を作成する。
- (CGFloat)GetPreviewScale:(CGRect)inRect {
    CGFloat scale;
    
    if( inRect.size.width < inRect.size.height )
    {
        scale = inRect.size.width / PREVIEW_SIZE_WIDTH;
    }
    else
    {
        scale = inRect.size.height / PREVIEW_SIZE_HEIGHT;
    }
    
    CGFloat width   = PREVIEW_SIZE_WIDTH * scale;
    CGFloat height  = PREVIEW_SIZE_HEIGHT * scale;
    
    if( (width > inRect.size.width) || (height > inRect.size.height) )
    {
        if(inRect.size.width < inRect.size.height)
        {
            scale = inRect.size.height / PREVIEW_SIZE_HEIGHT;
        }
        else
        {
            scale = inRect.size.width / PREVIEW_SIZE_WIDTH;
        }
    }
    
    return scale;
}

#define RESULT_TRACE_ON

- (void)OKAO_Execute
{
    HVCW_INT32          rtn;
    HVCW_UINT8          returnStatus;
    HVCW_UINT8          *pReturnStatus = &returnStatus;
    USE_FUNCTION        func;
    HVCW_OKAO_RESULT    result;
    
    NSLog(@"OKAO_Execute:%d", _ExecFlag);
    
    HVC_FUNCTION    ExecuteFlag = [AppSettingInfo GetExecType];
    
    func.abUseFunction[HVCW_OkaoFunction_Body] = (ExecuteFlag & HVC_ACTIV_BODY_DETECTION) ? 1 : 0;
    func.abUseFunction[HVCW_OkaoFunction_Hand] = (ExecuteFlag & HVC_ACTIV_HAND_DETECTION) ? 1 : 0;
    func.abUseFunction[HVCW_OkaoFunction_Pet] = 0;
    func.abUseFunction[HVCW_OkaoFunction_Face] = (ExecuteFlag & HVC_ACTIV_FACE_DETECTION) ? 1 : 0;
    func.abUseFunction[HVCW_OkaoFunction_Direction] = (ExecuteFlag & HVC_ACTIV_FACE_DIRECTION) ? 1 : 0;
    func.abUseFunction[HVCW_OkaoFunction_Age] = (ExecuteFlag & HVC_ACTIV_AGE_ESTIMATION) ? 1 : 0;
    func.abUseFunction[HVCW_OkaoFunction_Gender] = (ExecuteFlag & HVC_ACTIV_GENDER_ESTIMATION) ? 1 : 0;
    func.abUseFunction[HVCW_OkaoFunction_Gaze] = (ExecuteFlag & HVC_ACTIV_GAZE_ESTIMATION) ? 1 : 0;
    func.abUseFunction[HVCW_OkaoFunction_Blink] = (ExecuteFlag & HVC_ACTIV_BLINK_ESTIMATION) ? 1 : 0;
    func.abUseFunction[HVCW_OkaoFunction_Expression] = (ExecuteFlag & HVC_ACTIV_EXPRESSION_ESTIMATION) ? 1 : 0;
    func.abUseFunction[HVCW_OkaoFunction_Recognition] = (ExecuteFlag & HVC_ACTIV_FACE_RECOGNITION) ? 1 : 0;
    
    while( _ExecFlag == YES )
    {
        rtn = HVCW_OKAO_Execute( hHVC, func.abUseFunction, &result, pReturnStatus );
        
        #ifdef RESULT_TRACE_ON
        
        NSLog( @"bodys.nCount= %d", result.bodys.nCount );
        
        for( int i = 0; i < result.bodys.nCount; i++ )
        {
            NSLog( @"body[%d].center= %d,%d nSize= %d nConfidence= %d", i, result.bodys.body[i].center.nX, result.bodys.body[i].center.nY, result.bodys.body[i].nSize, result.bodys.body[i].nConfidence);
        }
        
        NSLog( @"hands.nCount= %d", result.hands.nCount );
        
        for( int i = 0; i < result.hands.nCount; i++ )
        {
            NSLog( @"hand[%d].center= %d,%d nSize= %d nConfidence= %d", i, result.hands.hand[i].center.nX, result.hands.hand[i].center.nY, result.hands.hand[i].nSize, result.hands.hand[i].nConfidence );
        }
        
        NSLog( @"pets.nCount= %d", result.pets.nCount );
        
        for( int i = 0; i < result.pets.nCount; i++ )
        {
            NSLog( @"pet[%d].center= %d,%d nSize= %d nConfidence= %d nPetType= %d", i, result.pets.pet[i].ptCenter.nX, result.pets.pet[i].ptCenter.nY, result.pets.pet[i].nSize, result.pets.pet[i].nConfidence, result.pets.pet[i].nPetType );
        }
        
        NSLog( @"faces.nCount= %d", result.faces.nCount );
        
        for( int i = 0; i < result.faces.nCount; i++ )
        {
            NSLog( @"face[%d].center= %d,%d nSize= %d nConfidence= %d", i, result.faces.face[i].center.nX, result.faces.face[i].center.nY, result.faces.face[i].nSize, result.faces.face[i].nConfidence );
            
            NSLog( @"face[%d].direction.nLR= %d nUD= %d nRoll= %d", i, result.faces.face[i].direction.nLR, result.faces.face[i].direction.nUD, result.faces.face[i].direction.nRoll );
            
            NSLog( @"face[%d].age.nAge= %d nConfidence= %d", i, result.faces.face[i].age.nAge, result.faces.face[i].age.nConfidence );
            
            NSLog( @"face[%d].gender.nGender= %d nConfidence= %d", i, result.faces.face[i].gender.nGender, result.faces.face[i].gender.nConfidence );
            
            NSLog( @"face[%d].gaze.nLR= %d nUD= %d", i, result.faces.face[i].gaze.nLR, result.faces.face[i].gaze.nUD );
            
            NSLog( @"face[%d].blink.nLeftEye= %d nRightEye= %d", i, result.faces.face[i].blink.nLeftEye, result.faces.face[i].blink.nRightEye );
            
            NSLog( @"face[%d].expression.anScore= %d,%d,%d,%d,%d nDegree= %d", i, result.faces.face[i].expression.anScore[HVCW_Expression_Neutral], result.faces.face[i].expression.anScore[HVCW_Expression_Happiness], result.faces.face[i].expression.anScore[HVCW_Expression_Surprise], result.faces.face[i].expression.anScore[HVCW_Expression_Anger], result.faces.face[i].expression.anScore[HVCW_Expression_Sadness], result.faces.face[i].expression.nDegree );
            
            NSLog( @"face[%d].recognition.nUID= %d nScore= %d", i, result.faces.face[i].recognition.nUID, result.faces.face[i].recognition.nScore );
        }
        
        #endif
        
        NSLog( @"%d %X" , rtn, *pReturnStatus );
        
        if( (rtn != 1) || (*pReturnStatus != 0) )
        {
            NSLog( @"失敗" );
            
            if( rtn == HVCW_DISCONNECTED )
            {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"カメラとの接続が切断されました"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil
                                      ];
                
                // アラートを表示する
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [alert show];
                }];
                
                openingViewController.disconnectFlag = 1;
                _ExecFlag = NO;
                continue;
            }
            else
            {
                continue;
            }
        }
        else
        {
            NSLog( @"成功" );
        }
        
        NSLog(@"result.bodys.nCount= %d", result.bodys.nCount);
        
        // OKAO結果表示
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self FinishExec:(HVCW_OKAO_RESULT*)&result useFunction:func];
        }];
    }
    
    NSLog(@"OKAO_Execute Terminal");
}

- (void)FinishExec:(HVCW_OKAO_RESULT*)result useFunction:(USE_FUNCTION)func {
    NSLog(@"FinishExec");
    
    NSLog(@"result.bodys.nCount= %d", result->bodys.nCount);
    
    //登録したviewをすべて解除する
    for (UIView *view in [_ResultDispView subviews])
    {
        [view removeFromSuperview];
    }
    
    if( result->bodys.nCount > 0 )
    {
        for(int i = 0; i < result->bodys.nCount; i++)
        {
            CGFloat left    = (result->bodys.body[i].center.nX - result->bodys.body[i].nSize / 2) * _BaseScale ;
            CGFloat top     = (result->bodys.body[i].center.nY - result->bodys.body[i].nSize / 2) * _BaseScale;
            CGFloat width   = result->bodys.body[i].nSize * _BaseScale;
            CGFloat height  = result->bodys.body[i].nSize * _BaseScale;
            CGRect rect = CGRectMake( left, top, width, height );
            
            UIView* sub_view = [[UIView alloc] initWithFrame:rect];
            sub_view.layer.borderWidth = 2.0f;                            //枠線
            sub_view.layer.borderColor = [[UIColor blueColor] CGColor];   //枠線の色
            [_ResultDispView addSubview:sub_view];
        }
    }
    
    if( result->hands.nCount > 0 )
    {
        for(int i = 0; i < result->hands.nCount; i++)
        {
            CGFloat left    = (result->hands.hand[i].center.nX - result->hands.hand[i].nSize / 2) * _BaseScale;
            CGFloat top     = (result->hands.hand[i].center.nY - result->hands.hand[i].nSize / 2) * _BaseScale;
            CGFloat width   = result->hands.hand[i].nSize * _BaseScale;
            CGFloat height  = result->hands.hand[i].nSize * _BaseScale;
            CGRect rect = CGRectMake( left, top, width, height );
            
            UIView* sub_view = [[UIView alloc] initWithFrame:rect];
            sub_view.layer.borderWidth = 2.0f;                            //枠線
            sub_view.layer.borderColor = [[UIColor redColor] CGColor];    //枠線の色
            [_ResultDispView addSubview:sub_view];
        }
    }

    if( result->faces.nCount > 0 )
    {
        // 検出結果のサイズ、位置を決定
        for( int i = 0; i < result->faces.nCount; i++ )
        {
            CGFloat left    = (result->faces.face[i].center.nX - result->faces.face[i].nSize / 2) * _BaseScale;
            CGFloat top     = (result->faces.face[i].center.nY - result->faces.face[i].nSize / 2) * _BaseScale;
            CGFloat width   = result->faces.face[i].nSize * _BaseScale;
            CGFloat height  = result->faces.face[i].nSize * _BaseScale;
            CGRect rect = CGRectMake( left, top, width, height );
            
            UIView* sub_view = [[UIView alloc] initWithFrame:rect];
            sub_view.layer.borderWidth = 2.0f;                             //枠線
            sub_view.layer.borderColor = [[UIColor greenColor] CGColor];   //枠線の色
            [_ResultDispView addSubview:sub_view];
        }
        
        for( int i = 0; i < 1; i++ )
        {
            // 顔向き推定
            if( func.abUseFunction[HVCW_OkaoFunction_Direction] == 1 )
            {
                NSString* str = @"";
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%d", result->faces.face[i].direction.nLR]];
                _FaceDerectionLabel.text = str;
                str = @"";
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%d", result->faces.face[i].direction.nUD]];
                _FaceDerectionLabel2.text = str;
                str = @"";
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%d", result->faces.face[i].direction.nRoll]];
                _FaceDerectionLabel3.text = str;
            }

            // 年齢推定
            if( func.abUseFunction[HVCW_OkaoFunction_Age] == 1 )
            {
                NSString*   str = @"";
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%d歳\n", result->faces.face[i].age.nAge]];
                _AgeLabel.text = str;
            }
            
            // 性別推定
            if( func.abUseFunction[HVCW_OkaoFunction_Gender] == 1 )
            {
                NSString*   str = @"";
                NSString *gender;
                
                if( result->faces.face[i].gender.nGender == HVC_GEN_MALE )
                {
                    gender = @"男性";
                }
                else
                {
                    gender = @"女性";
                }
                
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%@", gender]];
                _GenderLabel.text = str;
            }
            
            // 視線推定
            if( func.abUseFunction[HVCW_OkaoFunction_Gaze] == 1 )
            {
                NSString*   str = @"";
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%3d", result->faces.face[i].gaze.nLR]];
                _EyeLineLabel.text = str;
                str = @"";
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%3d", result->faces.face[i].gaze.nUD]];
                _EyeLineLabel2.text = str;
                
            }
            
            // 目つむり推定
            if( func.abUseFunction[HVCW_OkaoFunction_Blink] == 1 )
            {
                NSString*   str = @"";
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%3d", result->faces.face[i].blink.nLeftEye]];
                _EyeOpenLabel.text = str;
                str = @"";
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%3d", result->faces.face[i].blink.nRightEye]];
                _EyeOpenLabel2.text = str;
                
            }
            
            // 表情推定
            if( func.abUseFunction[HVCW_OkaoFunction_Expression] == 1 )
            {
                int     iExpression = HVCW_Expression_Ignore;
                int     iScoreMAx = 0;
                
                for( int n = 0; n < HVCW_Expression_Max; n++ )
                {
                    if( result->faces.face[i].expression.anScore[n] > iScoreMAx )
                    {
                        iScoreMAx = result->faces.face[i].expression.anScore[n];
                        iExpression = n;
                    }
                }
                
                NSLog(@"iExpression= %d", iExpression);
                
                NSString*   str = @"";
                NSString*   expression;
                
                switch( iExpression )
                {
                    case HVCW_Expression_Neutral:
                        expression = @"無表情";
                        break;
                        
                    case HVCW_Expression_Happiness:
                        expression = @"嬉しい";
                        break;
                        
                    case HVCW_Expression_Surprise:
                        expression = @"驚き";
                        break;
                        
                    case HVCW_Expression_Anger:
                        expression = @"怒り";
                        break;
                        
                    case HVCW_Expression_Sadness:
                        expression = @"悲しい";
                        break;
                        
                    case HVCW_Expression_Ignore:
                        expression = @"不明";
                        break;
                }
                
                str = [str stringByAppendingString:[NSString stringWithFormat:@"degree = %d\n", result->faces.face[i].expression.nDegree]];
                _ExpressionLabel.text = expression;
            }
            
            if( func.abUseFunction[HVCW_OkaoFunction_Recognition] == 1 )
            {
                NSString*   str = @"";
                NSString*   recognition;
                
                if( result->faces.face[i].recognition.nUID == 0 )
                {
                    recognition = @"◯";
                }
                else
                {
                    recognition = @"☓";
                }
                
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%@", recognition]];
                _RecognitionLabel.text = str;
            }
        }
    }
}

@end
