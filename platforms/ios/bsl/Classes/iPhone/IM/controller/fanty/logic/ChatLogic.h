//
//  ChatLogic.h
//  cube-ios
//
//  Created by apple2310 on 13-9-7.
//
//

#import <Foundation/Foundation.h>
@class FormDataRequest;
@interface ChatLogic : NSObject{
//    FormDataRequest * request;
    
}

@property(nonatomic,strong) NSString* roomJID;


-(void)cancel;
-(BOOL)checkTheGroupIsConnect:(BOOL)isGroup;

-(void)sendNotificationMessage:(NSString* )content messageId:(NSString*)messageId isGroup:(BOOL)isGroup name:(NSString*)name onlyUpdateChat:(BOOL)onlyUpdateChat;

-(BOOL)sendMessage:(NSString* )content messageId:(NSString*)messageId isGroup:(BOOL)isGroup name:(NSString*)name;

-(BOOL)sendfile:(NSString* )content messageId:(NSString*)messageId isGroup:(BOOL)isGroup name:(NSString*)name;


-(BOOL)sendRoomQuitAction:(NSString*)messageId isMyGroup:(BOOL)isMyGroup;

-(BOOL)sendRoomQuitMemberAction:(NSString*)messageId userJid:(NSString*)userJid;

-(BOOL)uploadImageToServer:(UIImage*)image finish:(void (^)(NSString* fileId))finish;


-(BOOL)isInFaviorContacts:(NSString*)chatWithUser;
-(void)addFaviorInContacts:(NSString*)chatWithUser;
-(void)addFaviorersInContacts:(NSArray *)users;
-(void)removeFaviorInContacts:(NSString*)chatWithUser;


@end

