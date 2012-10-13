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
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "NINetworkImageView.h"

@implementation IFeedItemCell

- (CGFloat)requiredRowHeightInTableView:(UITableView *)tableView { return 0; }
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier item:(Item*)item { return nil; }


+ (IFeedItemCell*) cellWithReuseIdentifier:(NSString *)reuseIdentifier item:(Item*)item listView:(BOOL)listView
{
    return listView ? [[ListFeedItemCell alloc] initWithReuseIdentifier:reuseIdentifier item:item] : [[FullFeedItemCell alloc]initWithReuseIdentifier:reuseIdentifier item:item];
}
@end

@implementation ListFeedItemCell

- (CGFloat)requiredRowHeightInTableView:(UITableView *)tableView { return 50; }
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier item:(Item*)item {
    self = [super initWithStyle:UITableViewStylePlain reuseIdentifier:reuseIdentifier];
    if (self) {
        self.item = item;
        self.textLabel.text = item.title;
    }
    return self;
}

@end

@interface FullFeedItemCell ()
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
@property (nonatomic, strong) NSMutableSet *mediaPlayers;

@end
@implementation FullFeedItemCell

- (void)linkPushed:(DTLinkButton *)button
{
	NSURL *URL = button.URL;
    
	if ([[UIApplication sharedApplication] canOpenURL:[URL absoluteURL]])
	{
        RequestBrowserOpen([URL absoluteURL]);
	}
	else
	{
#if 0
		if (![URL host] && ![URL path])
		{
            
			// possibly a local anchor link
			NSString *fragment = [URL fragment];
            
			if (fragment)
			{
                DTAttributedTextContentView *_textView = [button associatedValueForKey:"contentView"];
				[_textView scrollToAnchorNamed:fragment animated:NO];
			}
		}
#endif
	}
}


- (void)openTitleLink {
    RequestBrowserOpen([self.item.canonical objectAtIndex:0]);
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier item:(Item*)item
{
    self = [super initWithStyle:UITableViewStylePlain reuseIdentifier:reuseIdentifier];
    if (self) {
		_attributedTextContextView = [[DTAttributedTextContentView alloc] initWithFrame:CGRectZero];
		_attributedTextContextView.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        self.item = item;

        _titleView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_titleView setTitle:item.title forState:UIControlStateNormal];
        [_titleView setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _titleView.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_titleView sizeToFit];
        [_titleView addTarget:self action:@selector(openTitleLink) forControlEvents:UIControlEventTouchUpInside];

        _dateView = [[UILabel alloc] initWithFrame:CGRectZero];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDoesRelativeDateFormatting:YES];
        
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:item.published];
        
        _dateView.text = [dateFormatter stringFromDate:date];
        
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
        
        self.attributedTextContextView.shouldDrawImages = YES;
        self.attributedTextContextView.shouldDrawLinks = NO;
        self.attributedTextContextView.delegate = self;

    }
    return self;
}

#define TITLE_SPACING 10

- (void)layoutSubviews
{
	
	CGFloat neededContentHeight = [self requiredRowHeightInTableView:(UITableView *)self.superview];
	
	// after the first call here the content view size is correct
    CGFloat topOffset = _titleView.frame.size.height + TITLE_SPACING + 9;
    CGFloat bottomOffset =  _starBtn2.frame.size.height + TITLE_SPACING;
    CGFloat contentWidth = self.contentView.bounds.size.width - 10;
    CGRect titleFrame = _titleView.frame;
    CGRect dateFrame = _dateView.frame;
    
    titleFrame.origin.y = 9;
    titleFrame.size.width -= dateFrame.size.width - 10;
    titleFrame.origin.x = 10;
    _titleView.frame = titleFrame;
    dateFrame.origin.x = contentWidth - dateFrame.size.width - 5;
    dateFrame.origin.y = 9;
    _dateView.frame = dateFrame;

    CGRect star1Frame = _starBtn1.frame;
    star1Frame.origin.x = _titleView.frame.size.width + 10;
    _starBtn1.frame = star1Frame;

    CGFloat bottomY =  neededContentHeight - bottomOffset + 5;

    CGRect star2Frame = _starBtn2.frame;
    star2Frame.origin.x = 10;
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


    CGRect frame = CGRectMake(10, topOffset, contentWidth-80, neededContentHeight - topOffset - bottomOffset);
	
	// only change frame if width has changed to avoid extra layouting
	if (_attributedTextContextView.frame.size.width != frame.size.width)
	{
		_attributedTextContextView.frame = frame;
	}
    
    [super layoutSubviews];

}

