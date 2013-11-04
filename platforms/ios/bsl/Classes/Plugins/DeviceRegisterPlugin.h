//
//  DeviceRegisterPlugin.h
//  bsl
//
//  Created by hibad(Alfredo) on 13/10/31.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface DeviceRegisterPlugin : CDVPlugin<UIAlertViewDelegate>

@property (strong,nonatomic) NSString *data;

//更新成功后跳转
-(void)redirectMain:(CDVInvokedUrlCommand*)command;
//新增or更新信息
-(void)submitInfo:(CDVInvokedUrlCommand*)command;
//查询信息
-(void)queryDevcieInfo:(CDVInvokedUrlCommand*)command;


@end
