//
//  MultiUserInfo.h
//  bsl
//
//  Created by zhoujun on 13-11-8.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Repository.h"

@interface MultiUserInfo : NSManagedObject

@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSString * systemId;
@property (nonatomic, strong) NSString * md5Str;

@end
