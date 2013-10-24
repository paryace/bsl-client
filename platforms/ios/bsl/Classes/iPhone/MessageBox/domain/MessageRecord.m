//
//  MessageRecord.m
//  Cube-iOS
//
//  Created by chen shaomou on 2/1/13.
//
//

#import "MessageRecord.h"
#import "CubeCommandDispatcher.h"
#import "HTTPRequest.h"
#import "Announcement.h"
#import "ConfigManager.h"
#import "HTTPRequest.h"
#import "UIDevice+IdentifierAddition.h"
#import "MessageObject.h"
#import "MessageDelayHandler.h"

@implementation MessageRecord
@dynamic alert;
@dynamic sound;
@dynamic badge;
@dynamic module;
@dynamic recordId;
@dynamic content;
@dynamic reviceTime;
@dynamic isIconBadge;
@dynamic store;
@dynamic isMessageBadge;
@dynamic faceBackId;
@dynamic isRead;
@dynamic allContent;
@dynamic username;

+(BOOL)createByApnsInfo:(NSDictionary *)info outputArrayIds:(NSMutableArray*)outputArrayIds{
    NSString * mFaceBackId = [info objectForKey:@"sendId"];
    BOOL ret=NO;
   
    if (![mFaceBackId isEqual:[NSNull null]] && [mFaceBackId length]>0) {
        
        [outputArrayIds addObject:mFaceBackId];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults valueForKey:@"username"];
        
        //通过sendID在数据库中判断是否存在记录
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"faceBackId==%@",mFaceBackId];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MessageRecord"];
        [fetchRequest setPredicate:predicate];
        NSArray *fetchedPersonArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        MessageRecord *message = nil;
        //如果数据库中存在记录
        if (fetchedPersonArray.count>0) {
//            [[fetchedPersonArray objectAtIndex:0] sendFeedBack];
        }else{
            ret=YES;
            message  = (MessageRecord *)[NSEntityDescription insertNewObjectForEntityForName:@"MessageRecord" inManagedObjectContext:self.managedObjectContext];

            NSDictionary *aps = [info objectForKey:@"aps"];
            NSString* alert = [aps objectForKey:@"alert"];
            if ([alert length]<1) {
                alert = [info objectForKey:@"title"];
            }
            [message setAlert:alert];
            [message setSound:[aps objectForKey:@"sound"]];
            [message setBadge:[aps objectForKey:@"badge"]];
            [message setUsername:username];
            [message setFaceBackId:mFaceBackId];
            //设置消息未读 add by zhoujun begin
            [message setIsRead:[NSNumber numberWithBool:NO]];
            //edit end
            NSString* messageType = [info objectForKey:@"messageType"];
            if ([messageType isEqualToString:@"SYS"] ) {
                
            }else if ([messageType isEqualToString:@"MODULE"] ) {
                NSDictionary *module = [info objectForKey:@"extras"];
                
                if (module) {
                   
                    message.allContent =[NSString stringWithFormat:@"%d", [[module objectForKey:@"busiDetail"]  intValue]] ;
                    NSNumber* num = [module objectForKey:@"moduleBadge"];
                    NSString* identifier =   [module objectForKey:@"moduleIdentifer"];
                    CubeApplication* cubeApp = [CubeApplication currentApplication];
                    CubeModule* module1 = [cubeApp moduleForIdentifier:identifier];
                    if ([num boolValue]) {
                        if (module1) {
                            module1.moduleBadge = @"";
                        }
                    }else{
                        if (module1) {
                            module1.moduleBadge = @"1";
                        }
                    }
                    [message setModule:[module objectForKey:@"moduleIdentifer"]];
                    [message setRecordId:[module objectForKey:@"announceId"]];
                }
            }
            id content = [info objectForKey:@"content"];
            if([content isKindOfClass:[NSDictionary class]]){
                @autoreleasepool {
                    NSData *data = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    [message setContent:string];
                    
                }
            }
            else if([content isKindOfClass:[NSString class]]){
                [message setContent:content];
            }
            [message setReviceTime:[NSDate date]];
            
            [message setIsIconBadge:[NSNumber numberWithInt:1]];
            [message setIsMessageBadge:[NSNumber numberWithInt:1]];
//            [message save];
            //将消息添加到队列begin=====
//            [[MessageDelayHandler shareInstance]addToQueue:message];
            //end====
//            [message sendFeedBack];
            
            [message showAlert];
           [MessageRecord isCommand:info];
            
//            [MessageRecord isAnnouncement:info];
        }
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        NSString *module = message.module;
        NSString *lastReceiveTime = [appDelegate.moduleReceiveMsg objectForKey:module];
        
        long lrt = [lastReceiveTime longLongValue];
        
        long now = [[NSDate date] timeIntervalSince1970];
        
        if(!lastReceiveTime || now - lrt > 5){//第一次收到该模块消息,或超过十秒
            //播放系统短信提示音
//            [appDelegate ativatePushSound];
            
            NSString *nowStr = [NSString stringWithFormat:@"%ld",now];
            if(module){
                [appDelegate.moduleReceiveMsg setValue:nowStr forKey:module];
            }
            else{
                [appDelegate.moduleReceiveMsg setValue:nowStr forKey:@"系统"];
            }
        }
    }
    
    return ret;
}

