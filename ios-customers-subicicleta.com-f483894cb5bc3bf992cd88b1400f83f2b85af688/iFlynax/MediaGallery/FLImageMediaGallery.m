//
//  FLImageMediaGallery.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/16/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLImageMediaGallery.h"
#import "FLImageMGAddControl.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CCActionSheet.h"
#import "FLTextField.h"
#import "FLImageMGItemModel.h"

@interface FLImageMediaGallery ()<UIAlertViewDelegate>

@property (copy, nonatomic) NSMutableArray *thumbnails;
@property (copy, nonatomic) NSMutableArray *urls;
@property (strong, nonatomic) FLImageMGItemCell *primatyItem;
@property (strong, nonatomic) UIAlertView *alertViewDesc;
@property (weak, nonatomic) UITextField *alertDescField;
@property (strong, nonatomic) UIImage *loadingImage;
@end

@implementation FLImageMediaGallery {
    NSString *_okTitle;
}

@dynamic selectedItemCell;

- (void)setup {
    [super setup];
    
    _thumbnails = [NSMutableArray array];
    _urls       = [NSMutableArray array];
    
    self.itemDeterminantSize =  CGSizeMake(240, 240);
    self.itemsSpacing  = 15.0f;
    self.addControlPos = FLMediaGalleryAddPosBelow;
    
    // action sheet init
    [self actionCancelItemTitle:FLLocalizedString(@"button_cancel")];
    [self actionAddItemWithTitle:FLLocalizedString(@"button_action_make_primary")];
    [self actionAddItemWithTitle:FLLocalizedString(@"button_action_edit_description")];
    [self actionAddDestructiveItemWithTitle:FLLocalizedString(@"button_remove")];
    
    _okTitle = FLLocalizedString(@"button_ok");
}

- (UIImage *)loadingImage {
    if (_loadingImage == nil) {
        _loadingImage = [UIImage imageNamed:@"loading45x45"];
    }
    return _loadingImage;
}

- (void)nibsOrClassesCollectionViewRegistration {
    
    UINib *addNib = [UINib nibWithNibName:@"FLImageMGAddControl" bundle:nil];
    [self registerNibForAddControl:addNib];
    
    UINib *cellNib = [UINib nibWithNibName:@"FLImageMGItemCell" bundle:nil];
    [self registerNibForItem:cellNib];
}

- (void)customizeAddControl:(FLImageMGAddControl *)control atIndexPath:(NSIndexPath *)indexPath {
    control.imageView.image = [UIImage imageNamed:@"add_photo"];
}

- (void)customizeItemCell:(FLImageMGItemCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (cell.data.isNew) {
        
        ALAsset  *asset = cell.data.asset;
        NSString   *url = asset.defaultRepresentation.url.absoluteString;
        NSInteger urlIndex = [_urls indexOfObject:url];
        cell.primary = cell.data.isPrimary;
        if (urlIndex == NSNotFound) {
            [_urls addObject:url];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *thumbnail = [self properAssetThumbnail:asset fromSource:FLIMGAssetThumbSourceScreenImage];
                [_thumbnails addObject:thumbnail];
                [self imageThumbnail:thumbnail forCell:cell];
            });
        }
        else if (cell.imageView.image != _thumbnails[urlIndex]) {
            [self imageThumbnail:_thumbnails[urlIndex] forCell:cell];
        }
    }
    else if (![cell.data.thumbnailUrl isEmpty]) {
        NSURL *thumbnailURL = [NSURL URLWithString:cell.data.thumbnailUrl];
        NSMutableURLRequest *thumbnailRequest = [NSMutableURLRequest requestWithURL:thumbnailURL];
        [thumbnailRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        [cell.imageView setImageWithURLRequest:thumbnailRequest
                                placeholderImage:self.loadingImage
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                             if (image) {
                                                 UIImage *scaledImage = [image imageScaledToFitSize:cell.imageView.size];

                                                 [_thumbnails addObject:image];
                                                 [_urls addObject:cell.data.thumbnailUrl];
                                                 
                                                 [self imageThumbnail:scaledImage forCell:cell];
                                             }
                                         } failure:nil];

        cell.primary = cell.data.isPrimary;
        
        if (cell.primary) {
            _primatyItem = cell;
        }
    }
}

- (void)loadFromAssets:(NSArray *)assets {
    for (ALAsset *asset in assets) {
        FLImageMGItemModel *imageModel = [FLImageMGItemModel new];
        imageModel.asset = asset;
        [self addItem:imageModel];
    }
}

- (void)loadFromArray:(NSArray *)items {
    for (NSDictionary *info in items) {
        FLImageMGItemModel *imageModel = [FLImageMGItemModel fromDictionary:info];
        [self addItem:imageModel updateCollection:NO];
    }
}

- (void)handleActionAtIndex:(NSInteger)index {
    if (index == 1) {
        self.primatyItem = self.selectedItemCell;
    }
    else if (index == 2) {
        [self.alertViewDesc show];
        self.alertDescField.text = self.selectedItemCell.data.imageDescription;
    }
    else if (index == 3) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:self.selectedItemCell];
        [self deleteItemAtIndexPath:indexPath];
    }
    [super handleActionAtIndex:index];
}

