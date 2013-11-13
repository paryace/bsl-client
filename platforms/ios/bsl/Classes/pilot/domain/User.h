//
//  User.h
//  pilot
//
//  Created by wuzheng on 12/6/12.
//  Copyright (c) 2012 chen shaomou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Repository.h"

@interface User : NSManagedObject

-(BOOL)verifyPassword:(NSString *)enterPassword;
+ (User *)currentUser;
+ (void)setCurrentUser:(User *)user;

@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * workNo;
@property (nonatomic, retain) NSString * result;
@property (nonatomic, retain) NSString * baseCode;
@property (nonatomic, retain) NSString * pilotFlag;

@end
