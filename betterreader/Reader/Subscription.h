//
//  Subscription.h
//  betterreader
//
//  Created by Sir Reflog on 9/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface Subscription : NSObject

- (id) initWithNode:(GDataXMLNode*)node;
@property (nonatomic, strong) NSString *subscribtionId;
@property (nonatomic, strong) NSString *htmlUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *sortId;
@property (nonatomic, strong)  NSArray *labels;
@property (nonatomic)        long long firstItemSec;
@property (nonatomic)        long long newestItemTimestampUsec;
@property (nonatomic)              int unreadCount;
@end
