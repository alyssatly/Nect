//
//  UserProfileViewController.h
//  Nect
//
//  Created by Alyssa Tan on 7/20/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "RequestsViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserProfileViewController : UIViewController

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) RequestsViewController *requestViewController;

@end

NS_ASSUME_NONNULL_END
