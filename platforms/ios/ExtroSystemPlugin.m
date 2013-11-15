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
#import "SVProgressHUD.h"
#import "UIDevice+IdentifierAddition.h"
#import "ServerAPI.h"
#import "HTTPRequest.h"
#import "Utility.h"
#import "MultiUserInfo.h"
#import "NSString+MD5Addition.h"
#import "RCPopoverView.h"
@implementation ExtroSystemPlugin
-(void)listAllExtroSystem:(CDVInvokedUrlCommand*)command
{
    _command = command;
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    NSString* userName = [defaults valueForKey:@"username"];
    NSArray *systems =  [SystemInfo findByPredicate:[NSPredicate predicateWithFormat:@"username=%@",userName]];
    NSMutableArray *backArray = [[NSMutableArray alloc]initWithCapacity:systems.count];
    if(![defaults boolForKey:@"isOffLogin"])
    {
        
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
        
    }
    else
    {
        NSArray *userArray = [MultiUserInfo findByPredicate:[NSPredicate predicateWithFormat:@"username=%@",userName]];
        for (MultiUserInfo *user in userArray) {
            for (SystemInfo *system in systems) {
                if([user.systemId isEqualToString:system.systemId])
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
            }
        }
        
    }
    _options = backArray;
    MultiSystemsView *view = [[MultiSystemsView alloc]initWithFrame:CGRectZero];
    [view initWithDataSource:_options];
    view.multiDelegate = self;
    [RCPopoverView showWithView:view];
    
    
}

-(void)login:(CDVInvokedUrlCommand*)command
{
    NSString *userName = [command.arguments objectAtIndex:0];
    NSString *password = [command.arguments objectAtIndex:1];
    NSString *systemId = [command.arguments objectAtIndex:2];
    [self didLoginAndSaveData:userName withPwd:password withSystemId:systemId andPluginCommon:command];
    
}
-(void)cancel:(CDVInvokedUrlCommand*)command
{
    [httRequest cancel];
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    [json setValue:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[json JSONString]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];}

-(void)didLoginAndSaveData:(NSString*)userName withPwd:(NSString*)userPass withSystemId:(NSString*)sysId andPluginCommon:(CDVInvokedUrlCommand*)command
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
            if([SVProgressHUD isVisible]){
                [SVProgressHUD dismiss];
            }
            if(![message boolValue]&& nil != tips)
            {
                
                if(command)
                {
                    NSMutableDictionary *json = [NSMutableDictionary dictionary];
                    [json setValue:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
                    [json setValue:tips  forKey:@"message"];
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsString:json.JSONString];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"登录失败" message:tips delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                alert=nil;
                return;
                
            }
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
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
                        SystemInfo *system  = [SystemInfo insert];
                        NSString* systemName = [dict valueForKey:@"sysName"];
                        NSString* alias = [dict valueForKey:@"alias"];
                        NSString* curr = [dict valueForKey:@"curr"];
                        system.systemId = [dict valueForKey:@"id"];
                        system.alias= alias;
                        system.curr = [NSNumber numberWithBool:[curr boolValue]];
                        if([curr boolValue])
                        {
                            currentSysId =[dict valueForKey:@"id"];
                        }
                        system.systemName=  systemName;
                        system.username = userName;
                        [system save];
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
                                NSString* systemName = [dict valueForKey:@"sysName"];
                                NSString* alias = [dict valueForKey:@"alias"];
                                NSString* curr = [dict valueForKey:@"curr"];
                                system.alias= alias;
                                system.curr = [NSNumber numberWithBool:[curr boolValue]];
                                if([curr boolValue])
                                {
                                    currentSysId =system.systemId;
                                }
                                system.systemName=  systemName;
                                system.username = userName;
                                [system save];
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
                            SystemInfo *system  = [SystemInfo insert];
                            NSString* systemName = [dict valueForKey:@"sysName"];
                            NSString* alias = [dict valueForKey:@"alias"];
                            NSString* curr = [dict valueForKey:@"curr"];
                            system.systemId = [dict valueForKey:@"id"];
                            system.alias= alias;
                            system.curr = [NSNumber numberWithBool:[curr boolValue]];
                            if([curr boolValue])
                            {
                                currentSysId =[dict valueForKey:@"id"];
                            }
                            system.systemName=  systemName;
                            system.username = userName;
                            [system save];
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
                        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsString:json.JSONString];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                    NSString* token = [messageDictionary objectForKey:@"sessionKey"];
                    
                    //------------------------------------------------------------------------------------------
                    NSArray *systems =[messageDictionary objectForKey:@"authSysList"];
                    NSArray *temArray = [SystemInfo findByPredicate:[NSPredicate predicateWithFormat:@"username=%@",userName]];
                    
                    for (NSDictionary *dict in systems) {
                        NSString* systemId = [dict valueForKey:@"id"];
                        if(temArray && temArray.count >0)
                        {
                            for (SystemInfo *sys in temArray) {
                                if([sys.systemId isEqualToString:systemId])
                                {
                                    NSString* systemName = [dict valueForKey:@"sysName"];
                                    NSString* alias = [dict valueForKey:@"alias"];
                                    NSString* curr = [dict valueForKey:@"curr"];
                                    sys.alias= alias;
                                    sys.curr = [NSNumber numberWithBool:[curr boolValue]];
                                    if([curr boolValue])
                                    {
                                        currentSysId =systemId;
                                    }
                                    sys.systemName=  systemName;
                                    sys.username = userName;
                                    [sys save];
                                }
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
                        user.privileges = [messageDictionary objectForKey:@"privileges"];
                        
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

-(void)itemDidSelected:(NSIndexPath *)indexPath
{
    if(_options)
    {
        NSDictionary *dict = [_options objectAtIndex:indexPath.row];
        NSString *username = [dict valueForKey:@"username"];
        NSString *systemId = [dict valueForKey:@"sysId"];
        NSArray *userArray = [MultiUserInfo findByPredicate:[NSPredicate predicateWithFormat:@"username=%@ and systemId=%@",username,systemId]];
        NSString *password =@"";
        if(userArray.count>0)
        {
            MultiUserInfo *user = [userArray objectAtIndex:0];
            password = user.password;
        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if(![defaults boolForKey:@"isOffLogin"])
        {
            [self didLoginAndSaveData:username withPwd:password withSystemId:systemId andPluginCommon:nil];
            
        }
        else
        {
            [defaults setObject:@"" forKey:@"token"];
            [defaults setObject:username forKey:@"loginUsername"];
            [defaults setObject:password forKey:@"loginPassword"];
            [defaults setObject:username forKey:@"LoginUser"];
            [defaults setValue:systemId forKey:@"systemId"];
            [defaults synchronize];
            //修改其他系统是否为当前登录系统
            NSArray *temArray = [SystemInfo findByPredicate:[NSPredicate predicateWithFormat:@"username=%@",username]];
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
            [RCPopoverView dismiss];
            [appDelegate didOffLogin];
        }
        
        
//        if([dict valueForKey:@"curr"] == [NSNumber numberWithBool:YES])
//        {
//            
//        }
//        else
//        {
//            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[dict JSONString]];
//            [self.commandDelegate sendPluginResult:pluginResult callbackId:_command.callbackId];
//            _command = nil;
//        }
        

    }
}
-(void)getCurrSystem:(CDVInvokedUrlCommand*)command
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSArray *temArray = [SystemInfo findByPredicate:[NSPredicate predicateWithFormat:@"username=%@",username]];
    for (SystemInfo * system in temArray) {
        if(system.curr == [NSNumber numberWithBool:YES])
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
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[dictionary JSONString]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
    }
    
}
@end
