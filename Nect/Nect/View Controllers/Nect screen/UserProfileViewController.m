//
//  UserProfileViewController.m
//  Nect
//
//  Created by Alyssa Tan on 7/20/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "UserProfileViewController.h"
#import <Parse/Parse.h>
#import "ProfileGameCell.h"
#import "ProfileGameCell.h"
#import "Game.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsGameViewController.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "RequestsViewController.h"
@import Parse;

@interface UserProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet PFImageView *profilePicView;
@property (strong, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIButton *addOrRemoveButton;
@property (strong, nonatomic) IBOutlet UILabel *aboutLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *games;
@property (strong, nonatomic) PFUser *matchedUser;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self getProfile];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    layout.minimumLineSpacing = 3;
    layout.minimumInteritemSpacing = 4;
    
    const CGFloat postersPerLine = 4;
    const CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1))/postersPerLine;
    const CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth,itemHeight);
}

-(void)getProfile{
    self.profilePicView.layer.masksToBounds = YES;
    self.profilePicView.layer.cornerRadius = self.profilePicView.frame.size.height/2.1;
    self.profilePicView.layer.borderWidth = 0;
    
    self.profilePicView.image = [UIImage imageNamed:@"default_profile"];
    if(self.user.displayPhoto != nil){
        self.profilePicView.file= self.user.displayPhoto;
        [self.profilePicView loadInBackground];
    }
    self.displayNameLabel.text = self.user.displayName;
    if([self.displayNameLabel.text isEqualToString:@""]|| self.displayNameLabel.text == nil){
        self.displayNameLabel.text = self.user.username;
    }
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", self.user.username];
    self.aboutLabel.text = self.user.about;
    
    self.games = [NSMutableArray array];
    for(NSDictionary *gameDict in self.user.games){
        Game *game = [[Game alloc] initWithDictionary:gameDict];
        [self.games addObject:game];
    }
    
    PFUser *currentUser = [[PFUser currentUser] fetch];
    
    if([currentUser[@"friends"] containsObject:self.user.username]){
        [self.addOrRemoveButton setTitle:@"Remove Friend" forState:UIControlStateNormal];
    }else if([currentUser[@"pendingFriends"] containsObject:self.user.username]){
        [self.addOrRemoveButton setTitle:@"Cancel Request" forState:UIControlStateNormal];
    }else if([currentUser[@"nectRequests"] containsObject:self.user.username]){
        [self.addOrRemoveButton setTitle:@"Accept Request" forState:UIControlStateNormal];
    }else{
        [self.addOrRemoveButton setTitle:@"Add Friend" forState:UIControlStateNormal];
    }
    
    [self.collectionView reloadData];
}

- (NSDictionary *)dictionaryFromUser:(User *)user{
    NSDictionary *returnDict = [NSDictionary dictionaryWithObjectsAndKeys:user.username,@"username",
                                user.displayName, @"displayName",
                                user.displayPhoto, @"displayPhoto",
                                user.games, @"games",
                                user.about , @"about",
                                nil];
    return returnDict;
}

- (IBAction)addOrRemovePressed:(id)sender {
    //get the user you are viewing
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:self.user.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if(error != nil){
            NSLog(@"%@",error.description);
        }else{
            NSLog(@"Successfully got user you are vieweing!");
            self.matchedUser = users[0];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            PFUser *currentUser = [[PFUser currentUser] fetch];
            if([currentUser[@"friends"] containsObject:self.user.username]){
                [self removeFriend];
                [self.navigationController popViewControllerAnimated:YES];
            }else if([currentUser[@"pendingFriends"] containsObject:self.user.username]){
                //remove from pending friends, remove nect request from other user
                [self cancelRequest];
                [self.navigationController popViewControllerAnimated:YES];
            }else if([currentUser[@"nectRequests"] containsObject:self.user.username]){
                //add to current User's friends remove from nextRequests. Add to other user's friends and remove from pending requests
                [self acceptRequest];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self newRequest];
            }
        }
    }];
    
}

