//
//  LoginViewController.m
//  Nect
//
//  Created by Alyssa Tan on 7/13/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIView *loginView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //hide keyboard with hideKeyboard selector
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.loginView addGestureRecognizer:gestureRecognizer];
    
}

-(void)hideKeyboard{
    [self.usernameField endEditing:YES];
    [self.passwordField endEditing:YES];
}

-(void)addAlert:(NSString *)title message:(NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{
    }];
}

- (IBAction)signupPressed:(id)sender {
    if([self.usernameField.text isEqual:@""]){
        [self addAlert:@"Error signing up" message:@"Username field is empty"];
    }else if([self.passwordField.text isEqual:@""]){
        [self addAlert:@"Error signing up" message:@"Password field is empty"];
    }else{
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:self.usernameField.text];
        query.limit = 1;
        [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
            if (users.count != 0) {
                [self addAlert:@"Username is taken" message:@"Please select a new username"];
            } else {
                PFUser *newUser = [PFUser user];
                // set user properties
                newUser.username = self.usernameField.text;
                //newUser.email = self.emailField.text;
                newUser.password = self.passwordField.text;
                // call sign up function on the object
                [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                    if (error != nil) {
                        NSLog(@"Error: %@", error.localizedDescription);
                        [self addAlert:@"Error signing up" message:error.localizedDescription];
                    } else {
                        NSLog(@"User registered successfully");
                        [self performSegueWithIdentifier:@"loginSegue" sender:nil];
                    }
                }];
            }
        }];
    }
}

- (IBAction)loginPressed:(id)sender {
    if([self.usernameField.text isEqual:@""]){
        [self addAlert:@"Error logging in" message:@"Username field is empty"];
        
    }else if([self.passwordField.text isEqual:@""]){
        [self addAlert:@"Error logging in" message:@"Password field is empty"];
    }else{
        NSString *username = self.usernameField.text;
        NSString *password = self.passwordField.text;
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
            if (error != nil) {
                NSLog(@"User log in failed: %@", error.localizedDescription);
                [self addAlert:@"Error logging in" message:error.localizedDescription];
                
            } else {
                NSLog(@"User logged in successfully");
                [self performSegueWithIdentifier:@"loginSegue" sender:nil];
            }
        }];
    }
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
