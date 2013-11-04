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
@interface AnnouncementTableViewCell : UITableViewCell{
    UIView* bgView;
    UILabel* titleLabel;
    UILabel* contentLabel;
    UILabel* isReadLabel;
    UILabel* timeLabel;
    UIView* lineView;
    UIView *attachView;
}

+(float)cellHeight:(NSString*)title content:(NSString*)content width:(float)w ;

-(void)title:(NSString*)title content:(NSString*)content time:(NSDate*)time isRead:(BOOL)isRead;
-(void)title:(NSString*)title content:(NSString*)content time:(NSDate*)time isRead:(BOOL)isRead withAttachment:(NSString*)files;


@end
