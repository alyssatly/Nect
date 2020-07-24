//
//  FriendCell.m
//  Nect
//
//  Created by Alyssa Tan on 7/21/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "FriendCell.h"


@implementation FriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCell:(User *)user{
    self.user = user;
    self.displayPhotoView.layer.masksToBounds = YES;
    self.displayPhotoView.layer.cornerRadius = self.displayPhotoView.frame.size.height/2.2;
    self.displayPhotoView.layer.borderWidth = 0;

    self.displayPhotoView.image = [UIImage imageNamed:@"default_profile"];

    if(user.displayPhoto != nil){
        self.displayPhotoView.file = user.displayPhoto;
        [self.displayPhotoView loadInBackground];
    }
    self.displayNameLabel.text = user.displayName;
    if([self.displayNameLabel.text isEqualToString:@""] || self.displayNameLabel.text == nil){
        self.displayNameLabel.text = user.username;
    }
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.username];
}

@end
