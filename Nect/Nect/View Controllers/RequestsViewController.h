//
//  RequestsViewController.h
//  Nect
//
//  Created by Alyssa Tan on 7/20/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface RequestsViewController : UIViewController

@property (strong, nonatomic)User *user;

-(void)getRequests;

@end

NS_ASSUME_NONNULL_END
