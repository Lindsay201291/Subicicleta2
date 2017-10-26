//
//  FLMediaGallery.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/7/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLMediaGallery.h"

static NSString * const kNibNameMediaGallery                = @"FLMediaGallery";
static NSString * const kReusableIdMediaGalleryItemCell     = @"flMediaGalleryItemCell";
static NSString * const kReusableIdMediaGalleryAddControl   = @"flMediaGalleryAddControl";

static NSString * const kFLMGCellInteractNotification = @"com.flynax.mgcellinteracted";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Media Gallery -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FLMediaGallery ()<UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet FLMediaGalleryFlowLayout *flowLayer;

@property (copy, nonatomic) NSMutableArray *mutableItemsData;

@property (strong, nonatomic) NSIndexPath *addCellIndexPath;
@property (strong, nonatomic) NSIndexPath *cellToRemoveIndePath;

@end

@implementation FLMediaGallery {
    FLMediaGalleryAddControl *_addingControl;
    NSInteger actionIndex;
}

#pragma mark Initialization

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self defineMainView];
    
    _mutableItemsData = [NSMutableArray new];
    _editable = YES;
    
    _collectionView.backgroundColor = FLHexColor(kColorBackgroundColor);
    _collectionView.mediaGallery = self;
    _collectionView.allowsSelection = NO;
    
    // basic settings
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.addControlPos   = FLMediaGalleryAddPosAbove;
    self.addControlType  = FLMediaGalleryAddTypeCell;
    self.itemDeterminantSize = CGSizeMake(200, 200);
    self.reusableViewSize    = CGSizeMake(200, 100);
    self.itemsSpacing = 5.0f;
    
    //action sheet
    _actionSheet = [[CCActionSheet alloc] initWithTitle:nil];
    actionIndex = 0;
    
    [self nibsOrClassesCollectionViewRegistration];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCellPressed:) name:kFLMGCellInteractNotification object:_addingControl];
    
}

- (void)actionCancelItemTitle:(NSString *)title {
    NSInteger index = actionIndex;
    __unsafe_unretained typeof(self) weakSelf = self;
    [_actionSheet addCancelButtonWithTitle:title block:^{[weakSelf handleActionAtIndex:index];}];
    actionIndex++;
}

- (void)actionAddDestructiveItemWithTitle:(NSString *)title {
    NSInteger index = actionIndex;
    __unsafe_unretained typeof(self) weakSelf = self;
    [_actionSheet addDestructiveButtonWithTitle:title block:^{[weakSelf handleActionAtIndex:index];}];
    actionIndex++;
}

- (void)actionAddItemWithTitle:(NSString *)title {
    NSInteger index = actionIndex;
    __unsafe_unretained typeof(self) weakSelf = self;
    [_actionSheet addButtonWithTitle:title block:^{[weakSelf handleActionAtIndex:index];}];
    actionIndex++;
}

- (void)handleActionAtIndex:(NSInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(mediaGallery:actionAtIndex:forCell:)]) {
        [_delegate mediaGallery:self actionAtIndex:index forCell:_selectedItemCell];
    }
    _selectedItemCell.selected = NO;
}

- (void)nibsOrClassesCollectionViewRegistration {
    [self registerClassForItemCell:[FLMediaGalleryItemCell class]];
    [self registerClassForAddControl:[FLMediaGalleryAddControl class]];
}

- (void)registerNibForAddControl:(UINib *)nib {
    [_collectionView registerNib:nib forCellWithReuseIdentifier:kReusableIdMediaGalleryAddControl];
    [_collectionView registerNib:nib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kReusableIdMediaGalleryAddControl];
    [_collectionView registerNib:nib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kReusableIdMediaGalleryAddControl];
}

- (void)registerClassForAddControl:(Class)class {
    [_collectionView registerClass:class forCellWithReuseIdentifier:kReusableIdMediaGalleryAddControl];
    [_collectionView registerClass:class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kReusableIdMediaGalleryAddControl];
    [_collectionView registerClass:class forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kReusableIdMediaGalleryAddControl];
}

- (void)registerNibForItem:(UINib *)nib {
    [_collectionView registerNib:nib forCellWithReuseIdentifier:kReusableIdMediaGalleryItemCell];
}

