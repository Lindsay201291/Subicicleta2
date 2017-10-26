//
//  FLRemoteNotifications.m
//  iFlynax
//
//  Created by Alex on 10/29/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLRemoteNotifications.h"
#import "FLMainNavigation.h"
#import "FLRootView.h"

#import "FLTopNotificationView.h"
#import "FLMyMessagesView.h"
#import "FLMessaging.h"

#import "FLRemoteNotificationMessageModel.h"

static NSString * const kDevicePushTokenKey = @"com.flynax.device.pushToken";

@interface FLRemoteNotifications ()
@property (copy, nonatomic) dispatch_block_t switchToMessanger;
@end

@implementation FLRemoteNotifications

+ (instancetype)sharedInstance {
    static FLRemoteNotifications *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

+ (void)registerDevice {
    if ([self isRegisteredForRemoteNotifications])
        return;

    UIApplication *application = [UIApplication sharedApplication];

    // iOS 8+
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    else {
        UIRemoteNotificationType types = UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        [application registerForRemoteNotificationTypes:types];
    }
}

+ (void)unRegisterDevice {
//    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

+ (BOOL)isRegisteredForRemoteNotifications {
    UIApplication *application = [UIApplication sharedApplication];

    // iOS 8+
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        return [application isRegisteredForRemoteNotifications];
    }
    return [application enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone;
}

+ (NSString *)deviceTokenForRemoteNotifications {
    return FLTrueString([[NSUserDefaults standardUserDefaults] objectForKey:kDevicePushTokenKey]);
}

+ (void)sendDeviceTokenToAPI:(NSData *)token {
    NSString *pushToken = [token description];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@" " withString:@""];

    [flynaxAPIClient postApiItem:kApiItemRequests
                      parameters:@{@"cmd"       : kApiItemRequests_registerForRemoteNotification,
                                   @"push_token": pushToken}
                      completion:^(NSDictionary *response, NSError *error) {
                          if (!error && [response isKindOfClass:NSDictionary.class]) {
                              if (!FLTrueBool(response[@"success"])) {
                                  // TODO: some changes
                              }
                          }
                      }];

    // save the token for future purpose
    [[NSUserDefaults standardUserDefaults] setObject:pushToken forKey:kDevicePushTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Handle Received Notifications

+ (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary *notification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    [[FLRemoteNotifications sharedInstance] didReceiveRemoteNotification:notification fromState:UIApplicationStateInactive];
}

+ (void)didReceiveRemoteNotification:(NSDictionary *)notification {
    UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
    [[FLRemoteNotifications sharedInstance] didReceiveRemoteNotification:notification fromState:appState];
}

- (void)didReceiveRemoteNotification:(NSDictionary *)dictionary fromState:(UIApplicationState)appState {
    FLRemoteNotificationAction notificationAction = FLTrueInteger(dictionary[kNotifyApsKey][kNotifyActionKey]);
    UIViewController *visibleVC;
    FLMainNavigation *mainNC;

    @try {
        FLRootView *rootView = (FLRootView *)[[UIApplication sharedApplication] keyWindow].rootViewController;
        mainNC = (FLMainNavigation *)rootView.contentViewController;

        if ([mainNC isKindOfClass:FLMainNavigation.class]) {
            visibleVC = mainNC.visibleViewController;
        }
    } @catch (NSException *exception) {
        NSLog(@"didReceiveRemoteNotification[exception]: %@", exception.reason);
    } @finally {
        // Code that gets executed whether or not an exception is thrown
    }

    if (!mainNC || !visibleVC) {
        return;
    }

    if (notificationAction == FLRemoteNotificationActionMessages) {
        FLRemoteNotificationMessageModel *notification = [FLRemoteNotificationMessageModel fromDictionary:dictionary];
        __block FLMessaging *newMessanger = nil;

        dispatch_block_t _switchToMessanger_ReflectOnState = ^{
            if (appState == UIApplicationStateActive) {
                [FLTopNotificationView showNewMessageNotificationFrom:notification.sender message:notification.message onTouch:^{
                    _switchToMessanger();
                }];
            }
            else if (appState == UIApplicationStateInactive) {
                _switchToMessanger();
            }
        };

        dispatch_block_t _initMessanger = ^{
            newMessanger = [mainNC.storyboard instantiateViewControllerWithIdentifier:kStoryBoardMessagingView];
            newMessanger.partnerImage = notification.thumbnail;
            newMessanger.recipient = notification.from;
            newMessanger.title = notification.sender;
        };

        if (visibleVC.class == FLMessaging.class) {
            FLMessaging *messanger = (FLMessaging *)visibleVC;
            
            if ([notification.from isEqualToNumber:messanger.recipient]) {
                messanger.partnerImage = notification.thumbnail;
                [messanger appendRemoteMessage:notification.message];
            }
            else {
                _switchToMessanger = ^{
                    _initMessanger();
                    
                    NSMutableArray *_viewControllers = [mainNC.viewControllers mutableCopy];
                    [_viewControllers removeObject:messanger];
                    [_viewControllers addObject:newMessanger];
                    
                    [mainNC setViewControllers:_viewControllers animated:YES];
                };
                _switchToMessanger_ReflectOnState();
            }
        }
        else if (visibleVC.class == FLMyMessagesView.class) {
            FLMyMessagesView *myMessageList = (FLMyMessagesView *)visibleVC;
            [myMessageList refreshConversations];
        }
        else {
            _switchToMessanger = ^{
                _initMessanger();

                if (mainNC.presentedViewController) {
                    [mainNC.presentedViewController presentViewController:newMessanger.flNavigationController animated:YES completion:nil];
                }
                else {
                    FLMyMessagesView *myMessagesList =
                    [mainNC.storyboard instantiateViewControllerWithIdentifier:kStoryBoardMyMessagesView];
                    FLNavigationController *myMessagesNC = myMessagesList.flNavigationController;

                    [mainNC presentViewController:myMessagesNC animated:YES completion:^{
                        [myMessagesNC pushViewController:newMessanger animated:NO];
                    }];
                }
            };
            _switchToMessanger_ReflectOnState();
        }
    }
}

@end
