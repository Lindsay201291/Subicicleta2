//
//  FLInputAccessoryToolbar.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/2/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLInputAccessoryToolbar.h"
#import "FLDropDown.h"

@interface FLInputAccessoryToolbar ()

@property (strong, nonatomic) UIBarButtonItem *nextButton;
@property (strong, nonatomic) UIBarButtonItem *prevButton;
@property (strong, nonatomic) UIBarButtonItem *doneButton;

@property (nonatomic, copy) NSMutableArray *inputItems;

@property (nonatomic) NSInteger activeItemIndex;
@property (nonatomic) id activeItem;

@end

@implementation FLInputAccessoryToolbar

+ (instancetype)toolbarWithInputItems:(NSArray *)items {
    return [[self alloc] initWithInputItems:items];
}

#pragma mark - Initializations

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tintColor = FLHexColor(kColorInputAccessoryToolbarTint);
        _inputItems = [NSMutableArray new];

        _prevButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:101 target:self action:@selector(prevButtonTaped)];
        _nextButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:102 target:self action:@selector(nextButtonTaped)];
        _doneButton = [[UIBarButtonItem alloc] initWithTitle:FLLocalizedString(@"button_done") style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonTaped)];
        [_doneButton setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17]} forState:UIControlStateNormal];

        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedSpace.width = 20.0f;
        
        UIBarButtonItem *flexSpace  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        NSArray<UIBarButtonItem *> *barButtons = @[_prevButton, fixedSpace, _nextButton, flexSpace, _doneButton];
        
        [self sizeToFit];
        
        self.items = barButtons;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidBeginEditing:)
                                                     name:UITextFieldTextDidBeginEditingNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidBeginEditing:)
                                                     name:UITextViewTextDidBeginEditingNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidBeginEditing:)
                                                     name:FLDropDownStartSelectingNotification
                                                   object:nil];
        
    }
    return self;
}

- (instancetype) initWithInputItems:(NSArray *)items {
    self = [self init];
    
    for (id item in items) {
        [self addInputItem:item];
    }
    
    return self;
}

#pragma mark - Accessors

- (void)addInputItem:(id)item {
    if ([item respondsToSelector:@selector(setInputAccessoryView:)]) {
        [item setInputAccessoryView:self];
    }
    
    [_inputItems addObject:item];
}

#pragma mark - Actions

- (void)itemDidBeginEditing:(NSNotification *)noticifation {
    NSInteger itemIndex = [_inputItems indexOfObject:noticifation.object];
    if (itemIndex != NSNotFound && _activeItem != noticifation.object) {
        _activeItemIndex = itemIndex;
        _activeItem      = noticifation.object;
        [self activeItemChanged];
    }
}

- (void)activeItemChanged {
    _prevButton.enabled = _activeItemIndex != 0;
    _nextButton.enabled = _activeItemIndex != _inputItems.count - 1;
}

- (void)prevButtonTaped {
    [self goToPrevItem];
}

- (void)nextButtonTaped {
    [self goToNextItem];
}

- (void)goToNextItem {
    [_inputItems[_activeItemIndex + 1] becomeFirstResponder];
}

- (void)goToPrevItem {
    [_inputItems[_activeItemIndex - 1] becomeFirstResponder];
}

- (void)doneButtonTaped {
    if (_didDoneTapBlock) {
        _didDoneTapBlock(_activeItem);
    }
    [_activeItem resignFirstResponder];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FLDropDownStartSelectingNotification object:nil];
}

@end
