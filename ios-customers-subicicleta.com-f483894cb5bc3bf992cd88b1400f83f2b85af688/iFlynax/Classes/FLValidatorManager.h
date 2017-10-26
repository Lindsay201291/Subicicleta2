//
//  FLValidatorManager.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 9/28/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLInputControlValidator.h"
#import "FLValiderPasswordPolicy.h"
#import "FLValiderEqualInput.h"
#import "FLValiderRequired.h"
#import "FLValiderEmail.h"
#import "FLValiderURL.h"

@interface FLValidatorManager : NSObject

- (void)addValidator:(FLInputControlValidator *)validator;

- (BOOL)validate;

@end
