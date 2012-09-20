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

@interface FeedsViewController()
{
    NSCache* cellCache;
}
@property(nonatomic,strong) NITableViewModel* model;
@end

@implementation FeedsViewController
@synthesize feed = _feed;
@synthesize model;


- (DTAttributedTextCell *)tableView:(UITableView *)tableView preparedCellForIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"cellIdentifier";    
	if (!cellCache)
		cellCache = [[NSCache alloc] init];
	
	// workaround for iOS 5 bug
	NSString *key = [NSString stringWithFormat:@"%d-%d", indexPath.section, indexPath.row];	
	DTAttributedTextCell *cell = [cellCache objectForKey:key];    
	if (!cell)
	{
        cell = [[DTAttributedTextCell alloc] initWithReuseIdentifier:cellIdentifier accessoryType:UITableViewCellAccessoryNone];
        cell.attributedTextContextView.shouldDrawImages = YES;
        cell.attributedTextContextView.delegate = self;
        cell.attributedTextContextView.shouldDrawLinks = NO;
		[cellCache setObject:cell forKey:key];
	}
	
    Item *i = [self.model objectAtIndexPath:indexPath];
    [cell setHTMLString:i.content.content];
	return cell;
}

- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    return [self tableView:tableView preparedCellForIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	DTAttributedTextCell *cell = (DTAttributedTextCell *)[self tableView:tableView preparedCellForIndexPath:indexPath];
    
	return [cell requiredRowHeightInTableView:tableView];
}

- (void) setFeed:(Feed*)f
{
    [cellCache removeAllObjects];
    _feed = f;
    self.model = [[NITableViewModel alloc] initWithListArray:self.feed.items delegate:self];
    self.tableView.dataSource = self.model;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
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


- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame
{
	if (attachment.contentType == DTTextAttachmentTypeVideoURL)
	{
		NSURL *url = (id)attachment.contentURL;
		
		// we could customize the view that shows before playback starts
		UIView *grayView = [[UIView alloc] initWithFrame:frame];
		grayView.backgroundColor = [DTColor blackColor];
#if 0		
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
#endif		
		return grayView;
	}
	else if (attachment.contentType == DTTextAttachmentTypeImage)
	{
		// if the attachment has a hyperlinkURL then this is currently ignored
		DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
		imageView.delegate = self;
		if (attachment.contents)
		{
			imageView.image = attachment.contents;
		}
		
		// url for deferred loading
		imageView.url = attachment.contentURL;
		
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

- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
	NSURL *url = lazyImageView.url;
	CGSize imageSize = size;
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
    
	for (int i=0;i<[self.model tableView:self.tableView numberOfRowsInSection:0];i++){
        NSIndexPath* ip = [NSIndexPath indexPathForRow:i inSection:0];
        DTAttributedTextCell* cell = [self tableView:self.tableView preparedCellForIndexPath:ip];
        // update all attachments that matchin this URL (possibly multiple images with same size)
        DTAttributedTextContentView* _textView = cell.attributedTextContextView;
        for (DTTextAttachment *oneAttachment in [_textView.layoutFrame textAttachmentsWithPredicate:pred])
        {
            oneAttachment.originalSize = imageSize;
            
            if (!CGSizeEqualToSize(imageSize, oneAttachment.displaySize))
            {
                oneAttachment.displaySize = imageSize;
            }
        }
        // redo layout
        // here we're layouting the entire string, might be more efficient to only relayout the paragraphs that contain these attachments
        [_textView relayoutText];
    }
    [self.tableView reloadData];
}

@end