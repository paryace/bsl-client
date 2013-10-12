//
//  ChatImageCell.h
//  cube-ios
//
//  Created by apple2310 on 13-9-9.
//
//

#import <UIKit/UIKit.h>
#import "ChatCell.h"


@class ChatImageCell;
@class ImageDownloadedView;

@protocol ChatImageCellDelegate <NSObject>

-(void)chatImageCellDidSelect:(ChatImageCell*)cell url:(NSString*)url;

@end

@interface ChatImageCell : UITableViewCell{
    ImageDownloadedView* imageView;

    UIButton* avatorView;
    UIImageView* bubbleView;
    UILabel* nameLabel;

    ImageDownloadedView* contentImageView;
    
    UILabel* dateLabel;

}
@property(nonatomic,weak) id<ChatImageCellDelegate> delegate;
+(float)cellHeight:(NSBubbleType)bubbleType;
-(void)headerUrl:(NSString*)headerUrl name:(NSString*)name imageFile:(NSString*)imageFile sendDate:(NSDate*)date bubbleType:(NSBubbleType)bubbleType;

@end
