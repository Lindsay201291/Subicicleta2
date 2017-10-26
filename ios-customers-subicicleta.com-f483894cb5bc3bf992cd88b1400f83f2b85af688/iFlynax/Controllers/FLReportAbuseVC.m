//
//  FLReportAbuseVC.m
//  iFlynax
//
//  Created by Alex on 2/13/17.
//  Copyright © 2017 Flynax. All rights reserved.
//

#import "FLReportAbuseVC.h"

@interface FLReportAbuseVC ()
@property (weak, nonatomic) IBOutlet UITextView *reportReasonTextView;
@end

@implementation FLReportAbuseVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    _reportReasonTextView.text = @"";
    [_reportReasonTextView becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = FLLocalizedString(@"reportAbuse_sheet_item");
}

- (FLNavigationController *)flNavigationController {
    if (!_flNavigationController) {
        _flNavigationController = [[FLNavigationController alloc] initWithRootViewController:self];

        UIBarButtonItem *cancelButton;
        cancelButton = [[UIBarButtonItem alloc] initWithTitle:FLLocalizedString(@"reportAbuse_button_cancel")
                                                      style:UIBarButtonItemStyleBordered
                                                     target:self
                                                     action:@selector(cancelButtonDidTap)];
        self.navigationItem.leftBarButtonItem = cancelButton;

        UIBarButtonItem *reportButton;
        reportButton = [[UIBarButtonItem alloc] initWithTitle:FLLocalizedString(@"reportAbuse_button_report")
                                                        style:UIBarButtonItemStyleBordered
                                                       target:self
                                                       action:@selector(sendButtonDidTap)];
        self.navigationItem.rightBarButtonItem = reportButton;
    }
    return _flNavigationController;
}

#pragma mark - Actions

- (void)cancelButtonDidTap {
    [FLProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendButtonDidTap {
    if ([_reportReasonTextView.text isEmpty]) {
        [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"reportAbuse_empty_message_error")];
    }
    else {
        [FLProgressHUD showWithStatus:FLLocalizedString(@"processing")];

        [flynaxAPIClient
         postApiItem:kApiItemRequests
         parameters:@{@"cmd"    : kApiItemRequests_reportAbuse,
                      @"lid"    : @(self.lId),
                      @"message": _reportReasonTextView.text}

         completion:^(NSDictionary *response, NSError *error) {
            if (error == nil) {
                if (FLTrueBool(response[@"success"])) {
                    [self dismissViewControllerAnimated:YES completion:^{
                        [FLProgressHUD showSuccessWithStatus:FLLocalizedString(@"reportAbuse_successfully_sent")];
                    }];
                }
                else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"reportAbuse_failed_to_send")];
            }
            else [FLDebug showAdaptedError:error apiItem:kApiItemRequests_reportAbuse];
        }];
    }
}

@end
