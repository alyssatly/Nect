//
//  DetailedChatViewController.m
//  Nect
//
//  Created by Alyssa Tan on 7/30/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "DetailedChatViewController.h"
#import "MessageCell.h"
#import <Parse/Parse.h>
#import "Message.h"
@import GiphyUISDK;
@import GiphyCoreSDK;

@interface DetailedChatViewController () <UITableViewDataSource, UITableViewDelegate,GiphyDelegate>
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) IBOutlet UITableView *chatTableView;
@property (strong, nonatomic) IBOutlet UIView *currentView;
@property (strong, nonatomic) NSMutableArray *messages;
@property (assign, nonatomic) NSTimer *myTimer;

@end

@implementation DetailedChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [Giphy configureWithApiKey:@"3spFE1PoXldiHpwEC96b4zfolhT6gS8l" verificationMode:false] ;
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    self.title = self.user.displayName;
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatTableView.transform = CGAffineTransformMakeScale (1,-1);
    
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getMessages) userInfo:nil repeats:YES];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.currentView addGestureRecognizer:gestureRecognizer];
    
    if(self.user == nil){
        NSString *friend = @"";
        if([self.message.sender isEqualToString:[[PFUser currentUser] fetch][@"username"]]){
            friend = self.message.receiver;
        }else{
            friend = self.message.sender;
        }
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:friend];
        [query findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
            if (requests.count != 0) {
                User *friendUser = [[User alloc] initWithUser:requests[0]];
                self.user = friendUser;
                self.title = self.user.displayName;
                [self getMessages];
            }
        }];
    }else{
        [self getMessages];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.myTimer invalidate];
    self.myTimer = nil;
}

-(void)getMessages{
    NSLog(@"getting messages");
    PFQuery *chatQuery1 = [PFQuery queryWithClassName:@"Chat"];
    [chatQuery1 whereKey:@"sender" equalTo:self.user.username];
    [chatQuery1 whereKey:@"receiver" equalTo:[[PFUser currentUser] fetch][@"username"]];
    
    PFQuery *chatQuery2 = [PFQuery queryWithClassName:@"Chat"];
    [chatQuery2 whereKey:@"receiver" equalTo:self.user.username];
    [chatQuery2 whereKey:@"sender" equalTo:[[PFUser currentUser] fetch][@"username"]];
    
    PFQuery *mainChatQuery = [PFQuery orQueryWithSubqueries:@[chatQuery1,chatQuery2]];
    [mainChatQuery orderByDescending:@"createdAt"];
    mainChatQuery.limit = 15; // try to implement infinite scrolling as you scroll up?
    
    [mainChatQuery findObjectsInBackgroundWithBlock:^(NSArray *chats, NSError *error) {
        if (chats != nil) {
            self.messages = [NSMutableArray array];
            for(NSDictionary *dict in chats){
                Message *myMessage = [[Message alloc]initWithDictionary:dict];
                [self.messages addObject:myMessage];
            }
            [self.chatTableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

-(void)hideKeyboard{
    [self.currentView endEditing:YES];
}

// #pragma mark - Navigation
// 
// - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
// 
// }
- (IBAction)sendPressed:(id)sender {
    if(![self.messageTextField.text isEqualToString:@""]){
        PFObject *chat = [PFObject objectWithClassName:@"Chat"];
        chat[@"message"] = self.messageTextField.text;
        self.messageTextField.text = @"";
        chat[@"sender"] = [[PFUser currentUser] fetch][@"username"];
        chat[@"receiver"] = self.user.username;
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Chat created!");
                [self getMessages];
                
            } else {
                NSLog(@"Error: %@", error.description);
            }
        }];
    }
    [self.currentView endEditing:YES];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    cell.transform = CGAffineTransformMakeScale(1, -1);
    [cell setCell:self.messages[indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.currentView.frame;
        f.origin.y = -self.currentView.frame.size.height * 0.3;
        self.currentView.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.currentView.frame;
        f.origin.y = 0.0f;
        self.currentView.frame = f;
    }];
}

- (IBAction)gifPressed:(id)sender {
    GiphyViewController *giphy = [[GiphyViewController alloc]init ] ;
    giphy.layout = GPHGridLayoutWaterfall;
    giphy.theme = [[GPHTheme alloc] init];
    giphy.rating = GPHRatingTypeRatedPG13;
    giphy.delegate = self;
    giphy.showConfirmationScreen = true ;
    [giphy setMediaConfigWithTypes: [ [NSMutableArray alloc] initWithObjects:
                                     @(GPHContentTypeGifs),@(GPHContentTypeStickers), @(GPHContentTypeText),@(GPHContentTypeEmoji), nil] ];
    [self presentViewController:giphy animated:true completion:nil] ;
}
- (void)didDismissWithController:(GiphyViewController * _Nullable)controller {
    
}

- (void)didSelectMediaWithGiphyViewController:(GiphyViewController * _Nonnull)giphyViewController media:(GPHMedia * _Nonnull)media {
    PFObject *chat = [PFObject objectWithClassName:@"Chat"];
    self.messageTextField.text = @"";
    chat[@"sender"] = [[PFUser currentUser] fetch][@"username"];
    chat[@"receiver"] = self.user.username;
    NSString *url = [NSString stringWithFormat:@"https://media%ld.giphy.com/media/%@/giphy.gif",media.type + 1,media.id];
    chat[@"gif"] = url ;
    //NSLog(@"%@, %@, %@",media.source, media.url, media.id);
    [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Gif created!");
            [self getMessages];

        } else {
            NSLog(@"Error: %@", error.description);
        }
    }];

    [self.currentView endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
