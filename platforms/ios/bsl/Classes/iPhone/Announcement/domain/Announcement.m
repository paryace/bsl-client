//
//  Announcement.m
//  Cube-iOS
//
//  Created by chen shaomou on 2/5/13.
//
//

#import "Announcement.h"
#import "ConfigManager.h"
#import "HTTPRequest.h"
#import "NSObject+propertyList.h"
#import "NSManagedObject+Repository.h"


@implementation Announcement

@dynamic title;

@dynamic content;

/**
 * 公告状态
 * 0: 未生效
 * 1：已生效
 * 2：已过期
 * 3：已失效
 */
@dynamic state;

@dynamic activeTime;

@dynamic invalidTime;

/**
 * 重要级别
 * 0: 一般
 * 1: 重要
 * 2: 紧急
 */
@dynamic level;

@dynamic attachment;

@dynamic applicationId;

@dynamic announcementId;

@dynamic createdAt;

@dynamic modifiedAt;

@dynamic isRead;

@dynamic reviceTime;
@dynamic recordId;
@dynamic username;
+(void)requestAnnouncement:(NSDictionary*)data{
    NSDictionary *module = [data objectForKey:@"extras"];
    NSString* recordId=nil;
    if (module) {
        recordId=[module objectForKey:@"announceId"];
    }
    
    Announcement *announcement = [Announcement insert];

    NSArray *propertyList = [announcement getPropertyList];
        
    for(NSString *each in propertyList){
        if([data objectForKey:each] && ![[data objectForKey:each] isEqual:[NSNull null]] ){
            if (![each isEqualToString:@"level"]) {
                [announcement setValue:[data objectForKey:each] forKey:each];
            }
        }
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults valueForKey:@"username"];
    
    [announcement setRecordId:recordId];
    //id 要另外设定
    [announcement setAnnouncementId:[data objectForKey:@"id"]];
    [announcement setIsRead:0];
    [announcement setUsername:username];
    [announcement setReviceTime:[NSDate date]];
}



+(NSArray *)findAllOrderByReviceTime{
    
    //NSArray *array = [Announcement findAll];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults valueForKey:@"username"];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"reviceTime" ascending:NO];
    return  [Announcement findByPredicate:[NSPredicate predicateWithFormat:@"username=%@",username] sortDescriptors:[NSArray arrayWithObject:sort]];
    
}


@end
