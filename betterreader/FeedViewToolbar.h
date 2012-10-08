//
//  FeedViewToolbar.h
//  betterreader
//
//  Created by reflog on 10/8/12.
//
//

#import "DYFloatingHeaderView.h"
typedef enum {
    SORT_MODE_ASC,
    SORT_MODE_DES,
    SORT_MODE_MAGIC
} SortMode;

@protocol FeedViewToolbarDelegate
- (void) refreshClicked;
- (void) viewModeChanged:(BOOL)showAll;
- (void) displayModeChanged:(BOOL)showList;
- (void) nextFeedItemClicked;
- (void) prevFeedItemClicked;
- (void) sortModeChanged:(SortMode)mode;
- (void) unsubscribeClicked;
- (void) renameClicked;
@end

@interface FeedViewToolbar : DYFloatingHeaderView

@property(nonatomic,weak) id<FeedViewToolbarDelegate> delegate;
@end
