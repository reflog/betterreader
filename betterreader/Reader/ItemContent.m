//
//  ItemContent.m
//  
//
//  Created by Eli Yukelzon on 9/20/12.
//  Copyright (c) 2012 Kodermonkeys. All rights reserved.
//

#import "ItemContent.h"

@implementation ItemContent

@synthesize content;
@synthesize direction;

+ (ItemContent *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    ItemContent *instance = [[ItemContent alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary
{

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self setValuesForKeysWithDictionary:aDictionary];

}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"direction"]) {
        self.direction = [value isEqualToString:@"ltr"] ;
    } else {
        [super setValue:value forKey:key];
    }
    
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    @try {
        [super setValue:value forUndefinedKey:key];
    }
    @catch (NSException *exception) {
    }
}

@end
