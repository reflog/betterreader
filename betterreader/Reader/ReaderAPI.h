//
// Created by User on 20/09/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//

typedef void (^auth_block_t)(BOOL success, BOOL closed);
typedef void (^operation_block_t)(NSError *);

#define kAuthScope  @"http://www.google.com/reader/api http://www.google.com/reader/atom"
#define kSubscriptionsUrl @"https://www.google.com/reader/api/0/subscription/list"
#define kUnreadCountsUrl @"https://www.google.com/reader/api/0/unread-count?allcomments=true&autorefresh=2&output=json"
#define kAppName @"BetterReaderIOS"
@interface ReaderAPI : NSObject

+ (ReaderAPI*) sharedInstance;
- (BOOL) requiresAuthentication;
- (UIViewController *) authenticateWithBlock:(auth_block_t)block;
- (void)fetchSubscriptionsWithBlock:(operation_block_t)block;


@property(nonatomic,strong) NSDictionary* feeds; // feed by id
@property(nonatomic,strong) NSDictionary* labels; // feeds arrays by label

@end