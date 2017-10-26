//
//  FLValider.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 9/28/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

@interface FLValider : NSObject

@property (nonatomic, getter=isAutoValidated) BOOL autoValidated;
@property (nonatomic, copy) NSString *hint;
@property (nonatomic, getter=IsAutoHinted) BOOL autoHinted;

+ (instancetype)validerWithHint:(NSString *)hint;

- (instancetype)initWithHint:(NSString *)hint;
- (BOOL)validate:(id)subject;

@end
