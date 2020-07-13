//
//  EditViewController.m
//  Nect
//
//  Created by Alyssa Tan on 7/13/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "EditViewController.h"
#import <Parse/Parse.h>

@interface EditViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (strong, nonatomic) IBOutlet UITextView *aboutTextView;

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.aboutTextView.text = @"";
    self.profilePictureView.layer.masksToBounds = YES;
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.width/2;
    
    self.aboutTextView.layer.borderWidth = 1.0f;
    self.aboutTextView.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)savePressed:(id)sender {
    //upload information to parse
    PFUser *currentUser = [PFUser currentUser];
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
      if (succeeded) {
        NSLog(@"Success");
      } else {
        // There was a problem, check error.description
          NSLog(@"There was a problem: %@", error.description);
      }
    }];
    NSLog(@"changed");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
