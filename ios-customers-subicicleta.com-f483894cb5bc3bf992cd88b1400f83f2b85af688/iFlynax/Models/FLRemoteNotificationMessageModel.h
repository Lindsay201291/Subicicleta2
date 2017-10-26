//
//  FLRemoteNotificationMessageModel.h
//  iFlynax
//
//  Created by Alex on 4/12/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import "FLRemoteNotificationModel.h"

@interface FLRemoteNotificationMessageModel : FLRemoteNotificationModel
@property (copy, nonatomic, readonly) NSString *sender;
@property (copy, nonatomic, readonly) NSString *message;
@property (strong, nonatomic, readonly) NSNumber *from;
@property (strong, nonatomic, readonly) NSNumber *admin;
@property (strong, nonatomic, readonly) UIImage *thumbnail;
@end