/*
+(MessageRecord *)createByJSON:(NSString *)jsonString{
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    MessageRecord *message = [MessageRecord insert];
    
    [message setAlert:[dictionary objectForKey:@"alert"]];
    
    [message setSound:[dictionary objectForKey:@"sound"]];
    
    [message setBadge:[dictionary objectForKey:@"badge"]];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = message.badge.intValue;
    
    [message setModule:[[dictionary objectForKey:@"data"] objectForKey:@"module"]];
    
    id content = [[dictionary objectForKey:@"data"] objectForKey:@"content"];
    
    if([content isKindOfClass:[NSDictionary class]]){
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:nil];
        
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        [message setContent:string];
        
    }
    
    if([content isKindOfClass:[NSString class]]){
        
        [message setContent:content];
    }
    
    [message setRecordId:[[dictionary objectForKey:@"data"] objectForKey:@"recordId"]];
    
    [message setReviceTime:[NSDate date]];
    
    [message setIsIconBadge:[NSNumber numberWithInt:1]];
    [message setIsMessageBadge:[NSNumber numberWithInt:1]];
    
    [message save];
    
    [message sendFeedBack];
    
    [message showAlert];
    
    [MessageRecord isCommand:[dictionary objectForKey:@"data"]];
    
    [MessageRecord isAnnouncement:[dictionary objectForKey:@"data"]];
    
    NSDictionary *storeObject = [[dictionary objectForKey:@"data"] objectForKey:@"store"];
    
    if(storeObject){
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *username = [defaults objectForKey:@"username"];
        
        [[[storeObject allValues] objectAtIndex:0] setValue:username forKey:@"phone_user"];
        
        [[[storeObject allValues] objectAtIndex:0] setValue:message.recordId forKey:@"recordId"];
        
        [[MessageRecordManager sharedMessageRecordManager] storeJSONObject:storeObject module:[[dictionary objectForKey:@"data"] objectForKey:@"module"]];
        
    }
    
//    dispatch_sync(dispatch_get_main_queue(), ^{ @autoreleasepool {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_RECORD_DID_SAVE_NOTIFICATION object:message];
        
//    }});
    
    return message;
    
}
 */

+(int)countAllAtBadge{
    
    return [[MessageRecord findAllAtBadge] count];
}

+(NSArray *)findAllAtBadge{
    NSString *username  = [[NSUserDefaults standardUserDefaults]valueForKey:@"username"];
    return [MessageRecord findByPredicate:[NSPredicate predicateWithFormat:@" isMessageBadge=%@ and username=%@",[NSNumber numberWithInt:1],username]];
}

-(void)showAlert{
    UILocalNotification * localAlert = [[UILocalNotification alloc]init];
    localAlert.alertBody = self.alert;
    localAlert.alertAction = @"确定";
    [[UIApplication sharedApplication] scheduleLocalNotification:localAlert];
    localAlert=nil;
}

+(BOOL)isCommand:(NSDictionary *)data{
    
    if([data objectForKey:@"command"]){
        
        [[CubeCommandDispatcher instance] executeCommand:data];
        
        return YES;
    }else{
        
        return NO;
    }
    
}

