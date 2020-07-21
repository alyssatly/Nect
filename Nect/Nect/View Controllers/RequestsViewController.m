//
//  RequestsViewController.m
//  Nect
//
//  Created by Alyssa Tan on 7/20/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "RequestsViewController.h"
#import "RequestCell.h"
#import "UserProfileViewController.h"

@interface RequestsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *requests;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation RequestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.requests = [NSMutableArray array];
    
    [self getRequests];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getRequests) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    [self.tableView addSubview:self.refreshControl];
}

-(void)getRequests{
    self.requests = [NSMutableArray array];
    PFUser *currentUser = [[PFUser currentUser] fetch];
    PFQuery *requestQuery = [PFQuery queryWithClassName:@"NectRequest"];
    [requestQuery whereKey:@"receiver" equalTo:currentUser[@"username"]];
    // fetch data asynchronously
    [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
        if (requests.count != 0) {
            for(PFObject *request in requests){
                PFQuery *userQuery = [PFUser query];
                [userQuery whereKey:@"username" equalTo:request[@"sender"]];
                [userQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
                    if (users.count != 0) {
                        User *requestedUser = [[User alloc] initWithUser:users[0]];
                        [self.requests addObject:requestedUser];
                    }
                    [self.tableView reloadData];
                }];
            }
            [self.refreshControl endRefreshing];
        } else {
            self.requests = [NSMutableArray array];
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
    }];

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqual:@"showRequestProfile"]){
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)tappedCell];
        User *requestedUser = self.requests[indexPath.row];
        UserProfileViewController *userProfileViewController = [segue destinationViewController];
        userProfileViewController.user = requestedUser;
        userProfileViewController.requestViewController = self;
    }
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RequestCell"];
    User *requestUser = self.requests[indexPath.row];
    cell.requestsViewController = self;
    [cell setPost:requestUser];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.requests.count;
}

@end