- (void)setFrame:(CGRect)frame {
    frame.origin.x -= 20;
    frame.size.width += 40;
    [super setFrame:frame];
}

- (CGFloat)requiredRowHeightInTableView:(UITableView *)tableView
{
	
	CGFloat contentWidth = tableView.frame.size.width - 10;
    
	CGSize neededSize = [_attributedTextContextView suggestedFrameSizeToFitEntireStringConstraintedToWidth:contentWidth];
    CGFloat topOffset = _titleView.frame.size.height + TITLE_SPACING;
    CGFloat bottomOffset =  _starBtn2.frame.size.height + TITLE_SPACING;
	
	// note: non-integer row heights caused trouble < iOS 5.0
	return (int)(neededSize.height + topOffset + bottomOffset );
}

#pragma mark Properties

- (void)setHTMLString:(NSString *)html
{
	// we don't preserve the html but compare it's hash
	NSUInteger newHash = [html hash];
	
	if (newHash == _htmlHash)
	{
		return;
	}
	
	_htmlHash = newHash;

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


- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame
{
	NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
	
	NSURL *URL = [attributes objectForKey:DTLinkAttribute];
	NSString *identifier = [attributes objectForKey:DTGUIDAttribute];
	
	
	DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
	button.URL = URL;
	button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
	button.GUID = identifier;
    //[button associateValue:attributedTextContentView withKey:"contentView"];
    // we draw the contents ourselves
	button.attributedString = string;
	
	// make a version with different text color
	NSMutableAttributedString *highlightedString = [string mutableCopy];
	
	NSRange range = NSMakeRange(0, highlightedString.length);
	
	NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:(__bridge id)[UIColor redColor].CGColor forKey:(id)kCTForegroundColorAttributeName];
	
	
	[highlightedString addAttributes:highlightedAttributes range:range];
	
	button.highlightedAttributedString = highlightedString;
	
	// use normal push action for opening URL
	[button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
	
	// demonstrate combination with long press
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
	[button addGestureRecognizer:longPress];
	
	return button;
}

- (BOOL)videoView:(DTWebVideoView *)videoView shouldOpenExternalURL:(NSURL *)url {
    return NO;
}


- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame
{
	if (attachment.contentType == DTTextAttachmentTypeVideoURL)
	{
		NSURL *url = (id)attachment.contentURL;
		
		// we could customize the view that shows before playback starts
		UIView *grayView = [[UIView alloc] initWithFrame:frame];
		grayView.backgroundColor = [DTColor blackColor];
        
		// find a player for this URL if we already got one
		MPMoviePlayerController *player = nil;
		for (player in self.mediaPlayers)
		{
			if ([player.contentURL isEqual:url])
			{
				break;
			}
		}
		
		if (!player)
		{
			player = [[MPMoviePlayerController alloc] initWithContentURL:url];
			[self.mediaPlayers addObject:player];
		}
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_4_2
		NSString *airplayAttr = [attachment.attributes objectForKey:@"x-webkit-airplay"];
		if ([airplayAttr isEqualToString:@"allow"])
		{
			if ([player respondsToSelector:@selector(setAllowsAirPlay:)])
			{
				player.allowsAirPlay = YES;
			}
		}
#endif
		
		NSString *controlsAttr = [attachment.attributes objectForKey:@"controls"];
		if (controlsAttr)
		{
			player.controlStyle = MPMovieControlStyleEmbedded;
		}
		else
		{
			player.controlStyle = MPMovieControlStyleNone;
		}
		
		NSString *loopAttr = [attachment.attributes objectForKey:@"loop"];
		if (loopAttr)
		{
			player.repeatMode = MPMovieRepeatModeOne;
		}
		else
		{
			player.repeatMode = MPMovieRepeatModeNone;
		}
		
		NSString *autoplayAttr = [attachment.attributes objectForKey:@"autoplay"];
		if (autoplayAttr)
		{
			player.shouldAutoplay = YES;
		}
		else
		{
			player.shouldAutoplay = NO;
		}
		
		[player prepareToPlay];
		
		player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		player.view.frame = grayView.bounds;
		[grayView addSubview:player.view];
        
		return grayView;
	}
	else if (attachment.contentType == DTTextAttachmentTypeImage)
	{
        if(!attachment.contentURL) return nil;
		// if the attachment has a hyperlinkURL then this is currently ignored
        NINetworkImageView *imageView = [[NINetworkImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [imageView setSizeForDisplay:NO];
		imageView.delegate = self;
		if (attachment.contents)
		{
			imageView.image = attachment.contents;
		}
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView associateValue:attributedTextContentView withKey:"cell"];
        [imageView associateValue:attachment.contentURL withKey:"imageUrl"];
		
		// url for deferred loading
        [imageView setPathToNetworkImage:[attachment.contentURL absoluteString] ];
		
		// if there is a hyperlink then add a link button on top of this image
		if (attachment.hyperLinkURL)
		{
			// NOTE: this is a hack, you probably want to use your own image view and touch handling
			// also, this treats an image with a hyperlink by itself because we don't have the GUID of the link parts
			imageView.userInteractionEnabled = YES;
            //TODO: clickable image
			//DTLinkButton *button = (DTLinkButton *)[self attributedTextContentView:attributedTextContentView viewForLink:attachment.hyperLinkURL identifier:attachment.hyperLinkGUID frame:imageView.bounds];
			//[imageView addSubview:button];
		}
		
		return imageView;
	}
	else if (attachment.contentType == DTTextAttachmentTypeIframe)
	{
		frame.origin.x += 50;
		DTWebVideoView *videoView = [[DTWebVideoView alloc] initWithFrame:frame];
        videoView.delegate = self;
		videoView.attachment = attachment;
		
		return videoView;
	}
	else if (attachment.contentType == DTTextAttachmentTypeObject)
	{
	}
	
	return nil;
}
static const CGSize CGSizeZeroOne = {1,1};

#pragma mark DTLazyImageViewDelegate
- (void)networkImageView:(NINetworkImageView *)imageView didLoadImage:(UIImage *)image
{
    [self performBlock:^(id sender) {
        NSURL *url = [imageView associatedValueForKey:"imageUrl"];
        CGSize imageSize = image.size;
        DTAttributedTextContentView* _textView = [imageView associatedValueForKey:"cell"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
        BOOL ok = NO;
        CGRect iframe = imageView.frame;
        iframe.size = imageSize;
        for (DTTextAttachment *oneAttachment in [_textView.layoutFrame textAttachmentsWithPredicate:predicate])
        {
            CGSize iSize = imageSize;
            if(CGRectGetMaxX(iframe) > CGRectGetMaxX(_textView.frame)){
                iSize.width -= (CGRectGetMaxX(iframe) - CGRectGetMaxX(_textView.frame) - 5);
                iframe.size.width = iSize.width;
                imageView.frame = iframe;
            }
            if(CGSizeEqualToSize(oneAttachment.originalSize , CGSizeZero)){
                oneAttachment.originalSize = iSize;
                ok = YES;
            }
            if(CGSizeEqualToSize(oneAttachment.displaySize , CGSizeZeroOne)){
                if (!CGSizeEqualToSize(iSize, oneAttachment.displaySize))
                {
                    oneAttachment.displaySize = iSize;
                    ok = YES;
                }
            }
        }
        if(ok){
            UITableView* t = (UITableView*) self.superview;
            [t beginUpdates];
            [_textView relayoutText];
            [t endUpdates];
        }
        //        [self.tableView reloadData];
    } afterDelay:0.001];
}

@end
