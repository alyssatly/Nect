//
//  NectViewController.m
//  Nect
//
//  Created by Alyssa Tan on 7/13/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "NectViewController.h"
#import <Parse/Parse.h>
#import "User.h"
#import "FriendsViewController.h"
#import "UserProfileViewController.h"
#import "FilterViewController.h"
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
@property (strong, nonatomic) User *bestMatch;
@property (assign, nonatomic) NSInteger *highestScore;
@property (strong, nonatomic) NSMutableArray *matchedGames;
@property (strong, nonatomic) NSString *genderPreference;
@property (assign, nonatomic) NSInteger youngest;
@property (assign, nonatomic) NSInteger oldest;
@property (strong, nonatomic) NSString *countryPreference;

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
    self.youngest = 0;
    self.oldest = 100;
    
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
    [self dontMatch];
    
    if(self.nectButton.frame.origin.y < (self.currentView.frame.size.height * 0.6)){
        [self.nectButton setTranslatesAutoresizingMaskIntoConstraints:YES];
        [UIView animateWithDuration:1 animations:^{
            self.nectButton.frame = CGRectMake(self.nectButton.frame.origin.x, self.nectButton.frame.origin.y + (self.currentView.frame.size.height * 0.23), self.nectButton.frame.size.width, self.nectButton.frame.size.height);
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
    
    self.displayPhotoView.image = [UIImage imageNamed:@"default_game"];
    
    if(self.bestMatch.displayPhoto != nil){
        self.displayPhotoView.file = self.bestMatch.displayPhoto;
        [self.displayPhotoView loadInBackground];
    }
    self.displayNameLabel.text = self.bestMatch.displayName;
    if([self.displayNameLabel.text isEqualToString:@""]){
        self.displayNameLabel.text = self.bestMatch.username;
    }
    self.nectUsernameLabel.text = [NSString stringWithFormat:@"@%@", self.bestMatch.username];
    self.theyAlsoPlay.text = @"They also play:";
    
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
}

-(void)refreshInfo{
    PFUser *currentUser = [[PFUser currentUser] fetch];
    User *thisUser = [[User alloc] initWithUser:currentUser];
    thisUser.pendingFriends = [NSMutableArray array];
    thisUser.nectRequests = [NSMutableArray array];
    thisUser.friends = [NSMutableArray array];
    
    PFQuery *pendingQuery = [PFQuery queryWithClassName:@"NectRequest"];
    [pendingQuery whereKey:@"sender" equalTo:thisUser.username];
    [pendingQuery findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
        if (requests != nil) {
            for(PFObject *request in requests){
                [thisUser.dontMatchNames addObject:request[@"receiver"]];
                [thisUser.pendingFriends addObject:request[@"receiver"]];
            }
            PFQuery *requestQuery = [PFQuery queryWithClassName:@"NectRequest"];
            [requestQuery whereKey:@"receiver" equalTo:thisUser.username];
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

//This function retreieves all the users that the user should not match with (friends/pending friends/nect requests)
// it does this by going through the parse data base and looking through the nect request and friend relationships
-(void)dontMatch{
    PFUser *currentUser = [[PFUser currentUser] fetch];
    User *thisUser = [[User alloc] initWithUser:currentUser];
    thisUser.pendingFriends = [NSMutableArray array];
    thisUser.nectRequests = [NSMutableArray array];
    thisUser.friends = [NSMutableArray array];
    //first query retrieves users the current user have sent nect requests to
    PFQuery *pendingQuery = [PFQuery queryWithClassName:@"NectRequest"];
    [pendingQuery whereKey:@"sender" equalTo:thisUser.username];
    [pendingQuery findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
        if (requests != nil) {
            for(PFObject *request in requests){
                [thisUser.dontMatchNames addObject:request[@"receiver"]];
                [thisUser.pendingFriends addObject:request[@"receiver"]];
            }
            //second query retrieves the users that have sent the user a nect request
            PFQuery *requestQuery = [PFQuery queryWithClassName:@"NectRequest"];
            [requestQuery whereKey:@"receiver" equalTo:thisUser.username];
            [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
                if (requests != nil) {
                    for(PFObject *request in requests){
                        [thisUser.dontMatchNames addObject:request[@"sender"]];
                        [thisUser.nectRequests addObject:request[@"sender"]];
                    }
                    //third query and fourth query retrieve all friends of the current user
                    PFQuery *friends1Query = [PFQuery queryWithClassName:@"Friend"];
                    [friends1Query whereKey:@"friend1" equalTo:thisUser.username];
                    [friends1Query findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
                        if (requests != nil) {
                            for(PFObject *request in requests){
                                [thisUser.friends addObject:request[@"friend2"]];
                                [thisUser.dontMatchNames addObject:request[@"friend2"]];
                            }
                            //fourth query because a friend relationship consists of friend 1 and friend 2 in no particular order
                            //need to go through both to find all of the user's friends
                            PFQuery *friends2Query = [PFQuery queryWithClassName:@"Friend"];
                            [friends2Query whereKey:@"friend2" equalTo:thisUser.username];
                            [friends2Query findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
                                if (requests != nil) {
                                    for(PFObject *request in requests){
                                        [thisUser.friends addObject:request[@"friend1"]];
                                        [thisUser.dontMatchNames addObject:request[@"friend1"]];
                                    }
                                }
                                //finally this updates the user object so that the database is up to date with all of the user's friends/pending friends and nect requests
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
                                //after getting all users the current user should not match with, we can now procceed with matching the user with someone
                                [self matchUser:thisUser];
                            }];
                        } else {
                            //if there are no instances of the user as friend 1, there is still the possibility of the user being friend 2
                            //therefore we must still make sure this query is requested and that the data gets saved reagrdless.
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
    //set up query to filter out friends/pending friends/people already matched with
    [query whereKey:@"username" notEqualTo:thisUser.username];
    while(thisUser.dontMatchNames == nil){
        NSLog(@"loading");
    }
    for(NSString *username in thisUser.dontMatchNames){
        if(![self.matchedUsers containsObject:username]){
            [self.matchedUsers addObject:username];
        }
    }
    //set up query to use filters user requested to filter out matches
    [query whereKey:@"username" notContainedIn:self.matchedUsers];
    if(self.genderPreference != nil){
        [query whereKey:@"gender" equalTo:self.genderPreference];
    }
    [query whereKey:@"age" greaterThanOrEqualTo:@(self.youngest)];
    [query whereKey:@"age" lessThanOrEqualTo:@(self.oldest)];
    if(self.countryPreference != nil){
        [query whereKey:@"country" equalTo:self.countryPreference];
    }
    
    //used to keep track of best match for current user
    self.highestScore = 0;
    self.bestMatch = nil;
    self.matchedGames = [NSMutableArray array]; //keep track of similar games for the best macthed user
    //retrives all users that meet criteria
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users.count != 0) {
            for(PFUser *user in users){
                NSMutableArray *currentMatchedGames = [NSMutableArray array];
                User *matchingUser = [[User alloc] initWithUser:user];
                NSInteger gameCount = 0;
                //to be more efficiently, we go through the list of games of the user who has less games to see if any games are matching
                //if this user has hte most simillar games with current user, reassign highest score and best match
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
            //if there were no matches because no users had simillar games to the user, we return the first user that meets filter critirea
            if(self.bestMatch == nil){
                self.bestMatch = [[User alloc] initWithUser:users[0]];
            }
            //adding to matched list so that user can't get matched with this user again this session
            [self.matchedUsers addObject:self.bestMatch.username];
            [self displayMatch];
        } else {
            // either user has matched with all users or there are no longer anymore compatable matches given the filters
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
        }
    }];
}

-(void)updateFilters:(NSString *)gender young:(NSInteger)young old:(NSInteger)old country:(NSString *)country{
    self.genderPreference = nil;
    self.youngest = 0;
    self.oldest = 0;
    self.countryPreference = nil;
    if(![gender isEqualToString:@"None"]){
        self.genderPreference = gender;
    }
    self.youngest = young;
    self.oldest = old;
    if(![country isEqualToString:@""]){
        self.countryPreference = country;
    }
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
    if([[segue identifier] isEqual:@"filter"]){
        FilterViewController *filterViewController = [segue destinationViewController];
        filterViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        filterViewController.nectViewController = self;
    }
}


@end
