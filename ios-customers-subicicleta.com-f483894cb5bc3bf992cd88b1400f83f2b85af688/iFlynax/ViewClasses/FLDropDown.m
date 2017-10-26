//
//  FLDropDown.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/2/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLDropDown.h"
#import "FLGraphics.h"

static NSString * const kTitleInOptionsFormat = @"- %@ -";
static NSString * const kMarkerSymbol_LTR     = @"❯";
static NSString * const kMarkerSymbol_RTL     = @"❮";
static CGFloat    const kMarkerLabelSize      = 20.0f;
static CGFloat    const kMarkerAnimDuration   = .1f;

@interface FLDropDown () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate> {
    NSArray<NSLayoutConstraint *> *_storyboardConstraints;
    NSMutableArray                *_theOptions;
    NSMutableArray                *_theOptionsKey;
    UITapGestureRecognizer        *_singleTap;
}
@property (nonatomic, strong) UITextField  *textField;
@property (nonatomic, strong) UILabel      *valueLabel;
@property (nonatomic, strong) UILabel      *markerLabel;
@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, getter=isOpen) BOOL open;
@end

@implementation FLDropDown

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self loadBasics];
    }
    return self;
}

- (void)loadBasics {
    _theOptions    = [NSMutableArray new];
    _theOptionsKey = [NSMutableArray new];

    _open    = NO;
    _enabled = YES;

    _optionRowHeight    = 44;
    self.contentInsents = UIEdgeInsetsMake(0, 8, 0, 8);

    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 1, _optionRowHeight)];
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textField.autocorrectionType     = UITextAutocorrectionTypeNo;
    _textField.spellCheckingType      = UITextSpellCheckingTypeNo;
    _textField.delegate = self;
    [self addSubview:_textField];

    _valueLabel = [UILabel new];
    _valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_valueLabel];

    _markerLabel = [UILabel new];
    _markerLabel.text = IS_RTL ? kMarkerSymbol_RTL : kMarkerSymbol_LTR;
    _markerLabel.font = [UIFont systemFontOfSize:16.0f];
    _markerLabel.textAlignment = NSTextAlignmentCenter;
    _markerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_markerLabel];
    [self markerLabelConstraints];

    _pickerView = [UIPickerView new];
    _pickerView.dataSource = self;
    _pickerView.delegate   = self;

    self.inputView = _pickerView;

    _storyboardConstraints = self.constraints;

    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewHasTapped:)];
    [self addGestureRecognizer:_singleTap];
    [self prepareLayerUI];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    _singleTap.enabled = enabled;
    _markerLabel.hidden = !enabled;
}

- (void)drawRect:(CGRect)rect {
    FLContextPainter *painter = [[FLContextPainter alloc] initWithCurrentContext];
    if (self.isOpen) {
        [painter linearGraientWithRect:self.bounds
                             fromColor:FLHexColor(@"DEDEDE")
                               toColor:[UIColor whiteColor]];
    }
    else {
        [painter linearGraientWithRect:self.bounds
                             fromColor:[UIColor whiteColor]
                               toColor:FLHexColor(@"DEDEDE")];
    }
}

- (void)prepareLayerUI {
    self.layer.borderWidth   = 1;
    self.layer.borderColor   = FLHexColor(@"919191").CGColor;
    self.layer.shadowColor   = [UIColor whiteColor].CGColor;
    self.layer.shadowOffset  = CGSizeMake(0, 1);
    self.layer.shadowOpacity = .5f;
    self.layer.shadowRadius  = .0f;
    self.layer.masksToBounds = YES;

    _markerLabel.textColor = FLHexColor(@"474747");
    _markerLabel.alpha = .8f;

    _titleColor  = FLHexColor(kColorPlaceholderFont);
    _titleFont   = [UIFont systemFontOfSize:14.0f];

    _optionColor = FLHexColor(@"1b1b1b");
    _optionFont  = [UIFont systemFontOfSize:14.0f];
}

#pragma mark - Accessors

- (void)setTitle:(NSString *)title {
    _title = title;
    _valueLabel.attributedText = [self attributedStingForOption:title withTitleStyle:YES andFormatted:YES];

    [_theOptions insertObject:_title atIndex:0];
    [_theOptionsKey insertObject:FLDropDownTitleKey atIndex:0];
    [self selectRow:0];
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    _valueLabel.attributedText =  (loading
                                   ? [self attributedStingForOption:FLLocalizedString(@"loading") withTitleStyle:YES andFormatted:NO]
                                   : [self attributedStingForOption:_title withTitleStyle:YES andFormatted:YES]);
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    _valueLabel.font = titleFont;
}

- (void)setOpen:(BOOL)open {
    _open = open;

    [UIView animateWithDuration:kMarkerAnimDuration animations:^{
        CGFloat _degree = IS_RTL ? -M_PI_2 : M_PI_2;
        _markerLabel.transform = open ? CGAffineTransformMakeRotation(_degree) : CGAffineTransformIdentity;
    }];
    [self setNeedsDisplay];
}

- (void)setSelectedOption:(id)option {
    _valueLabel.attributedText = [self attributedStingForOption:[self optionTitleFromValue:option]];
    _selectedOption = option;
}

