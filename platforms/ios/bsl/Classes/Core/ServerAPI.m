//
//  ServerAPI.m
//  Cube-iOS
//
//  Created by Justin Yip on 2/2/13.
//
//

#import "ServerAPI.h"
#import "Config.h"
#import "stdlib.h"

@implementation ServerAPI

#ifdef MOBILE_BSL

+(NSString*)urlForAttachmentId:(NSString*)aid {
    return [kServerURLString stringByAppendingFormat:@"/csair-mam/api/mam/clients/files/%@/", aid];
}

+(NSString*)urlForAppUpdate {
    return [kServerURLString stringByAppendingFormat:@"/csair-mam/api/mam/clients/update/ios/%@/?ts=%f", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"], [NSDate timeIntervalSinceReferenceDate]];
}
//下载后更新计数
+(NSString*)urlForAppUpdateRecord {
    return [kServerURLString stringByAppendingFormat:@"/csair-mam/api/mam/clients/update/appcount/ios/"];
}

+(NSString*)urlForLogin {
    return kServerLoginURLString;
}

+(NSString*)urlForSync {
    return [kServerURLString stringByAppendingFormat:@"/csair-mam/api/mam/clients/ios/%@/%@/", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
}
+(NSString*)urlForSyncImpc {
    return [kServerURLString stringByAppendingFormat:@"/csair-extension/api/extendClients/ios/%@/%@/", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
}

+(NSString*)urlForlogout:(NSString* )sessionKey{
    return [kServerURLString stringByAppendingFormat:@"/csair-system/api/system/mobile/accounts/logout/%@", sessionKey];
}

#else


+(NSString*)urlForAttachmentId:(NSString*)aid {
    return [kServerURLString stringByAppendingFormat:@"/csair-mam/api/mam/clients/files/%@", aid];
}

+(NSString*)urlForAppUpdate {
    return [kServerURLString stringByAppendingFormat:@"/csair-mam/api/mam/clients/update/ios/%@/?ts=%f", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"], [NSDate timeIntervalSinceReferenceDate]];
}
//下载后更新计数
+(NSString*)urlForAppUpdateRecord {
    return [kServerURLString stringByAppendingFormat:@"/csair-mam/api/mam/clients/update/appcount/ios/"];
}

+(NSString*)urlForLogin {
    return kServerLoginURLString;
}

+(NSString*)urlforUserSync{
    return [kServerURLString stringByAppendingFormat:@"/csair-mam/api/mam/clients/modules/%@/?ts=%f",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"], [NSDate timeIntervalSinceReferenceDate]];
}

+(NSString*)urlForSync {
    return [kServerURLString stringByAppendingFormat:@"/csair-mam/api/mam/clients/ios/%@/%@/", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
}
+(NSString*)urlForSyncImpc {
    return [kServerURLString stringByAppendingFormat:@"/csair-extension/api/extendClients/ios/%@/%@/", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
}

+(NSString*)urlForlogout:(NSString* )sessionKey{
     return [kServerURLString stringByAppendingFormat:@"/csair-system/api/system/mobile/accounts/logout/%@", sessionKey];
}

+(NSString*)urlForGeoLocation:(NSString* )sessionKey
{
    return [kServerURLString stringByAppendingFormat:@"/csair-mam/api/mam/device/position/add?sessionKey=%@", sessionKey];
}

#endif

@end

