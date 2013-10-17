//
//  CubeModulePlugin.m
//  cube-ios
//
//  Created by 东 on 6/6/13.
//
//

#import "CubeModulePlugin.h"
#import "JSONKit.h"
#import "MessageRecord.h"

@implementation CubeModulePlugin


/**
 *	@author 	张国东
 *	@brief	获取应用中未安装的模块信息
 *
 *	@param 	command
 */
-(void)uninstallList:(CDVInvokedUrlCommand*)command
{
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    NSMutableDictionary *moduleCategoryDictionary = [self getCategoryFromArray:cubeApp.availableModules];
    NSString* jsonStr =[self getJsonFromDictioary:moduleCategoryDictionary showHide:NO];
    CDVPluginResult* pluginResult = nil;
    if (jsonStr) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonStr];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"获取信息失败！"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


/**
 *	@author 	张国东
 *	@brief	或用应用中安装的模块信息
 *
 *	@param 	command 	
 */
-(void)installList:(CDVInvokedUrlCommand*)command
{
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    
    NSMutableDictionary *moduleCategoryDictionary = [self getCategoryFromArray:cubeApp.modules];
    
    NSString* jsonStr =[self getJsonFromDictioary:moduleCategoryDictionary showHide:NO];
    CDVPluginResult* pluginResult = nil;
    if (jsonStr) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonStr];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"获取信息失败！"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


/**
 *	@author 	张国东
 *	@brief	获取应用中可更新的模块信息
 *
 *	@param 	command
 */
-(void)upgradableList:(CDVInvokedUrlCommand*)command{
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    NSMutableDictionary *moduleCategoryDictionary = [self getCategoryFromArray:cubeApp.updatableModules];
    NSString* jsonStr =                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                [self getJsonFromDictioary:moduleCategoryDictionary showHide:NO];
    CDVPluginResult* pluginResult = nil;
    if (jsonStr) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonStr];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"获取信息失败！"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}



/**
 *	@author 	张国东
 *	@brief	获取主页面所有模块信息
 *
 *	@param 	command 	
 */
-(void)mainList:(CDVInvokedUrlCommand*)command
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_VIEW" object:[NSNumber numberWithInt:1]];
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    //循环获取所有安装模块的category
    NSMutableDictionary *moduleCategoryDictionary = [self getCategoryFromArray:cubeApp.modules];
    
    NSString* jsonStr =[self getJsonFromDictioary:moduleCategoryDictionary showHide:YES];
    CDVPluginResult* pluginResult = nil;
    if (jsonStr) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonStr];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"获取信息失败！"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}


-(void)ShowMainView:(CDVInvokedUrlCommand*)command{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_MAINVIEW" object:nil];
}

-(NSString* )getJsonFromDictioary:(NSMutableDictionary*)moduleCategoryDictionary  showHide:(Boolean)hide{
  NSString* jsonString=@"";
    
    @autoreleasepool {
        //根据category来循环写入json数据
        NSMutableDictionary*  Json = [[NSMutableDictionary alloc]init];
        for (NSString* category  in  moduleCategoryDictionary.keyEnumerator) {
            
            NSArray* eachArray = [moduleCategoryDictionary objectForKey:category];
            NSMutableArray* mudoleArray = [[NSMutableArray alloc]init];
            for (CubeModule *each in eachArray) {
                if (!hide || !each.hidden) {
                    [mudoleArray addObject:  [self modueToJson:each]];
                }
            }
            //组合 cateGory 数据
            //add by fanty
            if([mudoleArray count]>0)
                [Json setObject:mudoleArray forKey:category];
            mudoleArray=nil;
        }
        jsonString=Json.JSONString ;
        Json=nil;
    }
  

    return  jsonString;
}


/**
 *	@author 	张国东
 *	@brief	将模块信息转化成一个NSMutableDictionary
 *
 *	@param 	each 	模块
 *
 *	@return	模块信息字典 NSMutableDictionary
 */
