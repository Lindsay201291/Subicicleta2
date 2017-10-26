//
//  FLYouTubeGallery.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/19/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLYouTubeGallery.h"
#import "FLYouTubeMGItemCell.h"

@interface FLYouTubeGallery ()

@property (copy, nonatomic) NSMutableArray *thumbnails;
@property (copy, nonatomic) NSMutableArray *urls;

@end

@implementation FLYouTubeGallery

- (void)setup {
    [super setup];
    
    self.itemDeterminantSize = CGSizeMake(1600, 500);
    self.reusableViewSize = CGSizeMake(75, 75);
    self.itemsSpacing   = 1.0f;
    self.addControlPos  = FLMediaGalleryAddPosBelow;
    self.addControlType = FLMediaGalleryAddTypeReusableView;
    self.sectionInsets = UIEdgeInsetsMake(0, 0, 15, 0);
    
    // action sheet init
    [self actionCancelItemTitle:FLLocalizedString(@"button_cancel")];
    [self actionAddDestructiveItemWithTitle:FLLocalizedString(@"button_remove")];
}

- (void)nibsOrClassesCollectionViewRegistration {
    
    UINib *addNib = [UINib nibWithNibName:@"FLImageMGAddControl" bundle:nil];
    [self registerNibForAddControl:addNib];
    
    UINib *cellNib = [UINib nibWithNibName:@"FLYouTubeMGItemCell" bundle:nil];
    [self registerNibForItem:cellNib];
}

- (void)customizeItemCell:(FLYouTubeMGItemCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (!cell.isDataCustiomized) {
        [cell customizeFromData];
    }
}

- (void)handleActionAtIndex:(NSInteger)index {
    if (index == 1) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:self.selectedItemCell];
        [self deleteItemAtIndexPath:indexPath];
    }
    [super handleActionAtIndex:index];
}

- (void)loadFromArray:(NSArray *)items {
    for (NSDictionary *info in items) {
        [FLYouTubeMGItemModel loadWithYouTubeId:info[@"Preview"] success:^(FLYouTubeMGItemModel *model) {
            [self addItem:model updateCollection:NO];
        } failure:nil];
    }
}

@end
