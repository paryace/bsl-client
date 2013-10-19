//
//  ChatPanel.h
//  WeChat
//
//  Created by apple2310 on 13-9-5.
//  Copyright (c) 2013年 apple2310. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChatPanel;
@class EmoctionPanel;
@class CameraPanel;
@class ScrollTextView;

@protocol ChatPanelDelegate <NSObject>
-(void)chatPanelDidSend:(ChatPanel*)chatPanel;
-(void)chatPanelRecordTouch:(ChatPanel*)chatPanel isTouch:(BOOL)touch;
-(void)chatPanelRecordCancel:(ChatPanel*)chatPanel;
-(void)chatPanelDidSelectedAdd:(ChatPanel*)chatPanel;
@end

@interface ChatPanel : UIView{
    
    UIImageView* chatPanelBgView;
    UIButton* chatButton;
    UIImageView*  textBgView;
    UIButton* recordButton;
    UIView* textView;
    UIButton* emoctionButton;
    UIButton* addButton;
    
    UILabel* msgLabel;
    
    EmoctionPanel* emoctionPanel;
    CameraPanel* camerPanel;
    
    float currentHeight;
}

@property(nonatomic,weak) id<ChatPanelDelegate> delegate;
@property(nonatomic,assign) NSUInteger limitMaxNumber;
@property(nonatomic,strong) NSString* text;
@property(nonatomic,strong) NSDictionary* emoctionList;
@property(nonatomic,assign) float superViewHeight;
@property(nonatomic,assign) BOOL cancelRecond;

@property(nonatomic,assign) BOOL onlineStatus;
@property(nonatomic,assign) BOOL quitStatus;

-(float)panelHeight;

-(void)disableChatButton;

-(void)checkAllControlPanel;

@end
