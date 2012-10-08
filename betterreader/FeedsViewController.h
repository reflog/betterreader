//
// Created by eli on 9/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "NINetworkTableViewController.h"
#import "NimbusCore.h"
#import "NimbusModels.h"
#import "FeedViewToolbar.h"

@class Feed;

@interface FeedsViewController : NINetworkTableViewController<NITableViewModelDelegate,
                                DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate, DTWebVideoViewDelegate, FeedViewToolbarDelegate>

@property (nonatomic, strong) Feed* feed;

@end