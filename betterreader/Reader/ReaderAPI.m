//#define REQ_DEBUG


#import "ReaderAPI.h"
#import "OAuth2Secrets.h"
#import "Subscription.h"
#import "AFXMLDomRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "Utils.h"
#import "NimbusCore+Additions.h"
#import "Feed.h"

@interface ReaderAPI ()
{
}
@property(nonatomic, strong) GTMOAuth2Authentication* authentication;
@property(nonatomic, strong) NSString* userId;
@end

@implementation ReaderAPI

- (id)init {
    self = [super init];
    if (self) {
        self.authentication = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                    clientID:kClientID
                                                                                clientSecret:kClientSecret];
        self.userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
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
    return ![self.authentication canAuthorize] || self.userId == nil;
}

- (NSString*) applyCommonParamsToUrl:(NSString*)url {
    NSInteger timestamp = [[NSDate date] timeIntervalSince1970] * 1000 * -1;
    NSString* ts = [NSString stringWithFormat:@"%d", timestamp];
    return [url stringByAddingQueryDictionary:[NSDictionary dictionaryWithObjectsAndKeys:ts,@"ck",kAppName,@"client", nil]];
}

- (void)performJSONFetchUrl:(NSString*)furl withBlock:(operation_block_t)block withProcessBlock:(json_process_block_t)json_process
{
    NSURL* url = [NSURL URLWithString:[self applyCommonParamsToUrl: furl]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    [self.authentication authorizeRequest:request completionHandler:^(NSError *error) {
        if(error)
        {
            block(error);
        }else{
#ifdef REQ_DEBUG
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSData* d = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:[furl rangeOfString:@"unread-count"].length>0 ?@"req2":@"req3" ofType:@""]];
                
                json_process([NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingAllowFragments error:nil]);
                block(nil);
            });
            return;
#endif
            AFJSONRequestOperation* operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        NSLog(@"%@",descriptionForRequest(request));
                        json_process(JSON);
                        block(nil);
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                        NSLog(@"%@",descriptionForRequest(request));
                        block(error);                                                                                                  block(error);
                    }];
            [operation start];
        }
    }];

}

- (void)fetchFeed:(Subscription*)subscription withBlock:(operation_block_t)block unreadOnly:(BOOL)unreadOnly
{
    NSString* furl = [NSString stringWithFormat:@"%@%@?r=n&n=%d%@", kFeedItemsUrl, [subscription.subscribtionId stringByAddingPercentEscapesForURLParameter], kMaxItemsPerFetch, unreadOnly ? [NSString stringWithFormat:@"&xt=user/%@/state/com.google/read" , self.userId] : @"", nil];
    [self performJSONFetchUrl:furl withBlock:block withProcessBlock:^(id data) {
        subscription.feed = [Feed instanceFromDictionary:data];
    }];
}

- (void)fetchUnreadCountsWithBlock:(operation_block_t)block
{
    [self performJSONFetchUrl:kUnreadCountsUrl withBlock:block withProcessBlock:^(id data) {
        for(NSDictionary* unreadCount in data[@"unreadcounts"]){
                Subscription* s = self.feeds[unreadCount[@"id"]];
                if(s){
                    s.unreadCount = [unreadCount[@"count"] intValue];
                    s.newestItemTimestampUsec = [unreadCount[@"newestItemTimestampUsec"] longLongValue];
                }
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
                    [me fetchUnreadCountsWithBlock: block];
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
    for(id zz in [document.rootElement.children [0] children]){
        Subscription * su = [[Subscription alloc] initWithNode: zz];
        [fds setValue:su forKey:su.subscribtionId];
        NSArray *curLabels = su.labels.count > 0 ? su.labels : [NSArray arrayWithObject:kUnlabeledItems];
        for (NSString* l in curLabels) {
            NSMutableArray* lfeeds = lbls[l];
            if (!lfeeds) {
                lfeeds = [NSMutableArray array];
                lbls[l] = lfeeds;
            }
            [lfeeds addObject:su];
        }
    }
    self.feeds = fds;
    self.labels = lbls;
}

- (GTMOAuth2ViewControllerTouch *)authenticateWithBlock:(auth_block_t)block {
    __block ReaderAPI* me = self;
    GTMOAuth2ViewControllerTouch *viewController = [GTMOAuth2ViewControllerTouch controllerWithScope:kAuthScope clientID:kClientID clientSecret:kClientSecret keychainItemName:kKeychainItemName
    completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
        me.authentication = auth;
        if(error){
            block(NO, [error code] == kGTMOAuth2ErrorWindowClosed);
        }else {
            [me performJSONFetchUrl:kUserInfoUrl withBlock:^(NSError *error) {
                block(error == nil, NO);
            } withProcessBlock:^(id o) {
                self.userId = [o valueForKey:@"userId"];
                [[NSUserDefaults standardUserDefaults] setValue:self.userId forKey:@"userId"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }];
        }
    }];
    return viewController;
}


@end