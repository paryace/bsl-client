//
//  AnnouncementTableViewCell.h
//  Cube-iOS
//
//  Created by chen shaomou on 2/5/13.
//
//

#import <UIKit/UIKit.h>
#import "Announcement.h"

@interface AnnouncementTableViewCell : UITableViewCell{
    UIView* bgView;
    UILabel* titleLabel;
    UILabel* contentLabel;
    UILabel* isReadLabel;
    UILabel* timeLabel;
    UIView* lineView;
}

+(float)cellHeight:(NSString*)content width:(float)w editing:(BOOL)editing ;

-(void)title:(NSString*)title content:(NSString*)content time:(NSDate*)time isRead:(BOOL)isRead;

@end
