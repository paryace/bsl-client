//
//  MessageRecord.h
//  Cube-iOS
//
//  Created by chen shaomou on 2/1/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Repository.h"
#import "MessageRecordManager.h"

#define MESSAGE_RECORD_DID_SAVE_NOTIFICATION @"message_record_did_save_notification" 


@interface MessageRecord : NSManagedObject

@property (nonatomic, strong) NSString * alert;//alert 的内容
@property (nonatomic, strong) NSString * sound;//声音
@property (nonatomic, strong) NSNumber * badge;//显示个数
@property (nonatomic, strong)   NSString * module;
@property (nonatomic, strong) NSString * recordId;
@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSDate * reviceTime;
@property (nonatomic, strong) NSNumber *isIconBadge;
@property (nonatomic, strong) NSString *store;
@property (nonatomic, strong) NSNumber *isMessageBadge;
@property (nonatomic, strong) NSNumber *isRead;
@property (nonatomic, strong) NSString * faceBackId;
@property (nonatomic, strong) NSString * allContent;
@property (nonatomic, strong) NSString * username;

+(BOOL)createByApnsInfo:(NSDictionary *)info outputArrayIds:(NSMutableArray*)outputArrayIds;

/*
+(MessageRecord *)createByJSON:(NSString *)jsonString;
*/
+(void)createModuleBadge:(NSString *)identifier num:(int)num;

+(NSArray *)findForModuleIdentifier:(NSString *)moduleName;

+(NSArray *)findSystemRecord;

+(int)countForModuleIdentifierAtBadge:(NSString *)identifier;

+(void)dismissModuleBadge:(NSString *)identifier;

+(int)countAllAtBadge;
+(MessageRecord *) findMessageRecordByRecordId:(NSString*)recordId;
+(MessageRecord*) findMessageRecordByAnounceId:(NSString *)announceId;
@end
