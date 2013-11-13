//
//  LoginPlugin.h
//  cube-ios
//
//  Created by 东 on 6/3/13.
//
//

#import <Cordova/CDVPlugin.h>
#import "SVProgressHUD.h"

#import "LeveyPopListView.h"
@class ASIHTTPRequest;
@interface LoginPlugin : CDVPlugin<LeveyPopListViewDelegate>{
    ASIHTTPRequest* httRequest;
    NSMutableArray *_options;
}
//获取用户保存本地的数据
-(void)getAccountMessage:(CDVInvokedUrlCommand*)command;
-(void)login:(CDVInvokedUrlCommand*)command;
-(void)canceLogin:(CDVInvokedUrlCommand*)command;
@end
