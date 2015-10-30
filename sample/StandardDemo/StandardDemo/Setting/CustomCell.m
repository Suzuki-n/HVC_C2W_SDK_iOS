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
//  CustomCell.m
//  StandardDemo
//

#import "CustomCell.h"

@implementation CustomCell
@synthesize delegate = _delegate;

- (void)awakeFromNib {
    _TextField.delegate = self;
    _TextField.keyboardType = UIKeyboardTypeNumberPad;

    //数字入力パッドに決定ボタンを付ける
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                                 target:nil
                                                                                                 action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"決定"
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    _TextField.inputAccessoryView = numberToolbar;
}

// 決定ボタン押下時の挙動
- (void)doneWithNumberPad {
    // キーボードを非表示にします。
    [_TextField endEditing:YES];
}

//テキストフィールドを選択した
- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    return YES;
}

//テキストフィールドに対する選択状態が外れた時
- (BOOL)textFieldShouldEndEditing:(UITextField*)textField {
    //ここで入力した数値を渡す
    if([_delegate respondsToSelector:@selector(SelectedCell:)]){
        [_delegate SelectedCell:self];
    }
    return YES;
}

@end
