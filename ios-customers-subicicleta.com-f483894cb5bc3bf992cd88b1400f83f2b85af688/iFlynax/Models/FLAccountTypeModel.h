//
//  FLAccountTypeModel.h
//  iFlynax
//
//  Created by Alex on 3/20/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLAccountTypeModel : NSObject
@property (nonatomic, strong, readonly) NSString *key;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) BOOL      autoLogin;
@property (nonatomic, assign, readonly) BOOL      emailConfirm;
@property (nonatomic, assign, readonly) BOOL      ownLocation;
@property (nonatomic, assign, readonly) BOOL      searchForm;
@property (nonatomic, assign, readonly) BOOL      page;

@property (nonatomic, strong) NSArray   *searchFormFields;

//
+ (instancetype)fromDictionary:(NSDictionary *)accountType;
@end
