//
//  FLMediaGallery.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/7/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLYTWebView.h"
#import "CCActionSheet.h"

static NSString * const FLMediaGalleryDidStartEditionNotification = @"com.flynax.mediagallerydidstartedition";

typedef NS_ENUM(NSInteger, FLMediaGalleryAddType) {
    FLMediaGalleryAddTypeCell,
    FLMediaGalleryAddTypeReusableView
};

typedef NS_ENUM(NSInteger, FLMediaGalleryAddPos) {
    FLMediaGalleryAddPosAbove,
    FLMediaGalleryAddPosBelow
};

@protocol FLMediaGalleryDelegate;

@interface FLMediaGalleryCell : UICollectionViewCell

@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic) CGSize         animationScaleSize;

@property (strong, nonatomic) UITapGestureRecognizer       *tapRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *pressRecognizer;

- (void)setDefaults;

- (void)didTouchUpInside;

@end

@interface FLMediaGalleryItemCell : FLMediaGalleryCell

@property (strong, nonatomic) id data;

@end

@interface FLMediaGalleryAddControl : FLMediaGalleryCell

@end

@class FLMediaGallery;

@interface FLMediaGalleryCollectionView : UICollectionView

@property (weak, nonatomic) FLMediaGallery *mediaGallery;

@end

@interface FLMediaGalleryFlowLayout : UICollectionViewFlowLayout

@end

@interface FLMediaGallery : UIView

@property (weak, nonatomic) id<FLMediaGalleryDelegate> delegate;

@property (weak, nonatomic) IBOutlet FLMediaGalleryCollectionView *collectionView;

@property (nonatomic) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic, getter=isEditable) BOOL editable;
@property (nonatomic) FLMediaGalleryAddType addControlType;
@property (nonatomic) FLMediaGalleryAddPos  addControlPos;
@property (nonatomic) CGSize    reusableViewSize;
@property (nonatomic) CGSize    itemDeterminantSize;
@property (nonatomic) CGFloat   itemsSpacing;
@property (nonatomic) NSInteger itemsLimit;

@property (readonly, getter=isAddingAvailable, nonatomic) BOOL addingAvailable;
@property (nonatomic) UIEdgeInsets sectionInsets;
@property (readonly, nonatomic) NSInteger itemsLeft;
@property (readonly, nonatomic) NSInteger insertIndex;

@property (strong, nonatomic) CCActionSheet *actionSheet;

@property (strong, nonatomic) FLMediaGalleryItemCell *selectedItemCell;

- (void)setup;

- (void)nibsOrClassesCollectionViewRegistration;

- (void)registerNibForAddControl:(UINib *)nib;

- (void)registerClassForAddControl:(Class)class;

- (void)registerNibForItem:(UINib *)nib;

- (void)registerClassForItemCell:(Class)class;

- (NSArray *)items;

- (void)customizeAddControl:(FLMediaGalleryAddControl *)control atIndexPath:(NSIndexPath *)indexPath;

- (void)customizeItemCell:(FLMediaGalleryItemCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)addItem:(id)item;

- (void)addItem:(id)item updateCollection:(BOOL)update;

- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)addControlDidPress:(FLMediaGalleryAddControl *)control;

- (void)itemCellDidPress:(FLMediaGalleryItemCell *)cell;

- (void)reload;

- (void)actionCancelItemTitle:(NSString *)title;

- (void)actionAddDestructiveItemWithTitle:(NSString *)title;

- (void)actionAddItemWithTitle:(NSString *)title;

- (void)handleActionAtIndex:(NSInteger)index;

- (CGSize)itemSize;

@end

@protocol FLMediaGalleryDelegate <NSObject>

@optional

- (void)mediaGalleryDidStartAdding:(FLMediaGallery *)mediaGallery;

- (void)mediaGallery:(FLMediaGallery *)mediaGallery actionAtIndex:(NSInteger)index forCell:(FLMediaGalleryItemCell *)cell;

- (void)mediaGalleryDidAddItem:(FLMediaGallery *)mediaGallery;

- (void)mediaGallery:(FLMediaGallery *)mediaGallery didRemoveItemCell:(FLMediaGalleryItemCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)mediaGallery:(FLMediaGallery *)mediaGallery didChangeContentSize:(CGSize)contentSize;

@end
