//
//  EditViewController.m
//  Nect
//
//  Created by Alyssa Tan on 7/13/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "EditViewController.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
@import Parse;

@interface EditViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet PFImageView *profilePictureView;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *displayNameField;
@property (strong, nonatomic) IBOutlet UITextView *aboutTextView;

@property (strong, nonatomic) IBOutlet PFImageView *game1;
@property (strong, nonatomic) IBOutlet PFImageView *game2;
@property (strong, nonatomic) IBOutlet PFImageView *game3;
@property (strong, nonatomic) IBOutlet PFImageView *game4;
@property (strong, nonatomic) IBOutlet PFImageView *game5;
@property (strong, nonatomic) IBOutlet PFImageView *game6;
@property (strong, nonatomic) IBOutlet PFImageView *game7;
@property (strong, nonatomic) IBOutlet PFImageView *game8;

@property (assign, nonatomic) BOOL cont;


@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set values for existing fields
    PFUser *currentUser = [PFUser currentUser];
    if(currentUser[@"displayPhoto"] != nil){
        self.profilePictureView.file = currentUser[@"displayPhoto"];
        [self.profilePictureView loadInBackground];
        
    }
    self.usernameField.text = currentUser[@"username"];
    self.passwordField.text = @"";
    self.displayNameField.text = currentUser[@"displayName"];
    self.aboutTextView.text = currentUser[@"about"];
    
    //Make all images round
    [self roundImage:self.profilePictureView];
    [self roundImage:self.game1];
    [self roundImage:self.game2];
    [self roundImage:self.game3];
    [self roundImage:self.game4];
    [self roundImage:self.game5];
    [self roundImage:self.game6];
    [self roundImage:self.game7];
    [self roundImage:self.game8];
    
    //Add border to about text view
    self.aboutTextView.layer.borderWidth = 1.0f;
    self.aboutTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    //Added tap gesture to change profile picture
    self.profilePictureView.userInteractionEnabled = YES;
    UITapGestureRecognizer *profiePicGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(choosePhoto:)];
    profiePicGesture.numberOfTapsRequired = 1;
    [profiePicGesture setDelegate:self];
    [self.profilePictureView addGestureRecognizer:profiePicGesture];
}

- (void) choosePhoto: (id)sender
{
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NULL message:NULL preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePickerVC animated:YES completion:nil];
            
        }];
        UIAlertAction *library = [UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePickerVC animated:YES completion:nil];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"cancel");
        }];
        [actionSheet addAction:camera];
        [actionSheet addAction:library];
        [actionSheet addAction:cancel];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }
 }

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.profilePictureView.image = editedImage;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)roundImage:(UIImageView *)picture{
    picture.layer.masksToBounds = YES;
    picture.layer.cornerRadius = picture.frame.size.width/2;
}
- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)savePressed:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFUser *currentUser = [PFUser currentUser];
    
    //Assign new values
    if(![self.usernameField.text isEqualToString:@""]){
        if(![self.usernameField.text isEqualToString:currentUser[@"username"]]){
            PFQuery *query = [PFUser query];
            [query whereKey:@"username" equalTo:self.usernameField.text];
            query.limit = 1;

            // fetch data asynchronously
            [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
                if (users.count != 0) {
                    [self addAlert:@"Username is taken" message:@"Please select a new username"];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                  
                } else {
                   currentUser[@"username"] = self.usernameField.text;
                    [self updateData:currentUser];
                    NSLog(@"here");
                }
            }];
        } else{
            [self updateData:currentUser];
        }
    }
}

-(void)updateData:(PFUser *)currentUser{
    NSLog(@"inside");
    if(![self.passwordField.text isEqualToString:@""]){
        currentUser[@"password"] = self.passwordField.text;
        [currentUser setPassword:self.passwordField.text];
    }
    currentUser[@"displayName"] = self.displayNameField.text;
    currentUser[@"about"] = self.aboutTextView.text;
    currentUser[@"displayPhoto"] = [self getPFFileFromImage:self.profilePictureView.image];
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
      if (succeeded) {
          NSLog(@"Success");
          [MBProgressHUD hideHUDForView:self.view animated:YES];
          [self dismissViewControllerAnimated:true completion:nil];
      } else {
          NSLog(@"There was a problem: %@", error.description);
          [MBProgressHUD hideHUDForView:self.view animated:YES];
      }
    }];
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

- (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    // check if image is not nil
    if (!image) {
        return nil;
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

- (IBAction)editGamesPressed:(id)sender {
    
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
