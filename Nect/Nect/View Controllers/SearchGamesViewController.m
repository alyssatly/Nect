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
    
    //[self fetchGames];
    
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
    [searchBar resignFirstResponder];
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.games = [NSMutableArray array];
    self.gameNames = [NSMutableArray array];
    [self.collectionView reloadData];
    
    if(![searchBar.text isEqualToString:@""]){
        self.searchName = searchBar.text;
        [self fetchGames];
    }
    
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

-(void)fetchGames{
    NSDictionary *headers = @{ @"x-rapidapi-host": @"chicken-coop.p.rapidapi.com",
                               @"x-rapidapi-key": @"c91967f358msh851b0b71ae8c675p1070cbjsn0e2b892bbbfd" };

    //change it so that it takes in user input ****
    //self.searchName = [self.searchName stringByReplacingOccurrencesOfString:@":" withString:@"%253A"];
    self.searchName = [self.searchName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    self.searchName = [self.searchName stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    NSString* myURL =[NSString stringWithFormat:@"https://chicken-coop.p.rapidapi.com/games?title=%@", self.searchName];
    NSLog(@"%@", myURL);
    //https://chicken-coop.p.rapidapi.com/games?title=oxygen%20not%20included "/rest/games?title=oxygen%20not%20included"
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
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if([dataDictionary[@"result"] isKindOfClass:[NSArray class]]){
                NSArray *dictionaries = dataDictionary[@"result"];
                //NSLog(@"%@", dictionaries);
                for(NSDictionary *dictionary in dictionaries){
                    if(![self.gameNames containsObject:dictionary[@"title"]]){
                        [self.gameNames addObject:dictionary[@"title"]];
                        [self getInfo:dictionary];
                    }
                }
            }else{
                NSLog(@"No Results!");
            }

        }
    }];

    [dataTask resume];
   
    
}



-(void)getInfo:(NSDictionary *)dictionary {
    
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
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //NSLog(@"%@",dataDictionary);
            if([dataDictionary[@"result"] isKindOfClass:[NSDictionary class]]){
                
                Game *game = [[Game alloc] initWithDictionary:dataDictionary[@"result"]];
                //NSLog(@"%@", game.name);
                [self.games addObject:game];
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                    //Background Thread
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [self.collectionView reloadData];
                    });
                });
                
            }
        }
    }];
    [dataTask resume];
}

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
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
    GameCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GameCell" forIndexPath:indexPath];
    
    NSURL*posterURL = [NSURL URLWithString:game.image];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:posterURL];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.games.count;
}

@end
