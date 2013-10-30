//
//  ServerAPI.h
//  Cube-iOS
//
//  Created by Justin Yip on 2/2/13.
//
//

#import <Foundation/Foundation.h>

@interface ServerAPI : NSObject

+(NSString*)urlForAttachmentId:(NSString*)aid;
+(NSString*)urlForAppUpdate;
//下载后更新计数
+(NSString*)urlForAppUpdateRecord;
+(NSString*)urlForLogin;
+(NSString*)urlForSync;
+(NSString*)urlForlogout:(NSString* )sessionKey;
//南航定制的业务同步模块
+(NSString*)urlForSyncImpc;

@end
