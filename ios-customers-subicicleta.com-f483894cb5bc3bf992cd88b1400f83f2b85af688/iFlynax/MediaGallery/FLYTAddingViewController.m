//
//  FLYTAddingViewController.m
//  
//
//  Created by Evgeniy Novikov on 10/9/15.
//
//

#import "FLYTAddingViewController.h"
#import "FLTextField.h"
#import "YTPlayerView.h"
#import "FLYTPreviewer.h"
#import "FLValidatorManager.h"
#import "FLKeyboardHandler.h"
#import "FLYTVideoIdValider.h"
#import "FLInputAccessoryToolbar.h"
#import "FLYouTubeMGItemModel.h"

@interface FLYTAddingViewController ()<FLKeyboardHandlerDelegate, YTPlayerViewDelegate>

@property (weak, nonatomic) IBOutlet FLTextField *ytUrlOrIdField;
@property (weak, nonatomic) IBOutlet FLYTPreviewer *ytPlayerView;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet FLYTPreviewerCoverView *coverView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) FLYouTubeMGItemModel *activeYouTubeModel;

@end

@implementation FLYTAddingViewController {
    FLNavigationController *_flNavigationController;
    FLInputAccessoryToolbar *_accessoryToolbar;
    UIBarButtonItem *_barCancelButton;
    FLValidatorManager *_validatorManager;
    FLKeyboardHandler *_keyboardHandler;
    BOOL _afterKeyboardDismiss;
    FLYTVideoIdValider *_ytIdValider;
    FLInputControlValidator *_ytFieldValidator;
    BOOL _isFirstPreview;
}

+ (instancetype)controllerWithClassNibName {
    return [self controllerWithNibName:NSStringFromClass(self)];
}

+ (instancetype)controllerWithNibName:(NSString *)nibName {
    return [[self alloc] initWithNibName:nibName bundle:nil];
}

- (FLNavigationController *)flNavigationController {
    if (!_flNavigationController) {
        _flNavigationController = [[FLNavigationController alloc] initWithRootViewController:self];
        
        _barCancelButton = [[UIBarButtonItem alloc] initWithTitle:FLLocalizedString(@"button_cancel")
                                                                                 style:UIBarButtonItemStyleBordered
                                                                                target:self
                                                                                action:@selector(barCancelButtonDidTap:)];
        self.navigationItem.leftBarButtonItem = _barCancelButton;
        
    }
    return _flNavigationController;
}

#pragma mark - Life Cirlce

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = FLLocalizedString(@"yt_controller_title");
    self.view.backgroundColor = FLHexColor(kColorBackgroundColor);
    
    _statusLabel.textColor = FLHexColor(kColorPlaceholderFont);

    _ytUrlOrIdField.placeholder = FLLocalizedString(@"placeholder_yt_url_or_id");
    _ytUrlOrIdField.text = @"";
    [_addButton setTitle:FLLocalizedString(@"button_add") forState:UIControlStateNormal];
    _ytPlayerView.delegate = self;
    
    // validation inits
    //_validatorManager = [FLValidatorManager new];
    //FLValiderRequired *inputRequiredValider = [FLValiderRequired validerWithHint:FLLocalizedString(@"valider_fillin_the_field")];
    _ytIdValider = [FLYTVideoIdValider validerWithHint:FLLocalizedString(@"valider_yt_valid_url_or_id")];
    _ytIdValider.autoHinted = NO;
    
    //[_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_ytUrlOrIdField withValider:@[inputRequiredValider]]];
     _ytFieldValidator = [FLInputControlValidator validerWithInputControll:_ytUrlOrIdField withValider:@[_ytIdValider]];
    
    // keyboard handler
    _keyboardHandler = [[FLKeyboardHandler alloc] initWithScroll:self.scrollView];
    _keyboardHandler.delegate = self;
    
    // accessory toolbar
    _accessoryToolbar = [FLInputAccessoryToolbar toolbarWithInputItems:@[_ytUrlOrIdField]];
    __unsafe_unretained typeof(self) weakSelf = self;
    _accessoryToolbar.didDoneTapBlock = ^(id activeItem) {
            [weakSelf submitForm];
    };
    
    _isFirstPreview = YES;
    
    [self clearForm];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)clearForm {
    [self showPreviewMessage];
    _ytUrlOrIdField.text = @"";
}