-(void)removeFriend{
    PFUser *currentUser = [[PFUser currentUser] fetch];
    NSMutableArray *currentFriends = currentUser[@"friends"];
    NSLog(@"%@",currentFriends);
    PFQuery *query = [PFQuery queryWithClassName:@"Friend"];
    [query whereKey:@"friend1" equalTo:currentUser[@"username"]];
    [query whereKey:@"friend2" equalTo:self.user.username];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            [object deleteInBackground];
            [currentFriends removeObject:self.user.username];
            currentUser[@"friend"] = currentFriends;
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"Success");
                    [self.friendsViewController getFriends];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                } else {
                    NSLog(@"There was a problem: %@", error.description);
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }
            }];
        } else {
            PFQuery *query = [PFQuery queryWithClassName:@"Friend"];
            [query whereKey:@"friend2" equalTo:currentUser[@"username"]];
            [query whereKey:@"friend1" equalTo:self.user.username];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (object) {
                    [object deleteInBackground];
                    [currentFriends removeObject:self.user.username];
                    currentUser[@"friend"] = currentFriends;
                    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) {
                            NSLog(@"Success");
                            [self.friendsViewController getFriends];
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        } else {
                            NSLog(@"There was a problem: %@", error.description);
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        }
                    }];
                } else {
                    NSLog(@"Unable to remove request");
                }
            }];
        }
    }];
}

-(void)cancelRequest{
    PFUser *currentUser = [[PFUser currentUser] fetch];
    NSMutableArray *currentFriends = currentUser[@"pendingFriends"];
    PFQuery *query = [PFQuery queryWithClassName:@"NectRequest"];
    [query whereKey:@"sender" equalTo:currentUser[@"username"]];
    [query whereKey:@"receiver" equalTo:self.user.username];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            [object deleteInBackground];
            [currentFriends removeObject:self.user.username];
            currentUser[@"pendingFriends"] = currentFriends;
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"Success");
                    [self.friendsViewController getFriends];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                } else {
                    NSLog(@"There was a problem: %@", error.description);
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }
            }];
        }
    }];
}

-(void)acceptRequest{
    PFQuery *query = [PFQuery queryWithClassName:@"NectRequest"];
    [query whereKey:@"receiver" equalTo:[[PFUser currentUser] fetch][@"username"]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            [object deleteInBackground];
            PFObject *friend = [PFObject objectWithClassName:@"Friend"];
            friend[@"friend1"] = [[PFUser currentUser] fetch][@"username"];
            friend[@"friend2"] = self.user.username;
            [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Friend Added!");
                    [self.requestViewController getRequests];
                } else {
                    NSLog(@"Error: %@", error.description);
                }
            }];
        } else {
            NSLog(@"Unable to remove request");
        }
    }];
}

-(void)newRequest{
    PFObject *nectRequest = [PFObject objectWithClassName:@"NectRequest"];
    nectRequest[@"sender"] = [[PFUser currentUser] fetch][@"username"];
    nectRequest[@"receiver"] = self.user.username;
    [nectRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Nect Request sent!");
            [self addAlert:@"Nect Request sent!" message:[NSString stringWithFormat:@"Successfully sent %@ a request",self.user.username]];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } else {
            NSLog(@"Error: %@", error.description);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

-(void)updateParse:(PFUser *)thisUser{
    [thisUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"Success");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } else {
            NSLog(@"There was a problem: %@", error.description);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqual:@"viewGame"]){
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:(UICollectionViewCell *)tappedCell];
        Game *game = self.games[indexPath.item];
        DetailsGameViewController *detailsGameViewController = [segue destinationViewController];
        detailsGameViewController.game = game;
    }
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Game *game = self.games[indexPath.item];
    ProfileGameCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileGameCell" forIndexPath:indexPath];
    
    NSURL*posterURL = [NSURL URLWithString:game.image];
    cell.profileGameView.image = [UIImage imageNamed:@"default_game"];
    cell.profileGameView.alpha = 0.0;
    [cell.profileGameView setImageWithURL:posterURL];
    
    [UIView animateWithDuration:1.0 animations:^{
        cell.profileGameView.alpha = 1.0;
    }];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.games.count;
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

@end
