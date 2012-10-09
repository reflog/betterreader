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
#import "NICellBackgrounds.h"

static const CGSize CGSizeZeroOne = {1,1};

@interface FeedsViewController() <NINetworkImageViewDelegate> {
    NSCache* cellCache;
    NIGroupedCellBackground* cellBg;
    BOOL showAsList;
}

@property(nonatomic,strong) NITableViewModel* model;
@property (nonatomic, strong) NSMutableSet *mediaPlayers;
@property(nonatomic,strong) FeedViewToolbar *toolbar;
@property(nonatomic,strong) UITableView* tableViewList;
@property(nonatomic,strong) UITableView* tableViewFull;
@property(readonly) UITableView* currentTableView;
@end

@implementation FeedsViewController
- (UITableView*)currentTableView {
    return showAsList ? self.tableViewList : self.tableViewFull;
}
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

- (IFeedItemCell *)tableView:(UITableView *)tableView preparedCellForIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"cellIdentifier";    
	if (!cellCache)
		cellCache = [[NSCache alloc] init];
	
    Item *item = [self.model objectAtIndexPath:indexPath];
	// workaround for iOS 5 bug
	NSString *key = [NSString stringWithFormat:@"%d-%d-%d", indexPath.section, indexPath.row, showAsList?0:1];
	IFeedItemCell *cell = [cellCache objectForKey:key];
    
	if (!cell)
	{
        cell = [IFeedItemCell cellWithReuseIdentifier:cellIdentifier item:item listView:showAsList];
        if(!showAsList){
            ((FullFeedItemCell*)cell).attributedTextContextView.delegate = self;
        }
		[cellCache setObject:cell forKey:key];
	}
	
	return cell;
}

- (void)setLoadingFeed:(BOOL)loading
{
    [super setLoading:loading];
    if(loading){
        self.emptyView.titleLabel.text = NSLocalizedString(@"Please wait", nil);
        self.emptyView.subtitleLabel.text = NSLocalizedString(@"Loading your feed...", nil);
        [self.emptyView setEmptyImage:TKEmptyViewImageStopwatch];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [self initWithTitle:NSLocalizedString(@"Welcome to Better Reader", nil) subtitle:NSLocalizedString(@"Please pick a feed on your left", nil) image:TKEmptyViewImageStar];
    if (self) {
        showAsList = NO; //TODO: make persistent
        self.toolbar = [[FeedViewToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        self.toolbar.delegate = self;
        CGRect tableFrame = CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.height - 40);
        self.tableViewFull = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStyleGrouped];
        self.tableViewList = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];
        cellBg = [[NIGroupedCellBackground alloc]init];
        self.tableViewList.allowsSelection = NO;
        self.tableViewFull.allowsSelection = NO;
        self.tableViewFull.delegate = self;
        self.tableViewList.delegate = self;
        [self.view addSubview:self.toolbar];
        if(showAsList)
            [self.view addSubview:self.tableViewList];
        else
            [self.view addSubview:self.tableViewFull];
        [self setLoading:YES];
        self.title = NSLocalizedString(@"Better Reader", nil);

        
    }
    return self;
    
}

- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    return [self tableView:tableView preparedCellForIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	IFeedItemCell *cell = [self tableView:tableView preparedCellForIndexPath:indexPath];
    
	return [cell requiredRowHeightInTableView:tableView];
}

- (void) setFeed:(Feed*)f
{
    [cellCache removeAllObjects];
    self.tableViewList.dataSource = nil;
    self.tableViewFull.dataSource = nil;
    self.mediaPlayers = nil;
    _feed = f;
    self.title = f.title;
    NSMutableArray* feed_items = [NSMutableArray array];
    for (Item* i in self.feed.items) {
        [feed_items addObject:@""];
        [feed_items addObject:i];
    }
    self.model = [[NITableViewModel alloc] initWithSectionedArray:feed_items delegate:self];
    self.tableViewList.dataSource = self.model;
    [self.tableViewList reloadData];
    [self.tableViewList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    self.tableViewFull.dataSource = self.model;
    [self.tableViewFull reloadData];
    [self.tableViewFull scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGRect f = CGRectMake(0, 0, self.view.bounds.size.width, 40);
    CGRect tableFrame = CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.height-40);
    self.toolbar.frame = f;
    self.tableViewFull.frame = tableFrame;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cellBg tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
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
            [self.currentTableView beginUpdates];
            [_textView relayoutText];
            [self.currentTableView endUpdates];
        }
        //        [self.tableView reloadData];
    } afterDelay:0.001];
}

- (void)refreshClicked {

}

- (void)viewModeChanged:(BOOL)showAll {

}

- (void)displayModeChanged:(BOOL)showList {
    __block NSIndexPath* curpath = self.currentTableView.indexPathsForVisibleRows[0];
    UIView* fromv = self.currentTableView;
    showAsList = showList;
    [self.currentTableView reloadData];
    [UIView transitionFromView:fromv toView:self.currentTableView duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        [self.currentTableView scrollToRowAtIndexPath:curpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }];
}

- (void)nextFeedItemClicked {
    NSIndexPath*ipold = [self.currentTableView indexPathsForVisibleRows][0];
    if(ipold.section+1 >= [self.currentTableView numberOfSections]) return;
    NSIndexPath*ip = [NSIndexPath indexPathForRow:0 inSection:ipold.section+1];
    [self.currentTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)prevFeedItemClicked {
    NSIndexPath*ipold = [self.currentTableView indexPathsForVisibleRows][0];
    if(ipold.section-1 < 0) return;
    NSIndexPath*ip = [NSIndexPath indexPathForRow:0 inSection:ipold.section-1];
    [self.currentTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];

}

- (void)sortModeChanged:(SortMode)mode {

}

- (void)unsubscribeClicked {

}

- (void)renameClicked {

}




@end