//
//  FeedItemCell.h
//  betterreader
//
//  Created by Sir Reflog on 9/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Item.h"
#import "NINetworkImageView.h"

@interface IFeedItemCell : UITableViewCell
- (CGFloat)requiredRowHeightInTableView:(UITableView *)tableView;
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier item:(Item*)item;
+ (IFeedItemCell*) cellWithReuseIdentifier:(NSString *)reuseIdentifier item:(Item*)item listView:(BOOL)listView;
@property (nonatomic, strong) Item* item;
@end

@interface FullFeedItemCell : IFeedItemCell <DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate, DTWebVideoViewDelegate, NINetworkImageViewDelegate>
@property (nonatomic, strong) NSAttributedString *attributedString;
@property (nonatomic, readonly) DTAttributedTextContentView *attributedTextContextView;
- (void)setHTMLString:(NSString *)html;
@end

@interface ListFeedItemCell : IFeedItemCell
@end