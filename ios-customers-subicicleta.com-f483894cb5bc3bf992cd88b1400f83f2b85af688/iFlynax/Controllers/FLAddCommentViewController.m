//
//  FLAddCommentViewController.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 9/15/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLAddCommentViewController.h"
#import "FLTextField.h"
#import "FLRatingStars.h"
#import "FLTextView.h"
#import "FLKeyboardHandler.h"
#import "FLCommentModel.h"
#import "FLValidatorManager.h"
#import "FLValiderRequired.h"
#import "FLInputAccessoryToolbar.h"

static NSString * const kColorStarGradient1  = @"f7ca0a";
static NSString * const kColorStarGradient2  = @"fffc1c";
static NSString * const kColorStarBackground = @"9c9c9c";
static NSString * const kColorStarStrok      = @"97732a";
static CGFloat    const kStarStrokeWidh      = 1.0f;
static CGFloat    const kStarSpasing         = 5.0f;
static NSInteger  const kStarsNumber         = 5;

static NSString * const kApiResultSuccessKey      = @"success";
static NSString * const kApiResultMessageKey      = @"message";
static NSString * const kApiResultErrorKey        = @"error";

static CGFloat    const kCharsLimitFontSize         = 14;
static NSString * const kCharsLimitFontColor        = @"323232";
static NSString * const kCharsLimitFontWarningColor = @"D27515";
static NSString * const kCharsLimitFontDangerColor  = @"FF0000";

@interface FLAddCommentViewController ()<FLKeyboardHandlerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet FLTextField *titleTextField;
@property (weak, nonatomic) IBOutlet FLTextField *authorTextField;
@property (weak, nonatomic) IBOutlet FLRatingStars *ratingStars;
@property (weak, nonatomic) IBOutlet FLTextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton *addCommentButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *charsLimitLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTopSpacingConstraint;

@property (strong, nonatomic) FLCommentModel *commentModel;

@property (nonatomic) FLValidatorManager *validatorManager;
@property (strong, nonatomic) FLKeyboardHandler *keyboardHandler;

@end

@implementation FLAddCommentViewController {
    int _messageSymbolsLimit;
    BOOL _afterKeyboardDismiss;
    FLInputAccessoryToolbar *_accessoryToolbar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = FLLocalizedString(@"screen_add_comment");
    self.view.backgroundColor = FLHexColor(kColorBackgroundColor);
    
    self.preferredContentSize = CGSizeMake(400, 421);
 
    // init form controls
    _authorTextField.placeholder = FLLocalizedString(@"placeholder_author");
    if ([FLAccount isLogin]) {
        _authorTextField.text = [FLAccount fullName];
    }

    [_cancelButton setTitle:FLLocalizedString(@"button_cancel")];
    [_addCommentButton setTitle:FLLocalizedString(@"button_add_comment") forState:UIControlStateNormal];
    _titleTextField.placeholder = FLLocalizedString(@"placeholder_title");
    
    _ratingStars.starsNumber  = kStarsNumber;
    _ratingStars.rating       = 0;
    _ratingStars.starsSpacing = kStarSpasing;
    _ratingStars.backColor    = FLHexColor(kColorStarBackground);
    _ratingStars.strokeWidth  = kStarStrokeWidh;
    _ratingStars.strokeColor  = FLHexColor(kColorStarStrok);
    _ratingStars.gradientCGColors = @[(id)FLHexColor(kColorStarGradient1).CGColor, (id)FLHexColor(kColorStarGradient2).CGColor];
    
    // show rating control regarding to settings
    if (![FLConfig boolWithKey:kConfigCommentsRatingModuleKey]) {
        _messageTopSpacingConstraint.constant = 15;
        _ratingStars.hidden = YES;
    }
    
    _messageTextView.placeholder      = FLLocalizedString(@"placeholder_message");
    _messageTextView.placeholderColor = FLHexColor(kColorPlaceholderFont);
    _messageTextView.delegate = self;
    _messageSymbolsLimit = [FLConfigWithKey(kConfigCommentSymbolsNumberKey) intValue];
    [self defineCharsLimitLabelText:_messageSymbolsLimit];
    
    // validation
    _validatorManager = [FLValidatorManager new];
    FLValiderRequired *requiredValider = [FLValiderRequired validerWithHint:FLLocalizedString(@"valider_fillin_the_field")];
    
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_authorTextField withValider:@[requiredValider]]];
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_titleTextField  withValider:@[requiredValider]]];
    
    FLInputControlValidator *messageValidator = [FLInputControlValidator validerWithInputControll:_messageTextView withValider:@[requiredValider]];
    messageValidator.tooltipPos = FLValidatorTooltipPosAbove | FLValidatorTooltipPosRight;
    [_validatorManager addValidator:messageValidator];
    
    // accessory toolbar
    _accessoryToolbar = [FLInputAccessoryToolbar toolbarWithInputItems:@[_authorTextField, _titleTextField, _messageTextView]];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    _accessoryToolbar.didDoneTapBlock = ^(id activeItem) {
        if (activeItem == _messageTextView) {
            [weakSelf submitForm];
        }
    };
    
    // keyboard handler
    _keyboardHandler = [[FLKeyboardHandler alloc] initWithScroll:self.scrollView];
    _keyboardHandler.delegate = self;
}

