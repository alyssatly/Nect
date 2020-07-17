//
//  EditViewController.m
//  Nect
//
//  Created by Alyssa Tan on 7/13/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "EditViewController.h"
#import "SearchGamesViewController.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
@import Parse;

@interface EditViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIView *profileView;

@property (strong, nonatomic) IBOutlet PFImageView *profilePictureView;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *displayNameField;
@property (strong, nonatomic) IBOutlet UITextView *aboutTextView;

@property (strong, nonatomic) IBOutlet UIImageView *game1;
@property (strong, nonatomic) IBOutlet UIImageView *game2;
@property (strong, nonatomic) IBOutlet UIImageView *game3;
@property (strong, nonatomic) IBOutlet UIImageView *game4;
@property (strong, nonatomic) IBOutlet UIImageView *game5;
@property (strong, nonatomic) IBOutlet UIImageView *game6;
@property (strong, nonatomic) IBOutlet UIImageView *game7;
@property (strong, nonatomic) IBOutlet UIImageView *game8;


@property (assign, nonatomic) BOOL cont;


@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set values for existing fields
    PFUser *currentUser = [[PFUser currentUser] fetch];
    if(currentUser[@"displayPhoto"] != nil){
        self.profilePictureView.file= currentUser[@"displayPhoto"];
        [self.profilePictureView loadInBackground];
        NSLog(@"%@",self.profilePictureView.file);
        
    }
    self.usernameField.text = currentUser[@"username"];
    self.passwordField.text = @"";
    self.displayNameField.text = currentUser[@"displayName"];
    self.aboutTextView.text = currentUser[@"about"];
    
    //Make all images round
    self.profilePictureView.layer.masksToBounds = YES;
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.height/2.2;
    self.profilePictureView.layer.borderWidth = 0;
    [self updateImages];
    
    //Add border to about text view
    self.aboutTextView.layer.borderWidth = 1.0f;
    self.aboutTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    //Added tap gesture to change profile picture
    self.profilePictureView.userInteractionEnabled = YES;
    UITapGestureRecognizer *profiePicGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(choosePhoto:)];
    profiePicGesture.numberOfTapsRequired = 1;
    [profiePicGesture setDelegate:self];
    [self.profilePictureView addGestureRecognizer:profiePicGesture];
    
    //hide keyboard when view it touched
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.profileView addGestureRecognizer:gestureRecognizer];
}

//need to find a way to not hard code this later
-(void)updateImages{
    [self resetImages];
    PFUser *currentUser = [[PFUser currentUser] fetch];
    NSArray *myGames = currentUser[@"games"];
    if(myGames.count >= 1){
        [self setGameImage:self.game1 URLString:myGames[0][@"image"]];
        if(myGames.count >= 2){
            [self setGameImage:self.game2 URLString:myGames[1][@"image"]];
            if(myGames.count >= 3){
                [self setGameImage:self.game3 URLString:myGames[2][@"image"]];
                if(myGames.count >= 4){
                    [self setGameImage:self.game4 URLString:myGames[3][@"image"]];
                    if(myGames.count >= 5){
                        [self setGameImage:self.game5 URLString:myGames[4][@"image"]];
                        if(myGames.count >= 6){
                            [self setGameImage:self.game6 URLString:myGames[5][@"image"]];
                            if(myGames.count >= 7){
                                [self setGameImage:self.game7 URLString:myGames[6][@"image"]];
                                if(myGames.count >= 8){
                                    [self setGameImage:self.game8 URLString:myGames[7][@"image"]];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

-(void)setGameImage:(UIImageView *)picture URLString:(NSString *)URLString{
    picture.contentMode = UIViewContentModeScaleAspectFill;
    NSURL *posterURL = [NSURL URLWithString:URLString];
    picture.image = [UIImage systemImageNamed:@"gamecontroller"];
    [picture setImageWithURL:posterURL];
}

-(void)resetImages{
    [self roundImage:self.game1];
    [self roundImage:self.game2];
    [self roundImage:self.game3];
    [self roundImage:self.game4];
    [self roundImage:self.game5];
    [self roundImage:self.game6];
    [self roundImage:self.game7];
    [self roundImage:self.game8];
}
    

-(void)roundImage:(UIImageView *)picture{
    picture.layer.masksToBounds = YES;
    picture.layer.cornerRadius = picture.frame.size.height/2.2;
    picture.layer.borderWidth = 0;
    picture.image = [UIImage systemImageNamed:@"gamecontroller.fill"];
    picture.contentMode = UIViewContentModeScaleAspectFit;
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



- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)savePressed:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFUser *currentUser = [[PFUser currentUser] fetch];
    
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

-(void)hideKeyboard{
    [self.usernameField endEditing:YES];
    [self.passwordField endEditing:YES];
    [self.displayNameField endEditing:YES];
    [self.aboutTextView endEditing:YES];
    
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqual:@"editGames"]){
        //give the current EditViewController to the searchGamesViewController
        NSLog(@"Tapped!");
        UINavigationController *navigationController = [segue destinationViewController];
        SearchGamesViewController *searchViewController = (SearchGamesViewController *)navigationController.topViewController;
        searchViewController.editViewController = self;
    }
}


@end
