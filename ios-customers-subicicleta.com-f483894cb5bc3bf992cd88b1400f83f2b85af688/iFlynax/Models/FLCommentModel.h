//
//  FLCommentModel.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 9/21/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

typedef NS_ENUM(NSInteger, FLCommentStatus) {
    FLCommentStatusActive,
    FLCommentStatusPending,
    FLCommentStatusOther
};

@interface FLCommentModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *author;
@property (nonatomic) NSInteger rating;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *date;
@property (nonatomic) FLCommentStatus status;

+ (instancetype)fromDictionary:(NSDictionary *)data;
@end
