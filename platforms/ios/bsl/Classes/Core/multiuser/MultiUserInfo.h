//
//  MultiUserInfo.h
//  bsl
//
//  Created by zhoujun on 13-11-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Repository.h"

@interface MultiUserInfo : NSManagedObject

@property (nonatomic, strong) NSString * md5Str;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) NSString * privileges;
@property (nonatomic, strong) NSString * sex;
@property (nonatomic, strong) NSString * systemId;
@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * zhName;
@property (nonatomic, strong) NSNumber * loginFlag;
-(BOOL)passwordExplain:(NSString*)md5str;
@end