- (void)setInputView:(UIView *)inputView {
    _textField.inputView = inputView;
}

- (void)setInputAccessoryView:(UIView *)inputAccessoryView {
    _textField.inputAccessoryView = inputAccessoryView;
}

- (void)setContentInsents:(UIEdgeInsets)intsets {
    _contentInsents = intsets;
    [self setNeedsUpdateConstraints];
}

- (void)addOption:(id)option {
    [self addOption:option forKey:nil];
}

- (void)addOption:(id)option forKey:(NSString *)key {
    [_theOptions addObject:option];

    if (!key) {
        key = [self optionKeyFromValue:option];
        // deep checking
        if (!key) {
            key = F(@"key_%d", (int)_theOptionsKey.count);
        }
    }
    [_theOptionsKey addObject:key];
}

- (BOOL)isSelected {
    return _selectedOptionKey != FLDropDownTitleKey;
}

- (NSAttributedString *)attributedStingForOption:(NSString *)option {
    return [self attributedStingForOption:option withTitleStyle:option == _title andFormatted:YES];
}

- (NSAttributedString *)attributedStingForOption:(NSString *)option withTitleStyle:(BOOL)withTitleStyle andFormatted:(BOOL)formated {
    UIFont *font = _optionFont;
    UIColor *fontColor = _optionColor;

    if (withTitleStyle) {
        font = _titleFont;
        fontColor = _titleColor;
    }

    if (formated && withTitleStyle) {
        option = [NSString stringWithFormat:kTitleInOptionsFormat, option];
    }

    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:option
                                                                           attributes:@{NSFontAttributeName: font,
                                                                                        NSForegroundColorAttributeName:fontColor}];
    return attributedString;
}

#pragma mark - Constraints

- (void)updateConstraints {
    [super updateConstraints];
    [self removeConstraints:self.constraints];
    [self addConstraints:_storyboardConstraints];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_valueLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0f
                                                      constant:_contentInsents.left]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_valueLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0f
                                                      constant:_contentInsents.top]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_markerLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_valueLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0f
                                                      constant:_contentInsents.right]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_valueLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:_contentInsents.bottom]];
}

- (void)markerLabelConstraints {
    [_markerLabel addConstraint:[NSLayoutConstraint constraintWithItem:_markerLabel
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0f
                                                              constant:kMarkerLabelSize]];

    [_markerLabel addConstraint:[NSLayoutConstraint constraintWithItem:_markerLabel
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0f
                                                              constant:kMarkerLabelSize]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_markerLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_markerLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0f
                                                      constant:8.0f]];
}

#pragma mark - Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.open = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:FLDropDownStartSelectingNotification object:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.open = NO;
}

#pragma mark - Picker data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _theOptions.count;
}

#pragma mark - Picker delegate

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)componen {
    return [self attributedStingForOption:[self optionTitleFromValue:_theOptions[row]]];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return _optionRowHeight;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (_selectedOption != _theOptions[row]) {
        [self selectRow:row];

        if (_didChangeBlock) {
            _didChangeBlock(_theOptions[row], _theOptionsKey[row]);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:FLDropDownDidChangedNotification object:self];
    }
}

#pragma mark - Actions

- (void)selectOption:(id)option {
    NSInteger index = [_theOptions indexOfObject:option];
    [self selectOptionAtIndex:index];
}

- (void)selectOptionForKey:(NSString *)key {
    NSInteger index = [_theOptionsKey indexOfObject:key];
    [self selectOptionAtIndex:index];
}

- (void)selectOptionAtIndex:(NSInteger)row {
    if (row != NSNotFound) {
        [self selectRow:row];
        [_pickerView selectRow:row inComponent:0 animated:NO];
    }
}

- (void)selectRow:(NSInteger)row {
    self.selectedOption    = _theOptions[row];
    self.selectedOptionKey = _theOptionsKey[row];
}

- (BOOL)becomeFirstResponder {
    [_textField becomeFirstResponder];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [_textField resignFirstResponder];
    return [super resignFirstResponder];
}

- (UIResponder *)responder {
    return _textField;
}

- (NSString *)optionKeyFromValue:(id)value {
    return [self optionFromValue:value toStringByKey:@"key"];
}

- (NSString *)optionTitleFromValue:(id)value {
    return [self optionFromValue:value toStringByKey:@"name"];
}

- (NSString *)optionFromValue:(id)value toStringByKey:(NSString *)key {
    if (value != nil) {
        SEL _selector = NSSelectorFromString(key);

        if ([value isKindOfClass:NSObject.class] &&
            [value respondsToSelector:_selector])
        {
            return [value performSelector:_selector];
        }
        else if ([value isKindOfClass:NSDictionary.class]) {
            return FLCleanString([value objectForKey:key]);
        }
        else if ([value isKindOfClass:NSString.class]) {
            return value;
        }
    }
    return nil;
}

- (void)viewHasTapped:(UIGestureRecognizer *)recognize {
    if (_textField.isFirstResponder) {
        [self resignFirstResponder];
    } else {
        [self becomeFirstResponder];
    }
}

- (void)reloadAllComponents {
    [_pickerView reloadAllComponents];
}

- (void)clearDataSource {
    [_theOptions removeAllObjects];
    [_theOptionsKey removeAllObjects];
}

@end
