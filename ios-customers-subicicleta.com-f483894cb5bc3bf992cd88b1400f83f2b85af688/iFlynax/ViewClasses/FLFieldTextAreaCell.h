//
//  FLFieldTextAreaCell.h
//  iFlynax
//
//  Created by Alex on 8/31/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldTextArea.h"
#import "FLFieldCell.h"
#import "FLTextView.h"

@interface FLFieldTextAreaCell : FLFieldCell
@property (strong, nonatomic) FLFieldTextArea *item;
@property (weak, nonatomic) IBOutlet FLTextView *textView;
@end
