//
//  FLFieldCell.h
//  iFlynax
//
//  Created by Alex on 10/5/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "RETableViewCell.h"

@interface FLFieldCell : RETableViewCell
@property (nonatomic, strong) UILabel *fieldPlaceholder;

- (void)highlightInput:(id)input highlighted:(BOOL)highlighted;
@end
