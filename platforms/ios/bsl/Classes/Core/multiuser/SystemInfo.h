//
//  SystemInfo.h
//  bsl
//
//  Created by zhoujun on 13-11-8.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Repository.h"

@interface SystemInfo : NSManagedObject

@property (nonatomic, strong) NSString * systemId;
@property (nonatomic, strong) NSString * systemName;
@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * alias;
@property (nonatomic, strong) NSNumber * curr;
+(NSArray*)findSystemsByuserName:(NSString*)userName;
+(BOOL)systemStore:(NSDictionary*)dictionary withUserName:(NSString*)userName;
+(BOOL)systemUpdate:(SystemInfo*)origin withObject:(NSDictionary*)newObject andUserName:(NSString*)userName;
@end
