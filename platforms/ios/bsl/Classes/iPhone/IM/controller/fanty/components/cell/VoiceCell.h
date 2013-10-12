//
//  VoiceCell.h
//  cube-ios
//
//  Created by apple2310 on 13-9-9.
//
//

#import <UIKit/UIKit.h>
#import "ChatCell.h"

@class ImageDownloadedView;
@interface VoiceCell : UITableViewCell{
    ImageDownloadedView* imageView;
    UILabel* nameLabel;
    UIImageView* noHeaderView;
    UIButton* button;
    UIImageView* voiceImageView;
    UILabel* dateLabel;
    UIView* statusView;
    float voiceWidth;
}

@property(nonatomic,assign)NSBubbleType type;
@property(nonatomic,assign)int status;

-(void)headerUrl:(NSString*)headerUrl;
-(void)voiceLength:(float)voiceLegth animate:(BOOL)animate;
-(void)playAnimated:(BOOL)play;
-(void)name:(NSString*)name;
-(void)sendDate:(NSDate*)date;
+(float)cellHeight:(NSBubbleType)type;

-(void)addVoiceButton:(id)target action:(SEL)action;

@end
