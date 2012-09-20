//
//  FeedsViewController.m
//  betterreader
//
//  Created by Sir Reflog on 9/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedsViewController.h"
#import "Subscription.h"
#import "Utils.h"
#import "NIBadgeView.h"
#import "ReaderAPI.h"

@interface FeedsViewController ()
{
    operation_block_t subscriptionFetchResultBlock;
    BOOL unreadOnly;
}
@property(nonatomic,strong) NITableViewModel* model;
@property (nonatomic, readwrite, retain) NITableViewActions* actions;
@end

@implementation FeedsViewController
@synthesize model, actions;

- (UITableViewCell *)tableViewModel: (NITableViewModel *)tableViewModel
                   cellForTableView: (UITableView *)tableView
                        atIndexPath: (NSIndexPath *)indexPath
                         withObject: (id)object {
    // A pretty standard implementation of creating table view cells follows.
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"row"];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                       reuseIdentifier: @"row"] ;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[NIBadgeView alloc] initWithFrame: CGRectZero];
    }
    Subscription * s = [object objectForKey:@"value"];
    NIBadgeView *badgeView = (NIBadgeView *) cell.accessoryView;
    badgeView.backgroundColor = [UIColor whiteColor];
    badgeView.text = [NSString stringWithFormat:@"%d", s.unreadCount];;
    [badgeView sizeToFit];
    cell.textLabel.text = s.title;
    
    return cell;
}


- (void)buildSubscriptionModel
{
    NITableViewActionBlock tapAction = ^BOOL(id object, UIViewController *controller) {
        ShowMessage(NSLocalizedString(@"Bla", nil), [object description]);
        return YES;
    };  

    
    NSMutableArray* modelData = [NSMutableArray array];
    for (NSString* label in [[ReaderAPI sharedInstance].labels allKeys]) {
        [modelData addObject:label];
        int c = 0;
        for(Subscription * s in [[ReaderAPI sharedInstance].labels valueForKey:label]){
            if(s.unreadCount > 0 || !unreadOnly) {
                [modelData addObject:[self.actions attachTapAction:tapAction toObject:[NSDictionary dictionaryWithObject:s forKey:@"value"]]];
                c++;
            }
        }
        if(c == 0)
            [modelData removeLastObject];
    }
    self.model = [[NITableViewModel alloc] initWithSectionedArray:modelData delegate:self];
    self.tableView.dataSource = self.model;
    [self.tableView reloadData];
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
        [me setIsLoading:NO];

        [me buildSubscriptionModel];
    };
    [self setIsLoading:YES];
    self.actions = [[NITableViewActions alloc] initWithController:self];
    self.tableView.delegate = self.actions;

    if([[ReaderAPI sharedInstance] requiresAuthentication])
        [self authenticateTry];
    else
        [[ReaderAPI sharedInstance] fetchSubscriptionsWithBlock:subscriptionFetchResultBlock];
}

- (void)authenticateTry {
    [[self navigationController] pushViewController:[[ReaderAPI sharedInstance] authenticateWithBlock:^(BOOL success, BOOL closed) {
            if(closed || !success){
                NSString* msg = closed ? NSLocalizedString(@"Cannot continue without logging in. Please try again!", nil) : NSLocalizedString(@"Invalid credentials!", nil);
                UIAlertView *alert = [UIAlertView alertViewWithTitle:NSLocalizedString(@"Error", nil) message:msg];
                [alert setCancelButtonWithTitle:NSLocalizedString(@"OK", nil) handler:^{
                    [self authenticateTry];
                }];
            } else {
                [[ReaderAPI sharedInstance] fetchSubscriptionsWithBlock:subscriptionFetchResultBlock];
            }
        }] animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NIIsSupportedOrientation(toInterfaceOrientation);
}
@end
