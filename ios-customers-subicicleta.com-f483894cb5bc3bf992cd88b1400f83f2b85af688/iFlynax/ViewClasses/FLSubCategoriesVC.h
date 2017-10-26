//
//  FLSubCategoriesVC.h
//  iFlynax
//
//  Created by Alex on 2/9/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FLSubCategoriesVCDelegate <NSObject>
@required
- (void)fillUpSubCategoryCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withData:(NSDictionary *)data;
- (void)goToSubCategoryWithData:(NSDictionary *)data;
@end

@interface FLSubCategoriesVC : UITableViewController
@property (weak, nonatomic) id<FLSubCategoriesVCDelegate> parentVC;
@property (nonatomic, strong) NSArray<NSDictionary *> *entries;
@end
