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
#import "FriendsViewController.h"
#import "UserProfileViewController.h"
@import Parse;

@interface NectViewController () <UIGestureRecognizerDelegate>

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
    [self refreshInfo];
    self.matchedUsers = [NSMutableArray array];
    self.displayPhotoView.alpha = 0;
    self.displayNameLabel.alpha = 0;
    self.nectUsernameLabel.alpha = 0;
    self.theyAlsoPlay.alpha = 0;
    self.matchedGamesLabel.alpha = 0;
    self.theyAlsoPlay.text = @"They also play:";

    self.displayPhotoView.userInteractionEnabled = YES;
    UITapGestureRecognizer *profileGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(viewProfile)];
    profileGesture.numberOfTapsRequired = 1;
    [profileGesture setDelegate:self];
    [self.displayPhotoView addGestureRecognizer:profileGesture];
    
    [self addGesture:self.displayNameLabel];
    [self addGesture:self.nectUsernameLabel];
}

-(void)addGesture:(UILabel *)label{
    label.userInteractionEnabled = YES;
    UITapGestureRecognizer *profileGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(viewProfile)];
    profileGesture.numberOfTapsRequired = 1;
    [profileGesture setDelegate:self];
    [label addGestureRecognizer:profileGesture];
}

-(void)viewProfile{
    [self performSegueWithIdentifier:@"ShowUserProfile" sender:self];
}

