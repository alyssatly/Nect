//
//  NectViewController.h
//  Nect
//
//  Created by Alyssa Tan on 7/13/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NectViewController : UIViewController

-(void)refreshInfo;
-(void)updateFilters:(NSString *)gender young:(NSInteger)young old:(NSInteger)old country:(NSString *)country;

@end

NS_ASSUME_NONNULL_END
