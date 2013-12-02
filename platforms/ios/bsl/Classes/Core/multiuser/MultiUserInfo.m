//
//  MultiUserInfo.m
//  bsl
//
//  Created by zhoujun on 13-11-22.
//
//

#import "MultiUserInfo.h"


@implementation MultiUserInfo

@dynamic md5Str;
@dynamic password;
@dynamic phone;
@dynamic privileges;
@dynamic sex;
@dynamic systemId;
@dynamic username;
@dynamic zhName;
@dynamic loginFlag;
-(BOOL)passwordExplain:(NSString*)md5str
{
    MultiUserInfo *user = [MultiUserInfo first:@"md5Str=%@",md5str,nil];
    if(user)
    {
        return YES;
    }
    return NO;
    
}
@end
