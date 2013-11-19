//
//  AnnouncementTableViewCell.h
//  Cube-iOS
//
//  Created by chen shaomou on 2/5/13.
//
//

#import <UIKit/UIKit.h>
#import "Announcement.h"
#import "JSONKit.h"
#import "CubeWebViewController.h"
@protocol OpenAttachmentDelegate
@required
-(void)openFile:(NSString*)attachmentId;
@end
@interface AnnouncementTableViewCell : UITableViewCell<UIAlertViewDelegate>{
    UIView* bgView;
    UILabel* titleLabel;
    UILabel* contentLabel;
    UILabel* isReadLabel;
    UILabel* timeLabel;
    UIView* lineView;
    UIView *attachView;
    NSString *currentFileId;
    __unsafe_unretained id <OpenAttachmentDelegate> delegate;
}
@property(nonatomic,assign)id <OpenAttachmentDelegate> delegate;
+(float)cellHeight:(NSString*)title content:(NSString*)content width:(float)w ;
+(float)cellHeight:(NSString*)title content:(NSString*)content width:(float)w attachments:(NSString *)attachments;
-(void)title:(NSString*)title content:(NSString*)content time:(NSDate*)time isRead:(BOOL)isRead;
-(void)title:(NSString*)title content:(NSString*)content time:(NSDate*)time isRead:(BOOL)isRead withAttachment:(NSString*)files;


@end