- (void)registerClassForItemCell:(Class)class {
    [_collectionView registerClass:class forCellWithReuseIdentifier:kReusableIdMediaGalleryItemCell];
}

- (void)defineMainView {
    if (!_view) {
        [[NSBundle mainBundle] loadNibNamed:kNibNameMediaGallery owner:self options:nil];
        _view.translatesAutoresizingMaskIntoConstraints = NO;
        [self insertSubview:_view atIndex:0];
    }
    
    // outer contsraints
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_view
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0f
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_view
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0f
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_view
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_view
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0f
                                                      constant:0]];
}

#pragma mark Accessors

- (NSIndexPath *)addCellIndexPath {
    if (_addControlType != FLMediaGalleryAddTypeCell) {
        return nil;
    }
    NSInteger row = 0;
    if (_addControlPos == FLMediaGalleryAddPosBelow) {
        row = _mutableItemsData.count;
    }
    return [NSIndexPath indexPathForRow:row inSection:0];
}

- (NSInteger)insertIndex {
    return _addControlPos == FLMediaGalleryAddPosBelow ? _mutableItemsData.count : 0;
}

- (NSArray *)items {
    return _mutableItemsData.copy;
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)direction {
    _flowLayer.scrollDirection = direction;
    _scrollDirection = direction;
}

- (void)setItemsSpacing:(CGFloat)spacing {
    _flowLayer.minimumLineSpacing      = spacing;
    _flowLayer.minimumInteritemSpacing = spacing;
    _itemsSpacing = spacing;
}

- (void)setItemsLimit:(NSInteger)limit {
    if (limit != _itemsLimit) {
        if (limit < _mutableItemsData.count) {
            [_mutableItemsData removeObjectsInRange:NSMakeRange(limit, _mutableItemsData.count - limit)];
        }
        [self reload];
        _itemsLimit = limit;
    }
}

- (BOOL)isAddingAvailable {
    return _editable && _mutableItemsData.count < _itemsLimit;
}

- (NSInteger)itemsLeft {
    return _itemsLimit - _mutableItemsData.count;
}

- (void)setSectionInsets:(UIEdgeInsets)sectionInsets {
    _flowLayer.sectionInset = sectionInsets;
    _sectionInsets = sectionInsets;
}

#pragma mark Data

- (void)addItem:(id)item {
    [self addItem:item updateCollection:YES];
}

- (void)addItem:(id)item updateCollection:(BOOL)update {
    NSInteger insertIndex;

    if (!item) {
        return;
    }

    switch (_addControlPos) {
        case FLMediaGalleryAddPosAbove:
            [_mutableItemsData insertObject:item atIndex:0];
            insertIndex = (_addControlType == FLMediaGalleryAddTypeCell && _itemsLimit > _mutableItemsData.count) * 1;
            break;
        case FLMediaGalleryAddPosBelow:
            [_mutableItemsData addObject:item];
            insertIndex = _mutableItemsData.count - 1;
            break;
    }

    if (update) {
        [_collectionView performBatchUpdates:^{
            NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:insertIndex inSection:0];
            if (_addControlType == FLMediaGalleryAddTypeCell && _itemsLimit == _mutableItemsData.count) {
                [_collectionView deleteItemsAtIndexPaths:@[insertIndexPath]];
            }
            
            [_collectionView insertItemsAtIndexPaths:@[insertIndexPath]];
        } completion:^(BOOL finished){
            if (_delegate && [_delegate respondsToSelector:@selector(mediaGalleryDidAddItem:)]) {
                [_delegate mediaGalleryDidAddItem:self];
            }
        }];
    }
}

- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger removeIndex = [self removeIndexForIndexPath:indexPath];
    FLMediaGalleryItemCell *cellToRemove = (FLMediaGalleryItemCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    [_mutableItemsData removeObjectAtIndex:removeIndex];
    [_collectionView performBatchUpdates:^{
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
        if (_addControlType == FLMediaGalleryAddTypeCell && _itemsLimit - _mutableItemsData.count == 1) {
            [_collectionView insertItemsAtIndexPaths:@[self.addCellIndexPath]];
        }
    }
    completion:^(BOOL finished){
        if (_delegate && [_delegate respondsToSelector:@selector(mediaGallery:didRemoveItemCell:atIndexPath:)]) {
            [_delegate mediaGallery:self didRemoveItemCell:cellToRemove atIndexPath:indexPath];
        }
    }];
}

