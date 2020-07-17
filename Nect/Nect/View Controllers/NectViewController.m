//
//  NectViewController.m
//  Nect
//
//  Created by Alyssa Tan on 7/13/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "NectViewController.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "User.h"
@import Parse;

@interface NectViewController ()

@property (strong, nonatomic) IBOutlet UIButton *nectButton;
@property (strong, nonatomic) IBOutlet UIView *currentView;
@property (strong, nonatomic) IBOutlet PFImageView *displayPhotoView;
@property (strong, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *nectUsernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *theyAlsoPlay;
@property (strong, nonatomic) IBOutlet UILabel *matchedGamesLabel;



@property (strong, nonatomic) NSMutableArray *matchedUsers;
@property (strong, nonatomic)User *bestMatch;
@property (assign, nonatomic)NSInteger *highestScore;
@property (strong, nonatomic) NSMutableArray *matchedGames;

@end

@implementation NectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.matchedUsers = [NSMutableArray array];
    self.displayPhotoView.alpha = 0;
    self.displayNameLabel.alpha = 0;
    self.nectUsernameLabel.alpha = 0;
    self.theyAlsoPlay.alpha = 0;
    self.matchedGamesLabel.alpha = 0;
    [self.nectButton setTranslatesAutoresizingMaskIntoConstraints:YES];
    // Do any additional setup after loading the view.
}

- (IBAction)nectPressed:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self matchUser];
    
    if(self.nectButton.frame.origin.y < (self.currentView.frame.size.height * 0.6)){
        [UIView animateWithDuration:1 animations:^{
            self.nectButton.frame = CGRectMake(self.nectButton.frame.origin.x, self.nectButton.frame.origin.y + (self.currentView.frame.size.height * 0.27), self.nectButton.frame.size.width, self.nectButton.frame.size.height);
        }];
    } else {
        [UIView animateWithDuration:0.7 animations:^{
            self.nectButton.alpha = 0;
        }];
        [UIView animateWithDuration:0.5 animations:^{
            self.nectButton.alpha = 1;
        }];
    }
    
    
}

-(void)displayMatch{
    
    self.displayPhotoView.layer.masksToBounds = YES;
    self.displayPhotoView.layer.cornerRadius = self.displayPhotoView.frame.size.height/2.2;
    self.displayPhotoView.layer.borderWidth = 0;

    self.displayPhotoView.image = [UIImage systemImageNamed:@"person.circle.fill"];

    if(self.bestMatch.displayPhoto != nil){
        self.displayPhotoView.file = self.bestMatch.displayPhoto;
        [self.displayPhotoView loadInBackground];
    }
    self.displayNameLabel.text = self.bestMatch.displayName;
    self.nectUsernameLabel.text = [NSString stringWithFormat:@"@%@", self.bestMatch.username];
    
    NSMutableString *gameString = [NSMutableString stringWithString:@""];;
    for(NSMutableString *games in self.matchedGames){
        [gameString appendString:games];
        [gameString appendString:@",\n "];
    }
    if(![gameString isEqualToString:@""] ){
        NSRange range = NSMakeRange([gameString length]-3,1);
        [gameString replaceCharactersInRange:range withString:@""];
    }else{
        [gameString appendString:@"No simillar games"];
    }
    self.matchedGamesLabel.text = gameString;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.displayPhotoView.alpha = 0;
        self.displayNameLabel.alpha = 0;
        self.nectUsernameLabel.alpha = 0;
        self.theyAlsoPlay.alpha = 0;
        self.matchedGamesLabel.alpha = 0;
    }];
    
    [UIView animateWithDuration:1 animations:^{
        self.displayPhotoView.alpha = 1;
        self.displayNameLabel.alpha = 1;
        self.nectUsernameLabel.alpha = 1;
        self.theyAlsoPlay.alpha = 1;
        self.matchedGamesLabel.alpha = 1;
    }];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)matchUser{
    PFQuery *query = [PFUser query];
    PFUser *currentUser = [[PFUser currentUser] fetch];
    User *thisUser = [[User alloc] initWithUser:currentUser];
    
    //get valid users
    [query whereKey:@"username" notEqualTo:thisUser.username];
    [query whereKey:@"username" notContainedIn:thisUser.dontMatchNames];
    [query whereKey:@"username" notContainedIn:self.matchedUsers];
    
    self.highestScore = 0;
    self.bestMatch = nil;
    self.matchedGames = [NSMutableArray array];
     //fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users.count != 0) {
            // do something with the array of object returned by the call
            //NSLog(@"%@", [NSString stringWithFormat:@"%lu", (unsigned long)users.count]);
            for(PFUser *user in users){
                NSMutableArray *currentMatchedGames = [NSMutableArray array];
                User *matchingUser = [[User alloc] initWithUser:user];
                NSInteger gameCount = 0;
                
                if(thisUser.games.count <= matchingUser.games.count){
                    for(NSDictionary *game in thisUser.games){
                        if([matchingUser.games containsObject:game]){
                            gameCount += 1;
                            [currentMatchedGames addObject:game[@"title"]];
                        }
                    }
                    if((NSInteger *)gameCount > self.highestScore){
                        self.bestMatch = matchingUser;
                        self.matchedGames = currentMatchedGames;
                    }
                }else{
                    for(NSDictionary *game in matchingUser.games){
                        if([thisUser.games containsObject:game]){
                            gameCount += 1;
                            [currentMatchedGames addObject:game[@"title"]];
                        }
                    }
                    if((NSInteger *)gameCount > self.highestScore){
                        self.bestMatch = matchingUser;
                        self.matchedGames = currentMatchedGames;
                        self.highestScore = (NSInteger *)gameCount;
                    }
                }
                
                //NSLog(@"%@", [NSString stringWithFormat:@"Highest:%ld,%@:%ld",(long)highestScore,matchingUser.username,(long)gameCount]);
            }
            if(self.bestMatch == nil){
                self.bestMatch = [[User alloc] initWithUser:users[0]];
                NSLog(@"Shouldn't be here");
            }
            [self.matchedUsers addObject:self.bestMatch.username];
            //NSLog(@"%@, games: %@",self.bestMatch[@"username"],self.matchedGames);
            [self displayMatch];
             
        } else {
            NSLog(@"No new users to match with");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
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
