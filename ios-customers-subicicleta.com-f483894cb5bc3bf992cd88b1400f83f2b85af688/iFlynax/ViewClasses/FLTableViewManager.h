//
//  FLTableViewManager.h
//  iFlynax
//
//  Created by Alex on 3/4/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "RETableViewManager.h"
#import "RETableViewOptionsController.h"
// fields
#import "FLFieldBool.h"
#import "FLFieldText.h"
#import "FLFieldMixed.h"
#import "FLFieldRadio.h"
#import "FLFieldSelect.h"
#import "FLFieldNumber.h"
#import "FLFieldTextArea.h"
#import "FLFieldCheckbox.h"
#import "FLFieldAccept.h"
#import "FLFieldPhone.h"
#import "FLFieldDate.h"

@interface FLTableViewManager : RETableViewManager
@property (strong, readonly, nonatomic) NSDictionary *formValues;
@property (assign, nonatomic) BOOL formAccepted;
@property (copy, nonatomic) NSString *fieldAcceptTitle;

+ (instancetype)withTableView:(UITableView *)tableview;

- (BOOL)isValidForm;
- (void)resetForm;

@end
