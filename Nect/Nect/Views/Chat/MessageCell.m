//
//  MessageCell.m
//  Nect
//
//  Created by Alyssa Tan on 7/30/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "MessageCell.h"
#import "Message.h"
#import "Parse/Parse.h"

@implementation MessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setCell:(Message *)message{
    self.message = message;
    
    if(self.message.sender == [[PFUser currentUser] fetch][@"username"]){
        self.bubbleView2.alpha = 1;
        self.messageLabel2.alpha = 1;
        self.bubbleView.alpha = 0;
        self.messageLabel.alpha = 0;
        self.usernameLabel.textAlignment = NSTextAlignmentRight;
        
        self.bubbleView2.layer.cornerRadius = 16;
        self.bubbleView2.clipsToBounds = true;
        self.usernameLabel.text = self.message.sender;
        self.messageLabel2.text = self.message.message;
    }else{
        self.bubbleView2.alpha = 0;
        self.messageLabel2.alpha = 0;
        self.bubbleView.alpha = 1;
        self.messageLabel.alpha = 1;
        self.usernameLabel.textAlignment = NSTextAlignmentLeft;
        
        self.bubbleView.layer.cornerRadius = 16;
        self.bubbleView.clipsToBounds = true;
        self.usernameLabel.text = self.message.sender;
        self.messageLabel.text = self.message.message;
    }
}

@end
