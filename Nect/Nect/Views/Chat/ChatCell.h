//
//  ChatCell.h
//  Nect
//
//  Created by Alyssa Tan on 7/30/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "User.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface ChatCell : UITableViewCell

@property (strong, nonatomic) IBOutlet PFImageView *displayPhotoView;
@property (strong, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Message *message;

-(void)setCell:(Message *)message;

@end

NS_ASSUME_NONNULL_END
