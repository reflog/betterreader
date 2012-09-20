//
//  Subscription.m
//  betterreader
//
//  Created by Sir Reflog on 9/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Subscription.h"
#import "Feed.h"

@implementation Subscription

@synthesize htmlUrl, title, sortId, labels, firstItemSec, unreadCount, newestItemTimestampUsec, subscribtionId;
@synthesize feed = _feed;


- (id) initWithNode:(GDataXMLNode*)node
{
    self = [super init];
    if (self) {
        for(GDataXMLElement* el in [node children]){
            NSString* name = [[el attributeForName:@"name"] stringValue];
            NSString* ev = [el stringValue];
            if([name isEqualToString: @"htmlUrl"]) 
                self.htmlUrl = ev;
            else if([name isEqualToString: @"id"]) 
                self.subscribtionId = ev;
            else if([name isEqualToString: @"title"]) 
                self.title = ev;
            else if([name isEqualToString: @"sortid"]) 
                self.sortId = ev;
            else if([name isEqualToString: @"categories"])
            {
                NSMutableArray* lbls = [NSMutableArray array];
                for(GDataXMLElement* zsel in [el children]){
                    for(GDataXMLElement* sel in [zsel children]){
                        NSString* sname = [[sel attributeForName:@"name"] stringValue];
                        NSString* sev = [sel stringValue];
                        if([sname isEqualToString: @"label"]) 
                            [lbls addObject:sev];
                    }
                }
                self.labels = lbls;
            }
            else if([name isEqualToString: @"firstitemmsec"]) 
                self.firstItemSec = [ev longLongValue];
        }
    }
    return self;
}

//=========================================================== 
// - (NSArray *)keyPaths
//
//=========================================================== 
- (NSArray *)keyPaths
{
    NSArray *result = [NSArray arrayWithObjects:
                       @"htmlUrl",
                       @"title",
                       @"sortId",
                       @"labels",
                       @"firstItemSec",
                       @"newestItemTimestampUsec",
                       @"subscribtionId",
                       @"unreadCount",
                       nil];
    
    return result;
}

//=========================================================== 
// - (NSString *)descriptionForKeyPaths
//
//=========================================================== 
- (NSString *)descriptionForKeyPaths 
{
    NSMutableString *desc = [NSMutableString string];
    [desc appendString:@"\n\n"];
    [desc appendFormat:@"Class name: %@\n", NSStringFromClass([self class])];
    
    NSArray *keyPathsArray = [self keyPaths];
    for (NSString *keyPath in keyPathsArray) {
        [desc appendFormat: @"%@: %@\n", keyPath, [self valueForKey:keyPath]];
    }
    
    return [NSString stringWithString:desc];
}
- (NSString *)description 
{
    return [self descriptionForKeyPaths]; 
}


@end