- (NSInteger)removeIndexForIndexPath:(NSIndexPath *)indexPath {
    return _addControlType == FLMediaGalleryAddTypeCell && _addControlPos == FLMediaGalleryAddPosAbove  && indexPath.row ? indexPath.row - 1 : indexPath.row;
}

- (void)reload {
    [_collectionView reloadData];
}

#pragma mark Actions

- (void)handleCellPressed:(NSNotification *)notification {
    if (notification.object == _addingControl) {
        [self addControlDidPress:_addingControl];
    }
    else if ([notification.object isKindOfClass:FLMediaGalleryItemCell.class]) {
        if (((FLMediaGalleryItemCell *)notification.object).superview == _collectionView) {
            _selectedItemCell.selected = notification.object == _selectedItemCell;
            _selectedItemCell = notification.object;
            [self itemCellDidPress:notification.object];
        }
    }
}

- (void)addControlDidPress:(FLMediaGalleryAddControl *)control {
    if (_delegate && [_delegate respondsToSelector:@selector(mediaGalleryDidStartAdding:)]) {
        [_delegate mediaGalleryDidStartAdding:self];
    }
}

- (void)itemCellDidPress:(FLMediaGalleryItemCell *)cell {
    [_actionSheet showInView:self];
}

- (CGSize)itemSize {
    return _flowLayer.itemSize;
}

#pragma mark Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger itemsNumber = _mutableItemsData.count;
    if (_addControlType == FLMediaGalleryAddTypeCell && self.isAddingAvailable) {
        itemsNumber++;
    }
    return itemsNumber;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isIndexPathOfAddCell:indexPath]) {
        return [self addControlForIndexPath:indexPath];
    }
    FLMediaGalleryItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReusableIdMediaGalleryItemCell forIndexPath:indexPath];
    NSInteger dataIndex = indexPath.row;
    if (_addControlType == FLMediaGalleryAddTypeCell && self.isAddingAvailable && _addControlPos == FLMediaGalleryAddPosAbove) {
        dataIndex--;
    }
    
    cell.data = _mutableItemsData[dataIndex];
    [self customizeItemCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)customizeItemCell:(FLMediaGalleryItemCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // shoild be inplemented in subclasses
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [self addControlForIndexPath:indexPath];
}

- (FLMediaGalleryAddControl *)addControlForIndexPath:(NSIndexPath *)indexPath {
    switch (_addControlType) {
        case FLMediaGalleryAddTypeCell:
            _addingControl = [self cellAddControlForIndexPath:indexPath];
            break;
        case FLMediaGalleryAddTypeReusableView:
            _addingControl = [self reusableViewAddControlForIndexPath:indexPath];
            break;
    }
    [self customizeAddControl:_addingControl atIndexPath:indexPath];
    return _addingControl;
}

- (void)customizeAddControl:(FLMediaGalleryAddControl *)control atIndexPath:(NSIndexPath *)indexPath {
    // shoild be inplemented in subclasses
}

- (FLMediaGalleryAddControl *)reusableViewAddControlForIndexPath:(NSIndexPath *)indexPath {
    FLMediaGalleryAddControl *addControl;
    switch (_addControlPos) {
        case FLMediaGalleryAddPosAbove:
            addControl = [_collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kReusableIdMediaGalleryAddControl forIndexPath:indexPath];
            break;
        case FLMediaGalleryAddPosBelow:
            addControl = [_collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kReusableIdMediaGalleryAddControl forIndexPath:indexPath];
            break;
    }
    return addControl;
}

- (FLMediaGalleryAddControl *)cellAddControlForIndexPath:(NSIndexPath *)indexPath {
    return [_collectionView dequeueReusableCellWithReuseIdentifier:kReusableIdMediaGalleryAddControl forIndexPath:indexPath];
}

- (BOOL)isIndexPathOfAddCell:(NSIndexPath *)indexPath {
    return (_addControlType == FLMediaGalleryAddTypeCell && self.isAddingAvailable && indexPath.row == self.addCellIndexPath.row);
}

