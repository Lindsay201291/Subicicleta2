//
//  FLMessaging.m
//  iFlynax
//
//  Created by Alex on 6/22/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLMyMessagesView.h"
#import "FLMessaging.h"
#import "FLMessage.h"

static NSString * const kResponseKeyRecipientPhoto = @"recipientPhoto";
static NSString * const kResponseKeyMessages       = @"messages";

@interface FLMessaging () {
    FLNavigationController *_flNavigationController;
    BOOL _websiteVisitor;
}
@property (strong, nonatomic) NSMutableArray *dataSource;
@end

@implementation FLMessaging

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.alpha = 0;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0);
    self.view.backgroundColor = self.tableView.backgroundColor = FLHexColor(kColorBackgroundColor);
    self.dataSource = [NSMutableArray array];

    [FLBlankSlate attachTo:self.tableView
                 withTitle:FLLocalizedString(@"blankSlate_messages_title")
                   message:FLLocalizedString(@"blankSlate_messages_message")];

    _websiteVisitor = [_recipient isEqualToNumber:@(kUserWebsiteVisitor)];

    if (_websiteVisitor) {
        [self.messageInputView removeFromSuperview];
    }
    else {
        self.messageInputView.mediaButton.hidden = YES;
        [self.messageInputView.sendButton setBackgroundImage:[UIImage imageNamed:@"button1"] forState:UIControlStateNormal];
        [self.messageInputView.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.messageInputView.sendButton setTitle:FLLocalizedString(@"button_message_send") forState:UIControlStateNormal];
        self.messageInputView.textView.placeholderText = FLLocalizedString(@"placeholder_type_message");

        CGRect inputFrame = self.messageInputView.textView.frame;
        CGFloat xDiff = inputFrame.origin.x - 30;
        CGFloat xOfset = 20;
        inputFrame.origin.x = xOfset;
        inputFrame.size.width += (xDiff - (xOfset/2)) + 11;
        self.messageInputView.textView.frame = inputFrame;
        
        CGRect bgImageFrame = self.messageInputView.textBgImageView.frame;
        bgImageFrame.origin.x = 15;
        bgImageFrame.size.width = inputFrame.size.width + 5;
        self.messageInputView.textBgImageView.frame = bgImageFrame;
        
        CGRect sendBtnFrame = self.messageInputView.sendButton.frame;
        sendBtnFrame.origin.x = bgImageFrame.origin.x + bgImageFrame.size.width;
        self.messageInputView.sendButton.frame = sendBtnFrame;
    }
    [self loadMessages];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if ([self.navigationController.topViewController isKindOfClass:FLMyMessagesView.class]) {
        FLMyMessagesView *topVC = (FLMyMessagesView *)self.navigationController.topViewController;
        [topVC refreshConversations];
    }
}

- (void)appendRemoteMessage:(NSString *)message {
    [self addNewMessage:message fromMe:NO];
}

- (void)loadMessages {
    [flynaxAPIClient getApiItem:kApiItemRequests
                     parameters:@{@"cmd"      : kApiItemRequests_fetchMessages,
                                  @"recipient": _websiteVisitor ? _visitorMail : _recipient}
                     completion:^(NSDictionary *response, NSError *error) {
                         if (error == nil && [response isKindOfClass:NSDictionary.class]) {
                             if (response[kResponseKeyMessages] != nil && [response[kResponseKeyMessages] count]) {
                                 NSArray *messages = response[kResponseKeyMessages];
                                 [self.dataSource removeAllObjects];

                                 [messages enumerateObjectsUsingBlock:^(NSDictionary *entry, NSUInteger idx, BOOL *stop) {
                                     FLMessage *message = [[FLMessage alloc] init];
                                     message.date = [NSDate dateWithTimeIntervalSince1970:FLTrueInteger(entry[@"date"])];
                                     message.fromMe = (entry[@"me"] != nil && [entry[@"me"] boolValue]);
                                     message.text = FLCleanString(entry[@"message"]);
                                     message.type = SOMessageTypeText;

                                     [self.dataSource addObject:message];
                                 }];

                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [self refreshMessages];
                                 });
                             }
                             else if (response[@"error"] != nil) {
                                 [FLProgressHUD showErrorWithStatus:FLCleanString(response[@"error"])];
                             }

                             [UIView animateWithDuration:.3f animations:^{
                                 [self.tableView setAlpha:1];
                             }];
                         }
                         else [FLDebug showAdaptedError:error apiItem:kApiItemRequests_fetchMessages];
                     }];
}

