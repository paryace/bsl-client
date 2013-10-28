//
//  VoiceUploadManager.h
//  bsl
//
//  Created by 肖昶 on 13-10-11.
//
//

#import <Foundation/Foundation.h>
@class VoiceObj;

@protocol VoiceUploadManagerDelegate <NSObject>

-(void)voiceUploadFinish:(NSString*)uqId finish:(BOOL)finish;
-(void)voiceDownloadFinish:(NSString*)uqId finish:(BOOL)finish;
@end

@protocol VoiceObjDelegate <NSObject>

-(void)removeVoiceObj:(VoiceObj*)obj finish:(NSNumber*)finish;
-(void)removeDownloadVoiceObj:(VoiceObj*)obj finish:(NSNumber*)finish;

@end

@class HTTPRequest;
@interface VoiceObj : NSObject{
    HTTPRequest* request;
}
@property(nonatomic,weak) id<VoiceObjDelegate> delegate;
@property(nonatomic,strong) NSString* uqID;
@property(nonatomic,strong) NSString* urlVoiceFile;
@property(nonatomic,strong) NSString* messageId;
@property(nonatomic,assign) BOOL isGroup;
@property(nonatomic,strong) NSString* name;

@end

@interface VoiceUploadManager : NSObject{
    NSMutableArray* array;
}
@property(nonatomic,weak) id<VoiceUploadManagerDelegate> delegate;
+(VoiceUploadManager*)sharedInstance;

-(void)cance;

-(BOOL)sendVoice:(NSString*)urlVoiceFile messageId:(NSString*)messageId isGroup:(BOOL)isGroup name:(NSString*)name uqId:(NSString*)uqId;

-(void)receiveVoice:(NSString*)content uqId:(NSString*)uqId messageId:(NSString*)messageId isGroup:(BOOL)isGroup;

@end
