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
//  OpeningViewController.h
//  StandardDemo
//

@import UIKit;
#import "../../SDK/HvcwSdkAPI.h"
#import "../../SDK/HvcwCommonDef.h"

@interface OpeningViewController : UIViewController

- (BOOL)connectCamera:(NSString*)cameraId;
- (BOOL)disconnectCamera;
- (void)setStatusLabel:(NSString*)value;
- (void)setTypeLabel:(NSString*)value;
- (void)setVersionLabel:(NSString*)value;
- (IBAction)loginBtn:(UIButton *)sender;
- (IBAction)registrationBtn:(UIButton *)sender;

@property HHVC  hHVC;
@property BOOL  disconnectFlag;

@end
