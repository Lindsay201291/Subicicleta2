//
//  FLTopNotificationView.m
//  iFlynax
//
//  Created by Alex on 4/11/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import "FLTopNotificationView.h"

@implementation FLTopNotificationView

+ (void)showNewMessageNotificationFrom:(NSString *)author
                               message:(NSString *)message
                               onTouch:(dispatch_block_t)onTouch
{
    UIImage *messageIcon = [UIImage imageNamed:@"message_icon"];
    NSString *title = FLLocalizedStringReplace(@"notification_new_message_by", @"{name}", author);

    [FLTopNotificationView showNotificationViewWithImage:messageIcon title:title message:message isAutoHide:YES onTouch:^{
        [FLTopNotificationView hideNotificationView];

        if (onTouch != nil) {
            onTouch();
        }
    }];
}

@end
