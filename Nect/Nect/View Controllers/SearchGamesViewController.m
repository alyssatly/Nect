//
//  SearchGamesViewController.m
//  Nect
//
//  Created by Alyssa Tan on 7/14/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "SearchGamesViewController.h"
#import "Game.h"
#import "GameCell.h"
#import "UIImageView+AFNetworking.h"
#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "DetailsGameViewController.h"
#import "EditViewController.h"
#import <Parse/Parse.h>

@interface SearchGamesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *games;
@property (strong, nonatomic) NSMutableArray *gameNames;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSString *searchName;


@end

@implementation SearchGamesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.searchBar.delegate = self;
    
    self.games = [NSMutableArray array];
    self.gameNames = [NSMutableArray array];
    
    //originally displays games in user's profile
    PFUser *currentUser = [[PFUser currentUser] fetch];
    for(NSDictionary *gameDict in currentUser[@"games"]){
        Game *game = [[Game alloc] initWithDictionary:gameDict];
        [self.games addObject:game];
    }
    [self.collectionView reloadData];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    layout.minimumLineSpacing = 3;
    layout.minimumInteritemSpacing = 4;

    CGFloat postersPerLine = 3;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1))/postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth,itemHeight);

    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // searchBarSearchButtonClicked is a callback from an UI action, so you can assume that this block is already running on main thread.
    [searchBar resignFirstResponder];
    // on main thread, so it's fine
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.games = [NSMutableArray array];
    self.gameNames = [NSMutableArray array];
    [self.collectionView reloadData];
    
    if(![searchBar.text isEqualToString:@""]){
        self.searchName = searchBar.text;
        // create this dispatch group
        dispatch_group_t group = dispatch_group_create();
        // this is for entering of API 1
        dispatch_group_enter(group);
        [self fetchGamesWithCompletionHandler:^(NSArray *gameArray, BOOL success) {
            if (success) {
                for(NSDictionary *dictionary in gameArray){
                    if(![self.gameNames containsObject:dictionary[@"title"]]){
                        [self.gameNames addObject:dictionary[@"title"]];
                        // This is for entering of API 2
                        dispatch_group_enter(group);
                        [self getInfo:dictionary completionHandler:^(NSDictionary *gameInfo, BOOL success) {
                            if (success) {
                                Game *game = [[Game alloc] initWithDictionary:gameInfo];
                                //NSLog(@"%@", game.name);
                                [self.games addObject:game];
                                dispatch_async(dispatch_get_main_queue(), ^(void){
                                    [self.collectionView reloadData];
                                });
                            }
                            // This is for leaving of API 2
                            dispatch_group_leave(group);
                        }];
                    }
                }
            }
            // This is for leaving of API 1
            dispatch_group_leave(group);
        }];
        // almost correct. you need to run this on main thread
        dispatch_group_notify(group, dispatch_get_main_queue(), ^ {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        //display user's games
        PFUser *currentUser = [[PFUser currentUser] fetch];
        self.games = [NSMutableArray array];
        for(NSDictionary *gameDict in currentUser[@"games"]){
            Game *game = [[Game alloc] initWithDictionary:gameDict];
            [self.games addObject:game];
        }
        [self.collectionView reloadData];
    }
}

-(void)fetchGamesWithCompletionHandler:(void (^)(NSArray* gameArray, BOOL success))completionHandler {
    NSDictionary *headers = @{ @"x-rapidapi-host": @"chicken-coop.p.rapidapi.com",
                               @"x-rapidapi-key": @"c91967f358msh851b0b71ae8c675p1070cbjsn0e2b892bbbfd" };

    //change it so that it takes in user input ****
    //self.searchName = [self.searchName stringByReplacingOccurrencesOfString:@":" withString:@"%253A"];
    self.searchName = [self.searchName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    self.searchName = [self.searchName stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    NSString* myURL =[NSString stringWithFormat:@"https://chicken-coop.p.rapidapi.com/games?title=%@", self.searchName];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:myURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:
    ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            completionHandler(nil, NO);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if([dataDictionary[@"result"] isKindOfClass:[NSArray class]]){
                NSArray *dictionaries = dataDictionary[@"result"];
                completionHandler(dictionaries, YES);
                /*
                //NSLog(@"%@", dictionaries);
                
                */
            } else {
                NSLog(@"No Results!");
                completionHandler(nil, NO);
            }

        }
    }];
    [dataTask resume];
}


-(void)getInfo:(NSDictionary *)dictionary completionHandler:(void (^)(NSDictionary* gameInfo, BOOL success))completionHandler{
    
    NSString *name = dictionary[@"title"];
    NSString *platform = dictionary[@"platform"];
    
    NSDictionary *headers = @{ @"x-rapidapi-host": @"chicken-coop.p.rapidapi.com",
                               @"x-rapidapi-key": @"c91967f358msh851b0b71ae8c675p1070cbjsn0e2b892bbbfd" };
    
    name = [name stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    name = [name stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    name = [name stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    //change it so that it takes in user input ****
    NSString* myURL =[NSString stringWithFormat:@"https://chicken-coop.p.rapidapi.com/games/%@?platform=%@", name,[platform lowercaseString]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:myURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            completionHandler(nil, NO);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //NSLog(@"%@",dataDictionary);
            if([dataDictionary[@"result"] isKindOfClass:[NSDictionary class]]){
                completionHandler(dataDictionary[@"result"], YES);
            } else {
                completionHandler(nil, NO);
            }
        }
    }];
    [dataTask resume];
}

- (IBAction)backPressed:(id)sender {
    [self.editViewController updateImages];
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqual:@"gameDetails"]){
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:(UICollectionViewCell *)tappedCell];
        Game *game = self.games[indexPath.item];
        DetailsGameViewController *detailsGameViewController = [segue destinationViewController];
        detailsGameViewController.game = game;
    }
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Game *game = self.games[indexPath.item];
    GameCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GameCell" forIndexPath:indexPath];
    
    NSURL*posterURL = [NSURL URLWithString:game.image];
    cell.posterView.image = [UIImage systemImageNamed:@"smiley"];
    cell.posterView.alpha = 0.0;
    [cell.posterView setImageWithURL:posterURL];
    
    [UIView animateWithDuration:1.0 animations:^{
        cell.posterView.alpha = 1.0;
    }];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.games.count;
}

@end
