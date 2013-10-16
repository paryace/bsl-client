//
//  ContactCell.h
//  WeChat
//
//  Created by apple2310 on 13-9-4.
//  Copyright (c) 2013年 apple2310. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ImageDownloadedView;

@interface ContactCell : UITableViewCell{
    UIImageView* bgView;
    ImageDownloadedView* imageView;
    UILabel* nicknameLabel;
    UIImageView* lineView;
}

-(void)headerUrl:(NSString*)headerUrl nickname:(NSString*)nickname;

+(float)height;


-(void)loadingImage:(NSString*)imageName;

@end
