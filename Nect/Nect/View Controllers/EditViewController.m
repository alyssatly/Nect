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

@interface EditViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *profileView;

@property (strong, nonatomic) IBOutlet PFImageView *profilePictureView;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *displayNameField;
@property (strong, nonatomic) IBOutlet UITextView *aboutTextView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *genderControl;
@property (strong, nonatomic) IBOutlet UITextField *ageTextField;
@property (strong, nonatomic) NSArray *countries;
@property (strong, nonatomic) UIPickerView *countryPickerView;
@property (strong, nonatomic) IBOutlet UITextField *countryPicker;


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
    self.countryPickerView = [[UIPickerView alloc] init];
    self.countryPickerView.dataSource = self;
    self.countryPickerView.delegate = self;
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
    if(currentUser[@"age"] != nil){
        self.ageTextField.text = [NSString stringWithFormat:@"%@", currentUser[@"age"]];
    }
    self.countryPicker.text = currentUser[@"country"];
    if([currentUser[@"gender"] isEqualToString:@"N/A"]){
        self.genderControl.selectedSegmentIndex = 2;
    }else if([currentUser[@"gender"] isEqualToString:@"Male"]){
        self.genderControl.selectedSegmentIndex = 0;
    }else if([currentUser[@"gender"] isEqualToString:@"Female"]){
        self.genderControl.selectedSegmentIndex = 1;
    }
    
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
    
    [self initalizeCountries];
    if(currentUser[@"country"] != nil){
        NSInteger countryIndex = [self.countries indexOfObject:currentUser[@"country"]];
        [self.countryPickerView selectRow:countryIndex inComponent:0 animated:YES];
    }
    self.countryPicker.inputView = self.countryPickerView;
    
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
    picture.image = [UIImage imageNamed:@"default_game"];
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
    currentUser[@"country"] = self.countryPicker.text;
    currentUser[@"displayPhoto"] = [self getPFFileFromImage:self.profilePictureView.image];
    if(![self.ageTextField.text isEqualToString:@""]){
        currentUser[@"age"] = @([self.ageTextField.text intValue]);
    }
    if(self.genderControl.selectedSegmentIndex == 2){
        currentUser[@"gender"]  = @"N/A";
    }else if(self.genderControl.selectedSegmentIndex == 0){
        currentUser[@"gender"]  = @"Male";
    }else if(self.genderControl.selectedSegmentIndex == 1){
        currentUser[@"gender"]  = @"Female";
    }
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
      if (succeeded) {
          NSLog(@"Success");
          [MBProgressHUD hideHUDForView:self.view animated:YES];
          [self dismissViewControllerAnimated:true completion:nil];
      } else {
          NSLog(@"There was a problem: %@", error.description);
          [self addAlert:@"Could not save profile" message:@"There was a problem saving your profile"];
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
    [self.profileView endEditing:YES];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqual:@"editGames"]){
        //give the current EditViewController to the searchGamesViewController
        UINavigationController *navigationController = [segue destinationViewController];
        SearchGamesViewController *searchViewController = (SearchGamesViewController *)navigationController.topViewController;
        searchViewController.editViewController = self;
    }
}


- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.countries.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.countries[row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.countryPicker.text = [self.countries objectAtIndex:row];
}

