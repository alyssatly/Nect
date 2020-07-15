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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.username = dictionary[@"username"];
        self.displayName = dictionary[@"displayName"];
        self.profilePic = dictionary[@"displayPhoto"];
        self.about = dictionary[@"about"];
        self.games = dictionary[@"games"];
        //...
      // Initialize any other properties
    }
    return self;
}

@end
