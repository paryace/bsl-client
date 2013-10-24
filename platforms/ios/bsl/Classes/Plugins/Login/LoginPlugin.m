//
//  LoginPlugin.m
//  cube-ios
//
//  Created by 东 on 6/3/13.
//
//

#import "LoginPlugin.h"
#import "JSONKit.h"
#import "UIDevice+IdentifierAddition.h"
#import "ServerAPI.h"
#import "HTTPRequest.h"

@implementation LoginPlugin
/**
 *	@author 	张国东
 *	@brief	获取用户信息
 *
 *	@param 	command 	
 */
-(void)getAccountMessage:(CDVInvokedUrlCommand*)command
{
    @autoreleasepool {
        NSUserDefaults* defaults  = [NSUserDefaults standardUserDefaults];
        Boolean switchIsOn = [defaults boolForKey:@"switchIsOn"] ;
        
        NSMutableDictionary *json = [NSMutableDictionary dictionary];
        [json setValue:[defaults objectForKey:@"username"] forKey:@"username"];
        [json setValue:[defaults objectForKey:@"password"]  forKey:@"password"];
   
        [json setValue: [NSNumber numberWithBool:switchIsOn] forKey:@"isRemember"];

        CDVPluginResult* pluginResult = nil;
        if (json) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:json.JSONString];
        } else {
            NSMutableDictionary *json = [NSMutableDictionary dictionary];
            [json setValue:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
            [json setValue:@"获取信息失败！" forKey:@"message"];

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:json.JSONString];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    }
    
    
}

/**
 *	@author 	张国东
 *	@brief	html5 调用本地登录方法
 *
 *	@param 	command
 */
-(void)login:(CDVInvokedUrlCommand*)command
{

    NSString* userName =  [command.arguments objectAtIndex:0];
    NSString* userPass =  [command.arguments objectAtIndex:1];
    NSString* userSwithch =  [command.arguments objectAtIndex:2];
    
    if ([userName isEqualToString:@""] || [userPass isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"用户名或密码不能为空！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        
        CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        if(![SVProgressHUD isVisible]){
            [SVProgressHUD showWithStatus:@"正在登录..."  maskType:SVProgressHUDMaskTypeGradient ];
        }
        
        [httRequest setCompletionBlock:nil];
        [httRequest setFailedBlock:nil];
        [httRequest cancel];

        FormDataRequest* request = [FormDataRequest requestWithURL:[NSURL URLWithString:[ServerAPI urlForLogin]]];
        httRequest=request;
        __block FormDataRequest*  __request=request;

        request.timeOutSeconds=120.0f;
        request.persistentConnectionTimeoutSeconds=120.0f;
        [request setPostValue:kAPPKey forKey:@"appKey"];
        [request setPostValue:userName forKey:@"username"];
        [request setPostValue:userPass forKey:@"password"];
        [request setPostValue:[[UIDevice currentDevice] uniqueDeviceIdentifier]  forKey:@"deviceId"];

        [request setPostValue:[[NSBundle mainBundle]bundleIdentifier] forKey:@"appId"];
        

        [request setFailedBlock:^{
            httRequest=nil;
            if([SVProgressHUD isVisible]){
                [SVProgressHUD showErrorWithStatus:@"连接服务器失败！"];
            }
            
            
            NSMutableDictionary *json = [NSMutableDictionary dictionary];
            [json setValue:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
            [json setValue:@"连接服务器失败！" forKey:@"message"];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsString:json.JSONString];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            [__request cancel];
            
        }];
        
        [request setCompletionBlock:^{
            httRequest=nil;
            if([__request responseStatusCode] == 404){
                [SVProgressHUD showErrorWithStatus:@"连接服务器失败！" ];

                [__request cancel];
                return ;
            }
            if([SVProgressHUD isVisible]){
                [SVProgressHUD dismiss];
            }

            NSData* data = [__request responseData];
            NSDictionary* messageDictionary = [data objectFromJSONData];
            NSString* message = [messageDictionary objectForKey:@"message"];
            if (message !=nil) {
                if([SVProgressHUD isVisible]){
                    [SVProgressHUD dismiss];
                }
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"登录失败" message:@"用户名或密码不正确" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                alert=nil;
            }else{
            NSString* messageAlert =   [messageDictionary objectForKey:@"message"];
            NSNumber* number =  [messageDictionary objectForKey:@"result"];
            if ([number boolValue]) {
                if([[messageDictionary valueForKey:@"hasOperation"] isEqualToString:@"false"])
                {
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"用户没有操作权限请联系管理员" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                    alert=nil;
                    return;
                }
//                NSMutableDictionary *json = [NSMutableDictionary dictionary];
//                [json setValue:@"true" forKey:@"isSuccess"];
//                
//                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsString:json.JSONString];
//                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//                return;
                NSString* token = [messageDictionary objectForKey:@"sessionKey"];
                                                
                NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                
                if ([userSwithch boolValue]) {
                    [defaults setBool:YES forKey:@"switchIsOn"];
                    [defaults setObject:userName forKey:@"username"];
                    [defaults setObject:userPass forKey:@"password"];
                }else{
                    [defaults setObject:userName forKey:@"username"];
                    [defaults setObject:@"" forKey:@"password"];
                    [defaults setBool:NO forKey:@"switchIsOn"];
                }
                //------------------------------------------------------------------------------------------

                [defaults setObject:userName forKey:@"loginUsername"];
                [defaults setObject:userPass forKey:@"loginPassword"];
                
                [defaults setObject:token forKey:@"token"];
                [defaults setObject:userName forKey:@"LoginUser"];
                [defaults setObject:[messageDictionary objectForKey:@"phone"] forKey:@"phone"];
                [defaults setObject:[messageDictionary objectForKey:@"sex"] forKey:@"sex"];
                [defaults setObject:[messageDictionary objectForKey:@"zhName"] forKey:@"zhName"];
                [defaults setObject:[messageDictionary objectForKey:@"privileges"] forKey:@"privileges"];
                //end ================
                
                [defaults synchronize];
                
                
                
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate didLogin];

            }else{
                if([[messageDictionary valueForKey:@"result"] isEqualToString:@"false"])
                {
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"登录失败" message:@"用户名或密码不正确" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                    alert=nil;
                }
                if ([messageAlert length] <= 0) {
                    messageAlert = @"服务器出错，请联系管理员！";
                }
                NSMutableDictionary *json = [NSMutableDictionary dictionary];
                [json setValue:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
                [json setValue:messageAlert  forKey:@"message"];
                
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsString:json.JSONString];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

                
            }
            [__request cancel];

                
            }
        }];
        [request startAsynchronous];
    }
}

@end
