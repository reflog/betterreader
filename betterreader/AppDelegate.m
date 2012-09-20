//
//  AppDelegate.m
//  betterreader
//
//  Created by Sir Reflog on 9/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "SubscriptionsViewController.h"
#import "FeedsViewController.h"
@implementation AppDelegate

@synthesize window = _window;
@synthesize splitViewController;
@synthesize popoverViewController = _popoverViewController;
@synthesize subsNav, feedsNav;

- (void)splitViewController: (MGSplitViewController *)svc willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = NSLocalizedString(@"Books", nil);
    [self.splitViewController.detailViewController.navigationItem setLeftBarButtonItem:barButtonItem animated:NO];
    self.popoverViewController = pc;
}


// called when the view is shown again in the split view, invalidating the button and popover controller
//
- (void)splitViewController: (MGSplitViewController *)svc willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.splitViewController.detailViewController.navigationItem setLeftBarButtonItem:nil animated:NO];
    self.popoverViewController = nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.splitViewController = [[MGSplitViewController alloc] init];
    self.splitViewController.delegate = self;
    SubscriptionsViewController *subscriptions = [[SubscriptionsViewController alloc] init];
    FeedsViewController*feeds = [[FeedsViewController alloc] init];
    self.subsNav = [[UINavigationController alloc] initWithRootViewController:subscriptions];
    self.feedsNav = [[UINavigationController alloc] initWithRootViewController:feeds];
    subscriptions.feedsViewController = feeds;
    self.splitViewController.showsMasterInPortrait = YES;
    self.splitViewController.allowsDraggingDivider = YES;
    self.splitViewController.dividerStyle = MGSplitViewDividerStylePaneSplitter;
    self.splitViewController.masterViewController = subsNav;
    self.splitViewController.detailViewController = feedsNav;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window addSubview:self.splitViewController.view];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
