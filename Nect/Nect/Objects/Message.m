//
//  Message.m
//  Nect
//
//  Created by Alyssa Tan on 7/30/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import "Message.h"

@implementation Message

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self){
        self.sender = dictionary[@"sender"];
        self.receiver = dictionary[@"receiver"];
        self.message = dictionary[@"message"];
    }
    return self;
}

@end
