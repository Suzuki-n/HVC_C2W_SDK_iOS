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
//  ExecTypeTableViewController.m
//  StandardDemo
//

#import "ExecTypeTableViewController.h"
#import "AppSettingInfo.h"

@interface ExecTypeTableViewController ()
@property(nonatomic,strong)NSArray  *SectionArray;
@property(nonatomic,strong)NSArray  *ExecTypeArray;
@property(nonatomic,assign)NSInteger ExecType;
@end

@implementation ExecTypeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _SectionArray   = @[@"検出タイプ設定"];
    _ExecTypeArray  = @[@"人体検出",@"手検出",@"顔検出",@"顔向き推定",@"年齢推定",
                        @"性別推定",@"視線推定",@"目つむり推定",@"表情推定",@"顔認証"];
    
    _ExecType = [AppSettingInfo GetExecType];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_SectionArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_ExecTypeArray count];
}

// indexPathで指定された場所に配置するセルを作る
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = _ExecTypeArray[indexPath.row];
    NSNumber* row = [NSNumber numberWithInteger:indexPath.row];
    NSInteger type = 1 << [row intValue];
    
    //選択している項目だけチェックマーク
    if( _ExecType & type ) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

// セルが選択された時に呼び出される
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 選択されたセルを取得
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // セルのアクセサリにチェックマークを指定
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark ){
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        NSNumber* row = [NSNumber numberWithInteger:indexPath.row];
        _ExecType &= ~(1 << [row intValue]);
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        NSNumber* row = [NSNumber numberWithInteger:indexPath.row];
        _ExecType |= (1 << [row intValue]);
    }
    
    //保存する
    [AppSettingInfo SetExecType:_ExecType];
}
@end
