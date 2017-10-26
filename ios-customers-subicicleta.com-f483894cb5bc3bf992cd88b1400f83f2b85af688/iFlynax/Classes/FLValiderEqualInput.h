//
//  FLValiderEqualInput.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/6/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLValider.h"

@interface FLValiderEqualInput : FLValider

+ (instancetype)validerWithControl:(id)control withHint:(NSString *)hint;

@end
