//
//  RequestCell.m
//  Nect
//
//  Created by Alyssa Tan on 7/20/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "RequestCell.h"
#import "User.h"
#import "RequestsViewController.h"

@implementation RequestCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPost:(User *)user{
    self.user = user;
    self.displayImageView.layer.masksToBounds = YES;
    self.displayImageView.layer.cornerRadius = self.displayImageView.frame.size.height/2.2;
    self.displayImageView.layer.borderWidth = 0;

    self.displayImageView.image = [UIImage systemImageNamed:@"person.crop.circle.fill"];

    if(user.displayPhoto != nil){
        self.displayImageView.file = user.displayPhoto;
        [self.displayImageView loadInBackground];
    }
    self.displayNameLabel.text = user.displayName;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.username];
}

- (IBAction)acceptPressed:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"NectRequest"];
    [query whereKey:@"receiver" equalTo:[[PFUser currentUser] fetch][@"username"]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
      if (object) {
        [object deleteInBackground];
        PFObject *friend = [PFObject objectWithClassName:@"Friend"];
           friend[@"friend1"] = [[PFUser currentUser] fetch][@"username"];
           friend[@"friend2"] = self.user.username;
           [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
             if (succeeded) {
                NSLog(@"Friend Added!");
               [self.requestsViewController getRequests];
             } else {
                NSLog(@"Error: %@", error.description);
             }
           }];
      } else {
        NSLog(@"Unable to remove request");
      }
    }];
}

- (IBAction)removePressed:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"NectRequest"];
    [query whereKey:@"receiver" equalTo:[[PFUser currentUser] fetch][@"username"]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
      if (object) {
        [object deleteInBackground];
        [self.requestsViewController getRequests];
      } else {
        NSLog(@"Unable to remove request");
      }
    }];
}


@end
