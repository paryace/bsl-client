//
//  CommonUtils.m
//  bsl
//
//  Created by zhoujun on 13-11-29.
//
//

#import "CommonUtils.h"
@implementation CommonUtils
+(BOOL)isOffLineLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"isOffLogin"];
}
+(NSString *)currentUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return  [defaults valueForKey:@"username"];
}


@end
