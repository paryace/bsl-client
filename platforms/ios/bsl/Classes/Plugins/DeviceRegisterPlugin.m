//
//  DeviceRegisterPlugin.m
//  bsl
//
//  Created by hibad(Alfredo) on 13/10/31.
//  设备注册插件
//

#import "DeviceRegisterPlugin.h"
#import "JSONKit.h"
#import "ASIFormDataRequest.h"
#import "UIDevice+IdentifierAddition.h"
#define kDeviceBaseUrl @"csair-extension/api/deviceRegInfo"
#define kDeviceRegSubmit @"reg"
#define kDeviceRegUpdate @"update"
#define kDeviceRegCheck @"check/"
#define kDeviceRegQuery @"get/"
#import "SVProgressHUD.h"
typedef void (^RegistFinsh)(NSString *responseStr);

@implementation DeviceRegisterPlugin


-(void)redirectMain:(CDVInvokedUrlCommand*)command{
    NSLog(@"[DeviceRegisterPlugin]: pop页面!");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"PopDeviceRegistView" object:nil]];
}

-(void)submitInfo:(CDVInvokedUrlCommand*)command{
    if(![SVProgressHUD isVisible])
    {
        [SVProgressHUD showWithStatus:@"数据提交中...." maskType:SVProgressHUDMaskTypeBlack];
    }
    NSString *jsonStr = [command argumentAtIndex:0];
    NSDictionary *json  =  [jsonStr objectFromJSONString];
    
    NSString *deviceId = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    NSMutableDictionary *mutableJson = [NSMutableDictionary dictionaryWithDictionary:json];
    [mutableJson setValue:deviceId forKey:@"deviceId"];
//    [json setValue:deviceId forKey:@"deviceId"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@",kServerURLString,kDeviceBaseUrl,kDeviceRegSubmit];
    urlStr = [self appendAppKeyForFinalUrl:urlStr];
//    NSLog(@"[DeviceRegisterPlugin]: submit url ->%@",urlStr);
    
    [self submit2Server:urlStr withData:mutableJson andFinishBlock:^(NSString *responseStr){
        NSDictionary *responseJson = [responseStr objectFromJSONString];
        if([@"success" isEqualToString:[responseJson objectForKey:@"result"]]){
            NSLog(@"[DeviceRegisterPlugin]: 注册成功!");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"注册成功!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert setTag:0];
            [alert show];
        }
        
    }];
}

-(void)queryDevcieInfo:(CDVInvokedUrlCommand*)command{
    //查询该设备是否已经注册
    NSString *deviceId = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@%@",kServerURLString,kDeviceBaseUrl,kDeviceRegCheck,deviceId];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self appendAppKeyForFinalUrl:urlStr]]];
    __block ASIHTTPRequest *_request = request;
    [request setRequestMethod:@"GET"];
    [request setCompletionBlock:^(void){
        NSString *responseStr = [_request responseString];
        NSLog(@"[DeviceRegisterPlugin]-queryDeviceInfo  检查更新返回: -> %@",responseStr);
        
        //二次请求查询设备注册信息
        NSString *queryUrl = [NSString stringWithFormat:@"%@/%@/%@%@",kServerURLString,kDeviceBaseUrl,kDeviceRegQuery,deviceId];
        queryUrl = [self appendAppKeyForFinalUrl:queryUrl];
        ASIHTTPRequest *secondRes = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self appendAppKeyForFinalUrl:queryUrl]]];
        [secondRes setResponseEncoding:NSUTF8StringEncoding];
        [secondRes setRequestMethod:@"GET"];
        [secondRes setCompletionBlock:^(void){
            NSString *secondResStr = [secondRes responseString];
            NSMutableDictionary *json = [secondResStr objectFromJSONString];
            NSString *str;
            if(json)
            {
                str = json.JSONString;
            }
            else
            {
                str=@"";
            }
//            NSMutableDictionary *json = [NSMutableDictionary dictionary];
//            [json setValue:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
//            [json setValue:secondResStr  forKey:@"message"];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsString:str];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//            NSLog(@"[DeviceRegisterPlugin]-queryDeviceInfo  查询注册信息返回 -> %@",secondResStr);
//            NSString *jscode =  [NSString stringWithFormat:@"%@%@%@",@"fillData('",secondResStr,@"')"];
//            [self.webView stringByEvaluatingJavaScriptFromString:jscode];
        }];
        [secondRes setFailedBlock:^{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"查询失败,请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
            alertView.tag = 100;
            [alertView show];
            NSMutableDictionary *json = [NSMutableDictionary dictionary];
            [json setValue:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsString:json.JSONString];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
        [secondRes startAsynchronous];
        
        
    }];
    [request startAsynchronous];
}

-(void)submit2Server:(NSString *)urlStr withData:(NSDictionary *)json andFinishBlock:(RegistFinsh)finishBlock{
    NSLog(@"[DeviceRegisterPlugin]: request url ->%@",urlStr);
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSArray *keys = [json allKeys];
    for (int i = 0; i < [keys count]; i++) {
        [request setPostValue:[json objectForKey:[keys objectAtIndex:i]] forKey:[keys objectAtIndex:i]];
    }
    [request setCompletionBlock:^(void){
        if([SVProgressHUD isVisible])
        {
            [SVProgressHUD dismiss];
        }
        NSString *responseStr = [request responseString];
        NSLog(@"[DeviceRegisterPlugin]: 请求成功,返回结果->  %@",responseStr);
        finishBlock(responseStr);
    }];
    [request setFailedBlock:^{
        
        if([SVProgressHUD isVisible])
        {
            [SVProgressHUD dismiss];
        }
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"提交失败,请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alertView.tag = 100;
        [alertView show];
    }];
    [request startAsynchronous];
}

-(NSString *)appendAppKeyForFinalUrl:(NSString *)url{
    if([url rangeOfString:@"appKey"].length == 0){
        NSString *appKeySubfix = [NSString stringWithFormat:@"?appKey=%@",kAPPKey];
        NSString *newUrl = [url stringByAppendingString:appKeySubfix];
        NSLog(@"[DeviceRegisterPlugin]-appendAppKeyForFinalUrl  newUrl : %@",newUrl);
        return newUrl;
    }
    return url;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 0){
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"DeviceRegistFinished" object:nil]];
    }
    else if(alertView.tag == 100)
    {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"DeviceRegistFinished" object:nil]];
    }
}

@end
