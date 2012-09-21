//
//  Item.m
//  
//
//  Created by Eli Yukelzon on 9/20/12.
//  Copyright (c) 2012 Kodermonkeys. All rights reserved.
//

#import "Item.h"
#import "ItemContent.h"
#import "GDataXMLNode.h"

@implementation Item

@synthesize canonical;
@synthesize content;
@synthesize crawlTimeMsec;
@synthesize isReadStateLocked;
@synthesize itemId;
@synthesize published;
@synthesize timestampUsec;
@synthesize title;
@synthesize updated;
@synthesize author;

+ (Item *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    Item *instance = [[Item alloc] init];
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
    if ([key isEqualToString:@"canonical"]) {
        
        if ([value isKindOfClass:[NSArray class]])
        {
            
            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                [myMembers addObject:[valueMember valueForKey:@"href"]];
            }
            
            self.canonical = myMembers;
            
        }
        
    }else if ([key isEqualToString:@"content"] || [key isEqualToString:@"summary"]) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            self.content = [ItemContent instanceFromDictionary:value];
        }
    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"itemId"];
    } else if ([key isEqualToString:@"published"] || [key isEqualToString:@"timestampUsec"] || [key isEqualToString:@"updated"]) {
        [super setValue:[NSNumber numberWithLongLong:[value longLongValue]] forUndefinedKey:key]; 
    } else {
        @try {
            [super setValue:value forUndefinedKey:key];
        }
        @catch (NSException *exception) {
        }

    }

}


@end
