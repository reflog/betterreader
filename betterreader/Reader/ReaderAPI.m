#import "ReaderAPI.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "OAuth2Secrets.h"
#import "Subscription.h"
#import "AFXMLDomRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "Utils.h"
#import "NimbusCore+Additions.h"

@interface ReaderAPI ()
{
}
@property(nonatomic, strong) GTMOAuth2Authentication* authentication;
@end

@implementation ReaderAPI

@synthesize authentication, feeds, labels;

- (id)init {
    self = [super init];
    if (self) {
        self.authentication = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                    clientID:kClientID
                                                                                clientSecret:kClientSecret];
    }

    return self;
}

+ (ReaderAPI*) sharedInstance
{
    static dispatch_once_t predicate = 0;
    __strong static ReaderAPI* _sharedObject = nil;
    dispatch_once(&predicate, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (BOOL)requiresAuthentication {
    return ![self.authentication canAuthorize];
}

- (NSString*) applyCommonParamsToUrl:(NSString*)url {
    NSInteger timestamp = [[NSDate date] timeIntervalSince1970] * 1000 * -1;
    NSString* ts = [NSString stringWithFormat:@"%d", timestamp];
    return [url stringByAddingQueryDictionary:[NSDictionary dictionaryWithObjectsAndKeys:ts,@"ck",kAppName,@"client", nil]];
}

- (void) applyUnredCountsWithData:(NSDictionary*) data 
{
    for(NSDictionary* unreadCount in [data valueForKey:@"unreadcounts"]){
        Subscription* s = [self.feeds valueForKey: [unreadCount valueForKey:@"id"]];
        if(s){
            s.unreadCount = [[unreadCount valueForKey:@"count"] intValue];
            s.newestItemTimestampUsec = [[unreadCount valueForKey:@"newestItemTimestampUsec"] longLongValue];
        }
    }
}

- (void)fetchUnreadCountsWithBlock:(operation_block_t)block
{
    NSURL* url = [NSURL URLWithString:[self applyCommonParamsToUrl: kUnreadCountsUrl]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    __block id me = self;
    [self.authentication authorizeRequest:request completionHandler:^(NSError *error) {
        if(error)
        {
            block(error);
        }else{
            AFJSONRequestOperation* operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                NSLog(@"%@",descriptionForRequest(request));
                [me applyUnredCountsWithData: JSON];
                block(nil);
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                NSLog(@"%@",descriptionForRequest(request));
                block(error);
            }];
            [operation start];
        }
    }];
}

- (void)fetchSubscriptionsWithBlock:(operation_block_t)block
{
    NSURL* url = [NSURL URLWithString:[self applyCommonParamsToUrl: kSubscriptionsUrl]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    __block id me = self;
    [self.authentication authorizeRequest:request completionHandler:^(NSError *error) {
        if(error)
        {
            block(error);
        }else{
            __block AFXMLDomRequestOperation* operation = [AFXMLDomRequestOperation XMLDocumentRequestOperationWithRequest:request
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, GDataXMLDocument *document) {
                NSLog(@"%@",descriptionForRequest(request));
                if(!document)
                    block([operation error]);
                else{
                    [me parseSubscriptions:document];
                    [self fetchUnreadCountsWithBlock: block];                    
                }
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, GDataXMLDocument *document) {
                NSLog(@"%@",descriptionForRequest(request));
                block(error);
            }];


            [operation start];
        }
    }];
}


- (void)parseSubscriptions:(GDataXMLDocument *)document
{
    NSMutableDictionary* fds = [NSMutableDictionary dictionary];
    NSMutableDictionary* lbls = [NSMutableDictionary dictionary];
    for(id zz in [[document.rootElement.children objectAtIndex:0] children]){
        Subscription * su = [[Subscription alloc] initWithNode: zz];
        [fds setValue:su forKey:su.subscribtionId];
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
}

- (UIViewController *)authenticateWithBlock:(auth_block_t)block {
    GTMOAuth2ViewControllerTouch *viewController = [GTMOAuth2ViewControllerTouch controllerWithScope:kAuthScope clientID:kClientID clientSecret:kClientSecret keychainItemName:kKeychainItemName completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
        self.authentication = auth;
        if(error){
            block(YES, [error code] == kGTMOAuth2ErrorWindowClosed);
        }else {
            block(NO, NO);
        }
    }];
    return viewController;
}


@end