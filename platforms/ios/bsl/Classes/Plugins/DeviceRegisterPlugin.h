//
//  DeviceRegisterPlugin.h
//  bsl
//
//  Created by hibad(Alfredo) on 13/10/31.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface DeviceRegisterPlugin : CDVPlugin

@property (strong,nonatomic) NSString *data;

//更新成功后跳转
-(void)redrectMain;
//新增信息
-(void)submitInfo:(CDVInvokedUrlCommand*)command;
//更新信息
-(void)updateDevice:(CDVInvokedUrlCommand*)command;
//查询信息
-(NSString *)queryDevcieInfo;


@end
