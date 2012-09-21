//
//  FeedItemCell.m
//  betterreader
//
//  Created by Sir Reflog on 9/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedItemCell.h"
#import "DTCoreText.h"
#import "DTAttributedTextCell.h"
#import "DTCSSStylesheet.h"
#import "Utils.h"

@interface FeedItemCell ()
{
    NSUInteger _htmlHash; // preserved hash to avoid relayouting for same HTML
}
@property (nonatomic, readonly) UIButton* titleView;
@property (nonatomic, readonly) UILabel* dateView;
@property (nonatomic, readonly) UIButton* starBtn1;
@property (nonatomic, readonly) UIButton* starBtn2;
@property (nonatomic, readonly) UIButton* plusOneBtn;
@property (nonatomic, readonly) UIButton* plusShareBtn;
@property (nonatomic, readonly) UIButton* keepUnreadBtn;

@end
@implementation FeedItemCell

@synthesize attributedString = _attributedString;
@synthesize attributedTextContextView = _attributedTextContextView;
@synthesize titleView = _titleView, item = _item;
@synthesize starBtn1 = _starBtn1, starBtn2 = _starBtn2;
@synthesize keepUnreadBtn = _keepUnreadBtn;
@synthesize plusShareBtn = _plusShareBtn;
@synthesize plusOneBtn = _plusOneBtn;
@synthesize dateView = _dateView;


- (void)openTitleLink {
    RequestBrowserOpen([self.item.canonical objectAtIndex:0]);
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier item:(Item*)item
{
    self = [super initWithStyle:UITableViewStylePlain reuseIdentifier:reuseIdentifier];
    if (self) {
		_attributedTextContextView = [[DTAttributedTextContentView alloc] initWithFrame:CGRectZero];
		_attributedTextContextView.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        _item = item;

        _titleView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_titleView setTitle:item.title forState:UIControlStateNormal];
        [_titleView setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_titleView sizeToFit];
        [_titleView addTarget:self action:@selector(openTitleLink) forControlEvents:UIControlEventTouchUpInside];

        _dateView = [[UILabel alloc] initWithFrame:CGRectZero];
        _dateView.text = [[NSDate dateWithTimeIntervalSince1970:item.published] description];
        [_dateView sizeToFit];

        _starBtn1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_starBtn1 setTitle:@"Star" forState:UIControlStateNormal];
        [_starBtn1 sizeToFit];

        _starBtn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_starBtn2 setTitle:@"Star" forState:UIControlStateNormal];
        [_starBtn2 sizeToFit];

        _plusOneBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_plusOneBtn setTitle:@"Plus One" forState:UIControlStateNormal];
        [_plusOneBtn sizeToFit];

        _plusShareBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_plusShareBtn setTitle:@"Plus Share" forState:UIControlStateNormal];
        [_plusShareBtn sizeToFit];

        _keepUnreadBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_keepUnreadBtn setTitle:@"Keep Unread" forState:UIControlStateNormal];
        [_keepUnreadBtn sizeToFit];



        [self.contentView addSubview:_titleView];
        [self.contentView addSubview:_dateView];
        [self.contentView addSubview:_starBtn1];
        [self.contentView addSubview:_starBtn2];
        [self.contentView addSubview:_plusOneBtn];
        [self.contentView addSubview:_plusShareBtn];
        [self.contentView addSubview:_keepUnreadBtn];
		[self.contentView addSubview:_attributedTextContextView];
        [self setHTMLString:item.content.content];
    }
    return self;
}

#define TITLE_SPACING 10

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGFloat neededContentHeight = [self requiredRowHeightInTableView:(UITableView *)self.superview];
	
	// after the first call here the content view size is correct
    CGFloat topOffset = _titleView.frame.size.height + TITLE_SPACING;
    CGFloat bottomOffset =  _starBtn2.frame.size.height + TITLE_SPACING;
    CGFloat contentWidth = self.contentView.bounds.size.width;

    CGRect dateFrame = _dateView.frame;
    dateFrame.origin.x = contentWidth - dateFrame.size.width;
    _dateView.frame = dateFrame;

    CGRect star1Frame = _starBtn1.frame;
    star1Frame.origin.x = _titleView.frame.size.width + 10;
    _starBtn1.frame = star1Frame;

    CGFloat bottomY =  neededContentHeight + topOffset + TITLE_SPACING;

    CGRect star2Frame = _starBtn2.frame;
    star2Frame.origin.y = bottomY;
    _starBtn2.frame = star2Frame;

    CGRect keepUnreadFrame = _keepUnreadBtn.frame;
    keepUnreadFrame.origin = CGPointMake(star2Frame.origin.x + star2Frame.size.width + 10, bottomY);
    _keepUnreadBtn.frame = keepUnreadFrame;

    CGRect plusShareFrame = _plusShareBtn.frame;
    plusShareFrame.origin = CGPointMake(keepUnreadFrame.origin.x + keepUnreadFrame.size.width + 10, bottomY);
    _plusShareBtn.frame = plusShareFrame;

    CGRect plusOneFrame = _plusOneBtn.frame;
    plusOneFrame.origin = CGPointMake(plusShareFrame.origin.x + plusShareFrame.size.width + 10, bottomY);
    _plusOneBtn.frame = plusOneFrame;


    CGRect frame = CGRectMake(0, topOffset, contentWidth, neededContentHeight - topOffset - bottomOffset);
	
	// only change frame if width has changed to avoid extra layouting
	if (_attributedTextContextView.frame.size.width != frame.size.width)
	{
		_attributedTextContextView.frame = frame;
	}
}


- (CGFloat)requiredRowHeightInTableView:(UITableView *)tableView
{
	
	CGFloat contentWidth = tableView.frame.size.width;
    
	CGSize neededSize = [_attributedTextContextView suggestedFrameSizeToFitEntireStringConstraintedToWidth:contentWidth];
    CGFloat topOffset = _titleView.frame.size.height + TITLE_SPACING;
    CGFloat bottomOffset =  _starBtn2.frame.size.height + TITLE_SPACING;
	
	// note: non-integer row heights caused trouble < iOS 5.0
	return (int)(neededSize.height + topOffset + bottomOffset);
}

#pragma mark Properties


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setHTMLString:(NSString *)html
{
	// we don't preserve the html but compare it's hash
	NSUInteger newHash = [html hash];
	
	if (newHash == _htmlHash)
	{
		return;
	}
	
	_htmlHash = newHash;
//	html = [html stringByReplacingOccurrencesOfString:@"<div" withString:@"<p"];
//	html = [html stringByReplacingOccurrencesOfString:@"</div" withString:@"</p"];
	NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
	void (^callBackBlock)(DTHTMLElement *element) = ^(DTHTMLElement *element) {
        // if an element is larger than twice the font size put it in it's own block
        if (element.displayStyle == DTHTMLElementDisplayStyleInline && element.textAttachment.displaySize.height > 2.0 * element.fontDescriptor.pointSize)
        {
            element.displayStyle = DTHTMLElementDisplayStyleBlock;
        }
    };
    
   	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], NSTextSizeMultiplierDocumentOption,	 @"Arial", DTDefaultFontFamily,  callBackBlock, DTWillFlushBlockCallBack, nil];
   	self.attributedString = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];	
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
	if (_attributedString != attributedString)
	{
		_attributedString = attributedString;
		
		// passthrough
		_attributedTextContextView.attributedString = _attributedString;
	}
}


@end
