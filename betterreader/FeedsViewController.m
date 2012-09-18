//
//  FeedsViewController.m
//  betterreader
//
//  Created by Sir Reflog on 9/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedsViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "AFXMLRequestOperation.h"
#import "GDataXMLNode.h"
#import "Subscribtion.h"
#import "OAuth2Secrets.h"
@interface FeedsViewController ()
@property(nonatomic, strong) GTMOAuth2Authentication* authentication;
- (void) fetchSubscribtions;
@end

@implementation FeedsViewController
@synthesize authentication, feeds, labels;

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    }

#define kAuthScope  @"http://www.google.com/reader/api http://www.google.com/reader/atom"
#define kSubscribtionsUrl @"https://www.google.com/reader/api/0/subscription/list"


- (NSString *)descriptionForRequest:(NSURLRequest*)request
{
    __block NSMutableString *displayString = [NSMutableString stringWithFormat:@"%@\nRequest\n-------\ncurl -X %@", 
                                              [[NSDate date] descriptionWithLocale:[NSLocale currentLocale]],
                                              [request HTTPMethod]];
    
    [[request allHTTPHeaderFields] enumerateKeysAndObjectsUsingBlock:^(id key, id val, BOOL *stop)
     {
         [displayString appendFormat:@" -H \"%@: %@\"", key, val];
     }];
    
    [displayString appendFormat:@" \"%@\"",  [request.URL absoluteString]];
    
    if ([[request HTTPMethod] isEqualToString:@"POST"]) {
        NSString *bodyString = [[NSString alloc] initWithData:[request HTTPBody]
                                                      encoding:NSUTF8StringEncoding] ;
        [displayString appendFormat:@" -d \"%@\"", bodyString];        
    }
    
    return displayString;
}

- (void) fetchSubscribtions
{
    [self setIsLoading:YES];
    NSURL* url = [NSURL URLWithString:kSubscribtionsUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    self.authentication.shouldAuthorizeAllRequests = YES;
    [self.authentication authorizeRequest:request completionHandler:^(NSError *error) {
        if(error)
        {
            //
        }else{
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSError* e = nil;
                GDataXMLDocument* doc = [[GDataXMLDocument alloc] initWithData:operation.responseData  options:0 error:&e];
                if(!e){
                    NSMutableArray* fds = [NSMutableArray array];
                    NSMutableDictionary* lbls = [NSMutableDictionary dictionary];
                    for(id zz in [[doc.rootElement.children objectAtIndex:0] children]){
                        Subscribtion * su = [[Subscribtion alloc] initWithNode: zz];
                        [fds addObject:su];
                        for (NSString* l in su.labels) {
                            NSMutableArray* lfeeds = [lbls valueForKey:l];
                            if (!lfeeds) {
                                lfeeds = [NSMutableArray array];
                                [lbls setValue:lfeeds forKey:l];
                            }
                            [lfeeds addObject:su];
                        }
                    }
                    self.feeds = fds;
                    self.labels = lbls;
                }else {
                    NSLog(@"%@",e);
                }
                //
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@\n%@",error,[self descriptionForRequest:request]);
            }];
            
            [operation start];    
        }
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.authentication = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                 clientID:kClientID
                                                             clientSecret:kClientSecret];
    BOOL isSignedIn = [self.authentication canAuthorize];
    if(!isSignedIn)
    {
    
        GTMOAuth2ViewControllerTouch *viewController = [GTMOAuth2ViewControllerTouch controllerWithScope:kAuthScope clientID:kClientID clientSecret:kClientSecret keychainItemName:kKeychainItemName completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
            self.authentication = auth;
            if(error){
                if([error code] == kGTMOAuth2ErrorWindowClosed){
                    
                }
            }else {
                [self fetchSubscribtions];
            }
        }];
        [[self navigationController] pushViewController:viewController animated:YES];	
    }else {
        [self fetchSubscribtions];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
