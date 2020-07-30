//
//  FilterViewController.m
//  Nect
//
//  Created by Alyssa Tan on 7/23/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "FilterViewController.h"
#import "NectViewController.h"

@interface FilterViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *filterView;
@property (strong, nonatomic) NSArray *countries;
@property (strong, nonatomic) UIPickerView *countryPickerView;
@property (strong, nonatomic) UIPickerView *agePickerView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *genderPicker;
@property (strong, nonatomic) IBOutlet UITextField *ageField;
@property (strong, nonatomic) IBOutlet UITextField *countryPicker;
@property (strong, nonatomic) NSArray *myCountries;
@property (strong, nonatomic) NSArray *youngest;
@property (strong, nonatomic) NSArray *oldest;
@property (strong, nonatomic) NSString *young;
@property (strong, nonatomic) NSString *old;
@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.agePickerView = [[UIPickerView alloc] init];
    self.agePickerView.dataSource = self;
    self.agePickerView.delegate = self;
    self.countryPickerView = [[UIPickerView alloc] init];
    self.countryPickerView.dataSource = self;
    self.countryPickerView.delegate = self;
    
    self.genderPicker.selectedSegmentIndex = 2;
    self.young = @"None";
    self.old = @"None";
    
    [self initalizeArrays];
    [self.countryPickerView selectRow:0 inComponent:0 animated:YES];
    self.countryPicker.inputView = self.countryPickerView;
    [self.agePickerView selectRow:0 inComponent:0 animated:YES];
    [self.agePickerView selectRow:0 inComponent:1 animated:YES];
    self.ageField.inputView = self.agePickerView;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.filterView addGestureRecognizer:gestureRecognizer];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height /1.8 , self.view.frame.size.width,self.view.frame.size.height )];
}

-(void)hideKeyboard{
    [self.filterView endEditing:YES];
}

