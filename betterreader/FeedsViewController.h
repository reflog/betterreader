//
// Created by eli on 9/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "NimbusCore.h"
#import "NimbusModels.h"
#import "FeedViewToolbar.h"
#import "LoadingViewController.h"

#define kMoreItemsRequested @"kMoreItemsRequested"

@class Feed;

@interface FeedsViewController : LoadingViewController<NITableViewModelDelegate, FeedViewToolbarDelegate>

@property (nonatomic, strong) Feed* feed;
- (void)setLoadingFeed:(BOOL)loading;
- (void)moreFeedItemsLoaded;
@end