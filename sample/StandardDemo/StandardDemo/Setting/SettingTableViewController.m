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
//  SettingTableViewController.m
//  StandardDemo
//

#import "SettingTableViewController.h"
#import "ExecParamTableViewController.h"
#import "ExecTypeTableViewController.h"

@interface SettingTableViewController ()
@property(nonatomic,strong)NSArray  *SectionArray;
@end

@implementation SettingTableViewController

@synthesize hHVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _SectionArray   = @[@"検出パラメータ",@"検出タイプ"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_SectionArray count];

}

// indexPathで指定された場所に配置するセルを作る
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = _SectionArray[indexPath.row];
    return cell;
}

// セルが選択された時に呼び出される
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( indexPath.row == 0 )
    {
        //パラメータ設定画面へ
        ExecParamTableViewController* view = [self.storyboard instantiateViewControllerWithIdentifier:@"ParamView"];
        view.hHVC = self.hHVC;
        [self.navigationController pushViewController:view animated:YES];
    }
    else
    {
        //検出タイプ設定画面へ
        ExecTypeTableViewController* view  = [self.storyboard instantiateViewControllerWithIdentifier:@"ExecTypeView"];
        [self.navigationController pushViewController:view animated:YES];
    }
}

@end
