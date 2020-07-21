//
//  FriendCell.h
//  Nect
//
//  Created by Alyssa Tan on 7/21/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "RequestsViewController.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface FriendCell : UITableViewCell

@property (strong, nonatomic) IBOutlet PFImageView *displayPhotoView;
@property (strong, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) RequestsViewController *requestsViewController;
@property (strong, nonatomic)User *user;

- (void)setCell:(User *)user;

@end

NS_ASSUME_NONNULL_END
