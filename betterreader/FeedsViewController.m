//
// Created by eli on 9/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FeedsViewController.h"
#import "Feed.h"
#import "Item.h"
#import "FeedItemCell.h"
#import "Utils.h"
#import "NICellBackgrounds.h"


@interface FeedsViewController(){
    NSCache* cellCache;
    NIGroupedCellBackground* cellBg;
    NIGroupedCellBackground* cellBgRead;
    BOOL showAsList;
    BOOL moreItemsRequested;
}

@property(nonatomic,strong) NIMutableTableViewModel* model;
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
    //TODO: for each cell, stop media
    /*
	// stop all playing media
	for (MPMoviePlayerController *player in self.mediaPlayers)
	{
		[player stop];
	}
*/
	[super viewWillDisappear:animated];
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
        moreItemsRequested = NO;
        showAsList = NO; //TODO: make persistent
        self.toolbar = [[FeedViewToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        self.toolbar.delegate = self;
        CGRect tableFrame = CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.height - 40);
        self.tableViewFull = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStyleGrouped];
        self.tableViewList = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];
        cellBg = [[NIGroupedCellBackground alloc]init];
        cellBgRead = [[NIGroupedCellBackground alloc]init];
        cellBgRead.shadowColor = [UIColor blueColor];
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
		[cellCache setObject:cell forKey:key];
	}
	
	return cell;
}

- (UITableViewCell*) makeLoadingCell:(UITableView*)tableView {
    static NSString* ident = @"LoadingCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
        UIActivityIndicatorView*act = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = act;
        cell.textLabel.text = NSLocalizedString(@"Loading...", nil);
        [act sizeToFit];
        [act startAnimating];
    }
    if(!moreItemsRequested){ // don't request load more twice
       // [[NSNotificationCenter defaultCenter] postNotificationName:kMoreItemsRequested object:nil];
        moreItemsRequested = YES;
    }
    return cell;
}

- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    if( [[self.model objectAtIndexPath:indexPath] isKindOfClass:[NSDictionary class]] )
        return [self makeLoadingCell:tableView];
    return [self tableView:tableView preparedCellForIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( [[self.model objectAtIndexPath:indexPath] isKindOfClass:[NSDictionary class]] )
        return 40;
	
    IFeedItemCell *cell = [self tableView:tableView preparedCellForIndexPath:indexPath];
    
	return [cell requiredRowHeightInTableView:tableView];
}

- (void) setFeed:(Feed*)f
{
    moreItemsRequested = NO;
    [cellCache removeAllObjects];
    self.tableViewList.dataSource = nil;
    self.tableViewFull.dataSource = nil;
    _feed = f;
    self.title = f.title;
    NSMutableArray* feed_items = [NSMutableArray array];
    //TODO: handle 'no items' case.
    ((Item*)self.feed.items[0]).isRead = YES;
    for (Item* i in self.feed.items) {
        [feed_items addObject:@""];
        [feed_items addObject:i];
    }
    if(self.feed.continuation){
        [feed_items addObject:@""];
        [feed_items addObject:@{@"object" :@"Loading.."}];
    }
    self.model = [[NIMutableTableViewModel alloc] initWithSectionedArray:feed_items delegate:self];
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
    id o = [self.model objectAtIndexPath:indexPath];
    if([o isKindOfClass:[NSDictionary class]])return;
    Item* i = o;
    if(i.isRead)
        [cellBgRead tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
        else
        [cellBg tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
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

- (void)moreFeedItemsLoaded
{
    [self.currentTableView beginUpdates];
    Item* lastItem = [self.model objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.currentTableView numberOfSections]-2]];
    NSArray* loadIp = [self.model removeObjectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.currentTableView numberOfSections]-1]];
    [self.currentTableView deleteRowsAtIndexPaths:loadIp withRowAnimation:UITableViewRowAnimationAutomatic];
    int lasti = [self.feed.items indexOfObject:lastItem];
    for(int i=lasti+1;i<self.feed.items.count;i++)
    {
        NSIndexSet* is = [self.model addSectionWithTitle:@""];
        [self.model addObject:[self.feed.items objectAtIndex:i]];
        [self.currentTableView insertSections:is withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    if(self.feed.continuation){
        NSIndexSet* is = [self.model addSectionWithTitle:@""];
        [self.model addObject:@{@"object" :@"Loading.."}];
        [self.currentTableView insertSections:is withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.currentTableView endUpdates];
}



@end