- (IBAction)backPressed:(id)sender {
    if(self.young > self.old && ![self.young isEqualToString:@"None"] && ![self.old isEqualToString:@"None"] ){
        [self addAlert:@"Could not add filters" message:@"Age range is invalid"];
    }else{
        NSString *gender = @"None";
        if(self.genderPicker.selectedSegmentIndex == 0){
            gender = @"Male";
        }else if(self.genderPicker.selectedSegmentIndex == 1){
            gender = @"Female";
        }
        if([self.young isEqualToString:@"None"]){
            self.young = @"0";
        }
        if([self.old isEqualToString:@"None"]){
            self.old = @"100";
        }
        [self.nectViewController updateFilters:gender young:(NSInteger)[self.young intValue] old:(NSInteger)[self.old intValue] country:self.countryPicker.text];
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    if(pickerView == self.agePickerView){
        return 2;
    }
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(pickerView == self.agePickerView){
        if(component == 0){
            return self.youngest.count;
        }
        return self.oldest.count;
    }
    return self.myCountries.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(thePickerView == self.agePickerView){
        if(component == 0){
            return self.youngest[row];
        }
        return self.oldest[row];
    }
    return self.myCountries[row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(thePickerView == self.agePickerView){
        if(component == 0){
            self.young = self.youngest[row];
        }else{
            self.old = self.oldest[row];
        }
        self.ageField.text = [NSString stringWithFormat:@"%@ - %@",self.young,self.old];
    }else{
        self.countryPicker.text = [self.myCountries objectAtIndex:row];
    }
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

-(void)initalizeArrays{
    self.youngest = [NSArray arrayWithObjects:@"None",@"15",@"20",@"25",@"30",@"35",@"40",@"45",@"50",@"55",@"60",nil];
    self.oldest = [NSArray arrayWithObjects:@"None",@"20",@"25",@"30",@"35",@"40",@"45",@"50",@"55",@"60",@"65",nil];
    self.myCountries = [NSArray arrayWithObjects: @"None",@"United States",@"Afghanistan", @"Akrotiri", @"Albania", @"Algeria", @"American Samoa", @"Andorra", @"Angola", @"Anguilla", @"Antarctica", @"Antigua and Barbuda", @"Argentina", @"Armenia", @"Aruba", @"Ashmore and Cartier Islands", @"Australia", @"Austria", @"Azerbaijan", @"The Bahamas", @"Bahrain", @"Bangladesh", @"Barbados", @"Bassas da India", @"Belarus", @"Belgium", @"Belize", @"Benin", @"Bermuda", @"Bhutan", @"Bolivia", @"Bosnia and Herzegovina", @"Botswana", @"Bouvet Island", @"Brazil", @"British Indian Ocean Territory", @"British Virgin Islands", @"Brunei", @"Bulgaria", @"Burkina Faso", @"Burma", @"Burundi", @"Cambodia", @"Cameroon", @"Canada", @"Cape Verde", @"Cayman Islands", @"Central African Republic", @"Chad", @"Chile", @"China", @"Christmas Island", @"Clipperton Island", @"Cocos (Keeling) Islands", @"Colombia", @"Comoros", @"Democratic Republic of the Congo", @"Republic of the Congo", @"Cook Islands", @"Coral Sea Islands", @"Costa Rica", @"Cote d'Ivoire", @"Croatia", @"Cuba", @"Cyprus", @"Czech Republic", @"Denmark", @"Dhekelia", @"Djibouti", @"Dominica", @"Dominican Republic", @"Ecuador", @"Egypt", @"El Salvador", @"Equatorial Guinea", @"Eritrea", @"Estonia", @"Ethiopia", @"Europa Island", @"Falkland Islands (Islas Malvinas)", @"Faroe Islands", @"Fiji", @"Finland", @"France", @"French Guiana", @"French Polynesia", @"French Southern and Antarctic Lands", @"Gabon", @"The Gambia", @"Gaza Strip", @"Georgia", @"Germany", @"Ghana", @"Gibraltar", @"Glorioso Islands", @"Greece", @"Greenland", @"Grenada", @"Guadeloupe", @"Guam", @"Guatemala", @"Guernsey", @"Guinea", @"Guinea-Bissau", @"Guyana", @"Haiti", @"Heard Island and McDonald Islands", @"Holy See (Vatican City)", @"Honduras", @"Hong Kong", @"Hungary", @"Iceland", @"India", @"Indonesia", @"Iran", @"Iraq", @"Ireland", @"Isle of Man", @"Israel", @"Italy", @"Jamaica", @"Jan Mayen", @"Japan", @"Jersey", @"Jordan", @"Juan de Nova Island", @"Kazakhstan", @"Kenya", @"Kiribati", @"North Korea", @"South Korea", @"Kuwait", @"Kyrgyzstan", @"Laos", @"Latvia", @"Lebanon", @"Lesotho", @"Liberia", @"Libya", @"Liechtenstein", @"Lithuania", @"Luxembourg", @"Macau", @"Macedonia", @"Madagascar", @"Malawi", @"Malaysia", @"Maldives", @"Mali", @"Malta", @"Marshall Islands", @"Martinique", @"Mauritania", @"Mauritius", @"Mayotte", @"Mexico", @"Federated States of Micronesia", @"Moldova", @"Monaco", @"Mongolia", @"Montserrat", @"Morocco", @"Mozambique", @"Namibia", @"Nauru", @"Navassa Island", @"Nepal", @"Netherlands", @"Netherlands Antilles", @"New Caledonia", @"New Zealand", @"Nicaragua", @"Niger", @"Nigeria", @"Niue", @"Norfolk Island", @"Northern Mariana Islands", @"Norway", @"Oman", @"Pakistan", @"Palau", @"Panama", @"Papua New Guinea", @"Paracel Islands", @"Paraguay", @"Peru", @"Philippines", @"Pitcairn Islands", @"Poland", @"Portugal", @"Puerto Rico", @"Qatar", @"Reunion", @"Romania", @"Russia", @"Rwanda", @"Saint Helena", @"Saint Kitts and Nevis", @"Saint Lucia", @"Saint Pierre and Miquelon", @"Saint Vincent and the Grenadines", @"Samoa", @"San Marino", @"Sao Tome and Principe", @"Saudi Arabia", @"Senegal", @"Serbia", @"Montenegro", @"Seychelles", @"Sierra Leone", @"Singapore", @"Slovakia", @"Slovenia", @"Solomon Islands", @"Somalia", @"South Africa", @"South Georgia and the South Sandwich Islands", @"Spain", @"Spratly Islands", @"Sri Lanka", @"Sudan", @"Suriname", @"Svalbard", @"Swaziland", @"Sweden", @"Switzerland", @"Syria", @"Taiwan", @"Tajikistan", @"Tanzania", @"Thailand", @"Tibet", @"Timor-Leste", @"Togo", @"Tokelau", @"Tonga", @"Trinidad and Tobago", @"Tromelin Island", @"Tunisia", @"Turkey", @"Turkmenistan", @"Turks and Caicos Islands", @"Tuvalu", @"Uganda", @"Ukraine", @"United Arab Emirates", @"United Kingdom", @"Uruguay", @"Uzbekistan", @"Vanuatu", @"Venezuela", @"Vietnam", @"Virgin Islands", @"Wake Island", @"Wallis and Futuna", @"West Bank", @"Western Sahara", @"Yemen", @"Zambia", @"Zimbabwe", nil];
    
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
