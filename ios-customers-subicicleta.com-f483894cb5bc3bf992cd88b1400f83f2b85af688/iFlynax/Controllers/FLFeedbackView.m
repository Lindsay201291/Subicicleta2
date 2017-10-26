//
//  FLFeedbackView.m
//  iFlynax
//
//  Created by Alex on 3/30/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFeedbackView.h"

@interface FLFeedbackView () <CTFeedbackViewControllerDelegate, REFrostedViewControllerDelegate>
@end

@implementation FLFeedbackView

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.localizedTopics = [self defaultLocalizedTopics];
        self.topics          = [self defaultTopics];

        self.hidesAdditionalContent = YES;
        self.useHTML                = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = FLLocalizedString(@"screen_feedback");
    self.selectSubjectScreenTitle = FLLocalizedString(@"screen_feedback_select_subject");    

    self.navigationItem.leftBarButtonItem = ({
        UIBarButtonItem *button;
        button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburger"]
                                                  style:UIBarButtonItemStyleBordered target:self
                                                 action:@selector(displaySwipeMenu)];
        button;
    });
    [self.navigationItem.rightBarButtonItem setTitle:FLLocalizedString(@"button_mail")];
}

// @override
- (NSArray *)defaultTopics {
    return @[@"feedback",
             @"bug_report",
             @"feature_request",
             @"contact_us"];
}
// @override
- (NSArray *)defaultLocalizedTopics {
    return @[FLLocalizedString(@"feedback_feedback"),
             FLLocalizedString(@"feedback_feature_request"),
             FLLocalizedString(@"feedback_contact_us"),
             FLLocalizedString(@"feedback_bug_report")];
}
// @override
- (NSArray *)toRecipients {
    return @[FLConfigWithKey(@"feedback_email")];
}
// @override
- (NSArray *)deviceInfoCellItems {
    return @[];
}
// @override
- (NSArray *)appInfoCellItems {
    return @[];
}
// @override
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}
// @override
- (NSString *)topicCellTitle {
    return FLLocalizedString(@"feedback_subject");
}

#pragma mark - Navigation

- (void)frostedViewController:(REFrostedViewController *)frostedViewController
   willShowMenuViewController:(UIViewController *)menuViewController
{
    [self.view endEditing:YES];
}

- (void)displaySwipeMenu {
    [self.frostedViewController presentMenuViewController];
}

- (void)feedbackViewController:(CTFeedbackViewController *)controller didFinishWithMailComposeResult:(MFMailComposeResult)result
                         error:(NSError *)error {
    if (!error) {
        [FLProgressHUD showSuccessWithStatus:FLLocalizedString(@"feedback_completed")];
    }
    else [FLDebug showAdaptedError:error apiItem:@"sendFeedback"];
}

@end
