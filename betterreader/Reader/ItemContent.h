//
//  ItemContent.h
//  
//
//  Created by Eli Yukelzon on 9/20/12.
//  Copyright (c) 2012 Kodermonkeys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemContent : NSObject {
}

@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) BOOL direction;

+ (ItemContent *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
