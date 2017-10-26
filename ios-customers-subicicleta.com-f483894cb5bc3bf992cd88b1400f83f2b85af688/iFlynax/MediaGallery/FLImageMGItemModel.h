//
//  FLImageMGItemModel.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/19/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(NSInteger, FLImageMGItemType) {
    FLImageMGItemTypePhoto,
    FLImageMGItemTypeMain
};

@interface FLImageMGItemModel : NSObject

@property (readonly, nonatomic) NSInteger imageId;
@property (copy, readonly, nonatomic) NSString *thumbnailUrl;
@property (copy, readonly, nonatomic) NSString *typeString;
@property (copy, nonatomic) NSString *imageDescription;

@property (readonly, getter=isNew, nonatomic) BOOL newModel;
@property (getter=isPrimary, nonatomic) BOOL primary;
@property (nonatomic) FLImageMGItemType type;
@property (strong, nonatomic) ALAsset *asset;

/**
 *	Convert data from dictionary to a model
 *	@param data - init dictionary
 *	@return listing image model
 */
+ (instancetype)fromDictionary:(NSDictionary *)data;

@end
