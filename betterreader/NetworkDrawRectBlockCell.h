//
//  NetworkDrawRectBlockCell.h
//  betterreader
//
//  Created by Sir Reflog on 9/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NimbusNetworkImage.h"

@interface NetworkDrawRectBlockCell : NIDrawRectBlockCell <NINetworkImageViewDelegate>
@property (nonatomic, readwrite, retain) NINetworkImageView* networkImageView;
+ (NICellDrawRectBlock) block;
@end
