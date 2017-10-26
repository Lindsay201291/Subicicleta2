//
//  FLAccount.h
//  iFlynax
//
//  Created by Alex on 10/20/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kUserStorageNewMessagesCountKey = @"userNewMessagesCount";

static NSString * const kUserStorageProfileKey    = @"userProfile";
static NSString * const kUserStorageStatisticsKey = @"userStatistics";
static NSString * const kUserStorageToken         = @"userToken";

static NSString * const kUserInfoId               = @"id";
static NSString * const kUserInfoMail             = @"mail";
static NSString * const kUserInfoType             = @"type";
static NSString * const kUserInfoUsernameKey      = @"username";
static NSString * const kUserInfoFullNameKey      = @"full_name";
static NSString * const kUserInfoListingsCountKey = @"listings_count";
static NSString * const kUserInfoThumbnailKey     = @"thumbnail";
static NSString * const kUserInfoStatisticsKey    = @"statistics";
static NSString * const kUserInfoAbilitiesKey     = @"abilities";

static NSInteger const kUserWebsiteVisitor = -1;

typedef NS_ENUM(NSInteger, FLAccountLoginMode) {
    FLAccountLoginModeUsername = 0,
    FLAccountLoginModeEmail    = 1,
    FLAccountLoginModeBoth     = 2
};

@interface FLAccount : NSObject
@property (nonatomic, assign, readonly) NSInteger    userId;
@property (nonatomic, assign, readonly) NSString     *username;
@property (nonatomic, assign, readonly) NSString     *fullName;
@property (nonatomic, strong, readonly) NSArray      *statistics;
@property (nonatomic, strong, readonly) NSDictionary *userInfo;

@property (nonatomic, assign) NSInteger listingsCount;
@property (nonatomic, assign) NSInteger newMessageCount;

+ (instancetype)loggedUser;

+ (NSInteger)userId;
+ (NSString *)username;
+ (NSString *)fullName;
+ (NSArray *)statistics;
+ (NSInteger)listingsCount;
+ (NSInteger)newMessageCount;

+ (BOOL)isLogin;
+ (BOOL)canPostAds;
+ (id)userInfo:(NSString *)key;
+ (BOOL)loginModeIs:(FLAccountLoginMode)mode;

- (void)saveSessionData:(NSDictionary *)data;
- (void)resetSessionData;
- (void)reloadLocalVariables;
@end
