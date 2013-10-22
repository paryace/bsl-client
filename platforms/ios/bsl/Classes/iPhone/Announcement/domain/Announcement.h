//
//  Announcement.h
//  Cube-iOS
//
//  Created by chen shaomou on 2/5/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define ANNOUNCEMENT_DID_SAVE_NOTIFICATION @"message_record_did_save_notification"


@interface Announcement : NSManagedObject

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSNumber * state;
@property (nonatomic, strong) NSString * activeTime;
@property (nonatomic, strong) NSString * invalidTime;
@property (nonatomic, strong) NSNumber * level;
@property (nonatomic, strong) NSString * attachment;
@property (nonatomic, strong) NSString * applicationId;
@property (nonatomic, strong) NSString * announcementId;
@property (nonatomic, strong) NSString * createdAt;
@property (nonatomic, strong) NSString * modifiedAt;
@property (nonatomic, strong) NSNumber * isRead;
@property (nonatomic, strong) NSDate * reviceTime;
@property (nonatomic,strong) NSString* recordId;
@property (nonatomic,strong) NSString *username;

+(void)requestAnnouncement:(NSDictionary*)data;
+(NSArray *)findAllOrderByReviceTime;


@end
