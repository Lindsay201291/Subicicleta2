//
//  FLMessage.m
//  iFlynax
//
//  Created by Alex on 4/8/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import "FLMessage.h"

@implementation FLMessage
@synthesize attributes, text, date, fromMe, media, thumbnail, type;

- (id)init {
    self = [super init];
    if (self) {
        self.date = [NSDate date];
    }
    return self;
}

@end
