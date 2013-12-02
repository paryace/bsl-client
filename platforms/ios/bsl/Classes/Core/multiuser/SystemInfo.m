//
//  SystemInfo.m
//  bsl
//
//  Created by zhoujun on 13-11-8.
//
//

#import "SystemInfo.h"


@implementation SystemInfo

@dynamic systemId;
@dynamic systemName;
@dynamic username;
@dynamic alias;
@dynamic curr;

+(NSArray*)findSystemsByuserName:(NSString*)userName
{
    return [SystemInfo findByPredicate:[NSPredicate predicateWithFormat:@"username=%@",userName]];
    
}
+(BOOL)systemStore:(NSDictionary*)dictionary withUserName:(NSString*)userName
{
    SystemInfo *system  = [SystemInfo insert];
    NSString* systemName = [dictionary valueForKey:@"sysName"];
    NSString* alias = [dictionary valueForKey:@"alias"];
    NSString* curr = [dictionary valueForKey:@"curr"];
    system.systemId = [dictionary valueForKey:@"id"];
    system.alias= alias;
    system.curr = [NSNumber numberWithBool:[curr boolValue]];
    system.systemName=  systemName;
    system.username = userName;
    return [system save];
}
+(BOOL)systemUpdate:(SystemInfo*)origin withObject:(NSDictionary*)newObject andUserName:(NSString*)userName
{
    NSString* systemName = [newObject valueForKey:@"sysName"];
    NSString* alias = [newObject valueForKey:@"alias"];
    NSString* curr = [newObject valueForKey:@"curr"];
    origin.alias= alias;
    origin.curr = [NSNumber numberWithBool:[curr boolValue]];
    origin.systemName=  systemName;
    origin.username = userName;
    return [origin save];
}
@end
