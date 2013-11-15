//
//  MultiUserInfo.h
//  bsl
//
//  Created by zhoujun on 13-11-15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Repository.h"

@interface MultiUserInfo : NSManagedObject

@property (nonatomic, retain) NSString * md5Str;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * systemId;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * zhName;
@property (nonatomic, retain) NSString * privileges;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSString * phone;

@end
