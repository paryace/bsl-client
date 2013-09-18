//
//  RoomService.m
//  cube-ios
//
//  Created by 肖昶 on 13-9-17.
//
//

#import "RoomService.h"
#import "XMPPRoom.h"
#import "XMPPRoomCoreDataStorage.h"



@implementation RoomService

@synthesize roomID;
@synthesize room;
@synthesize roomName;

-(void)dealloc{
    [self tearDown];
}

-(void)joinRoomServiceWithRoomID:(NSString*)__roomID
{
    XMPPRoom* newRoom=[[XMPPRoom alloc]initWithRoomStorage:[XMPPRoomCoreDataStorage sharedInstance] jid:[XMPPJID jidWithString:__roomID]];
    self.room=newRoom;
    
    [self.room activate:[self getCurrentStream]];
    [self.room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    if ([self.room preJoinWithNickname:[self getCurrentUserName]]){
        [self.room joinRoomUsingNickname:[self getCurrentUserName] history:nil];
    }
    
    [self performSelector:@selector(ConfigureNewRoom:) withObject:self.room afterDelay:0];
}


-(void)initRoomServce{
    XMPPRoom* newRoom=[[XMPPRoom alloc]initWithRoomStorage:[XMPPRoomCoreDataStorage sharedInstance] jid:[XMPPJID jidWithString:[self getGenerateUUID]]];
    self.room=newRoom;
    [self.room activate:[self getCurrentStream]];
    [self.room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    if ([self.room preJoinWithNickname:[self getCurrentUserName]])
    {
        [self.room joinRoomUsingNickname:[self getCurrentUserName] history:nil];
    }
    //    [self ConfigureNewRoom:_room];
    [self performSelector:@selector(ConfigureNewRoom:) withObject:self.room afterDelay:1];
}

////配置room
-(void)ConfigureNewRoom:(XMPPRoom *)sender
{
    [sender fetchConfigurationForm];
    [sender configureRoomUsingOptions:nil];
    self.roomID =[NSString stringWithFormat:@"%@",sender.myRoomJID.bare];
    self.roomName=[NSString stringWithFormat:@"%@",sender.roomJID];
}

-(NSString*)getGenerateUUID
{
    XMPPStream *stream = [self getCurrentStream];
    NSString *newMUCStr =[NSString stringWithFormat:@"%@@%@",[stream generateUUID],kMUCSevericeDomin];
    return newMUCStr;
}

-(XMPPStream*)getCurrentStream
{
    XMPPStream *stream = [ShareAppDelegate xmpp].xmppStream;
    return stream;
}

-(NSString*)getCurrentUserName
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"username"];
}



-(void)tearDown
{
    [self.room removeDelegate:self];
    [self.room deactivate];
    self.room=nil;
}

#pragma RoomDelegate

- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    self.roomID =[NSString stringWithFormat:@"%@",sender.myRoomJID.bare];
    self.roomName=[NSString stringWithFormat:@"%@",sender.roomJID];

    if (self.roomDidCreateBlock) {
        self.roomDidCreateBlock(self.room);
        self.roomDidCreateBlock=nil;
    }
    
}
- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult
{
    //    if([iqResult.type isEqualToString:@"result"])
    //    {
    //
    //    }
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    if (self.roomDidJoinBlock) {
        self.roomDidJoinBlock();
        self.roomDidJoinBlock=nil;
    }
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    
    NSString* msg =[NSString stringWithFormat:@"%@,加入了会议室", [occupantJID bare]];
    NSLog(@"===[%@]",msg);
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    
}

- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult
{
    NSLog(@"认证失败");
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items
{
    NSLog(@"didFetchMembersList:[%@]",items);
}
- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items
{
    NSLog(@"didFetchBanList:[%@]",items);
}
- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items
{
    NSLog(@"didFetchModeratorsList:[%@]",items);
}

@end
