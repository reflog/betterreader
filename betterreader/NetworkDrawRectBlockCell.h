//
//  NetworkDrawRectBlockCell.h
//  betterreader
//
//  Created by Sir Reflog on 9/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NimbusNetworkImage.h"
#import "NIBadgeView.h"

@interface NetworkDrawRectBlockCell : NIDrawRectBlockCell <NINetworkImageViewDelegate>
@property (nonatomic, strong) NINetworkImageView* networkImageView;
@property (nonatomic, strong) NIBadgeView *badgeView;

@property(nonatomic) CGSize imageSize;

+ (NICellDrawRectBlock) block;
@end
