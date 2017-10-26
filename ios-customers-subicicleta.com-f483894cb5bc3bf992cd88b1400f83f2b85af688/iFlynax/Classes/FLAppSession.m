//
//  FLAppSession.m
//  iFlynax
//
//  Created by Alex on 10/29/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLAppSession.h"

@interface FLAppSession ()
@property (nonatomic, strong) NSMutableDictionary *data;
@end

@implementation FLAppSession

+ (instancetype)sharedInstance {
	static FLAppSession *_sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[self alloc] init];
		_sharedInstance.data = [NSMutableDictionary dictionary];
	});
	return _sharedInstance;
}

+ (void)clearAll {
	[[FLAppSession sharedInstance].data removeAllObjects];
}

+ (void)removeItemWithKey:(NSString *)key {
	[[FLAppSession sharedInstance] removeItemWithKey:key];
}

+ (void)addItem:(id)value forKey:(NSString *)key {
	[[FLAppSession sharedInstance] addItem:value forKey:key];
}

+ (id)itemWithKey:(NSString *)key {
	return [[FLAppSession sharedInstance] itemWithKey:key];
}

#pragma mark - private methods

- (void)addItem:(id)value forKey:(NSString *)key {
	[self.data setObject:value forKey:key];
}

- (id)itemWithKey:(NSString *)key {
	return [self.data objectForKey:key];
}

- (void)removeItemWithKey:(NSString *)key {
	[self.data setValue:nil forKey:key];
}

@end
