//
//  FLYTAddingViewController.h
//  
//
//  Created by Evgeniy Novikov on 10/9/15.
//
//

#include "FLNavigationController.h"
#include "FLYouTubeMGItemModel.h"

@protocol FLYTAddingDelegate;

@interface FLYTAddingViewController : UIViewController

+ (instancetype)controllerWithClassNibName;
+ (instancetype)controllerWithNibName:(NSString *)nibName;

- (void)clearForm;

@property (weak, readonly, nonatomic) FLNavigationController *flNavigationController;
@property (weak, nonatomic) id<FLYTAddingDelegate> delegate;

@end

@protocol FLYTAddingDelegate <NSObject>

@optional

- (void)ytAddingController:(FLYTAddingViewController *)controller didFinishWith:(FLYouTubeMGItemModel *)model;

@end