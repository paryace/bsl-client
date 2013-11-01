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
#define kDeviceBaseUrl @"csair-extension/api/deviceRegInfo"
#define kDeviceRegSubmit @"reg"
#define kDeviceRegUpdate @"update"

typedef void (^RegistFinsh)(NSString *responseStr);

@implementation DeviceRegisterPlugin


-(void)redrectMain{
    
}

-(void)submitInfo:(CDVInvokedUrlCommand*)command{
    NSString *jsonStr = [command argumentAtIndex:0];
    NSMutableDictionary *json  =  [jsonStr objectFromJSONString];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@",kServerURLString,kDeviceBaseUrl,kDeviceRegSubmit];
//    NSLog(@"[DeviceRegisterPlugin]: submit url ->%@",urlStr);
    
    [self submit2Server:urlStr withData:json andFinishBlock:^(NSString *responseStr){
        NSDictionary *responseJson = [responseStr objectFromJSONString];
        if([@"success" isEqualToString:[responseJson objectForKey:@"result"]]){
            NSLog(@"[DeviceRegisterPlugin]: 注册成功!");
        }
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"DeviceRegistFinished" object:nil]];
    }];
}

-(void)updateDevice:(CDVInvokedUrlCommand*)command{
    NSString *jsonStr = [command argumentAtIndex:0];
    NSMutableDictionary *json  =  [jsonStr objectFromJSONString];
    
    [json objectForKey:@"id"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@",kServerURLString,kDeviceBaseUrl,kDeviceRegUpdate];
    
    [self submit2Server:urlStr withData:json andFinishBlock:^(NSString *responseStr){
        
    }];
    
}

-(NSString *)queryDevcieInfo{
    return NULL;
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


@end
