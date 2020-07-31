//
//  ChatCell.m
//  Nect
//
//  Created by Alyssa Tan on 7/30/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "ChatCell.h"
#import "DateTools.h"

@implementation ChatCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setCell:(Message *)message{
    self.message = message;
    if(self.message.message == nil){
        self.lastMessageLabel.text = self.message.gif;
    }else{
        self.lastMessageLabel.text = self.message.message;
    }
    self.timeLabel.text = [self.message.createdAt timeAgoSinceNow];
    //fecth user
    NSString *friend = @"";
    if([self.message.sender isEqualToString:[[PFUser currentUser] fetch][@"username"]]){
        friend = self.message.receiver;
    }else{
        friend = self.message.sender;
    }
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:friend];
    [query findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
        if (requests.count != 0) {
            self.user = [[User alloc] initWithUser:requests[0]];
            self.displayPhotoView.layer.masksToBounds = YES;
            self.displayPhotoView.layer.cornerRadius = self.displayPhotoView.frame.size.height/2.2;
            self.displayPhotoView.layer.borderWidth = 0;
            
            self.displayPhotoView.image = [UIImage imageNamed:@"default_profile"];
            
            if(self.user.displayPhoto != nil){
                self.displayPhotoView.file = self.user.displayPhoto;
                [self.displayPhotoView loadInBackground];
            }
            self.displayNameLabel.text = self.user.displayName;
            if([self.displayNameLabel.text isEqualToString:@""] || self.displayNameLabel.text == nil){
                self.displayNameLabel.text = self.user.username;
            }
        }
    }];
}

@end