#pragma mark Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFLMGCellInteractNotification object:_addingControl];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CollectionView -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FLMediaGalleryCollectionView ()

@end

@implementation FLMediaGalleryCollectionView

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Flow Layout -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FLMediaGalleryFlowLayout ()

@property (weak, nonatomic) FLMediaGallery *mediaGallery;

@property (nonatomic) NSInteger columsNumber;
@property (nonatomic) CGFloat itemAspectRatio;

@end

@implementation FLMediaGalleryFlowLayout {
    CGSize _contentSize;
}

- (FLMediaGallery *)mediaGallery {
    if (!_mediaGallery) {
        _mediaGallery = ((FLMediaGalleryCollectionView *)self.collectionView).mediaGallery;
    }
    return _mediaGallery;
}

- (void)prepareLayout {
    
    [super prepareLayout];
    
    CGSize itemsSize = CGSizeZero, addingItemSize = CGSizeZero;
    
    CGSize determinantSize = self.mediaGallery.itemDeterminantSize;
    
    _itemAspectRatio = determinantSize.width / determinantSize.height;
    
    CGSize containerSize = self.collectionView.bounds.size;
    
    switch (_mediaGallery.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal:
            _columsNumber    = ceil(containerSize.height / determinantSize.height);
            itemsSize.height = [self actualOnContainerSize:containerSize.height];
            itemsSize.width  = itemsSize.height * _itemAspectRatio;
            break;
        case UICollectionViewScrollDirectionVertical:
            _columsNumber    = ceil(containerSize.width / determinantSize.width);
            itemsSize.width  = [self actualOnContainerSize:containerSize.width];
            itemsSize.height = itemsSize.width / _itemAspectRatio;
            break;
    }
    
    // determine a reusable view size in case of section add button
    if (_mediaGallery.addControlType == FLMediaGalleryAddTypeReusableView) {
        if (_mediaGallery.isAddingAvailable) {
            addingItemSize = itemsSize;
            switch (_mediaGallery.scrollDirection) {
                case UICollectionViewScrollDirectionHorizontal:
                    addingItemSize.width  = _mediaGallery.reusableViewSize.width;
                    break;
                case UICollectionViewScrollDirectionVertical:
                    addingItemSize.height = _mediaGallery.reusableViewSize.height;
                    break;
            }
        }
        else {
            addingItemSize = CGSizeMake(0.00001, 0.00001);
        }
        
        switch (_mediaGallery.addControlPos) {
            case FLMediaGalleryAddPosAbove:
                self.headerReferenceSize = addingItemSize;
                break;
            case FLMediaGalleryAddPosBelow:
                self.footerReferenceSize = addingItemSize;
                break;
        }
        
    }
    else {
        self.headerReferenceSize = addingItemSize;
        self.footerReferenceSize = addingItemSize;
    }
    
    self.itemSize = itemsSize;
    
    CGSize contentSize = self.collectionViewContentSize;
    
    if (!CGSizeEqualToSize(contentSize,_contentSize)) {
        if ( _mediaGallery.delegate && [_mediaGallery.delegate respondsToSelector:@selector(mediaGallery:didChangeContentSize:)]) {
            [_mediaGallery.delegate mediaGallery:_mediaGallery didChangeContentSize:contentSize];
        }
        _contentSize = contentSize;
    }
    
}

- (CGFloat)actualOnContainerSize:(CGFloat)size {
    CGFloat actualSize = size - _mediaGallery.itemsSpacing * (_columsNumber - 1);
    switch (_mediaGallery.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal:
            actualSize -= self.sectionInset.top + self.sectionInset.bottom;
            break;
        case UICollectionViewScrollDirectionVertical:
            actualSize -= self.sectionInset.left + self.sectionInset.right;
            break;
    }
    
    actualSize /= _columsNumber;
    
    return IS_NOT_RETINA ? floorf(actualSize) : actualSize;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Linear Scale Transormation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CGAffineTransform FLMakeLinearScaleTransform (CGFloat xtScale, CGFloat ytScale, CGSize fromSize) {
    
    CGFloat sx = (fromSize.width + xtScale) / fromSize.width;
    CGFloat sy = (fromSize.height + ytScale) / fromSize.height;
    
    return CGAffineTransformMakeScale(sx, sy);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIView + Media Gallery Category -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIView (FLMediaGallery)

- (void)animateTouchInWithDuration:(NSTimeInterval)duration scaleSize:(CGSize)scaleSize fadeLevel:(CGFloat)fadeLevel completion:(void (^)(BOOL))completion;
- (void)animateTapOutWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL))completion;

