//
//  StarView.m
//  betterreader
//
//  Created by reflog on 9/27/12.
//
//

#import "StarView.h"

@implementation StarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //// Color Declarations
    UIColor* starColor = [UIColor colorWithRed: 0.99 green: 0.88 blue: 0.09 alpha: 1];
    
    //// Abstracted Graphic Attributes
    CGRect starFrame = CGRectMake(0, 0, 22, 22);
    
    
    //// Star Drawing
    UIBezierPath* starPath = [UIBezierPath bezierPath];
    [starPath moveToPoint: CGPointMake(11, -0)];
    [starPath addLineToPoint: CGPointMake(8.03, 6.91)];
    [starPath addLineToPoint: CGPointMake(0.54, 7.6)];
    [starPath addLineToPoint: CGPointMake(6.19, 12.56)];
    [starPath addLineToPoint: CGPointMake(4.53, 19.9)];
    [starPath addLineToPoint: CGPointMake(11, 16.05)];
    [starPath addLineToPoint: CGPointMake(17.47, 19.9)];
    [starPath addLineToPoint: CGPointMake(15.81, 12.56)];
    [starPath addLineToPoint: CGPointMake(21.46, 7.6)];
    [starPath addLineToPoint: CGPointMake(13.97, 6.91)];
    [starPath closePath];
    [starColor setFill];
    [starPath fill];
    
    [[UIColor blackColor] setStroke];
    starPath.lineWidth = 1;
    [starPath stroke];
    
}


@end
