//
//  SubscriptionsViewController.m
//  betterreader
//
//  Created by Sir Reflog on 9/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SubscriptionsViewController.h"
#import "Subscription.h"
#import "Utils.h"
#import "NIBadgeView.h"
#import "ReaderAPI.h"
#import "FeedsViewController.h"
#import "NetworkDrawRectBlockCell.h"
#import "AppDelegate.h"
#import "NimbusCore.h"
#import "NimbusModels.h"

@interface SubscriptionsViewController ()
{
    operation_block_t subscriptionFetchResultBlock;
    BOOL unreadOnly;
}
@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) NITableViewModel* model;
@property (nonatomic, readwrite, retain) NITableViewActions* actions;
@property (nonatomic, strong) NICellFactory * cellFactory;
@end

@implementation SubscriptionsViewController
@synthesize model, actions;
@synthesize feedsViewController = _feedsViewController;
@synthesize cellFactory = _cellFactory;


- (void)buildSubscriptionModel
{
    NITableViewActionBlock tapAction = ^BOOL(id object, UIViewController *controller) {
        NIDrawRectBlockCellObject* obj = object;
        Subscription * s = [obj.object valueForKey:@"object"];
        [self.feedsViewController setLoadingFeed:YES];
        [[ReaderAPI sharedInstance] fetchFeed:s withBlock:^(NSError *e) {
            //TODO: handle error
            if(!e){
                self.feedsViewController.feed = s.feed;
                [self.feedsViewController setLoadingFeed:NO];
            }
        } unreadOnly:unreadOnly];
        return YES;
    };  

    NICellDrawRectBlock drawCellBlock = [NetworkDrawRectBlockCell block];
    NSMutableArray* modelData = [NSMutableArray array];
    NSNumber* favIconSize = [NSNumber numberWithInt:16];
    for (NSString* label in [[ReaderAPI sharedInstance].labels allKeys]) {
        [modelData addObject:[label isEqualToString:kUnlabeledItems] ? @"" : label];
        int c = 0;
        for(Subscription * s in [[ReaderAPI sharedInstance].labels valueForKey:label]){
            if(s.unreadCount > 0 || !unreadOnly) {
                NSString* host = [[NSURL URLWithString:s.htmlUrl ] host];
                NSString* favurl = [NSString stringWithFormat:@"http://www.google.com/s2/favicons?domain=%@", 
                                    host,  nil];
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        s.title, @"text",
                        favurl, @"url",
                        favIconSize, @"width",
                        favIconSize, @"height",
                        [NSNumber numberWithInt:s.unreadCount], @"badgeValue",
                        s, @"object", nil];

                [modelData addObject:[self.actions attachNavigationAction:tapAction toObject:[NIDrawRectBlockCellObject objectWithBlock:drawCellBlock object:dict]]];
                c++;
            }
        }
        if(c == 0)
            [modelData removeLastObject];
    }
    _cellFactory = [[NICellFactory alloc] init];
    [_cellFactory mapObjectClass:[NIDrawRectBlockCellObject class]
                     toCellClass:[NetworkDrawRectBlockCell class]];
    self.model = [[NITableViewModel alloc] initWithSectionedArray:modelData delegate:_cellFactory];
    self.tableView.dataSource = self.model;
    [self.tableView reloadData];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [self initWithTitle:NSLocalizedString(@"Please wait", nil) subtitle:NSLocalizedString(@"Loading your subscriptions...", nil) image:TKEmptyViewImageStopwatch];
    if (self) {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [self.view addSubview:self.tableView];
        [self.view sendSubviewToBack:self.tableView];
        self.actions = [[NITableViewActions alloc] initWithController:self];
    }
    return self;
}
- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.frame;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Feeds", nil);
    unreadOnly = YES;
    __block UIBarButtonItem* btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Unread", nil) style:UIBarButtonItemStylePlain handler:^(id sender) {
        unreadOnly = !unreadOnly;
        btn.title = unreadOnly ? NSLocalizedString(@"Unread", nil) : NSLocalizedString(@"All", nil);
        [self buildSubscriptionModel];
    }];
    self.navigationItem.rightBarButtonItem = btn;
    __block id me = self;
    subscriptionFetchResultBlock = ^(NSError *error) {
        //TODO: errors?
        [me setLoading:NO];

        [me buildSubscriptionModel];
    };
    [self setLoading:YES];
    self.tableView.delegate = self.actions;

    if([[ReaderAPI sharedInstance] requiresAuthentication])
        [self authenticateTry];
    else
        [[ReaderAPI sharedInstance] fetchSubscriptionsWithBlock:subscriptionFetchResultBlock];
}

- (void)authenticateTry {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    GTMOAuth2ViewControllerTouch *authController = [[ReaderAPI sharedInstance] authenticateWithBlock:^(BOOL success, BOOL closed) {
        if(closed || !success){
            NSString* msg = NSLocalizedString(@"Cannot continue without signing in. Please try again!", nil);
            UIAlertView *alert = [UIAlertView alertViewWithTitle:NSLocalizedString(@"Error", nil) message:msg];
            [alert setCancelButtonWithTitle:NSLocalizedString(@"OK", nil) handler:^{
                [self authenticateTry];
            }];
            [alert show];
        } else {
            [[ReaderAPI sharedInstance] fetchSubscriptionsWithBlock:subscriptionFetchResultBlock];
        }
    }];
    authController.title = NSLocalizedString(@"BetterReader Sign in", nil);
    authController.popViewBlock = ^(){
        [appDelegate.splitViewController dismissModalViewControllerAnimated:YES];
    };

    UINavigationController *authNavigationController = [[UINavigationController alloc] initWithRootViewController:authController];
    authNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [appDelegate.splitViewController  presentModalViewController:authNavigationController animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NIIsSupportedOrientation(toInterfaceOrientation);
}
@end
