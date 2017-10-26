//
//  FLUserDefaults.m
//  iFlynax
//
//  Created by Alex on 6/17/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLUserDefaults.h"

static NSString * const kPointedToDomainKey = @"com.flynax.pointedToDomain";

@implementation FLUserDefaults

+ (instancetype)sharedInstance {
    static FLUserDefaults *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

+ (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:value forKey:defaultName];
    [defaults synchronize];
}

+ (NSInteger)integerForKey:(NSString *)forKey {
    return [[NSUserDefaults standardUserDefaults] integerForKey:forKey] ?: 0;
}

+ (BOOL)isPreloadType:(FLPreloadType)type {
    return [FLUserDefaults integerForKey:kPreloadTypeConfigsKey] == type;
}

+ (BOOL)appPointedToDomain {
    return [[FLUserDefaults sharedInstance] appPointedToDomain];
}

+ (NSString *)pointedDomain {
    return [[FLUserDefaults sharedInstance] pointedDomain];
}

+ (void)pointToDomain:(NSString *)domain {
    return [[FLUserDefaults sharedInstance] pointToDomain:domain];
}

- (BOOL)appPointedToDomain {
    if (!kLabeledSolution) {
        return YES;
    }
    return ([[NSUserDefaults standardUserDefaults] valueForKey:kPointedToDomainKey] != nil);
}

- (NSString *)pointedDomain {
    return [[NSUserDefaults standardUserDefaults] valueForKey:kPointedToDomainKey];
}

- (void)pointToDomain:(NSString *)domain {
    [flynaxAPIClient sharedInstance].apiDestination = nil;
    [[NSUserDefaults standardUserDefaults] setValue:domain forKey:kPointedToDomainKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
