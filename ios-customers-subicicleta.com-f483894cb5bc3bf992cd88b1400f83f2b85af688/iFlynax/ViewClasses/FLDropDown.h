//
//  FLDropDown.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/2/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

static NSString * const FLDropDownDidChangedNotification     = @"com.flynax.dropdown.didchange";
static NSString * const FLDropDownStartSelectingNotification = @"com.flynax.dropdown.startselecing";

static NSString * const FLDropDownTitleKey = @"_title_";

typedef void (^FLDropDownDidChange)(id option, NSString *key);

@interface FLDropDown : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, strong) UIView *inputView;
@property (nonatomic, strong) UIView *inputAccessoryView;
@property (nonatomic, strong) UIResponder *responder;

@property (nonatomic) UIEdgeInsets contentInsents;

@property (nonatomic, strong) id selectedOption;
@property (nonatomic, copy) NSString *selectedOptionKey;

@property (nonatomic) CGFloat optionRowHeight;
@property (nonatomic, strong) UIColor *optionColor;
@property (nonatomic, strong) UIFont *optionFont;

@property (nonatomic, readonly, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, getter=isLoading) BOOL loading;

@property (nonatomic, copy) FLDropDownDidChange didChangeBlock;

- (void)addOption:(id)option;
- (void)addOption:(id)option forKey:(NSString *)key;

- (void)selectOption:(id)option;
- (void)selectOptionForKey:(NSString *)key;
- (void)selectOptionAtIndex:(NSInteger)row;

- (void)reloadAllComponents;
- (void)clearDataSource;
@end
