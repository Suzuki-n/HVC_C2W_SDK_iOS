//
//  LoginContentsViewController.h
//
//
//  Copyright (C) 2014-2015 OMRON Corporation
//

#import <UIKit/UIKit.h>
#import "../../SDK/HvcwSdkAPI.h"
#import "../../SDK/HvcwCommonDef.h"
#import "OpeningViewController.h"

@interface LoginContentsViewController : UIViewController

@property OpeningViewController  *openingViewController;

+(CGFloat)viewHeight;

@end
