//
//  FLAdShortDetailsModel.h
//  iFlynax
//
//  Created by Alex on 6/5/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLAdShortDetailsModel : NSObject
@property (assign, nonatomic, readonly) NSInteger lId; // Listing ID
@property (assign, nonatomic, readonly) NSInteger sellerId;
@property (assign, nonatomic, readonly) NSInteger photosCount;

@property (strong, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSString *subTitle;
@property (strong, nonatomic, readonly) NSString *price;

@property (strong, nonatomic, readonly) NSDictionary *location;
@property (strong, nonatomic, readonly) NSURL *thumbnail;
@property (assign, nonatomic, readonly) BOOL featured;

+ (instancetype)fromDictionary:(NSDictionary *)data;
- (instancetype)initFromDictionary:(NSDictionary *)data;
@end
