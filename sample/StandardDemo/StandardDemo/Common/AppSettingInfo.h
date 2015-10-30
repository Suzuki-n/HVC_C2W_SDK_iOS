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
//  AppSettingInfo.h
//  StandardDemo
//

@import Foundation;


// Define Execution Function
typedef enum : NSInteger
{
    // Human Body Detection
    HVC_ACTIV_BODY_DETECTION        = 0x00000001,
    // Hand Detection
    HVC_ACTIV_HAND_DETECTION        = 0x00000002,
    // Face Detection
    HVC_ACTIV_FACE_DETECTION        = 0x00000004,
    // Face Direction Estimation
    HVC_ACTIV_FACE_DIRECTION        = 0x00000008,
    // Age Estimation
    HVC_ACTIV_AGE_ESTIMATION        = 0x00000010,
    // Gender Estimation
    HVC_ACTIV_GENDER_ESTIMATION     = 0x00000020,
    // Gaze Estimation
    HVC_ACTIV_GAZE_ESTIMATION       = 0x00000040,
    // Blink Estimation
    HVC_ACTIV_BLINK_ESTIMATION      = 0x00000080,
    // Expression Estimation
    HVC_ACTIV_EXPRESSION_ESTIMATION = 0x00000100,
    // Face Recognition
    HVC_ACTIV_FACE_RECOGNITION      = 0x00000200,
} HVC_FUNCTION;

// Gender
typedef enum : NSInteger
{
    // Female
    HVC_GEN_FEMALE = 0,
    // Male
    HVC_GEN_MALE = 1,
} HVC_GENDER;

#define AC_SETTING_EXEC_TYPE @"SettingExecType"

@interface AppSettingInfo : NSObject
+ (HVC_FUNCTION) GetExecType;
+ (void) SetExecType:(HVC_FUNCTION)type;
@end