-(void)initalizeCountries{
    self.countries = [NSArray arrayWithObjects: @"Prefer not to state",@"United States",@"Afghanistan", @"Akrotiri", @"Albania", @"Algeria", @"American Samoa", @"Andorra", @"Angola", @"Anguilla", @"Antarctica", @"Antigua and Barbuda", @"Argentina", @"Armenia", @"Aruba", @"Ashmore and Cartier Islands", @"Australia", @"Austria", @"Azerbaijan", @"The Bahamas", @"Bahrain", @"Bangladesh", @"Barbados", @"Bassas da India", @"Belarus", @"Belgium", @"Belize", @"Benin", @"Bermuda", @"Bhutan", @"Bolivia", @"Bosnia and Herzegovina", @"Botswana", @"Bouvet Island", @"Brazil", @"British Indian Ocean Territory", @"British Virgin Islands", @"Brunei", @"Bulgaria", @"Burkina Faso", @"Burma", @"Burundi", @"Cambodia", @"Cameroon", @"Canada", @"Cape Verde", @"Cayman Islands", @"Central African Republic", @"Chad", @"Chile", @"China", @"Christmas Island", @"Clipperton Island", @"Cocos (Keeling) Islands", @"Colombia", @"Comoros", @"Democratic Republic of the Congo", @"Republic of the Congo", @"Cook Islands", @"Coral Sea Islands", @"Costa Rica", @"Cote d'Ivoire", @"Croatia", @"Cuba", @"Cyprus", @"Czech Republic", @"Denmark", @"Dhekelia", @"Djibouti", @"Dominica", @"Dominican Republic", @"Ecuador", @"Egypt", @"El Salvador", @"Equatorial Guinea", @"Eritrea", @"Estonia", @"Ethiopia", @"Europa Island", @"Falkland Islands (Islas Malvinas)", @"Faroe Islands", @"Fiji", @"Finland", @"France", @"French Guiana", @"French Polynesia", @"French Southern and Antarctic Lands", @"Gabon", @"The Gambia", @"Gaza Strip", @"Georgia", @"Germany", @"Ghana", @"Gibraltar", @"Glorioso Islands", @"Greece", @"Greenland", @"Grenada", @"Guadeloupe", @"Guam", @"Guatemala", @"Guernsey", @"Guinea", @"Guinea-Bissau", @"Guyana", @"Haiti", @"Heard Island and McDonald Islands", @"Holy See (Vatican City)", @"Honduras", @"Hong Kong", @"Hungary", @"Iceland", @"India", @"Indonesia", @"Iran", @"Iraq", @"Ireland", @"Isle of Man", @"Israel", @"Italy", @"Jamaica", @"Jan Mayen", @"Japan", @"Jersey", @"Jordan", @"Juan de Nova Island", @"Kazakhstan", @"Kenya", @"Kiribati", @"North Korea", @"South Korea", @"Kuwait", @"Kyrgyzstan", @"Laos", @"Latvia", @"Lebanon", @"Lesotho", @"Liberia", @"Libya", @"Liechtenstein", @"Lithuania", @"Luxembourg", @"Macau", @"Macedonia", @"Madagascar", @"Malawi", @"Malaysia", @"Maldives", @"Mali", @"Malta", @"Marshall Islands", @"Martinique", @"Mauritania", @"Mauritius", @"Mayotte", @"Mexico", @"Federated States of Micronesia", @"Moldova", @"Monaco", @"Mongolia", @"Montserrat", @"Morocco", @"Mozambique", @"Namibia", @"Nauru", @"Navassa Island", @"Nepal", @"Netherlands", @"Netherlands Antilles", @"New Caledonia", @"New Zealand", @"Nicaragua", @"Niger", @"Nigeria", @"Niue", @"Norfolk Island", @"Northern Mariana Islands", @"Norway", @"Oman", @"Pakistan", @"Palau", @"Panama", @"Papua New Guinea", @"Paracel Islands", @"Paraguay", @"Peru", @"Philippines", @"Pitcairn Islands", @"Poland", @"Portugal", @"Puerto Rico", @"Qatar", @"Reunion", @"Romania", @"Russia", @"Rwanda", @"Saint Helena", @"Saint Kitts and Nevis", @"Saint Lucia", @"Saint Pierre and Miquelon", @"Saint Vincent and the Grenadines", @"Samoa", @"San Marino", @"Sao Tome and Principe", @"Saudi Arabia", @"Senegal", @"Serbia", @"Montenegro", @"Seychelles", @"Sierra Leone", @"Singapore", @"Slovakia", @"Slovenia", @"Solomon Islands", @"Somalia", @"South Africa", @"South Georgia and the South Sandwich Islands", @"Spain", @"Spratly Islands", @"Sri Lanka", @"Sudan", @"Suriname", @"Svalbard", @"Swaziland", @"Sweden", @"Switzerland", @"Syria", @"Taiwan", @"Tajikistan", @"Tanzania", @"Thailand", @"Tibet", @"Timor-Leste", @"Togo", @"Tokelau", @"Tonga", @"Trinidad and Tobago", @"Tromelin Island", @"Tunisia", @"Turkey", @"Turkmenistan", @"Turks and Caicos Islands", @"Tuvalu", @"Uganda", @"Ukraine", @"United Arab Emirates", @"United Kingdom", @"Uruguay", @"Uzbekistan", @"Vanuatu", @"Venezuela", @"Vietnam", @"Virgin Islands", @"Wake Island", @"Wallis and Futuna", @"West Bank", @"Western Sahara", @"Yemen", @"Zambia", @"Zimbabwe", nil];
}

@end
