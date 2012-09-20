//
//  Feed.h
//  
//
//  Created by Eli Yukelzon on 9/20/12.
//  Copyright (c) 2012 Kodermonkeys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Feed : NSObject {
    NSString *continuation;
    NSString *descriptionText;
    bool direction;
    NSString *feedId;
    NSArray *items;
    NSString *title;
    long long updated;
}

@property (nonatomic, copy) NSString *continuation;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, assign) bool direction;
@property (nonatomic, copy) NSString *feedId;
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) long long updated;

+ (Feed *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
