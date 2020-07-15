//
//  Game.m
//  Nect
//
//  Created by Alyssa Tan on 7/15/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "Game.h"

@implementation Game

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self){
        self.name = dictionary[@"title"];
        NSLog(@"%@", self.name);
        self.gameDescription = dictionary[@"description"];
        self.genres = dictionary[@"genres"];
        self.image = dictionary[@"image"];
        self.developer = dictionary[@"developer"];
        
    }
    return self;
}


@end
