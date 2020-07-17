//
//  User.m
//  Nect
//
//  Created by Alyssa Tan on 7/15/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "User.h"
#import <Parse/Parse.h>

@implementation User

- (instancetype)initWithUser:(PFUser *)user {
    self = [super init];
    if (self) {
        self.username = user[@"username"];
        self.displayName = user[@"displayName"];
        self.displayPhoto = user[@"displayPhoto"];
        self.about = user[@"about"];
        self.games = user[@"games"];
        self.friends = user[@"friends"];
        self.pendingFriends = user[@"pendingFriends"];
        self.nectRequests = user[@"nectRequests"];
        
        self.dontMatchNames = [NSMutableArray array];
        
        for(NSDictionary *user in self.friends){
            [self.dontMatchNames addObject:user[@"username"]];
        }
        
        for(NSDictionary *user in self.pendingFriends){
            [self.dontMatchNames addObject:user[@"username"]];
        }
        
        for(NSDictionary *user in self.nectRequests){
            [self.dontMatchNames addObject:user[@"username"]];
        }
    }
    return self;
}

@end
