//
//  ExtroSystemPlugin.h
//  bsl
//
//  Created by zhoujun on 13-11-11.
//
//

#import <Cordova/CDVPlugin.h>
#import "MultiSystemsView.h"
@class ASIHTTPRequest;
@interface ExtroSystemPlugin : CDVPlugin<MultiSystemDelegate>
{
    ASIHTTPRequest* httRequest;
    CDVInvokedUrlCommand*_command;
    NSMutableArray *_options;
}
-(void)listAllExtroSystem:(CDVInvokedUrlCommand*)command;
-(void)login:(CDVInvokedUrlCommand*)command;
-(void)cancel:(CDVInvokedUrlCommand*)command;
-(void)getCurrSystem:(CDVInvokedUrlCommand*)command;
-(void)dismissRightView:(CDVInvokedUrlCommand*)commond;
@end
