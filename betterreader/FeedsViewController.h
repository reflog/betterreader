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

@class Feed;

@interface FeedsViewController : LoadingViewController<NITableViewModelDelegate,
                                DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate, DTWebVideoViewDelegate, FeedViewToolbarDelegate>

@property (nonatomic, strong) Feed* feed;
- (void)setLoadingFeed:(BOOL)loading;

@end