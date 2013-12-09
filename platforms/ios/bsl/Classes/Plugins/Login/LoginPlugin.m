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
#import "SystemInfo.h"
#import "MultiUserInfo.h"
#import "NSString+MD5Addition.h"
#import "RCPopoverView.h"
#import "Utility.h"
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
        [json setValue:[NSNumber numberWithBool:[defaults boolForKey:@"isOffLogin"]] forKey:@"isOffLine"];
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

    if(!_options)
    {
        _options = [[NSMutableArray alloc]initWithCapacity:0];
    }
    else
    {
        [_options removeAllObjects];
    }
    NSString* userName =  [command.arguments objectAtIndex:0];
    NSString* userPass =  [command.arguments objectAtIndex:1];
    NSString* userSwithch =  [command.arguments objectAtIndex:2];
    NSString* isOffLogin =@"false";//[command.arguments objectAtIndex:3];
    _password = userPass;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([userSwithch boolValue]) {
        [defaults setBool:YES forKey:@"switchIsOn"];
        [defaults setObject:userName forKey:@"loginUsername"];
        [defaults setObject:userPass forKey:@"loginPassword"];
        [defaults setObject:userName forKey:@"LoginUser"];
        [defaults setObject:userName forKey:@"username"];
        [defaults setObject:userPass forKey:@"password"];
        
        
    }else{
        [defaults setBool:NO forKey:@"switchIsOn"];
        [defaults setObject:userName forKey:@"loginUsername"];
        [defaults setObject:userName forKey:@"LoginUser"];
        [defaults setObject:userName forKey:@"username"];
        [defaults setObject:@"" forKey:@"password"];
        [defaults setObject:@"" forKey:@"loginPassword"];
        
    }
    if([isOffLogin boolValue])
    {
        [defaults setBool:YES forKey:@"isOffLogin"];
        [defaults setBool:YES forKey:@"offLineSwitch"];
    }
    else
    {
        [defaults setBool:NO forKey:@"isOffLogin"];
        [defaults setBool:NO forKey:@"offLineSwitch"];
    }
    [defaults synchronize];
    _command = command;
    if(![isOffLogin boolValue])
    {
        
        [self didLoginAndSaveData:userName withPwd:userPass withSystemId:nil andswitchIsOn:userSwithch andPluginCommon:command];
    }
    else
    {
        if ([userName isEqualToString:@""] || [userPass isEqualToString:@""]) {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"用户名和密码不能为空！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            
            if(command)
            {
                CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }
        else
        {
            
            NSArray *userArray = [MultiUserInfo findByPredicate:[NSPredicate predicateWithFormat:@"username=%@",userName]];
            if(userArray.count==0)
            {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"用户未曾登录过应用，不能使用离线登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
                alertView = nil;
                return;
            }
            else
            {
                NSMutableArray *systemIds = [[NSMutableArray alloc]initWithCapacity:0];
                for(MultiUserInfo *user in userArray) {
                    if(user.systemId)
                    {
                        [systemIds addObject:user.systemId];
                    }
                }
                NSArray *temArray = [SystemInfo findByPredicate:[NSPredicate predicateWithFormat:@"username=%@",userName]];
                NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]init];
                for (SystemInfo * system in temArray) {
                    for (NSString *sysId in systemIds) {
                        if([sysId isEqualToString:system.systemId])
                        {
                            NSDictionary *dictonary = [[NSDictionary alloc]initWithObjectsAndKeys:system.systemName,@"sysName" ,sysId,@"systemId",nil];
                            if(![[tmpDict allKeys] containsObject:sysId])
                            [tmpDict setObject:dictonary forKey:sysId];
                            
                        }
                    }
                }
                [_options addObjectsFromArray:[tmpDict allValues]];
                if(_options.count>0)
                {
                    MultiSystemsView *view = [[MultiSystemsView alloc]initWithFrame:CGRectZero];
                    [view initWithDataSource:_options];
                    view.multiDelegate = self;
                    [RCPopoverView showWithView:view];
                    
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"用户未曾登录过应用，不能使用离线登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                    alertView = nil;
                }
                
            }
        }
    }
        
    
    
}
-(void)itemDidSelected:(NSIndexPath *)indexPath
{
    
    
    NSDictionary *dictionary = [_options objectAtIndex:indexPath.row];
    NSString *systemId = [dictionary valueForKey:@"systemId"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults valueForKey:@"LoginUser"];
    NSString *userPass = [_password copy];
    _password = nil;
    NSString* swithIsOn = [defaults valueForKey:@"switchIsOn"];
    [_options removeAllObjects];
    [RCPopoverView dismiss];
    if([defaults boolForKey:@"isOffLogin"])
    {
        [defaults setObject:@"" forKey:@"token"];
        [defaults setObject:userName forKey:@"loginUsername"];
        [defaults setObject:userPass forKey:@"loginPassword"];
        [defaults setObject:userName forKey:@"LoginUser"];
        [defaults setValue:systemId forKey:@"systemId"];
        [defaults synchronize];
        
        NSString *md5Str = [[[userName stringByAppendingString:@"-"]stringByAppendingString:userPass]stringFromMD5];
        NSArray *userArray = [MultiUserInfo findByPredicate:[NSPredicate predicateWithFormat:@"md5Str=%@ and username=%@",md5Str,userName]];
        if(userArray.count == 0)
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"帐号或密码错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
            alertView = nil;
            [defaults setObject:@"" forKey:@"password"];
            [defaults setObject:@"" forKey:@"loginPassword"];
            [defaults setObject:@"" forKey:@"loginUsername"];
            [defaults setObject:@"" forKey:@"LoginUser"];
            [defaults setObject:@"" forKey:@"username"];
            [defaults synchronize];
            NSMutableDictionary *json = [NSMutableDictionary dictionary];
            [json setValue:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
            [json setValue:@"帐号或密码错误"  forKey:@"message"];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsString:json.JSONString];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:_command.callbackId];
            return;
        }
        
        //修改其他系统是否为当前登录系统
        NSArray *temArray = [SystemInfo findByPredicate:[NSPredicate predicateWithFormat:@"username=%@",userName]];
        for(SystemInfo *system in temArray)
        {
            if([systemId isEqualToString:system.systemId])
            {
                system.curr = [NSNumber numberWithBool:YES];
            }
            else
            {
                system.curr = [NSNumber numberWithBool:NO];
            }
            [system save];
        }
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate didOffLogin];
        
    }
    else
    {
        [self didLoginAndSaveData:userName withPwd:userPass withSystemId:systemId andswitchIsOn:swithIsOn andPluginCommon:_command];

    }
    
}

