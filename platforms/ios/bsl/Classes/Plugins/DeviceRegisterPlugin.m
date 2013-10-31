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


@implementation DeviceRegisterPlugin


-(void)redrectMain{
    
}

-(void)submitInfo:(NSString *)jsonStr{
    NSMutableDictionary *json  =  [jsonStr objectFromJSONString];
    
    NSString *urlStr = @"";
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSArray *keys = [json allKeys];
    for (int i = 0; i < [keys count]; i++) {
        [request setPostValue:[json objectForKey:[keys objectAtIndex:i]] forKey:[keys objectAtIndex:i]];
    }
    [request setCompletionBlock:^(void){
        NSLog(@"[DeviceRegisterPlugin]: 请求成功");
    }];
    [request startAsynchronous];
}

-(void)updateDevice:(NSString *)jsonStr{
    
}

-(NSString *)queryDevcieInfo{
    return NULL;
}

@end