#pragma mark - Data

- (void)submitForm {
    if ([_validatorManager validate]) {
        [FLProgressHUD showWithStatus:FLLocalizedString(@"progress_adding")];

        [_addCommentButton setEnabled:NO];
        [self prepareCommentModel];

        NSInteger userId = [FLAccount isLogin] ? [FLAccount userId] : 0;

        [flynaxAPIClient postApiItem:kApiItemRequests
                          parameters:@{@"cmd"   : kApiItemRequests_addComment,
                                       @"lid"   : @(self.adId),
                                       @"aid"   : @(userId),
                                       @"title" : _commentModel.title,
                                       @"author": _commentModel.author,
                                       @"rating": @(_commentModel.rating),
                                       @"body"  : [_commentModel.body encodedString]}

                          completion:^(NSDictionary *result, NSError *error) {
                              if (error == nil && [result isKindOfClass:NSDictionary.class]) {
                                  if (result[kApiResultSuccessKey] != nil && [result[kApiResultSuccessKey] boolValue]) {

                                      NSDate *currentDate = [NSDate date];
                                      NSDateFormatter *dateFormatter = [NSDateFormatter new];
                                      [dateFormatter setDateFormat:@"MMM dd,yyyy"];
                                      _commentModel.date = [dateFormatter stringFromDate:currentDate];

                                      [FLProgressHUD showSuccessWithStatus:result[kApiResultMessageKey]];
                                      [self postNewCommentAddedNotification];
                                      [self dismiss];
                                  }
                                  else [FLProgressHUD showErrorWithStatus:result[kApiResultErrorKey]];
                              }
                              else [FLDebug showAdaptedError:error apiItem:kApiItemRequests_addComment];
                          }];
    }
}

- (void)prepareCommentModel {
    if (!_commentModel)
        _commentModel = [FLCommentModel new];
    
    _commentModel.title  = _titleTextField.text;
    _commentModel.author = _authorTextField.text;
    _commentModel.rating = _ratingStars.rating;
    _commentModel.body   = _messageTextView.text;
    _commentModel.status = [FLConfig boolWithKey:kConfigCommentAutoApprovalKey] ? FLCommentStatusActive : FLCommentStatusPending;
    
}

- (void)textViewDidChange:(UITextView *)textView {
    int left = _messageSymbolsLimit - (int)textView.text.length;
    if (left < 0) {
        left = 0;
        textView.text = [textView.text substringToIndex:_messageSymbolsLimit];
    }
    [self defineCharsLimitLabelText:left];
}

- (void)defineCharsLimitLabelText:(int)limit {
    
    NSString *string = F(FLLocalizedString(@"label_chars_limit_left"), limit);
    NSRange    range = [string rangeOfString:F(@"%d", limit)];
    
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

#pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_accessoryToolbar goToNextItem];
    return YES;
}

#pragma mark - FLKeyboardHandler delegate

- (void)keyboardHandlerDidHideKeyboard {
    if (_afterKeyboardDismiss) {
        [self dismiss];
    }
}

#pragma mark - Actions

- (void)postNewCommentAddedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewCommentAdded
                                                        object:_commentModel];
}

- (IBAction)addCommentButtonTaped:(UIButton *)sender {
    [self submitForm];
}

- (IBAction)cancelButtonTaped:(UIButton *)sender {
    _afterKeyboardDismiss = _keyboardHandler.isKeyboardOn;
    if (_afterKeyboardDismiss) {
        [self.view endEditing:YES];
    }
    else {
        [self dismiss];
    }
}

- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
