//
//  CubeAccountPlugin.m
//  bsl
//
//  Created by zhoujun on 13-10-11.
//
//

#import "CubeAccountPlugin.h"
#import "JSONKit.h"
#import "MultiUserInfo.h"
@implementation CubeAccountPlugin

-(void)getAccount:(CDVInvokedUrlCommand*)command
{
    @autoreleasepool {
        NSUserDefaults* defaults  = [NSUserDefaults standardUserDefaults];
        
        NSMutableDictionary *json = [NSMutableDictionary dictionary];
        NSString *systemId = [defaults valueForKey:@"systemId"];
        NSString *username = [defaults valueForKey:@"username"];
        NSArray *userArray = [MultiUserInfo findByPredicate:[NSPredicate predicateWithFormat:@"username=%@ and systemId=%@",username,systemId]];
        NSString *zhName =@"";
        if(userArray.count>0)
        {
            MultiUserInfo *user = [userArray objectAtIndex:0];
            zhName = user.zhName;
        }
        [json setValue:zhName forKey:@"accountname"];
        
        
        CDVPluginResult* pluginResult =  [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:json.JSONString];;
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }
    

}

@end
