//
//  MessageObject.h
//  cube-ios
//
//  Created by zhoujun on 13-8-27.
//
//

#import <Foundation/Foundation.h>

@interface MessageObject : NSManagedObject

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
@property (nonatomic, strong) NSString* allContent;
- (void)sendFeedBack;
-(void)showAlert;
@end
