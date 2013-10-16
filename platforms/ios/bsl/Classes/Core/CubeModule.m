//
//  CubeModule.m
//  Cube
//
//  Created by Justin Yip on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CubeModule.h"
#import "NSFileManager+Extra.h"
#import "SSZipArchive.h"
#import "ServerAPI.h"
#import "CubeApplication.h"
#import "JSONKit.h"
#import "SVProgressHUD.h"
#import "HTTPRequest.h"
#import "AFHTTPRequestOperation.h"
#import "CudeModuleDownDictionary.h"

NSString *const CubeModuleDownloadDidStartNotification = @"CubeModuleDownloadDidStartNotification";
NSString *const CubeModuleDownloadDidFinishNotification = @"CubeModuleDownloadDidFinishNotification";
NSString *const CubeModuleDownloadDidFailNotification = @"CubeModuleDownloadDidFailNotification";
NSString *const CubeModuleInstallDidFinishNotification = @"CubeModuleInstallDidFinishNotification";
NSString *const CubeModuleInstallDidFailNotification = @"CubeModuleInstallDidFailNotification";

NSString *const CubeModuleUpdateDidFinishNotification = @"CubeModuleUpdateDidFinishNotification";
NSString *const CubeModuleUpdateDidFailNotification = @"CubeModuleUpdateDidFailNotification";

NSString *const CubeModuleDeleteDidFinishNotification = @"CubeModuleDeleteDidFinishNotification";
NSString *const CubeModuleDeleteDidFailNotification = @"CubeModuleDeleteDidFailNotification";

@implementation CubeModule

@synthesize pushMsgLink;
@synthesize identifier;
@synthesize name;
@synthesize releaseNote;
@synthesize icon;
@synthesize url;
@synthesize bundle;
@synthesize package;
@synthesize version;
@synthesize build;
@synthesize local;
@synthesize localImageUrl;
@synthesize installed;
@synthesize isDownloading;
@synthesize downloadProgress;
@synthesize installType;
@synthesize hidden;

@synthesize discription;
@synthesize showPushMsgCount;
@synthesize isAutoShow;
@synthesize showIntervalTime;
@synthesize timeUnit;
@synthesize autoDownload;
@synthesize sortingWeight;


- (NSString*)description
{
    return [NSString stringWithFormat:@"Cube Module[%@|%@]: v%@ - build %d", name, identifier, version , build];
}

- (NSString*)identifierWithBuild
{
    //    return [NSString stringWithFormat:@"%@-%d", self.identifier, self.build];
    return self.identifier;
}

- (NSDictionary*)missingDependencies
{
    NSMutableArray *missingModules = [NSMutableArray array];
    NSMutableArray *needUpgradeModules = [NSMutableArray array];
    
    NSURL *moduleConfigURL = [[self runtimeURL] URLByAppendingPathComponent:@"CubeModule.json"];
    NSString *jsonString = [NSString stringWithContentsOfURL:moduleConfigURL encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *result = [jsonString objectFromJSONString];
    NSDictionary *dependencies = [result objectForKey:@"dependencies"];
    for (NSString *key in dependencies) {
        NSNumber *buildNumber = [dependencies objectForKey:key];
        CubeModule *module = [[CubeApplication currentApplication] moduleForIdentifier:key];
        if (!module) {
            [missingModules addObject:key];
        }else if([buildNumber integerValue] > module.build) {
            [needUpgradeModules addObject:key];
        }
    }
    
    return @{
             kMissingDependencyNeedInstallKey: missingModules,
             kMissingDependencyNeedUpgradeKey: needUpgradeModules
             };
}

- (NSURL*)runtimeURL
{
    return [[NSFileManager wwwRuntimeDirectory]
            URLByAppendingPathComponent:[self identifierWithBuild]];
}

- (NSString*)iconUrl {
    if (icon && ![icon isKindOfClass:[NSNull class]] && [icon hasPrefix:@"local:"]) {
        NSString *iconName = [icon substringFromIndex:6];
        return [[[NSBundle mainBundle] URLForResource:iconName withExtension:nil] absoluteString];
    } else {
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSString* runURLStr =  [[self runtimeURL] path];
        NSString* absoluteRunStr =[[self runtimeURL] absoluteString];
        if ([fileMgr fileExistsAtPath:runURLStr]) {
            if ([fileMgr fileExistsAtPath:[runURLStr stringByAppendingString:@"/icon.img"]]) {
                return [absoluteRunStr stringByAppendingString:@"/icon.img"];
            }else if ([fileMgr fileExistsAtPath:[runURLStr stringByAppendingString:@"/icon.png"]]){
                 return [absoluteRunStr stringByAppendingString:@"/icon.png"] ;
            }else{
                return [ServerAPI urlForAttachmentId:icon];
            }
        }
        
        return [ServerAPI urlForAttachmentId:icon];
    }
}

-(void)update{
    installType = @"update";
    [self install];
}


-(void)install
{
    if (bundle == nil) {
        self.installed = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:CubeModuleInstallDidFinishNotification object:self];
    } else {
        if ( self.isDownloading == 0 || self.isDownloading) {
            NSString* downUrl = [ServerAPI urlForAttachmentId:bundle];
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            NSString *token =  [defaults objectForKey:@"token"];
            downUrl= [downUrl stringByAppendingString:@"?sessionKey="];
            downUrl= [downUrl stringByAppendingString:token];
            downUrl= [downUrl stringByAppendingString:@"&appKey="];
            downUrl= [downUrl stringByAppendingString:kAPPKey];
            //判断模块是否在下载列表中存在
            BOOL exitDownMoule =(BOOL) [[CudeModuleDownDictionary shareModuleDownDictionary] objectForKey:self.identifier] ;
            if(exitDownMoule ){
                return;
            }
         
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downUrl]];
            AFHTTPRequestOperation * httpConnection = [[AFHTTPRequestOperation alloc]initWithRequest:request];
            
            [httpConnection setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self downloadFinished:responseObject];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [[CudeModuleDownDictionary shareModuleDownDictionary] removeObjectForKey:self.identifier];
                self.isDownloading = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_DETIALPAGE_INSTALLFAILED object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:CubeModuleDownloadDidFailNotification object:self];
            }];
           [httpConnection setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
               [self setProgress:totalBytesExpectedToRead/totalBytesRead];
           }];
            [httpConnection start]; 
            [self downloadStarted];
        }
    }
}

