//
//  FeedItemCell.h
//  betterreader
//
//  Created by Sir Reflog on 9/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Item.h"

@interface FeedItemCell : UITableViewCell

@property (nonatomic, strong) NSAttributedString *attributedString;
@property (nonatomic, readonly) Item* item;
@property (nonatomic, readonly) DTAttributedTextContentView *attributedTextContextView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier item:(Item*)item;
- (void)setHTMLString:(NSString *)html;
- (CGFloat)requiredRowHeightInTableView:(UITableView *)tableView;

@end
