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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        _networkImageView = [[NINetworkImageView alloc] init];
        
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
    NSString* url = [object.object valueForKey:@"url"];
    CGSize size = CGSizeMake([[object.object valueForKey:@"width"] intValue], [[object.object valueForKey:@"height"] intValue]);
    [self.networkImageView setPathToNetworkImage:url forDisplaySize:size];
    
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
        
        NSString* text = object;
        [[UIColor blackColor] set];
        UIFont* titleFont = [UIFont boldSystemFontOfSize:16];
        NetworkDrawRectBlockCell* networkCell = (NetworkDrawRectBlockCell *)cell;
        
        // Grab the image and then draw it on the cell. If there is no image yet then the draw method
        // will do nothing.
        UIImage* image = networkCell.networkImageView.image;
        [image drawAtPoint:CGPointMake(10, 5)];
        [text drawAtPoint:CGPointMake(10 + image.size.width + 10, 5) withFont:titleFont];
        
        return 0;
    };
    return drawTextBlock;
}


@end
