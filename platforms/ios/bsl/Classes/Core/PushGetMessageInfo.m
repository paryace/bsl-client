//
//  PushGetMessageInfo.m
//  cube-ios
//
//  Created by 东 on 8/8/13.
//
//

#import "PushGetMessageInfo.h"
#import "UIDevice+IdentifierAddition.h"
#import "JSONKit.h"
#import "MessageRecord.h"
#import "HTTPRequest.h"
#import "Announcement.h"

#import "NSManagedObject+Repository.h"

static PushGetMessageInfo* instance=nil;

@interface PushGetMessageInfo()
-(void)startTimer:(BOOL)callNow;
-(void)sendFeedBack:(NSMutableArray*)outputArrayIds;
-(BOOL)checkIsAnnouncementAndInsert:(NSDictionary *)data;
@end

@implementation PushGetMessageInfo

+(PushGetMessageInfo*)sharedInstance{
    if(instance==nil)
        instance=[[PushGetMessageInfo alloc] init];
    return instance;
}

-(void)dealloc{
    [request cancel];
    [updateTimer invalidate];
}

-(void)startTimer:(BOOL)callNow{
    [request cancel];
    request=nil;
    [updateTimer invalidate];
    updateTimer=nil;

    if(callNow){
        updateTimer=[NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(updatePushMessage) userInfo:nil repeats:NO];
    }
    else{
        updateTimer=[NSTimer scheduledTimerWithTimeInterval:300.0f target:self selector:@selector(updatePushMessage) userInfo:nil repeats:NO];
    }
}

-(void)sendFeedBack:(NSMutableArray*)outputArrayIds{

    /*
    for(NSString* sendId in outputArrayIds){
        FormDataRequest *formDataRequest = [FormDataRequest requestWithURL:[NSURL URLWithString:kPushServerReceiptsUrl]];
        
        formDataRequest.timeOutSeconds=5.0f;
        formDataRequest.persistentConnectionTimeoutSeconds=5.0f;
        [formDataRequest setPostValue:sendId  forKey:@"sendId"];
        NSString * uuid = [[UIDevice currentDevice] uniqueDeviceIdentifier];
        [formDataRequest setPostValue:uuid forKey:@"deviceId"];
        [formDataRequest setPostValue:kAPPKey forKey:@"appKey"];
        [formDataRequest setRequestMethod:@"PUT"];
        [formDataRequest startAsynchronous];
        __block FormDataRequest *__formDataRequest=formDataRequest;
        [formDataRequest setCompletionBlock:^{
            
            NSLog(@"result:%@",[__formDataRequest responseString]);
            [__formDataRequest cancel];
        }];
        
        [formDataRequest setFailedBlock:^{
            NSLog(@"result:%@",[__formDataRequest responseString]);
            [__formDataRequest cancel];
        }];
    }
     */
    
    
    NSMutableString* ids=[[NSMutableString alloc] initWithCapacity:1];
    
    [outputArrayIds enumerateObjectsUsingBlock:^(id obj,NSUInteger index,BOOL *stop){
    
        [ids appendString:obj];
        if(index<[outputArrayIds count]-1)
            [ids appendString:@","];
    }];
    
    FormDataRequest *formDataRequest = [FormDataRequest requestWithURL:[NSURL URLWithString:kPushServerReceiptsUrl]];
    
    formDataRequest.timeOutSeconds=5.0f;
    formDataRequest.persistentConnectionTimeoutSeconds=5.0f;
    [formDataRequest setPostValue:ids  forKey:@"sendId"];
    NSString * uuid = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    [formDataRequest setPostValue:uuid forKey:@"deviceId"];
    [formDataRequest setPostValue:kAPPKey forKey:@"appId"];
    [formDataRequest setRequestMethod:@"PUT"];
    [formDataRequest startAsynchronous];
    __block FormDataRequest *__formDataRequest=formDataRequest;
    [formDataRequest setCompletionBlock:^{
    
        NSLog(@"result:%@",[__formDataRequest responseString]);
        [__formDataRequest cancel];
    }];
    
    [formDataRequest setFailedBlock:^{
        NSLog(@"result:%@",[__formDataRequest responseString]);
        [__formDataRequest cancel];
    }];

    ids=nil;
    
}

-(void)updatePushMessage{
    [request cancel];
    request=nil;
    [updateTimer invalidate];
    updateTimer=nil;
    NSString* token = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
    
    if (token && [token length] > 0 ) {
        NSString* deviceId = [[UIDevice currentDevice] uniqueDeviceIdentifier];
        NSString* requestUrl = [NSString stringWithFormat:@"%@/%@/%@/%@",kPushGetMessageUrl,token,deviceId,kAPPKey];
        
        request = [HTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
        __block HTTPRequest* __request=request;
        __block PushGetMessageInfo* objSelf=self;
        [request setCompletionBlock:^{

            BOOL startNow=NO;
            if (__request.responseStatusCode != 500) {
                NSData *data = [__request responseData];
                NSMutableArray * messageArray = [data objectFromJSONData];
                NSMutableArray* outputArrayIds=[[NSMutableArray alloc] init];
                BOOL hasAnnouncemnt=NO;
                //FMDB 事务
                for (NSDictionary* dictionary in messageArray) {
                    if([MessageRecord createByApnsInfo:dictionary outputArrayIds:outputArrayIds]){
                        BOOL ret=[objSelf checkIsAnnouncementAndInsert:dictionary];
                        if(!hasAnnouncemnt)
                            hasAnnouncemnt=ret;
                    }                    
                }
                if([outputArrayIds count]>0)
                    [objSelf sendFeedBack:outputArrayIds];
                if([MessageRecord.managedObjectContext hasChanges]){
                    [MessageRecord.managedObjectContext save:nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_RECORD_DID_SAVE_NOTIFICATION object:nil];

                }
                if(hasAnnouncemnt){
                    [[NSNotificationCenter defaultCenter] postNotificationName:ANNOUNCEMENT_DID_SAVE_NOTIFICATION object:nil];
                }

                startNow=([messageArray count]>0);
            }
            [objSelf startTimer:startNow];
        }];
        [request setFailedBlock:^{
            [objSelf startTimer:NO];
        }];
        [request startAsynchronous];
    }

}

-(BOOL)checkIsAnnouncementAndInsert:(NSDictionary *)data{
    
    if([[data objectForKey:@"messageType"] isEqualToString:@"MODULE"]){
        NSDictionary *module = [data objectForKey:@"extras"];
        if (module && [[module objectForKey:@"moduleIdentifer"] isEqualToString:@"com.foss.announcement"]) {
            [Announcement requestAnnouncement:data];
        }
        return YES;
    }
    return NO;
}


@end
