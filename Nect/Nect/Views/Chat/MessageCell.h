//
//  MessageCell.h
//  Nect
//
//  Created by Alyssa Tan on 7/30/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIView *bubbleView;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel; 
@property (strong, nonatomic) Message *message;

@property (strong, nonatomic) IBOutlet UIView *bubbleView2;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel2;
@property (strong, nonatomic) IBOutlet UIImageView *gifView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageBottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageLeft;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageRight;

-(void)setCell:(Message *)message;
@end

NS_ASSUME_NONNULL_END
