//
//  ExtroSystemPlugin.h
//  bsl
//
//  Created by zhoujun on 13-11-11.
//
//

#import <Cordova/CDVPlugin.h>
@class ASIHTTPRequest;
@interface ExtroSystemPlugin : CDVPlugin
{
    ASIHTTPRequest* httRequest;
}
-(void)listAllExtroSystem:(CDVInvokedUrlCommand*)command;
-(void)login:(CDVInvokedUrlCommand*)command;
-(void)cancel:(CDVInvokedUrlCommand*)command;
@end
