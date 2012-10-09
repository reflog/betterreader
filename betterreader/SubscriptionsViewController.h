//
//  SubscriptionsViewController.h
//  betterreader
//
//  Created by Sir Reflog on 9/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingViewController.h"

@class FeedsViewController;

@interface SubscriptionsViewController : LoadingViewController


@property(nonatomic, strong) FeedsViewController *feedsViewController;
@end
