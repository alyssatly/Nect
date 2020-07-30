//
//  CreateChatViewController.m
//  Nect
//
//  Created by Alyssa Tan on 7/30/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "CreateChatViewController.h"
#import "DetailedChatViewController.h"
#import "StartChatCell.h"

@interface CreateChatViewController () <UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) NSArray *filteredFriends;
@property (strong, nonatomic) IBOutlet UITableView *startChatView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation CreateChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startChatView.delegate = self;
    self.startChatView.dataSource = self;
    self.searchBar.delegate = self;
    
    [self getFriends];
}

-(void)getFriends{
    self.friends = [NSMutableArray array];
    PFUser *currentUser = [[PFUser currentUser] fetch];
    NSArray *sortedFriends = [currentUser[@"friends"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for(NSString* username in sortedFriends){
        PFQuery *requestQuery = [PFUser query];
        [requestQuery whereKey:@"username" equalTo:username];
        [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
            if (requests.count != 0) {
                User *friendUser = [[User alloc]initWithUser:requests[0]];
                [self.friends addObject:friendUser];
            }
            self.filteredFriends = (NSArray *)self.friends;
            //need to find a way to sort alphabetically
            //self.filteredFriends = [self.friends sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [self.startChatView reloadData];
        }];
    }
}

 #pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if([[segue identifier] isEqual:@"ChatDetail"]){
      UITableViewCell *tappedCell = sender;
      NSIndexPath *indexPath = [self.startChatView indexPathForCell:(UITableViewCell *)tappedCell];
      User *friendUser = self.filteredFriends[indexPath.row];
      DetailedChatViewController *detailedChatViewController = [segue destinationViewController];
      detailedChatViewController.user = friendUser;
  }
 }

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    StartChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StartChatCell"];
    [cell setCell:self.filteredFriends[indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredFriends.count;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        self.filteredFriends = [self.friends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(displayName contains[c] %@)", searchText]];
    }
    else {
        self.filteredFriends = self.friends;
    }
    [self.startChatView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

@end