- (void)imageThumbnail:(UIImage *)thumbnail forCell:(FLImageMGItemCell *)cell {
    if (cell.imageView.contentMode != UIViewContentModeScaleAspectFill) {
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    cell.imageView.image = thumbnail;
}

- (void)setPrimatyItem:(FLImageMGItemCell *)item {
    
    if (item == _primatyItem) {
        return;
    }
    
    _primatyItem.primary = NO;
    _primatyItem.data.primary = NO;
    item.primary = YES;
    item.data.primary = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageGallery:didChangePrimaryItemCell:toItemCell:)]) {
        [(id)self.delegate imageGallery:self didChangePrimaryItemCell:_primatyItem toItemCell:item];
    }
    
    _primatyItem = item;
}

- (UIAlertView *)alertViewDesc {
    if (!_alertViewDesc) {
        _alertViewDesc = [[UIAlertView alloc] initWithTitle:FLLocalizedString(@"alert_title_edit_description")
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:FLLocalizedString(@"button_cancel")
                                          otherButtonTitles:_okTitle, nil];
        _alertViewDesc.alertViewStyle = UIAlertViewStylePlainTextInput;
        _alertDescField = [_alertViewDesc textFieldAtIndex:0];
    }
    return _alertViewDesc;
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([_alertViewDesc buttonTitleAtIndex:buttonIndex] == _okTitle && ![_alertDescField.text isEqualToString:self.selectedItemCell.data.imageDescription]) {
        self.selectedItemCell.data.imageDescription = _alertDescField.text;
        if (self.delegate && [self.delegate respondsToSelector:@selector(imageGallery:itemDidChangeDescription:)]) {
            [(id)self.delegate imageGallery:self itemDidChangeDescription:self.selectedItemCell];
        }
    }
}

- (UIImage *)properAssetThumbnail:(ALAsset *)asset fromSource:(FLIMGAssetThumbSource)source {
    UIImage *thumbnail;
    
    CGRect thumbRect = CGRectMake(0, 0, self.itemDeterminantSize.width, self.itemDeterminantSize.height);
    
    CGImageRef imageRef = source == FLIMGAssetThumbSourceScreenImage ? asset.defaultRepresentation.fullScreenImage: asset.defaultRepresentation.fullResolutionImage;
    
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    
    // rotate image if needed
    if (source == FLIMGAssetThumbSourceResolutionImage) {
        NSNumber *assetOrientation = [asset valueForProperty:@"ALAssetPropertyOrientation"];
        UIImageOrientation imageOrientation = assetOrientation ? assetOrientation.intValue : UIImageOrientationUp;
        
        CGFloat rotationAngle = 0;
        CGSize scaleSize = CGSizeMake(-1, 1), rotatedSize = CGSizeMake(imageSize.height, imageSize.width);
        
        switch (imageOrientation) {
            case UIImageOrientationRight:
                rotationAngle = -M_PI_2;
                break;
            case UIImageOrientationLeft:
                rotationAngle = M_PI_2;
                break;
            case UIImageOrientationDown:
                scaleSize = CGSizeMake(-1, -1);
                rotationAngle = M_PI;
                rotatedSize = CGSizeMake(imageSize.width, imageSize.height);
                break;
            default:
                scaleSize = CGSizeMake(1, 1);
                rotationAngle = 0;
                break;
        }
        
        if (rotationAngle) {
            UIGraphicsBeginImageContext(rotatedSize);
            CGContextRef bitmap = UIGraphicsGetCurrentContext();
            
            CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);
            CGContextRotateCTM(bitmap, rotationAngle);
            CGContextScaleCTM(bitmap, scaleSize.width, scaleSize.height);
            CGContextDrawImage(bitmap, CGRectMake(-imageSize.width / 2, -imageSize.height / 2, imageSize.width, imageSize.height), imageRef);
            
            imageRef  = CGBitmapContextCreateImage(bitmap);
            imageSize = rotatedSize;
            UIGraphicsEndImageContext();
        }
    }
    
    // crop the image to the optimal size
    CGSize cropSize;
    CGFloat offsetX = 0, offsetY = 0;
    CGFloat originalRatio = imageSize.width / imageSize.height;
    CGFloat thumbRatio    = thumbRect.size.width / thumbRect.size.height;
    
    if (originalRatio >= thumbRatio) {
        cropSize.height = imageSize.height;
        cropSize.width  = cropSize.height * thumbRatio;
        offsetX = (imageSize.width - cropSize.width) / 2;
    }
    else {
        cropSize.width = imageSize.width;
        cropSize.height = cropSize.width / thumbRatio;
        offsetY = (imageSize.height - cropSize.height) / 2;
    }

    CGRect cropRect = CGRectMake(offsetX, offsetY, cropSize.width, cropSize.height);
    imageRef = CGImageCreateWithImageInRect(imageRef, cropRect);
    
    // resize the image
    UIGraphicsBeginImageContext(thumbRect.size);
    [[UIImage imageWithCGImage:imageRef] drawInRect:thumbRect];
    thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // release CGImageRef to avoid memory leaks
    CGImageRelease(imageRef);
    
    return thumbnail;
}

@end