+(NSArray *)findForModuleIdentifier:(NSString *)identifier{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults valueForKey:@"username"];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"reviceTime" ascending:NO];
    return [MessageRecord findByPredicate:[NSPredicate predicateWithFormat:@"module=%@ and username=%@",identifier,username] sortDescriptors:[NSArray arrayWithObject:sort]];
}

+(int)countForModuleIdentifierAtBadge:(NSString *)identifier{
    if (identifier.length ==0 ) {
        return  0;
    }
    return [[MessageRecord findForModuleIdentifierAtBadge:identifier] count];
}

+(void)dismissModuleBadge:(NSString *)identifier{
    
    if ([identifier isEqualToString:@"com.foss.message.record"]) {
        NSArray * array = [MessageRecord findAllAtBadge];
        
        for(MessageRecord *each in array){
            [each setIsMessageBadge:[NSNumber numberWithInt:0]];
            
            [each save];
        }
        
        return;
    }
    
    @autoreleasepool {
        NSArray *array = [MessageRecord findForModuleIdentifierAtBadge:identifier];
        for(MessageRecord *each in array){
            [each setIsIconBadge:[NSNumber numberWithInt:0]];
        }
        [MessageRecord save];
    }
}

+(void)createModuleBadge:(NSString *)identifier num:(int)num{
    @autoreleasepool {
        NSArray *array = [MessageRecord findForModuleIdentifier:identifier];
        
        if (num >= [array count]) {
            for(MessageRecord *each in array){
                [each setIsIconBadge:[NSNumber numberWithInt:1]];
            }
            for (int i = 0; i < num - [array count]; i++) {
                MessageRecord* message = [MessageRecord insert];
                message.module = identifier ;
                message.isIconBadge = [NSNumber numberWithInt:1];
            }
            [MessageRecord save];
            
        }else{
            [self dismissModuleBadge:identifier];
            
            for (int i = 0; i < num; i++) {
                if ([array count]== 0) {
                    MessageRecord* message = [MessageRecord insert];
                    message.module = identifier ;
                    message.isIconBadge = [NSNumber numberWithInt:1];
                }else{
                    MessageRecord *each = [array objectAtIndex:i];
                    [each setIsIconBadge:[NSNumber numberWithInt:1]];
                }
            }
            [MessageRecord save];
        }
        NSLog(@"badgeChange  ==identifier = %@=== %d",identifier,num);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"module_badgeCount_change" object:self];
    }
}


+(NSArray *)findForModuleIdentifierAtBadge:(NSString *)identifier{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults valueForKey:@"username"];
    
    return [MessageRecord findByPredicate:[NSPredicate predicateWithFormat:@"module=%@ and isIconBadge=%@ and username=%@",identifier,[NSNumber numberWithInt:1],username]];
}

+(NSArray *)findSystemRecord{
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"reviceTime" ascending:NO];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults valueForKey:@"username"];
    
    return [MessageRecord findByPredicate:[NSPredicate predicateWithFormat:@"module=nil and username=%@",username] sortDescriptors:[NSArray arrayWithObject:sort]];
    
}


- (void)sendFeedBack{
    
    FormDataRequest *request = [FormDataRequest requestWithURL:[NSURL URLWithString:kPushServerReceiptsUrl]];
    if (self.faceBackId) {
        
        [request setPostValue:self.faceBackId  forKey:@"sendId"];
    }
    
    
    NSString * uuid = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    [request setPostValue:uuid forKey:@"deviceId"];
    [request setPostValue:kAPPKey forKey:@"appKey"];
    [request setRequestMethod:@"PUT"];
    [request startAsynchronous];
    
}

+(MessageRecord *) findMessageRecordByRecordId:(NSString*)recordId{
    NSArray *array =  [MessageRecord findByPredicate:[NSPredicate predicateWithFormat:@"faceBackId=%@",recordId]];
    if(array && array.count>0)
    {
        return [array objectAtIndex:0];
    }
    return nil;
}

+(MessageRecord*) findMessageRecordByAnounceId:(NSString *)announceId{
    NSArray *array =  [MessageRecord findByPredicate:[NSPredicate predicateWithFormat:@"recordId=%@",announceId]];
    if(array && array.count>0)
    {
        return [array objectAtIndex:0];
    }
    return nil;
}


@end
