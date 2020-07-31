//
//  ChatViewController.m
//  Nect
//
//  Created by Alyssa Tan on 7/30/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "ChatViewController.h"
#import "Message.h"
#import "ChatCell.h"
#import "DetailedChatViewController.h"

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *alreadyRetrievedFriends;
@property (strong, nonatomic) NSMutableArray *chats;
@property (strong, nonatomic) NSArray *filteredChats;
@property (strong, nonatomic) IBOutlet UITableView *chatTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic,assign) NSTimer *myTimer;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    self.searchBar.delegate = self;
    
    [self getChats];
    
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(getChats) userInfo:nil repeats:YES];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getChats) forControlEvents:UIControlEventValueChanged];
    [self.chatTableView addSubview:self.refreshControl];
}

-(void)viewDidDisappear:(BOOL)animated{
    //[self.myTimer invalidate];
}

-(void)getChats{
    PFQuery *chatQuery1 = [PFQuery queryWithClassName:@"Chat"];
    [chatQuery1 whereKey:@"receiver" equalTo:[[PFUser currentUser] fetch][@"username"]];
    
    PFQuery *chatQuery2 = [PFQuery queryWithClassName:@"Chat"];
    [chatQuery2 whereKey:@"sender" equalTo:[[PFUser currentUser] fetch][@"username"]];
    
    PFQuery *mainChatQuery = [PFQuery orQueryWithSubqueries:@[chatQuery1,chatQuery2]];
    [mainChatQuery orderByDescending:@"createdAt"];
    [mainChatQuery includeKey:@"author"];
    
    [mainChatQuery findObjectsInBackgroundWithBlock:^(NSArray *chats, NSError *error) {
        if (chats != nil) {
            self.chats = [NSMutableArray array];
            self.alreadyRetrievedFriends = [NSMutableArray array];
            for(PFObject *dict in chats){
                Message *myMessage = [[Message alloc]initWithDictionary:(NSDictionary *)dict];
                myMessage.createdAt = [dict createdAt];
                NSString *friend = @"";
                if([myMessage.sender isEqualToString:[[PFUser currentUser] fetch][@"username"]]){
                    friend = myMessage.receiver;
                }else{
                    friend = myMessage.sender;
                }
                if(![self.alreadyRetrievedFriends containsObject:friend]){
                    [self.chats addObject:myMessage];
                    [self.alreadyRetrievedFriends addObject:friend];
                }
            }
            self.filteredChats = (NSArray *)self.chats;
            [self.refreshControl endRefreshing];
            [self.chatTableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqual:@"ChatDetail"]){
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.chatTableView indexPathForCell:(UITableViewCell *)tappedCell];
        Message *message  = self.filteredChats[indexPath.row];
        DetailedChatViewController *detailedChatViewController = [segue destinationViewController];
        detailedChatViewController.message = message;
    }
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
    [cell setCell:self.filteredChats[indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredChats.count;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        //need to make it so that capitalizatino is not taken into account! *********
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"(sender contains[c] %@)",searchText];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"(receiver contains[c] %@)",searchText];
        NSPredicate *combinedPredicate = [NSCompoundPredicate orPredicateWithSubpredicates: @[predicate1,predicate2]];
        self.filteredChats = [self.chats filteredArrayUsingPredicate:combinedPredicate];
    }
    else {
        self.filteredChats = self.chats;
    }
    [self.chatTableView reloadData];
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
