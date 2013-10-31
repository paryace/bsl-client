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

//更新成功后跳转
-(void)redrectMain;
//新增信息
-(void)submitInfo:(NSString *)jsonStr;
//更新信息
-(void)updateDevice:(NSString *)jsonStr;
//查询信息
-(NSString *)queryDevcieInfo;


@end