-(BOOL)moduleFileIsExit{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[self runtimeURL] path]]) {
        
        return  YES;
    }
    
    return NO;
}

-(BOOL)moduleIsInstalled
{
    if([[NSFileManager defaultManager] fileExistsAtPath:[[self runtimeURL] path]])
    {
        return YES;
    }
    return NO;
}

-(BOOL)uninstall
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[self runtimeURL] path]]) {
         [[NSFileManager defaultManager] removeItemAtPath:[[self runtimeURL] path] error:nil];
        return YES;
    }
    return  YES;
}

- (void)setProgress:(float)newProgress{
    self.downloadProgress = newProgress;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"queue_module_download_progressupdate" object:self userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithFloat:newProgress],self.identifier,nil] forKeys:[NSArray arrayWithObjects:@"newProgress",@"key",nil]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"module_download_progressupdate" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:newProgress] forKey:@"newProgress"]];
}

-(void)downloadStarted
{
    [[CudeModuleDownDictionary shareModuleDownDictionary] setObject:[NSNumber numberWithBool:YES] forKey:self.identifier];
    NSLog(@"开始下载模块");
    self.isDownloading = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:CubeModuleDownloadDidStartNotification object:self];
}

-(void)downloadFinished:(id)downData
{
    [[CudeModuleDownDictionary shareModuleDownDictionary] removeObjectForKey:self.identifier];
    NSLog(@"下载模块完成");
    self.isDownloading = NO;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        //save to local file
        NSData *data = downData;
        
        NSURL *destURL = [[[NSFileManager applicationDocumentsDirectory] URLByAppendingPathComponent:[self identifierWithBuild]] URLByAppendingPathExtension:@"zip"];
        
        if (![data writeToURL:destURL atomically:YES])
        {
            NSLog(@"模块保存到本地失败");
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:CubeModuleDownloadDidFailNotification object:self];
            });
            return;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CubeModuleDownloadDidFinishNotification object:self];
            
        });
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[[self runtimeURL]path]]) {
            [[NSFileManager defaultManager] removeItemAtPath:[[self runtimeURL]path] error:nil];
        }
        
        //install
        NSError *error = nil;
        if(![SSZipArchive unzipFileAtPath:[destURL path]
                            toDestination:[[self runtimeURL] path]
                                overwrite:YES password:nil error:&error])
        {
            NSLog(@"模块解压失败，%@", error);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"queue_module_download_progressupdate" object:self userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.101],self.identifier,nil] forKeys:[NSArray arrayWithObjects:@"newProgress",@"key",nil]]];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:CubeModuleInstallDidFailNotification object:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_DETIALPAGE_INSTALLFAILED object:nil];
            });
            return;
        }
        //delete module local zip after installed
        if(![[NSFileManager defaultManager] removeItemAtURL:destURL error:&error])
        {
            NSLog(@"删除模块安装包失败，%@", error);
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            self.installed = YES;
            
            //清楚浏览器缓存
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            
            for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]){
                
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"queue_module_download_progressupdate" object:self userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.101],self.identifier,nil] forKeys:[NSArray arrayWithObjects:@"newProgress",@"key",nil]]];
            NSDictionary *missingModules = [self missingDependencies];
            NSArray *needInstall = [missingModules objectForKey:kMissingDependencyNeedInstallKey];
            NSArray *needUpgrade = [missingModules objectForKey:kMissingDependencyNeedUpgradeKey];
              CubeApplication *cubeApp = [CubeApplication currentApplication];
            
            if ([needInstall count] > 0 || [needUpgrade count] > 0) {
                for (NSString* module in needInstall) {
                    CubeModule* cubeModule = [cubeApp availableModuleForIdentifier:module];
                    if (cubeModule) {
                        [cubeModule install];
                    }
                }
                for (NSString* module in needUpgrade) {
                    CubeModule* cubeModule = [cubeApp moduleForIdentifier:module];
                    [cubeModule install];
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CubeModuleInstallDidFinishNotification object:self];
        });
    });//async
    
    //download dependency
}



