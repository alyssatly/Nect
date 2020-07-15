//
//  Game.h
//  Nect
//
//  Created by Alyssa Tan on 7/15/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Game : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *gameDescription;
@property (nonatomic, strong) NSArray *genres;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *developer;


- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
