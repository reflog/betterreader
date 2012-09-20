//
//  Item.h
//  
//
//  Created by Eli Yukelzon on 9/20/12.
//  Copyright (c) 2012 Kodermonkeys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemContent.h"
@class GDataXMLNode;

@interface Item : NSObject {
    NSArray *canonical;
    ItemContent *content;
    NSString *crawlTimeMsec;
    BOOL isReadStateLocked;
    NSString *itemId;
    long long published;
    long long timestampUsec;
    NSString *title;
    long long updated;
}

@property (nonatomic, copy) NSArray *canonical;
@property (nonatomic, strong) ItemContent *content;
@property (nonatomic, copy) NSString *crawlTimeMsec;
@property (nonatomic, assign) BOOL isReadStateLocked;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, assign) long long published;
@property (nonatomic, assign) long long timestampUsec;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) long long updated;

+ (Item *)instanceFromDictionary:(NSDictionary *)aDictionary;

@end
