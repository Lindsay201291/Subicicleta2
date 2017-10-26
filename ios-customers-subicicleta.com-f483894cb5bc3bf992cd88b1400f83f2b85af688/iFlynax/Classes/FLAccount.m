//
//  FLAccount.m
//  iFlynax
//
//  Created by Alex on 10/20/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLAccount.h"

static NSInteger FLConvertLoginModeFromString(NSString *modeString) {
    if ([modeString isEqualToString:@"username"]) {
        return FLAccountLoginModeUsername;
    }
    else if ([modeString isEqualToString:@"email"]) {
        return FLAccountLoginModeEmail;
    }
    return -1;
}

@implementation FLAccount

+ (instancetype)loggedUser {
	static FLAccount *_loggedUser = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_loggedUser = [[self alloc] init];
		[_loggedUser reloadLocalVariables];
	});
	return _loggedUser;
}

+ (BOOL)isLogin {
	return [[FLAccount loggedUser] isLogin];
}

+ (BOOL)canPostAds {
    NSArray *abilities = [FLAccount loggedUser].userInfo[kUserInfoAbilitiesKey];
    if (!abilities.count) {
        return NO;
    }

    __block BOOL allow = NO;
    [abilities enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([FLListingTypes withKey:obj] != nil) {
            allow = YES;
            *stop = YES;
        }
    }];
    return allow;
}

+ (id)userInfo:(NSString *)key {
	return [[FLAccount loggedUser] userInfo:key];
}

+ (BOOL)loginModeIs:(FLAccountLoginMode)mode {
    NSString *modeString = [FLConfig withKey:@"account_login_mode"];
    FLAccountLoginMode configMode = FLConvertLoginModeFromString(modeString);

    if (modeString != nil && configMode == mode) {
        return YES;
    }
    return NO;
}

#pragma mark - Helpers/getters

+ (NSInteger)userId {
	return [FLAccount loggedUser].userId;
}

+ (NSString *)username {
	return [FLAccount loggedUser].username;
}

+ (NSString *)fullName {
	return [FLAccount loggedUser].fullName;
}

+ (NSArray *)statistics {
	return [FLAccount loggedUser].statistics;
}

+ (NSInteger)listingsCount {
	return [FLAccount loggedUser].listingsCount;
}

+ (NSInteger)newMessageCount {
    return [FLAccount loggedUser].newMessageCount;
}

#pragma mark -

- (BOOL)isLogin {
	return _userInfo != nil ?: NO;
}

- (id)userInfo:(NSString *)key {
	if (_userInfo != nil && _userInfo[key] != nil)
		return _userInfo[key];
	return nil;
}

- (void)reloadLocalVariables {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	// assign user profile details
	_userInfo = [defaults objectForKey:kUserStorageProfileKey];
	// assign user statistics
	_statistics = [defaults objectForKey:kUserStorageStatisticsKey];

    _userId   = [_userInfo[kUserInfoId] integerValue];
    _username = _userInfo[kUserInfoUsernameKey];
    _fullName = _userInfo[kUserInfoFullNameKey];

    _listingsCount   = [_userInfo[kUserInfoListingsCountKey] integerValue];
    _newMessageCount = [defaults integerForKey:kUserStorageNewMessagesCountKey];
    
}

- (void)setNewMessageCount:(NSInteger)newMessageCount {
    _newMessageCount = MAX(0, newMessageCount);
    [[NSUserDefaults standardUserDefaults] setInteger:_newMessageCount forKey:kUserStorageNewMessagesCountKey];
}

// login / refresh profile details
- (void)saveSessionData:(NSDictionary *)data {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults setObject:[data objectForKey:@"profile"] forKey:kUserStorageProfileKey];
	[defaults setObject:[data objectForKey:@"statistics"] forKey:kUserStorageStatisticsKey];
    [defaults setInteger:FLTrueInteger(data[@"new_messages"]) forKey:kUserStorageNewMessagesCountKey];

	// save user Token generated through website
	if (data[@"token"] != nil)
		[defaults setObject:data[@"token"] forKey:kDefaultKeyAccountToken];

	[defaults synchronize];

	[self reloadLocalVariables];
}

// logout
- (void)resetSessionData {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:nil forKey:kUserStorageProfileKey];
	[defaults setValue:nil forKey:kDefaultKeyAccountToken];
	[defaults setValue:nil forKey:kUserStorageStatisticsKey];
    [defaults setValue:nil forKey:kUserStorageNewMessagesCountKey];
	[defaults synchronize];

    [[FLFavorites sharedInstance] clearFavorites];

	[self reloadLocalVariables];
}

@end
