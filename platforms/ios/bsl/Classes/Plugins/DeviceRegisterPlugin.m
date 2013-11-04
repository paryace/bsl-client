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

typedef void (^RegistFinsh)(NSString *responseStr);

@implementation DeviceRegisterPlugin


-(void)redirectMain:(CDVInvokedUrlCommand*)command{
    NSLog(@"[DeviceRegisterPlugin]: pop页面!");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"PopDeviceRegistView" object:nil]];
}

-(void)submitInfo:(CDVInvokedUrlCommand*)command{
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
        }
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"DeviceRegistFinished" object:nil]];
    }];
}

-(void)queryDevcieInfo:(CDVInvokedUrlCommand*)command{
    NSString *deviceId = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@%@",kServerURLString,kDeviceBaseUrl,kDeviceRegCheck,deviceId];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self appendAppKeyForFinalUrl:urlStr]]];
    [request setRequestMethod:@"GET"];
    [request setCompletionBlock:^(void){
        NSString *responseStr = [request responseString];
        NSLog(@"[DeviceRegisterPlugin]-queryDeviceInfo  检查更新返回: -> %@",responseStr);
        
        //二次请求查询数据
        NSString *queryUrl = [NSString stringWithFormat:@"%@/%@/%@%@",kServerURLString,kDeviceBaseUrl,kDeviceRegQuery,deviceId];
        queryUrl = [self appendAppKeyForFinalUrl:queryUrl];
        ASIHTTPRequest *secondRes = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self appendAppKeyForFinalUrl:queryUrl]]];
        [secondRes setResponseEncoding:NSUTF8StringEncoding];
        [secondRes setRequestMethod:@"GET"];
        [secondRes setCompletionBlock:^(void){
            NSString *secondResStr = [secondRes responseString];
            NSLog(@"[DeviceRegisterPlugin]-queryDeviceInfo  查询注册信息返回 -> %@",secondResStr);
            NSString *jscode =  [NSString stringWithFormat:@"%@%@%@",@"fillData('",secondResStr,@"')"];
            [self.webView stringByEvaluatingJavaScriptFromString:jscode];
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
        NSString *responseStr = [request responseString];
        NSLog(@"[DeviceRegisterPlugin]: 请求成功,返回结果->  %@",responseStr);
        finishBlock(responseStr);
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


@end