-(void)didLoginAndSaveData:(NSString*)userName withPwd:(NSString*)userPass withSystemId:(NSString*)sysId andswitchIsOn:(NSString*)swithIsOn andPluginCommon:(CDVInvokedUrlCommand*)command
{
    if ([userName isEqualToString:@""] || [userPass isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"用户名和密码不能为空！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        
        if(command)
        {
            CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }else{
        if(![SVProgressHUD isVisible]){
            [SVProgressHUD showWithStatus:@"正在登录..."  maskType:SVProgressHUDMaskTypeGradient ];
        }
        
        [httRequest setCompletionBlock:nil];
        [httRequest setFailedBlock:nil];
        [httRequest cancel];
        
        FormDataRequest* request = [FormDataRequest requestWithURL:[NSURL URLWithString:[ServerAPI urlForNewLogin]]];
        httRequest=request;
        __block FormDataRequest*  __request=request;
        NSString *identifier =  [[NSBundle mainBundle]bundleIdentifier];
        NSString *encodePwd =  [Utility encryptStr:userPass withKey:identifier];
        request.timeOutSeconds=120.0f;
        request.persistentConnectionTimeoutSeconds=120.0f;
        [request setPostValue:kAPPKey forKey:@"appKey"];
        [request setPostValue:userName forKey:@"username"];
        [request setPostValue:encodePwd forKey:@"password"];
        [request setPostValue:[[UIDevice currentDevice] uniqueDeviceIdentifier]  forKey:@"deviceId"];
        [request setPostValue:@"true" forKey:@"encrypt"];
        if(sysId)
        {
            [request setPostValue:sysId forKey:@"sysId"];
        }
        [request setPostValue:[[NSBundle mainBundle]bundleIdentifier] forKey:@"appIdentify"];
        
        
        [request setFailedBlock:^{
            httRequest=nil;
            if([SVProgressHUD isVisible]){
                [SVProgressHUD showErrorWithStatus:@"连接服务器失败！"];
            }
            
            
            NSMutableDictionary *json = [NSMutableDictionary dictionary];
            [json setValue:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
            [json setValue:@"连接服务器失败！" forKey:@"message"];
            if(command)
            {
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsString:json.JSONString];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                
            }
            [__request cancel];
            
        }];
        
        [request setCompletionBlock:^{
            httRequest=nil;
            if([__request responseStatusCode] == 404){
                [SVProgressHUD showErrorWithStatus:@"连接服务器失败！" ];
                
                [__request cancel];
                return ;
            }
            NSData* data = [__request responseData];
            NSDictionary* messageDictionary = [data objectFromJSONData];
            NSString* message = [messageDictionary objectForKey:@"loginOK"];
            NSString *tips = [messageDictionary objectForKey:@"errmsg"];
            NSString *currentSysId=@"";
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            if([SVProgressHUD isVisible]){
                [SVProgressHUD dismiss];
            }
            if(![message boolValue]&& nil != tips)
            {
                
                
                if(command)
                {
                    NSRange range = [tips rangeOfString:@"帐号或密码错误"];
                    if( range.location != NSNotFound)
                    {
                        [defaults setObject:@"" forKey:@"password"];
                        [defaults setObject:@"" forKey:@"loginPassword"];
                        [defaults setObject:@"" forKey:@"loginUsername"];
                        [defaults setObject:@"" forKey:@"LoginUser"];
                        [defaults setObject:@"" forKey:@"username"];
                        [defaults synchronize];
                        NSMutableDictionary *json = [NSMutableDictionary dictionary];
                        [json setValue:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
                        [json setValue:tips  forKey:@"message"];
                        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsString:json.JSONString];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                    else if ([tips rangeOfString:@"用户不存在"].location != NSNotFound )
                    {
                        [defaults setObject:@"" forKey:@"password"];
                        [defaults setObject:@"" forKey:@"loginPassword"];
                        [defaults setObject:@"" forKey:@"loginUsername"];
                        [defaults setObject:@"" forKey:@"LoginUser"];
                        [defaults setObject:@"" forKey:@"username"];
                        [defaults synchronize];
                        NSMutableDictionary *json = [NSMutableDictionary dictionary];
                        [json setValue:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
                        [json setValue:tips  forKey:@"message"];
                        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsString:json.JSONString];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                }
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"登录失败" message:tips delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                alert=nil;
                return;
                
            }
            if (![message boolValue] && [[messageDictionary valueForKey:@"showOpt"]boolValue]) {
                [_options removeAllObjects];
                NSMutableArray *systems =[messageDictionary objectForKey:@"authSysList"];
                NSArray *temArray = [SystemInfo findByPredicate:[NSPredicate predicateWithFormat:@"username=%@",userName]];
                NSMutableDictionary *existDictionary = [[NSMutableDictionary alloc]init];
                if(temArray.count == 0)
                {
                    for (NSDictionary *dict in systems) {
                        [existDictionary setObject:dict forKey:[dict valueForKey:@"id"]];
                        NSDictionary *dictonary = [[NSDictionary alloc]initWithObjectsAndKeys:[dict valueForKey:@"sysName"],@"sysName" ,[dict valueForKey:@"id"],@"systemId",nil];
                        [_options addObject:dictonary];
                        NSString* curr = [dict valueForKey:@"curr"];
                        if([curr boolValue])
                        {
                            currentSysId =[dict valueForKey:@"id"];
                        }
                        [SystemInfo systemStore:dict withUserName:userName];
                    }
                }
                else
                {
                    for (NSDictionary *dict in systems) {
                        [existDictionary setObject:dict forKey:[dict valueForKey:@"id"]];
                        NSDictionary *dictonary = [[NSDictionary alloc]initWithObjectsAndKeys:[dict valueForKey:@"sysName"],@"sysName" ,[dict valueForKey:@"id"],@"systemId",nil];
                        [_options addObject:dictonary];
                        
                        for (SystemInfo *system in temArray) {
                            if([system.systemId isEqualToString:[dict valueForKey:@"id"]])
                            {
                                NSString* curr = [dict valueForKey:@"curr"];
                                if([curr boolValue])
                                {
                                    currentSysId =system.systemId;
                                }
                                [SystemInfo systemUpdate:system withObject:dict andUserName:userName];
                            }
                            
                        }
                        
                    }
                }
                if(temArray.count >0)
                {
                    //删除不存在的系统
                    for(SystemInfo *sys in temArray)
                    {
                        if(![[existDictionary allKeys] containsObject:sys.systemId])
                        {
                            [sys remove];
                        }
                        else
                        {
                            [existDictionary removeObjectForKey:sys.systemId];
                        }
                    }//插入新增的系统
                    if([[existDictionary allValues] count]>0)
                    {
                        for(NSDictionary *dict in [existDictionary allValues])
                        {
                            NSString* curr = [dict valueForKey:@"curr"];
                            if([curr boolValue])
                            {
                                currentSysId =[dict valueForKey:@"id"];
                            }
                            [SystemInfo systemStore:dict withUserName:userName];
                        }
                    }
                }
                
                MultiSystemsView *view = [[MultiSystemsView alloc]initWithFrame:CGRectZero];
                [view initWithDataSource:_options];
                view.multiDelegate = self;
                [RCPopoverView showWithView:view];
                
            }
            else
            {
                
                NSNumber* number =  [messageDictionary objectForKey:@"loginOK"];
                if ([number boolValue])
                {
                    
                    if(command)
                    {
                        NSMutableDictionary *json = [NSMutableDictionary dictionary];
                        [json setValue:[NSNumber numberWithBool:YES] forKey:@"isSuccess"];
                        [json setValue:tips  forKey:@"message"];
                        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsString:json.JSONString];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                    NSString* token = [messageDictionary objectForKey:@"sessionKey"];
                    
                    //------------------------------------------------------------------------------------------
                    NSArray *systems =[messageDictionary objectForKey:@"authSysList"];
                    NSArray *temArray = [SystemInfo findSystemsByuserName:userName ];
                    NSMutableDictionary *existDictionary = [[NSMutableDictionary alloc]init];
                    
                    for (NSDictionary *dict in systems) {
                        NSString* systemId = [dict valueForKey:@"id"];
                        [existDictionary setObject:dict forKey:[dict valueForKey:@"id"]];
                        if(temArray && temArray.count >0)
                        {
                            for (SystemInfo *sys in temArray) {
                                if([sys.systemId isEqualToString:systemId])
                                {
                                    NSString* curr = [dict valueForKey:@"curr"];
                                    if([curr boolValue])
                                    {
                                        currentSysId =systemId;
                                    }
                                    [SystemInfo systemUpdate:sys withObject:dict andUserName:userName];
                                }
                            }
                        }
                        else
                        {
                            NSString* curr = [dict valueForKey:@"curr"];
                            if([curr boolValue])
                            {
                                currentSysId =[dict valueForKey:@"id"];
                            }
                            [SystemInfo systemStore:dict withUserName:userName];
                        }
                        
                    }
                    if(temArray.count >0)
                    {
                        //删除不存在的系统
                        for(SystemInfo *sys in temArray)
                        {
                            if(![[existDictionary allKeys] containsObject:sys.systemId])
                            {
                                [sys remove];
                            }
                            else
                            {
                                [existDictionary removeObjectForKey:sys.systemId];
                            }
                        }//插入新增的系统
                        if([[existDictionary allValues] count]>0)
                        {
                            for(NSDictionary *dict in [existDictionary allValues])
                            {
                                NSString* curr = [dict valueForKey:@"curr"];
                                if([curr boolValue])
                                {
                                    currentSysId =[dict valueForKey:@"id"];
                                }
                                [SystemInfo systemStore:dict withUserName:userName];
                            }
                        }
                    }

                    [defaults setObject:token forKey:@"token"];
                    [defaults setObject:[messageDictionary objectForKey:@"phone"] forKey:@"phone"];
                    [defaults setObject:[messageDictionary objectForKey:@"sex"] forKey:@"sex"];
                    [defaults setObject:[messageDictionary objectForKey:@"zhName"] forKey:@"zhName"];
                    [defaults setObject:[messageDictionary objectForKey:@"privileges"] forKey:@"privileges"];
                    //end ================
                    [defaults setValue:currentSysId forKey:@"systemId"];
                    [defaults synchronize];
  
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    NSArray *tmpArray = [MultiUserInfo findByPredicate:[NSPredicate predicateWithFormat:@"systemId=%@ and username=%@",currentSysId,userName]];
                    if(tmpArray.count >0)
                    {
                        MultiUserInfo *user= [tmpArray objectAtIndex:0];
                        user.username = userName;
                        user.password = userPass;
                        user.systemId = currentSysId;
                        user.md5Str = [[user.username stringByAppendingFormat:@"-%@",user.password ]stringFromMD5];
                        user.sex = [messageDictionary objectForKey:@"sex"];
                        user.phone = [messageDictionary objectForKey:@"phone"];
                        user.zhName = [messageDictionary objectForKey:@"zhName"];
                        user.privileges = [[messageDictionary objectForKey:@"privileges"] JSONString];
                        user.loginFlag = [NSNumber numberWithBool:YES];
                        [user save];
                    }
                    else
                    {
                        MultiUserInfo *user = [MultiUserInfo insert];
                        user.username = userName;
                        user.password = userPass;
                        user.systemId = currentSysId;
                        user.md5Str = [[user.username stringByAppendingFormat:@"-%@",user.password ]stringFromMD5];
                        user.sex = [messageDictionary objectForKey:@"sex"];
                        user.phone = [messageDictionary objectForKey:@"phone"];
                        user.zhName = [messageDictionary objectForKey:@"zhName"];
                        user.privileges = [[messageDictionary objectForKey:@"privileges"]JSONString];
                        user.loginFlag = [NSNumber numberWithBool:YES];
                        [user save];
                    }
                    [appDelegate didLogin];
                }else{
                    NSString* messageAlert =   [messageDictionary objectForKey:@"errmsg"];
                    if ([messageAlert length] <= 0) {
                        messageAlert = @"服务器出错，请联系管理员！";
                    }
                    NSMutableDictionary *json = [NSMutableDictionary dictionary];
                    [json setValue:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
                    [json setValue:messageAlert  forKey:@"message"];
                    if(command)
                    {
                        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsString:json.JSONString];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                }
                
            }
            [__request cancel];
            
        }];
        [request startAsynchronous];
    }
}
-(void)canceLogin:(CDVInvokedUrlCommand*)command
{
    [httRequest cancel];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)storeSyste:(NSDictionary *)dict
{
    
}

@end