-(NSMutableDictionary*)modueToJson:(CubeModule* )each
{

    NSMutableDictionary *jsonCube = [[NSMutableDictionary alloc] init];
    
    @autoreleasepool {

        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString *token =  [defaults objectForKey:@"token"];
        [jsonCube  setObject:each.version forKey:@"version"];
   
        [jsonCube setObject:[NSNumber numberWithBool:each.hidden] forKey:@"hidden"];
        [jsonCube  setObject:each.releaseNote forKey:@"releaseNote"];
        [jsonCube  setObject:each.category forKey:@"category"];
        if ([each.local length]>0)
        {
            if(each.iconUrl)
            {
                [jsonCube  setObject:each.iconUrl forKey:@"icon"];
            }
            else
            {
                [jsonCube  setObject:@"" forKey:@"icon"];
            }
        }
        else
        {
            if(each.iconUrl)
            {
                [jsonCube  setObject:[each.iconUrl stringByAppendingFormat:@"?sessionKey=%@&appKey=%@",token,kAPPKey] forKey:@"icon"];
            }
            else
            {
                [jsonCube  setObject:[@"" stringByAppendingFormat:@"?sessionKey=%@&appKey=%@",token,kAPPKey] forKey:@"icon"];
            }
        }
        [jsonCube  setObject:each.identifier forKey:@"identifier"];
        [jsonCube  setObject:!each.local?@"":each.local forKey:@"local"];
        [jsonCube  setObject:each.name forKey:@"name"];
        
        int count = 0 ;
        if (![each.moduleBadge isEqualToString:@"1"]) {
            if ([each.identifier  isEqualToString:@"com.foss.message.record"]) {
                count  =[MessageRecord countAllAtBadge];
            }else{
                count = [MessageRecord countForModuleIdentifierAtBadge:each.identifier];
            }
        }
        [jsonCube  setObject: [NSNumber numberWithInt:count] forKey:@"msgCount"];
        [jsonCube  setObject: [NSNumber numberWithInt:0] forKey:@"progress"];
        [jsonCube setObject:[NSNumber numberWithInt:each.sortingWeight] forKey:@"sortingWeight"];
        
        [jsonCube  setObject: [NSNumber numberWithInteger:each.build] forKey:@"build"];
        if ([self isUpdateModule:each.identifier]) {
            [jsonCube  setObject:  [NSNumber numberWithBool:YES] forKey:@"updatable"];
        }else{
            [jsonCube  setObject:  [NSNumber numberWithBool:NO] forKey:@"updatable"];
        }
    }
    return jsonCube;
}


/**
 *	@author 	张国东
 *	@brief	根据模块的Identifier判断当前模块是否是可更新的模块
 *
 *	@param 	moduleIdentifier 	模块的identifier
 *
 *	@return	返回模块是否存在更新  true/false
 */
-(Boolean)isUpdateModule:(NSString*)moduleIdentifier
{
     CubeApplication *cubeApp = [CubeApplication currentApplication];
     CubeModule *module = [cubeApp updatableModuleModuleForIdentifier:moduleIdentifier];
    if (module) {
        return YES;
    }
    return NO;
}



/**
 *	@author 	张国东
 *	@brief  更具模块数组返回Category
 *
 *	@param 	modylesArray 	模块数组
 *
 *	@return	返回一个Category字典
 */
-(NSMutableDictionary*)getCategoryFromArray:(NSMutableArray*)modylesArray
{
    NSMutableDictionary *moduleCategoryDictionary = [[NSMutableDictionary alloc]init];
    for(CubeModule *each in modylesArray){
        if (!each.category) {
            each.category = @"基本功能";
        }
      NSMutableArray* array =[moduleCategoryDictionary objectForKey:each.category];
      if (!array) {
           array  = [[NSMutableArray alloc]init];
       }
      [array addObject:each];
      [moduleCategoryDictionary setObject:array forKey:each.category];
    }
    return moduleCategoryDictionary;
}


@end


