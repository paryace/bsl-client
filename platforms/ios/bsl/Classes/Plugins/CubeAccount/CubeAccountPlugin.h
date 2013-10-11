//
//  CubeAccountPlugin.h
//  bsl
//
//  Created by zhoujun on 13-10-11.
//
//
#import <Cordova/CDVPlugin.h>
@interface CubeAccountPlugin : CDVPlugin

-(void)getAccount:(CDVInvokedUrlCommand*)command;
@end