#pragma mark - Serialization

+(CubeModule*)moduleFromJSONObject:(id)jsonObject
{
    CubeModule *module = [[CubeModule alloc] init];
    NSNumber* downNum =   [jsonObject objectForKey:@"autoDownload"];
    module.autoDownload =  [downNum boolValue];
    module.identifier = [jsonObject objectForKey:@"identifier"];
    module.name = [jsonObject objectForKey:@"name"];
    module.releaseNote = [jsonObject objectForKey:@"releaseNote"];
    module.local = [jsonObject objectForKey:@"local"];
    if ([module.local length]>0) {
        module.icon = [NSString stringWithFormat:@"local:%@.png",module.local];
    }else{
        module.icon = [jsonObject objectForKey:@"icon"];
    }
    
    module.bundle = [jsonObject objectForKey:@"bundle"];
    module.package = [jsonObject objectForKey:@"package"];
    module.version = [jsonObject objectForKey:@"version"];
    module.build = [[jsonObject objectForKey:@"build"] integerValue];
    module.installed = [[jsonObject objectForKey:@"installed"] boolValue];
    module.url = [jsonObject objectForKey:@"url"];
    module.localImageUrl = [jsonObject objectForKey:@"localImageUrl"];
    module.category = [jsonObject objectForKey:@"category"];
    module.privileges = [jsonObject objectForKey:@"privileges"];
    
    module.pushMsgLink = [jsonObject objectForKey:@"pushMsgLink"];
    module.discription = [jsonObject objectForKey:@"discription"];
    module.sortingWeight = [[jsonObject objectForKey:@"sortingWeight"] intValue];
    module.isAutoShow = [[jsonObject objectForKey:@"isAutoShow"]boolValue];
    module.showPushMsgCount = [[jsonObject objectForKey:@"showPushMsgCount"]integerValue];
    module.showIntervalTime = [[jsonObject valueForKey:@"showIntervalTime"] isEqual:[NSNull null] ] ? 0 : [[jsonObject valueForKey:@"showIntervalTime"] integerValue];
    
    module.timeUnit =  [[jsonObject valueForKey:@"timeUnit"] isEqual:[NSNull null] ] ? @"" : [jsonObject valueForKey:@"timeUnit"] ;
    //是否隐藏
    module.hidden =  [[jsonObject objectForKey:@"hidden"] boolValue];
    return module;
}

-(NSMutableDictionary*)dictionary
{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    [json setValue:[NSNumber numberWithBool:self.autoDownload] forKey:@"autoDownload"];
    [json setValue:self.identifier forKey:@"identifier"];
    [json setValue:self.name forKey:@"name"];
    [json setValue:self.releaseNote forKey:@"releaseNote"];
    [json setValue:self.icon forKey:@"icon"];
    [json setValue:self.url forKey:@"url"];
    [json setValue:self.bundle forKey:@"bundle"];
    [json setValue:self.package forKey:@"package"];
    [json setValue:self.version forKey:@"version"];
    [json setValue:self.category forKey:@"category"];
    [json setValue:self.localImageUrl forKey:@"localImageUrl"];
    [json setValue:[NSNumber numberWithInteger:self.sortingWeight] forKey:@"sortingWeight"];
    [json setValue:[NSNumber numberWithInteger:self.build] forKey:@"build"];
    [json setValue:[NSNumber numberWithBool:self.installed] forKey:@"installed"];
    [json setValue:self.local forKey:@"local"];
    [json setValue:self.privileges forKey:@"privileges"];
    [json setValue:self.pushMsgLink forKey:@"pushMsgLink"];
    
    [json setValue:[NSNumber numberWithBool:self.isAutoShow ]forKey:@"isAutoShow"];
    [json setValue:[NSNumber numberWithBool:self.showPushMsgCount] forKey:@"showPushMsgCount"];
    
    //是否隐藏
    [json setValue:[NSNumber numberWithBool:self.hidden] forKey:@"hidden"];
    return json;
}

-(NSURL*)moduleDataDirectory
{
    NSURL *mdd = [[NSFileManager applicationDocumentsDirectory] URLByAppendingPathComponent:self.identifier isDirectory:YES];
    BOOL isDir = NO;
    BOOL exists = [FS fileExistsAtPath:[mdd path] isDirectory:&isDir];
    if (!exists || !isDir) {
        NSError *error = nil;
        BOOL success = [FS createDirectoryAtURL:mdd withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success) NSLog(@"创建模块[%@]数据目录失败,%@", self.identifier, error);
    }
    return mdd;
}



@end
