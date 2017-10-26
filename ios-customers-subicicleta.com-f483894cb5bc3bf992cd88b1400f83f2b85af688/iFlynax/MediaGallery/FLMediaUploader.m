//
//  FLMediaUploader.m
//  iFlynax
//
//  Created by Alex on 10/22/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLMediaUploader.h"
#import "FLImageMGItemModel.h"

@interface FLMediaUploader () {
    NSArray   *_itemsToUpload;
    NSInteger _uploadedItemsCount;
    NSInteger _nextIndexToUpload;
    NSInteger _listingId;
}
@property (copy) dispatch_block_t compretionBlock;
@end

@implementation FLMediaUploader

+ (instancetype)sharedInstance {
    static FLMediaUploader *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

+ (void)uploadItems:(NSArray *)items forListingId:(NSInteger)listingId
     withCompletion:(dispatch_block_t)completionBlock
{
    return [[FLMediaUploader sharedInstance] uploadItems:items forListingId:listingId
                                          withCompletion:completionBlock];
}

- (void)uploadItems:(NSArray *)items forListingId:(NSInteger)listingId
     withCompletion:(dispatch_block_t)completionBlock
{
    self.compretionBlock = completionBlock;
    _uploadedItemsCount  = 0;
    _nextIndexToUpload   = 0;
    _itemsToUpload       = items;
    _listingId           = listingId;

    [self uploadItemAtIndex:_nextIndexToUpload];
}

- (void)uploadItemAtIndex:(NSInteger)index {
    BOOL lastItem = (index == _itemsToUpload.count - 1);

    FLImageMGItemModel *item = _itemsToUpload[index];
    NSInteger thumbQuality   = [FLConfig integerWithKey:@"img_quality"];

    NSDictionary *params = @{@"cmd"        : kApiItemRequests_savePicture,
                             @"lid"        : @(_listingId),
                             @"pid"        : @(item.imageId),
                             @"primary"    : @(item.primary),
                             @"desc"       : FLCleanString(item.imageDescription),
                             @"orientation": @(item.asset.defaultRepresentation.orientation),
                             @"last"       : @(lastItem)};

    if (item.newModel) {
        [flynaxAPIClient uploadWithBlock:^(id<AFMultipartFormData> formData) {
            UIImage *fullImage = [self fullResolutionImageForAsset:item.asset];
            UIImage *scaledImage = [self cropImageIfNecessary:fullImage];

            [formData appendPartWithFileData:UIImageJPEGRepresentation(scaledImage, thumbQuality)
                                        name:@"image"
                                    fileName:@"file.jpg"
                                    mimeType:@"image/jpeg"];
        }
        toApiItem:kApiItemRequests parameters:params
        progress:^(NSProgress *uploadProgress) {
            float progress = ((float) uploadProgress.completedUnitCount / (float) uploadProgress.totalUnitCount);

            if (progress >= 1.0f) {
                [FLProgressHUD showWithStatus:FLLocalizedString(@"processing")];
            }
            else {
                NSString *message = [self uploadinMessageAtIndex:index+1];
                [FLProgressHUD showProgress:progress status:message];
            }
        }
        completion:^(NSDictionary *response, NSError *error) {
            if (!error && [response isKindOfClass:NSDictionary.class] && FLTrueBool(response[@"success"])) {
                if (!lastItem) {
                    [self uploadItemAtIndex:_nextIndexToUpload];
                }
                _uploadedItemsCount++;
            }
            else {
                //TODO: save error or st. to future purpose
            }

            if (lastItem && self.compretionBlock) {
                self.compretionBlock();
            }
        }];
    }
    else {
        NSString *message = [self uploadinMessageAtIndex:index+1];
        [FLProgressHUD showWithStatus:message];

        [flynaxAPIClient
         postApiItem:kApiItemRequests
         parameters:params
         completion:^(NSDictionary *response, NSError *error) {
             if (!error && [response isKindOfClass:NSDictionary.class] && FLTrueBool(response[@"success"])) {
                 if (!lastItem) {
                     [self uploadItemAtIndex:_nextIndexToUpload];
                 }
                 _uploadedItemsCount++;
             }

             if (lastItem && self.compretionBlock) {
                 [FLProgressHUD dismiss];
                 self.compretionBlock();
             }
         }];
    }

    // increase if errors
    _nextIndexToUpload++;
}

- (NSString *)uploadinMessageAtIndex:(NSInteger)index {
    return F(FLLocalizedString(@"dialog_saving_picture"), (int)index, (int)_itemsToUpload.count);
}

- (UIImage *)cropImageIfNecessary:(UIImage *)image {
    return [image imageScaledToFitSize:CGSizeMake(900, 600)];
}

- (UIImage *)fullResolutionImageForAsset:(ALAsset *)asset{
    return [UIImage imageWithCGImage:[asset.defaultRepresentation fullResolutionImage]];
}

@end
