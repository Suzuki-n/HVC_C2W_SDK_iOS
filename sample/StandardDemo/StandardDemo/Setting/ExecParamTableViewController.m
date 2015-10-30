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
//  ExecParamTableViewController.m
//  StandardDemo
//

#import "ExecParamTableViewController.h"
#import "AppSettingInfo.h"

@interface ExecParamTableViewController ()

@property (nonatomic,strong)NSArray         *ParamItemArray;
@property (nonatomic,strong)NSMutableArray  *CellArray;
@property (nonatomic,strong)CustomCell      *SelectedCell;
@property (nonatomic,strong)NSMutableArray  *ValueArray;

@end

@implementation ExecParamTableViewController

@synthesize hHVC;
@synthesize getThreshold;
@synthesize getSizeRange;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _ParamItemArray = [NSArray arrayWithObjects:@"最小サイズ",@"最大サイズ",@"しきい値", nil];
    _CellArray = [[NSMutableArray alloc] init];
    
    _ValueArray = [[NSMutableArray alloc] init];
    
    for(int i  = 0; i < 9; i++)
    {
        NSNumber* value = [NSNumber numberWithInt:i];
        _ValueArray[i] = value;
    }
    
    HVCW_INT32  rtn;
    NSString    *rtn_str;
    HVCW_UINT8  returnStatus;
    
    rtn = HVCW_OKAO_GetThreshold( hHVC, &getThreshold, &returnStatus );
    
    rtn_str = [NSString stringWithFormat:@"%d %X" , rtn, returnStatus];
    NSLog( @"HVCW_OKAO_GetThreshold return= %@", rtn_str );
    
    if( (rtn != 1) || (returnStatus != 0) )
    {
        NSLog( @"失敗" );
        
        _ValueArray[2] = @"9999";
        _ValueArray[5] = @"9999";
        _ValueArray[8] = @"9999";
    }
    else
    {
        NSLog( @"成功" );
        
        _ValueArray[2] = [NSNumber numberWithInt:getThreshold.nFace];
        _ValueArray[5] = [NSNumber numberWithInt:getThreshold.nBody];
        _ValueArray[8] = [NSNumber numberWithInt:getThreshold.nHand];
    }
    
    rtn = HVCW_OKAO_GetSizeRange( hHVC, &getSizeRange, &returnStatus);
    
    rtn_str = [NSString stringWithFormat:@"%d %X" , rtn, returnStatus];
    NSLog( @"HVCW_OKAO_GetSizeRange return= %@", rtn_str );
    
    if( (rtn != 1) || (returnStatus != 0) )
    {
        NSLog( @"失敗" );
        
        _ValueArray[0] = @"9999";
        _ValueArray[1] = @"9999";
        _ValueArray[3] = @"9999";
        _ValueArray[4] = @"9999";
        _ValueArray[6] = @"9999";
        _ValueArray[7] = @"9999";
    }
    else
    {
        NSLog( @"成功" );
        
        _ValueArray[0] = [NSNumber numberWithInt:getSizeRange.face.nMin];
        _ValueArray[1] = [NSNumber numberWithInt:getSizeRange.face.nMax];
        _ValueArray[3] = [NSNumber numberWithInt:getSizeRange.body.nMin];
        _ValueArray[4] = [NSNumber numberWithInt:getSizeRange.body.nMax];
        _ValueArray[6] = [NSNumber numberWithInt:getSizeRange.hand.nMin];
        _ValueArray[7] = [NSNumber numberWithInt:getSizeRange.hand.nMax];
    }
    
    // カスタマイズしたセルをテーブルビューにセット
    UINib *nib = [UINib nibWithNibName:@"CustomCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"exec_param_cell"];
    [self.searchDisplayController.searchResultsTableView registerNib:nib forCellReuseIdentifier:@"exec_param_cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    if( [self.navigationController.viewControllers indexOfObject:self] == NSNotFound )
    {
        HVCW_INT32  rtn;
        NSString    *rtn_str;
        HVCW_UINT8  returnStatus;
        
        HVCW_OKAO_THRESHOLD     threshold;
        
        threshold.nBody = [_ValueArray[5] intValue];
        threshold.nHand = [_ValueArray[8] intValue];
        threshold.nPet = getThreshold.nPet;
        threshold.nFace = [_ValueArray[2] intValue];
        threshold.nRecognition = getThreshold.nRecognition;
        
        rtn = HVCW_OKAO_SetThreshold( hHVC, &threshold, &returnStatus );
        
        rtn_str = [NSString stringWithFormat:@"%d %X" , rtn, returnStatus];
        NSLog( @"HVCW_OKAO_SetThreshold return= %@", rtn_str );
        
        if( (rtn != 1) || (returnStatus != 0) )
        {
            NSLog( @"失敗" );
        }
        else
        {
            NSLog( @"成功" );
        }
        
        HVCW_OKAO_SIZE_RANGE    sizeRange;
        
        sizeRange.body.nMin = [_ValueArray[3] intValue];
        sizeRange.body.nMax = [_ValueArray[4] intValue];
        sizeRange.hand.nMin = [_ValueArray[6] intValue];
        sizeRange.hand.nMax = [_ValueArray[7] intValue];
        sizeRange.pet.nMin = getSizeRange.pet.nMin;
        sizeRange.pet.nMax = getSizeRange.pet.nMax;
        sizeRange.face.nMin = [_ValueArray[0] intValue];
        sizeRange.face.nMax = [_ValueArray[1] intValue];
        
        rtn = HVCW_OKAO_SetSizeRange( hHVC, &sizeRange, &returnStatus );
        
        rtn_str = [NSString stringWithFormat:@"%d %X" , rtn, returnStatus];
        NSLog( @"HVCW_OKAO_SetSizeRange return= %@", rtn_str );
        
        if( (rtn != 1) || (returnStatus != 0) )
        {
            NSLog( @"失敗" );
        }
        else
        {
            NSLog( @"成功" );
        }
    }
    
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"exec_param_cell" forIndexPath:indexPath];
    
    cell.accessoryType  = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    //顔検出
    if(indexPath.section == 0) {
        if( indexPath.row == 0) {
            cell.Label.text = @"最小検知サイズ";
            cell.TextField.text = [[NSString alloc] initWithFormat:@"%d",[_ValueArray[0] intValue]];
            cell.tag      = 0;
        }
        else if( indexPath.row == 1) {
            cell.Label.text = @"最大検知サイズ";
            cell.TextField.text = [[NSString alloc] initWithFormat:@"%d",[_ValueArray[1] intValue]];
            cell.tag      = 1;
        }
        else if( indexPath.row == 2) {
            cell.Label.text = @"しきい値";
            cell.TextField.text = [[NSString alloc] initWithFormat:@"%d",[_ValueArray[2] intValue]];
            cell.tag      = 2;
        }
    }
    //人体検出
    if(indexPath.section == 1) {
        if( indexPath.row == 0) {
            cell.Label.text = @"最小検知サイズ";
            cell.TextField.text = [[NSString alloc] initWithFormat:@"%d",[_ValueArray[3] intValue]];
            cell.tag      = 3;
        }
        else if( indexPath.row == 1) {
            cell.Label.text = @"最大検知サイズ";
            cell.TextField.text = [[NSString alloc] initWithFormat:@"%d",[_ValueArray[4] intValue]];
            cell.tag      = 4;
        }
        else if( indexPath.row == 2) {
            cell.Label.text = @"しきい値";
            cell.TextField.text = [[NSString alloc] initWithFormat:@"%d",[_ValueArray[5] intValue]];
            cell.tag      = 5;
        }
    }
    //手検出
    if(indexPath.section == 2) {
        if( indexPath.row == 0) {
            cell.Label.text = @"最小検知サイズ";
            cell.TextField.text = [[NSString alloc] initWithFormat:@"%d",[_ValueArray[6] intValue]];
            cell.tag      = 6;
        }
        else if( indexPath.row == 1) {
            cell.Label.text = @"最大検知サイズ";
            cell.TextField.text = [[NSString alloc] initWithFormat:@"%d",[_ValueArray[7] intValue]];
            cell.tag      = 7;
        }
        else if( indexPath.row == 2) {
            cell.Label.text = @"しきい値";
            cell.TextField.text = [[NSString alloc] initWithFormat:@"%d",[_ValueArray[8] intValue]];
            cell.tag      = 8;
        }
    }
    
    return cell;
}

// セルが選択された時に呼び出される
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//選択したテキストフィールドのセルを取得
- (void)SelectedCell:(id)cell {
    CustomCell* select = (CustomCell*)cell;
    
    NSInteger tag = select.tag;
    
    NSInteger num = [select.TextField.text intValue];
    _SelectedCell = select;
    _ValueArray[tag] = [NSNumber numberWithLong:num];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* title;
    switch ( section ){
        case 0 :
            title = @"顔検出";
            break;
        case 1 :
            title = @"人体検出";
            break;
        case 2 :
            title = @"手検出";
            break;
    }
    
    return title;
}

@end
