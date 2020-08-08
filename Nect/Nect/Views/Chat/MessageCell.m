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
#import "UIImage+animatedGIF.h"

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
    if(self.message.gif == nil){
        self.gifView.hidden = YES;
        NSLog(@"%@",self.message.sender);
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
            self.imageBottom.active = NO;
        }else{
            self.bubbleView2.alpha = 0;
            self.messageLabel2.alpha = 0;
            self.bubbleView.alpha = 1;
            self.messageLabel.alpha = 1;
            self.usernameLabel.textAlignment = NSTextAlignmentLeft;
            self.imageBottom.active = NO;
            
            self.bubbleView.layer.cornerRadius = 16;
            self.bubbleView.clipsToBounds = true;
            self.usernameLabel.text = self.message.sender;
            self.messageLabel.text = self.message.message;
        }
    }else{
        self.gifView.hidden = NO;
        self.imageBottom.active = YES;
        
        self.bubbleView2.alpha = 0;
        self.messageLabel2.alpha = 0;
        self.bubbleView.alpha = 0;
        self.messageLabel.alpha = 0;
        
        NSURL *url = [NSURL URLWithString:self.message.gif];
        UIImage* mygif = [UIImage animatedImageWithAnimatedGIFURL:url];
        self.gifView.image = mygif;
        
        if(self.message.sender == [[PFUser currentUser] fetch][@"username"]){
            self.imageRight.constant = 0;
            self.imageLeft.active = NO;
            self.imageRight.active = YES;
            self.usernameLabel.text = self.message.sender;
            self.usernameLabel.textAlignment = NSTextAlignmentRight;
        }else{
            self.imageLeft.constant = 0;
            self.imageLeft.active = YES;
            self.imageRight.active = NO;
            self.usernameLabel.text = self.message.sender;
            self.usernameLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
}

@end
