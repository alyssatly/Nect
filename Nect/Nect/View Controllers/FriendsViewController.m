//
//  FriendsViewController.m
//  Nect
//
//  Created by Alyssa Tan on 7/21/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "FriendsViewController.h"
#import "FriendCell.h"
#import "UserProfileViewController.h"
#import "NectViewController.h"

@interface FriendsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *tabControl;
@property (strong, nonatomic) IBOutlet UITableView *friendsTableView;
@property (strong, nonatomic) NSMutableArray *friends;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.friendsTableView.dataSource = self;
    self.friendsTableView.delegate = self;
    // Do any additional setup after loading the view.
    [self getFriends];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getFriends) forControlEvents:UIControlEventValueChanged];
    [self.friendsTableView insertSubview:self.refreshControl atIndex:0];
    [self.friendsTableView addSubview:self.refreshControl];
}

-(void)getFriends{
    [self.nectViewController refreshInfo];
    if(self.tabControl.selectedSegmentIndex == 0){
        self.friends = [NSMutableArray array];
        PFUser *currentUser = [[PFUser currentUser] fetch];
        for(NSString* username in currentUser[@"friends"]){
            PFQuery *requestQuery = [PFUser query];
            [requestQuery whereKey:@"username" equalTo:username];
            [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
                if (requests.count != 0) {
                    User *friendUser = [[User alloc]initWithUser:requests[0]];
                    [self.friends addObject:friendUser];
                }
                [self.friendsTableView reloadData];
            }];
        }
        [self.friendsTableView reloadData];
        [self.refreshControl endRefreshing];
    }else{
        self.friends = [NSMutableArray array];
        PFUser *currentUser = [[PFUser currentUser] fetch];
        PFQuery *requestQuery = [PFQuery queryWithClassName:@"NectRequest"];
        [requestQuery whereKey:@"sender" equalTo:currentUser[@"username"]];
        // fetch data asynchronously
        [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
            if (requests.count != 0) {
                for(PFObject *request in requests){
                    PFQuery *userQuery = [PFUser query];
                    [userQuery whereKey:@"username" equalTo:request[@"receiver"]];
                    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
                        if (users.count != 0) {
                            User *requestedUser = [[User alloc] initWithUser:users[0]];
                            [self.friends addObject:requestedUser];
                        }
                        [self.friendsTableView reloadData];
                    }];
                }
                [self.refreshControl endRefreshing];
            } else {
                self.friends = [NSMutableArray array];
                [self.friendsTableView reloadData];
                [self.refreshControl endRefreshing];
            }
        }];

    }
        
}
- (IBAction)changedValue:(id)sender {
    [self getFriends];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqual:@"showFriendProfile"]){
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.friendsTableView indexPathForCell:(UITableViewCell *)tappedCell];
        User *friendUser = self.friends[indexPath.row];
        UserProfileViewController *userProfileViewController = [segue destinationViewController];
        userProfileViewController.user = friendUser;
        userProfileViewController.friendsViewController = self;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendsCell"];
    User *requestUser = self.friends[indexPath.row];
    [cell setCell:requestUser];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friends.count;
}
@end
