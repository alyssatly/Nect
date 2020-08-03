//
//  DetailedChatViewController.h
//  Nect
//
//  Created by Alyssa Tan on 7/30/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailedChatViewController : UIViewController

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Message *message;


@end

NS_ASSUME_NONNULL_END
