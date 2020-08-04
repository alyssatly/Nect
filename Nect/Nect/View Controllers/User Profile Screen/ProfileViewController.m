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
#import "DetailsGameViewController.h"
#import "UIScrollView+EmptyDataSet.h"
@import Parse;

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

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
    
    self.collectionView.emptyDataSetSource = self;
    self.collectionView.emptyDataSetDelegate = self;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self getProfile];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getProfile) forControlEvents:UIControlEventValueChanged];
    [self.profileView addSubview:self.refreshControl];
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
    PFUser *currentUser = [[PFUser currentUser] fetch];
    
    self.profilePicView.layer.masksToBounds = YES;
    self.profilePicView.layer.cornerRadius = self.profilePicView.frame.size.height/2.1;
    self.profilePicView.layer.borderWidth = 0;
    if(currentUser[@"displayPhoto"] != nil){
        self.profilePicView.file= currentUser[@"displayPhoto"];
        [self.profilePicView loadInBackground];
    }
    self.displayNameLabel.text = currentUser[@"displayName"];
    if([self.displayNameLabel.text isEqualToString:@""] || currentUser[@"displayName"] == nil){
        self.displayNameLabel.text = currentUser[@"username"];
    }
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", currentUser[@"username"]];
    NSLog(@"%@", currentUser[@"username"]);
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

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage systemImageNamed:@"gamecontroller.fill"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"You Have No Games Added";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Click on Edit Profile -> Edit Games to add games";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
                                 
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

@end
