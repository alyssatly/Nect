//
//  FriendsViewController.h
//  Nect
//
//  Created by Alyssa Tan on 7/21/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NectViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FriendsViewController : UIViewController

@property (strong, nonatomic) NectViewController *nectViewController;
-(void)getFriends;

@end

NS_ASSUME_NONNULL_END
