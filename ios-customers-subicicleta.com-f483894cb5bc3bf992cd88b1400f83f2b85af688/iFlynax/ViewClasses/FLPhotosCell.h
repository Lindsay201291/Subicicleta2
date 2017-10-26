//
//  FLPhotosCell.h
//  iFlynax
//
//  Created by Alex on 6/4/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLPhotoView;

@interface FLPhotosCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet FLPhotoView *thumbnail;
@end

@interface FLPhotoView : UIImageView

@end