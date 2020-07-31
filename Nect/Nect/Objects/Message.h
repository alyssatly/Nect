//
//  Message.h
//  Nect
//
//  Created by Alyssa Tan on 7/30/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Message : NSObject

@property (nonatomic, strong) NSString *sender;
@property (nonatomic, strong) NSString *receiver;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDate *createdAt;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
