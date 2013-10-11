//
//  CubeAccountPlugin.m
//  bsl
//
//  Created by zhoujun on 13-10-11.
//
//

#import "CubeAccountPlugin.h"
#import "JSONKit.h"
@implementation CubeAccountPlugin

-(void)getAccount:(CDVInvokedUrlCommand*)command
{
    @autoreleasepool {
        NSUserDefaults* defaults  = [NSUserDefaults standardUserDefaults];
        
        NSMutableDictionary *json = [NSMutableDictionary dictionary];
        [json setValue:[defaults objectForKey:@"zhName"] forKey:@"accountname"];
        
        
        CDVPluginResult* pluginResult =  [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:json.JSONString];;
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }
    

}

@end
