//
//  ExtroSystemPlugin.m
//  bsl
//
//  Created by zhoujun on 13-11-11.
//
//

#import "ExtroSystemPlugin.h"
#import "SystemInfo.h"
#import "JSONKit.h"
@implementation ExtroSystemPlugin
-(void)listAllExtroSystem:(CDVInvokedUrlCommand*)command
{
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    NSString* userName = [defaults valueForKey:@"username"];
    NSArray *systems =  [SystemInfo findByPredicate:[NSPredicate predicateWithFormat:@"username=%@",userName]];
    NSMutableArray *backArray = [[NSMutableArray alloc]initWithCapacity:systems.count];
    for(SystemInfo *system in systems)
    {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]initWithCapacity:0];
        [dictionary setValue:system.username forKey:@"username"];
        [dictionary setValue:system.systemId forKey:@"sysId"];
        [dictionary setValue:system.systemName forKey:@"sysName"];
        [dictionary setValue:system.alias forKey:@"alias"];
        
        NSNumber *curr = [NSNumber numberWithInt:1];
        if([system.curr isEqualToNumber:curr]){
           [dictionary setValue:system.curr forKey:@"curr"];
        }
        
        [backArray addObject:dictionary];
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[backArray JSONString]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end