#pragma mark - SOMessaging data source

- (NSMutableArray *)messages {
    return self.dataSource;
}

- (UIImage *)balloonImageForSending {
    UIImage *bubble = [UIImage imageNamed:@"bubble"];
    return [bubble resizableImageWithCapInsets:UIEdgeInsetsMake(17, 21, 16, 27)];
}

- (UIImage *)balloonImageForReceiving {
    UIImage *bubble = [UIImage imageNamed:@"bubbleReceive.png"];
    return [bubble resizableImageWithCapInsets:UIEdgeInsetsMake(17, 27, 21, 17)];
}

- (NSTimeInterval)intervalForMessagesGrouping {
    return 3600; // 1 hour
}

- (void)configureMessageCell:(SOMessageCell *)cell forMessageAtIndex:(NSInteger)index {
    FLMessage *message = self.dataSource[index];

    cell.backgroundColor    = FLHexColor(kColorBackgroundColor);
    cell.textView.textColor = FLHexColor(@"1b1b1b");

    // Adjusting content for 3pt. (In this demo the width of bubble's tail is 6pt)
    if (!message.fromMe) {
        cell.contentInsets = UIEdgeInsetsMake(0, 3.0f, 0, 0); //Move content for 3 pt. to right
    }
    else {
        cell.contentInsets = UIEdgeInsetsMake(0, 0, 0, 3.0f); //Move content for 3 pt. to left
    }

    if (!message.fromMe) {
        cell.userImageView.autoresizingMask   = UIViewAutoresizingFlexibleBottomMargin;
        cell.userImageView.contentMode        = UIViewContentModeScaleAspectFit;
        cell.userImageView.backgroundColor    = FLHexColor(@"eeeeee");

        cell.userImageView.layer.borderColor  = [UIColor whiteColor].CGColor;
        cell.userImageView.layer.borderWidth  = 2;
        cell.userImageView.layer.cornerRadius = 0;

        cell.userImage = self.partnerImage;
    }
    else {
        cell.userImageView = nil;
    }
}

- (CGSize)userImageSize {
    return CGSizeMake(40, 40);
}

#pragma mark - SOMessaging delegate

- (void)addNewMessage:(NSString *)message fromMe:(BOOL)myMessage {
    FLMessage *msg = [[FLMessage alloc] init];

    msg.text   = message;
    msg.fromMe = myMessage;
    msg.date   = [NSDate date];

    if (myMessage)
        [self sendMessage:msg];
    else
        [self receiveMessage:msg];
}

- (void)messageInputView:(SOMessageInputView *)inputView didSendMessage:(NSString *)message {
    if (![[message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] || !_recipient) {
        return;
    }
    [self addNewMessage:message fromMe:YES];

    [flynaxAPIClient postApiItem:kApiItemRequests
                      parameters:@{@"cmd"      : kApiItemRequests_sendMessageTo,
                                   @"recipient": _recipient,
                                   @"message"  : [message encodedString]}
                      completion:^(NSDictionary *result, NSError *error) {
                          if (error == nil && [result isKindOfClass:NSDictionary.class]) {
                              if (result[@"sent"] != nil && [result[@"sent"] boolValue]) {
                                  // todo st like on system messages. put (!)
                              }
                              else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"iflynax+messages+not_delivered")];
                          }
                          else [FLDebug showAdaptedError:error apiItem:kApiItemRequests_sendMessageTo];
                      }];
}

#pragma mark - Navigation

- (FLNavigationController *)flNavigationController {
    if (!_flNavigationController) {
        _flNavigationController = [[FLNavigationController alloc] initWithRootViewController:self];
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:FLLocalizedString(@"button_cancel")
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self
                                                                        action:@selector(cancelButtonDidTap:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    return _flNavigationController;
}

- (void)cancelButtonDidTap:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
