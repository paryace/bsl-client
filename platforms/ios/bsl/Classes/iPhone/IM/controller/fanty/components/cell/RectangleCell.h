//
//  RectangleCell.h
//  WeChat
//
//  Created by apple2310 on 13-9-4.
//  Copyright (c) 2013年 apple2310. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    RectangleCellTypeMessage=0,
    RectangleCellTypeImage,
    RectangleCellTypeVoice
}RectangleCellType;

@class ImageDownloadedView;
@class NumberView;
@interface RectangleCell : UITableViewCell{
    UIImageView* bgView;
    ImageDownloadedView* imageView;
    NumberView* numberView;
    UILabel* titleLabel;
    UILabel* contentLabel;
    UIImageView* contentImageView;
    UILabel* dateLabel;
    UIImageView* lineView;
}

-(void)headerUrl:(NSString*)headerUrl title:(NSString*)title content:(NSString*)content date:(NSDate*)date;

-(void)number:(int)number;

-(void)rectangleType:(RectangleCellType)type;

+(float)height;

@end