- (void)showPreviewMessage {
    [self showMessage:FLLocalizedString(@"yt_preview") withLoading:NO];
}

- (void)showLoadingMessage {
    [self showMessage:FLLocalizedString(@"yt_preview_loading") withLoading:YES];
}

- (void)showMessage:(NSString *)message withLoading:(BOOL)loading {
    _statusLabel.text = message;
    
    _activityIndicator.hidden = !loading;
    _ytUrlOrIdField.enabled   = !loading;
    
    if (loading) {
        [_activityIndicator startAnimating];
    }
    else {
        [_ytUrlOrIdField becomeFirstResponder];
        [_activityIndicator stopAnimating];
    }
    
    if (!_coverView.alpha) {
        [self coverFideInWithCompletition:nil];
    }

}

- (void)showPreviewView {
    [self coverFideOutWithCompletition:nil];
    _ytUrlOrIdField.enabled = YES;
}

- (void)coverFideOutWithCompletition:(void(^)(BOOL finished))completion {
    _coverView.alpha = 1;
    [UIView animateWithDuration:.3f
                     animations:^{
                         _coverView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion(finished);
                         }
                     }];
}

- (void)coverFideInWithCompletition:(void(^)(BOOL finished))completion {
    _coverView.alpha = 0;
    [UIView animateWithDuration:.3f
                     animations:^{
                         _coverView.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion(finished);
                         }
                     }];
}

#pragma mark - Actions

- (void)textFieldDidChange:(NSNotification *)notification {
    [self showMessage:FLLocalizedString(@"yt_preview") withLoading:NO];
    if (_ytFieldValidator.isValid) {
        if (![_activeYouTubeModel.youTubeId isEqualToString:_ytIdValider.extractedVideoId]) {
            [self showLoadingMessage];
            [self validatePreviewById:_ytIdValider.extractedVideoId];
        }
        else {
            [self showPreviewView];
        }
    }
}

- (IBAction)addButtonDidTap:(UIButton *)sender {
    [self submitForm];
}

- (void)submitForm {
    if (!_ytFieldValidator.isValid) {
        _ytFieldValidator.tooltipMessage = _ytIdValider.hint;
        [_ytFieldValidator showHideTooltipInDelay:3.0f];
    }
    else {
        [self dismiss];
        if (_delegate && [_delegate respondsToSelector:@selector(ytAddingController:didFinishWith:)]) {
            [_delegate ytAddingController:self didFinishWith:_activeYouTubeModel];
        }
    }
}

- (void)validatePreviewById:(NSString *)youTubeId {
    [FLYouTubeMGItemModel loadWithYouTubeId: youTubeId
                                    success:^(FLYouTubeMGItemModel *model) {
                                        [self loadModelPreview:model];
                                    }
                                    failure:^(FLYouTubeMGItemModel *model, NSString *errorDiscription) {
                                        _activeYouTubeModel = nil;
                                        [self showMessage:errorDiscription withLoading:NO];
                                    }];
}

- (void)loadModelPreview:(FLYouTubeMGItemModel *)model {
    _activeYouTubeModel = model;
    [_ytPlayerView previewFromVideoId:model.youTubeId];
    
    if (!_isFirstPreview) {
        [self showPreviewView];
    }
    else {
        _isFirstPreview = NO;
    }
}

#pragma mark - FLKeyboardHandler delegate

- (void)keyboardHandlerDidHideKeyboard {
    if (_afterKeyboardDismiss) {
        [self dismiss];
    }
}

#pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self submitForm];
    return YES;
}

#pragma mark - YouTube Player Delegate

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView {
    [self showPreviewView];
}

#pragma mark - Navigation

- (void)barCancelButtonDidTap:(UIButton *)button {
    _afterKeyboardDismiss = _keyboardHandler.isKeyboardOn;
    if (_afterKeyboardDismiss) {
        [self.view endEditing:YES];
    }
    else [self dismiss];
}

- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

@end
