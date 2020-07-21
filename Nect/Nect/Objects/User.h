//
//  User.h
//  Nect
//
//  Created by Alyssa Tan on 7/15/20.
//  Copyright © 2020 Alyssa Tan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) PFFileObject *displayPhoto;
@property (nonatomic, strong) NSString *about;
@property (nonatomic, strong) NSArray *games;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *pendingFriends;
@property (nonatomic, strong) NSMutableArray *nectRequests;

//to help out with match making
@property (nonatomic, strong) NSMutableArray *dontMatchNames;


- (instancetype)initWithUser:(PFUser *)user;

@end

NS_ASSUME_NONNULL_END
