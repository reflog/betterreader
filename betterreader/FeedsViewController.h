//
//  FeedsViewController.h
//  betterreader
//
//  Created by Sir Reflog on 9/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NINetworkTableViewController.h"

@interface FeedsViewController : NINetworkTableViewController

@property(nonatomic,strong) NSArray* feeds;
@property(nonatomic,strong) NSDictionary* labels;
@end