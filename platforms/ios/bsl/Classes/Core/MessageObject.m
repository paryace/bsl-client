//
//  MessageObject.m
//  cube-ios
//
//  Created by zhoujun on 13-8-27.
//
//

#import "MessageObject.h"
#import "ASIFormDataRequest.h"
#import "UIDevice+IdentifierAddition.h"
@implementation MessageObject
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
@dynamic isRead;
@dynamic faceBackId;
@dynamic allContent;

- (void)sendFeedBack{
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kPushServerReceiptsUrl]];
    if (self.faceBackId) {
        [request setPostValue:self.faceBackId  forKey:@"sendId"];
    }
    
    NSString * uuid = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    [request setPostValue:uuid forKey:@"deviceId"];
    [request setPostValue:kAPPKey forKey:@"appKey"];
    [request setRequestMethod:@"PUT"];
    [request startAsynchronous];
    
}
-(void)showAlert{
    UILocalNotification * localAlert = [[UILocalNotification alloc]init];
    localAlert.alertBody = self.alert;
    localAlert.alertAction = @"确定";
    [[UIApplication sharedApplication] scheduleLocalNotification:localAlert];
    localAlert=nil;
}
@end
