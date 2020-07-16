//
//  ProfileViewController.m
//  Nect
//
//  Created by Alyssa Tan on 7/13/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "MBProgressHUD.h"
#import "Game.h"
#import "ProfileGameCell.h"
#import "UIImageView+AFNetworking.h"
@import Parse;

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet PFImageView *profilePicView;
@property (strong, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *aboutLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *games;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UIScrollView *profileView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    layout.minimumLineSpacing = 3;
    layout.minimumInteritemSpacing = 4;

    CGFloat postersPerLine = 4;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1))/postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth,itemHeight);

    [self getProfile];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
   [self.refreshControl addTarget:self action:@selector(getProfile) forControlEvents:UIControlEventValueChanged];
   [self.profileView insertSubview:self.refreshControl atIndex:0];
   [self.profileView addSubview:self.refreshControl];
}

-(void)getProfile{
    PFUser *currentUser = [[PFUser currentUser] fetch];
    
    self.profilePicView.layer.masksToBounds = YES;
    self.profilePicView.layer.cornerRadius = self.profilePicView.frame.size.height/2.2;
    self.profilePicView.layer.borderWidth = 0;
    if(currentUser[@"displayPhoto"] != nil){
        self.profilePicView.file= currentUser[@"displayPhoto"];
        [self.profilePicView loadInBackground];
    }
    self.displayNameLabel.text = currentUser[@"displayName"];
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", currentUser[@"username"]];
    self.aboutLabel.text = currentUser[@"about"];
    
    self.games = [NSMutableArray array];
    for(NSDictionary *gameDict in currentUser[@"games"]){
        Game *game = [[Game alloc] initWithDictionary:gameDict];
        [self.games addObject:game];
    }
    [self.collectionView reloadData];
    [self.refreshControl endRefreshing];
}

- (IBAction)logoutPressed:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if(error != nil){
            NSLog(@"There was a problem logging out");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }else{
            NSLog(@"Successfully logged out!");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        
            sceneDelegate.window.rootViewController = loginViewController;
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

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    Game *game = self.games[indexPath.item];
    ProfileGameCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileGameCell" forIndexPath:indexPath];
    
    NSURL*posterURL = [NSURL URLWithString:game.image];
    cell.profileGameView.image = [UIImage systemImageNamed:@"smiley"];
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

@end
