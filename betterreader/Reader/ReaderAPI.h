//
// Created by User on 20/09/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//

@class Subscription;

typedef void (^auth_block_t)(BOOL success, BOOL closed);
typedef void (^operation_block_t)(NSError *);
typedef void (^json_process_block_t)(id);

#define kAuthScope  @"http://www.google.com/reader/api http://www.google.com/reader/atom"
#define kSubscriptionsUrl @"https://www.google.com/reader/api/0/subscription/list"
#define kUnreadCountsUrl @"https://www.google.com/reader/api/0/unread-count?allcomments=true&autorefresh=2&output=json"
#define kFeedItemsUrl @"https://www.google.com/reader/api/0/stream/contents/"
#define kUserInfoUrl @"https://www.google.com/reader/api/0/user-info"

#define kMaxItemsPerFetch 20
#define kAppName @"BetterReaderIOS"

@interface ReaderAPI : NSObject

+ (ReaderAPI*) sharedInstance;
- (BOOL) requiresAuthentication;
- (UIViewController *) authenticateWithBlock:(auth_block_t)block;
- (void)fetchSubscriptionsWithBlock:(operation_block_t)block;
- (void)fetchFeed:(Subscription*)subscription withBlock:(operation_block_t)block unreadOnly:(BOOL)unreadOnly;


@property(nonatomic,strong) NSDictionary* feeds; // feed by id
@property(nonatomic,strong) NSDictionary* labels; // feeds arrays by label

@end