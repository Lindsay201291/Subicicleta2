//
//  FLSellerApiItemFactory.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 6/5/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLSellerApiItemFactory.h"

@implementation FLSellerApiItemFactory

+ (instancetype)sharedInstance {
    static FLSellerApiItemFactory *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
    });
    return _sharedInstance;
}

init

@end
