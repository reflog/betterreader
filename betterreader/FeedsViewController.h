//
// Created by eli on 9/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "NINetworkTableViewController.h"

@class Feed;

@interface FeedsViewController : NINetworkTableViewController<NITableViewModelDelegate,
                                DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate, DTWebVideoViewDelegate>

@property (nonatomic, strong) Feed* feed;

@end