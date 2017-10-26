//
//  FLMediaUploader.h
//  iFlynax
//
//  Created by Alex on 10/22/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLMediaUploader : NSObject

+ (instancetype)sharedInstance;

+ (void)uploadItems:(NSArray *)items forListingId:(NSInteger)listingId
     withCompletion:(dispatch_block_t)completionBlock;

@end
