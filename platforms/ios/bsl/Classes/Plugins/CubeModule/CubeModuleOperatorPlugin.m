//
//  CubeModuleOperatorPlugin.m
//  cube-ios
//
//  Created by 东 on 6/6/13.
//
//

#import "CubeModuleOperatorPlugin.h"
#import "SVProgressHUD.h"
#import "MessageRecord.h"

#define SHOW_SETTING_VIEW  @"SHOW_SETTING_VIEW"
#define SHOW_SETTHEME_VIEW  @"SHOW_SETTHEME_VIEW"

@implementation CubeModuleOperatorPlugin
@synthesize cdvCommand;

/**
 *	@author 	张国东
 *	@brief	根据模块的identitfier安装模块
 *
 *	@param 	command 	command.arguments 参数中 第一个参数是模块的identifier
 */
-(void)install:(CDVInvokedUrlCommand*)command
{
    NSLog(@"CubeModuleOperatorPlugin install");
    CubeApplication* cubeApp = [CubeApplication currentApplication];
    NSString* identifier = [command.arguments objectAtIndex:0];
    CubeModule *module = [cubeApp availableModuleForIdentifier:identifier];
    [cubeApp installModule:module];
    
    NSLog(@"CubeModuleOperatorPlugin install end");

}

/**
 *	@author 	张国东
 *	@brief	根据模块的identifier删除模块
 *
 *	@param 	command 	command.arguments 参数中 第一个参数是模块的identifier
 */
-(void)uninstall:(CDVInvokedUrlCommand*)command
{
    NSLog(@"CubeModuleOperatorPlugin uninstall");

    CubeApplication* cubeApp = [CubeApplication currentApplication];
    NSString* identifier = [command.arguments objectAtIndex:0];
    CubeModule *module = [cubeApp moduleForIdentifier:identifier];
    [cubeApp uninstallModule:module];
   
    NSLog(@"CubeModuleOperatorPlugin uninstall end");

}

/**
 *	@author 	张国东
 *	@brief	根据模块的identifier更新模块
 *
 *	@param 	command 	command.arguments 参数中 第一个参数是模块的identifier
 */
-(void)upgrade:(CDVInvokedUrlCommand*)command{
    NSLog(@"CubeModuleOperatorPlugin update");

    CubeApplication* cubeApp = [CubeApplication currentApplication];
    NSString* identifier = [command.arguments objectAtIndex:0];
    CubeModule *module = [cubeApp updatableModuleModuleForIdentifier:identifier];
    if ([module installed]) {
        [cubeApp uninstallModule:module];
    }
    [cubeApp updateModule:module];
    
    NSLog(@"CubeModuleOperatorPlugin update end");

}


/**
 *	@author 	张国东
 *	@brief	根据模块的ID 显示模块的相信信息
 *
 *	@param 	command 	command.arguments 参数中 第一个参数是模块的identifier
 */
-(void)showModule:(CDVInvokedUrlCommand*)command
{
    //NSString* identifier = [command.arguments objectAtIndex:0];
    /*
    if (![identifier isEqualToString:@"com.foss.chat"]) {
        [MessageRecord dismissModuleBadge:identifier];
    }
     */
    NSLog(@"CubeModuleOperatorPlugin showModule");

    [[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_DETAILVIEW" object:command.arguments];
    CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.cdvCommand.callbackId];
    
    NSLog(@"CubeModuleOperatorPlugin showModule end");

}

/**
 *	@author 	张国东
 *	@brief	打开设置模块
 *
 *	@param 	command 	command.arguments 参数中 第一个参数是模块的identifier
 */
-(void)setting:(CDVInvokedUrlCommand*)command
{
    
    NSLog(@"CubeModuleOperatorPlugin setting");

    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_SETTING_VIEW object:self];
    CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.cdvCommand.callbackId];
    
    NSLog(@"CubeModuleOperatorPlugin setting end");

}


/**
 *	@author 	张国东
 *	@brief	打开主题设置
 *
 *	@param 	command 	command.arguments 参数中 第一个参数是模块的identifier
 */
-(void)setTheme:(CDVInvokedUrlCommand*)command
{
    NSLog(@"CubeModuleOperatorPlugin setTheme");

    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_SETTHEME_VIEW object:self];
    CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.cdvCommand.callbackId];
    
    NSLog(@"CubeModuleOperatorPlugin setTheme end");

}

-(void)fragmenthide:(CDVInvokedUrlCommand*)command{
    NSLog(@"fragmenthide click............");
    [[NSNotificationCenter defaultCenter] postNotificationName:CubeSyncClickNotification object:[NSNumber numberWithInt:1]];

}

//同步数据
-(void)sync:(CDVInvokedUrlCommand*)command{
    NSLog(@"syncing............");
    
    if(![SVProgressHUD isVisible]){
        [SVProgressHUD showWithStatus:@"正在同步数据..." maskType:SVProgressHUDMaskTypeGradient ] ;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CubeSyncClickNotification object:[NSNumber numberWithInt:0]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patchTokemTimeOurInfoForFilter) name:CubeTokenTimeOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patchArrayInfoForFilter) name:CubeAppUpdateFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patchTokemTimeOurInfoForFilter) name:CubeSyncFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patchArrayInfoForFilter) name:CubeSyncFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patchArrayStart) name:CubeSyncStartedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patchTokemTimeOurInfoForFilter) name:KNOTIFICATION_DETIALPAGE_SYNFAILED object:nil];

    self.cdvCommand = command;
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    [cubeApp sync];
    
    
}

-(void)patchArrayStart{
    if(![SVProgressHUD isVisible]){
        [SVProgressHUD showWithStatus:@"正在同步数据..." maskType:SVProgressHUDMaskTypeGradient ] ;
    }
}

- (void)patchArrayInfoForFilter
{
    if([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.cdvCommand.callbackId];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_VIEW" object:[NSNumber numberWithInt:1]];
}

-(void)failedSyn{
   [SVProgressHUD showErrorWithStatus:@"同步数据失败" ];
}

-(void)patchTokemTimeOurInfoForFilter{
    
    [SVProgressHUD showErrorWithStatus:@"同步数据失败,请检查网络!" ];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.cdvCommand.callbackId];
}



@end
