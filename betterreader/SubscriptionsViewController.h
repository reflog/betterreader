//
//  SubscriptionsViewController.h
//  betterreader
//
//  Created by Sir Reflog on 9/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NINetworkTableViewController.h"

@class FeedsViewController;

@interface SubscriptionsViewController : NINetworkTableViewController


@property(nonatomic, strong) FeedsViewController *feedsViewController;
@end
