//
//  Subscribtion.h
//  betterreader
//
//  Created by Sir Reflog on 9/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface Subscribtion : NSObject

- (id) initWithNode:(GDataXMLNode*)node;

@property (nonatomic, strong) NSString *htmlUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *sortid;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, strong) NSNumber *firstItemSec;
@end