@end

@implementation UIView (FLMediaGallery)

- (void)animateTouchInWithDuration:(NSTimeInterval)duration scaleSize:(CGSize)scaleSize fadeLevel:(CGFloat)fadeLevel completion:(void (^)(BOOL))completion {
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = fadeLevel;
                         self.transform = FLMakeLinearScaleTransform(scaleSize.width, scaleSize.height, self.bounds.size);
                     }
                     completion:completion];
}

- (void)animateTapOutWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL))completion {
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.alpha = 1;
                         self.transform = CGAffineTransformIdentity;
                     }
                     completion:completion];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Media Gallery Item Cell -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FLMediaGalleryItemCell ()

@end

@implementation FLMediaGalleryItemCell {
    CALayer *_selectedLayer;
}

- (void)setDefaults {
    [super setDefaults];
    
    _selectedLayer = [CALayer layer];
    _selectedLayer.backgroundColor = [UIColor colorWithRed:1.0 green:0.5051 blue:0.0 alpha:.2].CGColor;
    _selectedLayer.opacity = .9f;
    _selectedLayer.borderWidth = 2.0f;
    _selectedLayer.borderColor = [UIColor orangeColor].CGColor;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    
    // change selected layer frame w/o animation;
    if (_selectedLayer.superlayer == layer) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _selectedLayer.frame = self.bounds;
        [CATransaction commit];
    }
}

- (void)setSelected:(BOOL)selected {
    
    if (!self.selected && selected) {
        [self.layer addSublayer:_selectedLayer];
    }
    else if (self.selected && !selected) {
        [_selectedLayer removeFromSuperlayer];
    }
    
    super.selected = selected;
}

- (void)didTouchUpInside {
    self.selected = YES;
    [super didTouchUpInside];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Media Gallery Add Control -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FLMediaGalleryAddControl

- (void)setDefaults {
    [super setDefaults];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Media Gallery Cell -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static NSString * const kMGItemCellBGColor = @"E0E0E0";

@interface FLMediaGalleryCell ()

@end

@implementation FLMediaGalleryCell {
    BOOL _isUnderPress;
    BOOL _isTochedDown;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (void)setDefaults {
    
    self.backgroundColor = FLHexColor(kMGItemCellBGColor);
    
    _isUnderPress = NO;
    
    _animationDuration = .3;
    _animationScaleSize = CGSizeMake(-10, -10);
    
    _pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePressEvent:)];
    _pressRecognizer.minimumPressDuration    = 0.1;
    _pressRecognizer.numberOfTouchesRequired = 1;
    _pressRecognizer.cancelsTouchesInView = NO;

    [self addGestureRecognizer:_pressRecognizer];
}

#pragma mark - Events

- (void)handlePressEvent:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer == _pressRecognizer && recognizer.state == UIGestureRecognizerStateBegan) {
        _isUnderPress = YES;
        [self animateTouchInWithDuration:_animationDuration / 2
                               scaleSize:_animationScaleSize
                               fadeLevel:.7f
                              completion:nil];
    }
    else if (recognizer == _pressRecognizer && recognizer.state == UIGestureRecognizerStateEnded) {
        [self unPress];
    }

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _isTochedDown = YES;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self unPress];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_isTochedDown) {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        if (![self pointInside:touchPoint withEvent:event]) {
            [self unPress];
            _isTochedDown = NO;
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_isTochedDown) {
        [self didTouchUpInside];
    }
}

- (void)unPress {
    if (_isUnderPress) {
        [self animateTapOutWithDuration:_animationDuration / 2 completion:nil];
        _isUnderPress = NO;
    }
}

- (void)didTouchUpInside {
    [self postInteractMessage];
}

- (void)postInteractMessage {
    [[NSNotificationCenter defaultCenter] postNotificationName:kFLMGCellInteractNotification object:self];
}

@end
