//
//  AppDelegate.h
//  betterreader
//
//  Created by Sir Reflog on 9/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSplitViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, MGSplitViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MGSplitViewController* splitViewController;
@property (strong, nonatomic) UIPopoverController* popoverViewController; 
@end
