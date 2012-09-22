//
//  NetworkDrawRectBlockCell.m
//  betterreader
//
//  Created by Sir Reflog on 9/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NetworkDrawRectBlockCell.h"

@implementation NetworkDrawRectBlockCell
@synthesize networkImageView = _networkImageView;
@synthesize badgeView = _badgeView;
@synthesize imageSize = _imageSize;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        _networkImageView = [[NINetworkImageView alloc] init];
        _badgeView = [[NIBadgeView alloc] init];
        // We implement the delegate so that we know when the image has finished downloading.
        _networkImageView.delegate = self;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.networkImageView prepareForReuse];
}

- (BOOL)shouldUpdateCellWithObject:(NIDrawRectBlockCellObject *)object {
    [super shouldUpdateCellWithObject:object];
    id dict = object.object;
    NSString* url = [dict valueForKey:@"url"];
    self.imageSize = CGSizeMake([[dict valueForKey:@"width"] intValue], [[dict valueForKey:@"height"] intValue]);
    self.badgeView.text = [[dict valueForKey:@"badgeValue"] stringValue];
    [self.badgeView sizeToFit];
    [self.networkImageView setPathToNetworkImage:url forDisplaySize:_imageSize];
    
    return YES;
}

#pragma mark - NINetworkImageViewDelegate

- (void)networkImageView:(NINetworkImageView *)imageView didLoadImage:(UIImage *)image {
    // Once the image has been downloaded we need to redraw the block.
    [self.blockView setNeedsDisplay];
}

+ (NICellDrawRectBlock) block
{
    NICellDrawRectBlock drawTextBlock = ^CGFloat(CGRect rect, id object, UITableViewCell *cell) {
        if (cell.isHighlighted || cell.isSelected) {
            [[UIColor clearColor] set];
        } else {
            [[UIColor whiteColor] set];
        }
        UIRectFill(rect);
        
        NSString* text = [object valueForKey:@"text"];
        [[UIColor blackColor] set];
        UIFont* titleFont = [UIFont boldSystemFontOfSize:16];
        NetworkDrawRectBlockCell* networkCell = (NetworkDrawRectBlockCell *)cell;
        
        UIImage* image = networkCell.networkImageView.image;
        [image drawAtPoint:CGPointMake(10, 12)];
        float textW = CGRectGetMaxX(cell.contentView.frame) - 20 - networkCell.imageSize.width - 10 - 5 - networkCell.badgeView.frame.size.width;
        [text drawAtPoint:CGPointMake(10 + networkCell.imageSize.width + 10, 10) forWidth:textW withFont:titleFont lineBreakMode:UILineBreakModeTailTruncation];
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), CGRectGetMaxX(cell.contentView.frame) - networkCell.badgeView.frame.size.width - 5, 5);
        CGRect brect = CGRectMake(0, 0, networkCell.badgeView.frame.size.width, networkCell.badgeView.frame.size.height);
        [networkCell.badgeView drawRect:brect];
        return 0;
    };
    return drawTextBlock;
}


@end
