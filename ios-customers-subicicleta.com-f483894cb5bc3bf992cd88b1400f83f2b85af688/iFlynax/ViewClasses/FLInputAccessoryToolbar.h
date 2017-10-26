//
//  FLInputAccessoryToolbar.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/2/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

typedef void (^FLInputAccessoryToolbarDidDoneTap)(id activeItem);

@interface FLInputAccessoryToolbar : UIToolbar

@property (nonatomic, copy) FLInputAccessoryToolbarDidDoneTap didDoneTapBlock;

+ (instancetype)toolbarWithInputItems:(NSArray *)items;

- (instancetype)initWithInputItems:(NSArray *)items;
- (void)addInputItem:(id)item;
- (void)goToNextItem;
- (void)goToPrevItem;

@end