- (IBAction)nectPressed:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self dontMatch];
    
    if(self.nectButton.frame.origin.y < (self.currentView.frame.size.height * 0.6)){
        [self.nectButton setTranslatesAutoresizingMaskIntoConstraints:YES];
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

    self.displayPhotoView.image = [UIImage systemImageNamed:@"person.crop.circle.fill"];

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

-(void)refreshInfo{
    PFUser *currentUser = [[PFUser currentUser] fetch];
    User *thisUser = [[User alloc] initWithUser:currentUser];
    thisUser.pendingFriends = [NSMutableArray array];
    thisUser.nectRequests = [NSMutableArray array];
    thisUser.friends = [NSMutableArray array];
    
    PFQuery *pendingQuery = [PFQuery queryWithClassName:@"NectRequest"];
    [pendingQuery whereKey:@"sender" equalTo:thisUser.username];
    // fetch data asynchronously
    [pendingQuery findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
        if (requests != nil) {
            for(PFObject *request in requests){
                [thisUser.dontMatchNames addObject:request[@"receiver"]];
                [thisUser.pendingFriends addObject:request[@"receiver"]];
            }
            PFQuery *requestQuery = [PFQuery queryWithClassName:@"NectRequest"];
            [requestQuery whereKey:@"receiver" equalTo:thisUser.username];
            // fetch data asynchronously
            [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
                if (requests != nil) {
                    for(PFObject *request in requests){
                        [thisUser.dontMatchNames addObject:request[@"sender"]];
                        [thisUser.nectRequests addObject:request[@"sender"]];
                    }
                    PFQuery *friends1Query = [PFQuery queryWithClassName:@"Friend"];
                    [friends1Query whereKey:@"friend1" equalTo:thisUser.username];
                    
                    [friends1Query findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
                        if (requests != nil) {
                            for(PFObject *request in requests){
                                [thisUser.friends addObject:request[@"friend2"]];
                                [thisUser.dontMatchNames addObject:request[@"friend2"]];
                            }
                            PFQuery *friends2Query = [PFQuery queryWithClassName:@"Friend"];
                            [friends2Query whereKey:@"friend2" equalTo:thisUser.username];
                            
                            [friends2Query findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
                                if (requests != nil) {
                                    for(PFObject *request in requests){
                                        [thisUser.friends addObject:request[@"friend1"]];
                                        [thisUser.dontMatchNames addObject:request[@"friend1"]];
                                    }
                                }
                                currentUser[@"pendingFriends"] = thisUser.pendingFriends;
                                currentUser[@"nectRequests"] = thisUser.nectRequests;
                                currentUser[@"friends"] = thisUser.friends;
                                [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                  if (succeeded) {
                                      NSLog(@"Success, saved user");
                                  } else {
                                      NSLog(@"There was a problem: %@", error.description);
                                  }
                                }];
                            }];
                        } else {
                            NSLog(@"%@", error.localizedDescription);
                            PFQuery *friends2Query = [PFQuery queryWithClassName:@"Friend"];
                            [friends2Query whereKey:@"friend2" equalTo:thisUser.username];
                            
                            [friends2Query findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
                                if (requests != nil) {
                                    for(PFObject *request in requests){
                                        [thisUser.friends addObject:request[@"friend1"]];
                                        [thisUser.dontMatchNames addObject:request[@"friend1"]];
                                    }
                                }
                                currentUser[@"pendingFriends"] = thisUser.pendingFriends;
                                currentUser[@"nectRequests"] = thisUser.nectRequests;
                                currentUser[@"friends"] = thisUser.friends;
                                [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                  if (succeeded) {
                                      NSLog(@"Success, saved user");
                                  } else {
                                      NSLog(@"There was a problem: %@", error.description);
                                  }
                                }];
                            }];
                        }
                    }];
                    currentUser[@"pendingFriends"] = thisUser.pendingFriends;
                    currentUser[@"nectRequests"] = thisUser.nectRequests;
                    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                      if (succeeded) {
                          NSLog(@"Success, saved user");
                      } else {
                          NSLog(@"There was a problem: %@", error.description);
                      }
                    }];
                } else {
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

-(void)dontMatch{
    PFUser *currentUser = [[PFUser currentUser] fetch];
    User *thisUser = [[User alloc] initWithUser:currentUser];
    thisUser.pendingFriends = [NSMutableArray array];
    thisUser.nectRequests = [NSMutableArray array];
    thisUser.friends = [NSMutableArray array];
    
    PFQuery *pendingQuery = [PFQuery queryWithClassName:@"NectRequest"];
    [pendingQuery whereKey:@"sender" equalTo:thisUser.username];
    // fetch data asynchronously
    [pendingQuery findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
        if (requests != nil) {
            for(PFObject *request in requests){
                [thisUser.dontMatchNames addObject:request[@"receiver"]];
                [thisUser.pendingFriends addObject:request[@"receiver"]];
            }
            PFQuery *requestQuery = [PFQuery queryWithClassName:@"NectRequest"];
            [requestQuery whereKey:@"receiver" equalTo:thisUser.username];
            // fetch data asynchronously
            [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
                if (requests != nil) {
                    for(PFObject *request in requests){
                        [thisUser.dontMatchNames addObject:request[@"sender"]];
                        [thisUser.nectRequests addObject:request[@"sender"]];
                    }
                    PFQuery *friends1Query = [PFQuery queryWithClassName:@"Friend"];
                    [friends1Query whereKey:@"friend1" equalTo:thisUser.username];
                    
                    [friends1Query findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
                        NSLog(@"Requests %@", requests);
                        if (requests != nil) {
                            for(PFObject *request in requests){
                                [thisUser.friends addObject:request[@"friend2"]];
                                [thisUser.dontMatchNames addObject:request[@"friend2"]];
                            }
                            NSLog(@"%@", thisUser.dontMatchNames);
                            PFQuery *friends2Query = [PFQuery queryWithClassName:@"Friend"];
                            [friends2Query whereKey:@"friend2" equalTo:thisUser.username];
                            
                            [friends2Query findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
                                if (requests != nil) {
                                    for(PFObject *request in requests){
                                        [thisUser.friends addObject:request[@"friend1"]];
                                        [thisUser.dontMatchNames addObject:request[@"friend1"]];
                                    }
                                }
                                currentUser[@"pendingFriends"] = thisUser.pendingFriends;
                                currentUser[@"nectRequests"] = thisUser.nectRequests;
                                currentUser[@"friends"] = thisUser.friends;
                                [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                  if (succeeded) {
                                      NSLog(@"Success, saved user");
                                  } else {
                                      NSLog(@"There was a problem: %@", error.description);
                                  }
                                }];
                                [self matchUser:thisUser];
                            }];
                            
                        } else {
                            NSLog(@"%@", error.localizedDescription);
                            PFQuery *friends2Query = [PFQuery queryWithClassName:@"Friend"];
                            [friends2Query whereKey:@"friend2" equalTo:thisUser.username];
                            
                            [friends2Query findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
                                if (requests != nil) {
                                    for(PFObject *request in requests){
                                        [thisUser.friends addObject:request[@"friend1"]];
                                        [thisUser.dontMatchNames addObject:request[@"friend1"]];
                                    }
                                }
                                currentUser[@"pendingFriends"] = thisUser.pendingFriends;
                                currentUser[@"nectRequests"] = thisUser.nectRequests;
                                currentUser[@"friends"] = thisUser.friends;
                                [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                  if (succeeded) {
                                      NSLog(@"Success, saved user");
                                  } else {
                                      NSLog(@"There was a problem: %@", error.description);
                                  }
                                }];
                            }];
                            [self matchUser:thisUser];
                        }
                    }];
                    currentUser[@"pendingFriends"] = thisUser.pendingFriends;
                    currentUser[@"nectRequests"] = thisUser.nectRequests;
                    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                      if (succeeded) {
                          NSLog(@"Success, saved user");
                      } else {
                          NSLog(@"There was a problem: %@", error.description);
                      }
                    }];
                } else {
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

-(void)matchUser:(User *)thisUser{
    PFQuery *query = [PFUser query];
//    PFUser *currentUser = [[PFUser currentUser] fetch];
//    User *thisUser = [[User alloc] initWithUser:currentUser];
//    [thisUser dontMatch];
    
    //get valid users
    [query whereKey:@"username" notEqualTo:thisUser.username];
    while(thisUser.dontMatchNames == nil){
        NSLog(@"loading");
    }
    NSLog(@"%@", thisUser.dontMatchNames);
    for(NSString *username in thisUser.dontMatchNames){
        if(![self.matchedUsers containsObject:username]){
            [self.matchedUsers addObject:username];
        }
    }
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
            }
            if(self.bestMatch == nil){
                self.bestMatch = [[User alloc] initWithUser:users[0]];
                NSLog(@"Shouldn't be here");
            }
            [self.matchedUsers addObject:self.bestMatch.username];
            [self displayMatch];
             
        } else {
            NSLog(@"No new users to match with");
            self.theyAlsoPlay.text = @"No matches :(";
            [UIView animateWithDuration:0.5 animations:^{
                self.displayPhotoView.alpha = 0;
                self.displayNameLabel.alpha = 0;
                self.nectUsernameLabel.alpha = 0;
                self.theyAlsoPlay.alpha = 0;
                self.matchedGamesLabel.alpha = 0;
            }];
            
            [UIView animateWithDuration:1 animations:^{
                self.theyAlsoPlay.alpha = 1;
            }];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if([[segue identifier] isEqual:@"ShowUserProfile"]){
         UserProfileViewController *userProfileViewController = [segue destinationViewController];
         userProfileViewController.user = self.bestMatch;
     }
    if([[segue identifier] isEqual:@"showFriends"]){
        FriendsViewController *friendsViewController = [segue destinationViewController];
        friendsViewController.nectViewController = self;
    }
}


@end
