//
//  FLFieldBoolCell.m
//  iFlynax
//
//  Created by Alex on 8/31/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldBoolCell.h"

@interface FLFieldBoolCell ()
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@end

@implementation FLFieldBoolCell
@dynamic item;

- (void)cellDidLoad {
    [super cellDidLoad];

    [_switchView addTarget:self action:@selector(switchValueDidChange:)
          forControlEvents:UIControlEventEditingChanged];
}

- (void)cellWillAppear {
    self.switchView.on = self.item.value;
    self.titleLabel.text = self.item.model.name;
}

#pragma mark - Handle events

- (void)switchValueDidChange:(UISwitch *)sender {
    self.item.value = sender.isOn;

    if (self.item.switchValueChangeHandler) {
        self.item.switchValueChangeHandler(self.item);
    }
}

@end
