//
//  MessageRecordCell.h
//  bsl
//
//  Created by 肖昶 on 13-10-11.
//
//

#import <UIKit/UIKit.h>

@interface MessageRecordCell :UITableViewCell{
    UIView* bgView;
    UILabel* titleLabel;
    UILabel* contentLabel;
    UILabel* isReadLabel;
    UILabel* timeLabel;
}

+(float)cellHeight:(NSString*)content width:(float)w;

-(void)title:(NSString*)title content:(NSString*)content time:(NSDate*)time isRead:(BOOL)isRead;

@end
