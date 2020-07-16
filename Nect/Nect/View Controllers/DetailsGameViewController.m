//
//  DetailsGameViewController.m
//  Nect
//
//  Created by Alyssa Tan on 7/16/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "DetailsGameViewController.h"
#import "Game.h"
#import <Parse/Parse.h>
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
@import Parse;

@interface DetailsGameViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addOrRemoveButton;
@property (strong, nonatomic) IBOutlet UIImageView *gamePictureView;
@property (strong, nonatomic) IBOutlet UILabel *gameNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *genresLabel;
@property (strong, nonatomic) IBOutlet UILabel *developerLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation DetailsGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //set button to add if user does not have game in profile, remove otherwise
    PFUser *currentUser = [[PFUser currentUser] fetch];
    NSDictionary *gameDict = [self dictionaryFromMenu:self.game];
    if(![currentUser[@"games"] containsObject:gameDict]){
        UIImage *btnImage = [UIImage systemImageNamed:@"plus"];
        [self.addOrRemoveButton setImage:btnImage];
    }else{
        UIImage *btnImage = [UIImage systemImageNamed:@"minus"];
        [self.addOrRemoveButton setImage:btnImage];
    }
    
    //building genres label text
    NSMutableString *genreString = [NSMutableString stringWithString:@""];;
    for(NSMutableString *genre in self.game.genres){
        [genreString appendString:genre];
        [genreString appendString:@", "];
    }
    NSRange range = NSMakeRange([genreString length]-2,1);
    [genreString replaceCharactersInRange:range withString:@""];
    
    //set values
    self.genresLabel.text = genreString;
    self.gameNameLabel.text = self.game.name;
    self.developerLabel.text = [NSString stringWithFormat:@"By: %@", self.game.developer];
    NSString* descriptionString  = [self.game.gameDescription stringByReplacingOccurrencesOfString:@" &hellip;  Expand" withString:@""];
    self.descriptionLabel.text = descriptionString;
    
    NSURL *posterURL = [NSURL URLWithString:self.game.image];
    self.gamePictureView.image = [UIImage systemImageNamed:@"gamecontroller.fill"];
    [self.gamePictureView setImageWithURL:posterURL];
    
}

- (IBAction)addOrRemovePressed:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFUser *currentUser = [[PFUser currentUser] fetch];
    NSDictionary *gameDict = [self dictionaryFromMenu:self.game];
    NSMutableArray *gamesArray = currentUser[@"games"];
    if(![currentUser[@"games"] containsObject:gameDict]){
        if(gamesArray == nil){
            gamesArray = [NSMutableArray array];
        }
        [gamesArray addObject:gameDict];
        currentUser[@"games"] = gamesArray;
        NSLog(@"Trying to add: %@",currentUser[@"games"]);
    }else{
        [gamesArray removeObject:gameDict];
        currentUser[@"games"] = gamesArray;
        NSLog(@"Tried to remove %@",currentUser[@"games"]);
        
    }
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
      if (succeeded) {
          NSLog(@"Success");
          [MBProgressHUD hideHUDForView:self.view animated:YES];
      } else {
          NSLog(@"There was a problem: %@", error.description);
          [MBProgressHUD hideHUDForView:self.view animated:YES];
      }
    }];
}

- (NSDictionary *)dictionaryFromMenu:(Game *)game {
    NSDictionary *returnDict = [NSDictionary dictionaryWithObjectsAndKeys:game.name,@"gameName",
     game.gameDescription, @"gameDescription",
     game.developer, @"developer",
     game.image, @"image",
     game.genres , @"genres",
    nil];
    
    return returnDict;
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
