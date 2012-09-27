//
// Created by eli on 9/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FeedsViewController.h"
#import "Feed.h"
#import "Item.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "FeedItemCell.h"
#import "Utils.h"
#import "NINetworkImageView.h"

static const CGSize CGSizeZeroOne = {1,1};

@interface FeedsViewController() <NINetworkImageViewDelegate> {
    NSCache* cellCache;
    NSMutableSet *mediaPlayers;
}
@property(nonatomic,strong) NITableViewModel* model;
@property (nonatomic, strong) NSMutableSet *mediaPlayers;

@end

@implementation FeedsViewController
@synthesize feed = _feed;
@synthesize model, mediaPlayers;

- (void)viewWillDisappear:(BOOL)animated;
{
	// stop all playing media
	for (MPMoviePlayerController *player in self.mediaPlayers)
	{
		[player stop];
	}

	[super viewWillDisappear:animated];
}

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

- (FeedItemCell *)tableView:(UITableView *)tableView preparedCellForIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"cellIdentifier";    
	if (!cellCache)
		cellCache = [[NSCache alloc] init];
	
    Item *item = [self.model objectAtIndexPath:indexPath];
	// workaround for iOS 5 bug
	NSString *key = [NSString stringWithFormat:@"%d-%d", indexPath.section, indexPath.row];	
	FeedItemCell *cell = [cellCache objectForKey:key];    
	if (!cell)
	{
        cell = [[FeedItemCell alloc] initWithReuseIdentifier:cellIdentifier item:item];
        cell.attributedTextContextView.shouldDrawImages = YES;
        cell.attributedTextContextView.delegate = self;
        cell.attributedTextContextView.shouldDrawLinks = NO;
		[cellCache setObject:cell forKey:key];
	}
	
	return cell;
}

- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    return [self tableView:tableView preparedCellForIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	FeedItemCell *cell = [self tableView:tableView preparedCellForIndexPath:indexPath];
    
	return [cell requiredRowHeightInTableView:tableView];
}

- (void) setFeed:(Feed*)f
{
    [cellCache removeAllObjects];
    self.tableView.dataSource = nil;
    self.mediaPlayers = nil;
    _feed = f;
    self.title = f.title;
    self.model = [[NITableViewModel alloc] initWithListArray:self.feed.items delegate:self];
    self.tableView.dataSource = self.model;
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
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
		// somecolorparameter has a HTML color
		UIColor *someColor = [UIColor colorWithHTMLName:[attachment.attributes objectForKey:@"somecolorparameter"]];
		
		UIView *someView = [[UIView alloc] initWithFrame:frame];
		someView.backgroundColor = someColor;
		someView.layer.borderWidth = 1;
		someView.layer.borderColor = [UIColor blackColor].CGColor;
		
		return someView;
	}
	
	return nil;
}

#pragma mark DTLazyImageViewDelegate
- (void)networkImageView:(NINetworkImageView *)imageView didLoadImage:(UIImage *)image
{
    [self performBlock:^(id sender) {
        NSURL *url = [imageView associatedValueForKey:"imageUrl"];
        CGSize imageSize = image.size;
        DTAttributedTextContentView* _textView = [imageView associatedValueForKey:"cell"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
        BOOL ok = NO;
        for (DTTextAttachment *oneAttachment in [_textView.layoutFrame textAttachmentsWithPredicate:predicate])
        {
            if(CGSizeEqualToSize(oneAttachment.originalSize , CGSizeZero)){
                oneAttachment.originalSize = imageSize;
                ok = YES;
            }            
            if(CGSizeEqualToSize(oneAttachment.displaySize , CGSizeZeroOne)){
                if (!CGSizeEqualToSize(imageSize, oneAttachment.displaySize))
                {
                   oneAttachment.displaySize = imageSize;
                    ok = YES;
                }
            }
        }
        if(ok){
            [self.tableView beginUpdates];
            [_textView relayoutText];
            [self.tableView endUpdates];
        }
    } afterDelay:0.001];
}


@end