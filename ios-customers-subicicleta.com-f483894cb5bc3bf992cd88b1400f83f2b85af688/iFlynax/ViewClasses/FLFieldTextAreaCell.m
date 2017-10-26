//
//  FLFieldTextAreaCell.m
//  iFlynax
//
//  Created by Alex on 8/31/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldTextAreaCell.h"

static CGFloat    const kCharsLimitFontSize         = 14;
static NSString * const kCharsLimitFontColor        = @"323232";
static NSString * const kCharsLimitFontWarningColor = @"D27515";
static NSString * const kCharsLimitFontDangerColor  = @"FF0000";

@interface FLFieldTextAreaCell () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *charsLimitLabel;
@property (assign, nonatomic) NSInteger messageSymbolsLimit;
@end

@implementation FLFieldTextAreaCell
@dynamic item;

- (void)cellDidLoad {
    [super cellDidLoad];

    _textView.inputAccessoryView = self.actionBar;
    _textView.delegate = self;
    _textView.textAlignment = IS_RTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
}

- (void)cellWillAppear {
    self.fieldPlaceholder.text = self.item.placeholder;

    _textView.placeholder = self.item.placeholder;
    _textView.text = self.item.value;

    // chars limit
    self.messageSymbolsLimit = FLTrueInteger(self.item.model.values);

    // errors trigger
    [self highlightAsFieldWithError:(self.item.errorMessage != nil)];
}

- (void)highlightAsFieldWithError:(BOOL)highlighted {
    [self highlightInput:_textView highlighted:highlighted];

    if (!highlighted) {
        self.item.errorMessage = nil;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [_textView becomeFirstResponder];
    }
}

+ (BOOL)canFocusWithItem:(FLFieldTextArea *)item {
    return YES;
}

- (UIResponder *)responder {
    return _textView;
}

#pragma mark - Chars Limit Handler

- (void)setMessageSymbolsLimit:(NSInteger)messageSymbolsLimit {
    _messageSymbolsLimit = messageSymbolsLimit;
    NSInteger left = [self getCharsLeftAndsubstringToIndexIfNecessary];
    [self defineCharsLimitLabelText:left];
}

- (NSInteger)getCharsLeftAndsubstringToIndexIfNecessary {
    NSInteger left = _messageSymbolsLimit - _textView.text.length;
    if (left < 0) {
        left = 0;
        _textView.text = [_textView.text substringToIndex:_messageSymbolsLimit];
    }
    return left;
}

- (void)defineCharsLimitLabelText:(NSInteger)limit {
    NSString *string = F(FLLocalizedString(@"label_chars_limit_left"), limit);
    NSRange    range = [string rangeOfString:F(@"%d", (int)limit)];

    UIColor *mainColor = FLHexColor(kCharsLimitFontColor);
    NSDictionary *mainAttrs = @{NSFontAttributeName: [UIFont systemFontOfSize:kCharsLimitFontSize],
                                NSForegroundColorAttributeName: mainColor};

    UIColor *digitsColor = mainColor;
    if (limit < 10) {
        digitsColor = FLHexColor(kCharsLimitFontDangerColor);
    }
    else if (limit < 20) {
        digitsColor = FLHexColor(kCharsLimitFontWarningColor);
    }

    NSDictionary *digitsAttrs = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:kCharsLimitFontSize],
                                  NSForegroundColorAttributeName: digitsColor};

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:string
                                                                                       attributes:mainAttrs];
    [attributedText setAttributes:digitsAttrs range:range];

    _charsLimitLabel.attributedText = attributedText;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    NSInteger left = [self getCharsLeftAndsubstringToIndexIfNecessary];
    [self defineCharsLimitLabelText:left];
    [self highlightAsFieldWithError:NO];

    self.item.value = _textView.text;
}

@end
