//
//  AnnouncementTableViewCell.m
//  Cube-iOS
//
//  Created by chen shaomou on 2/5/13.
//
//

#define OFFSET 30.0f

#import "AnnouncementTableViewCell.h"
#import "UIColor+expanded.h"

@implementation AnnouncementTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        bgView=[[UIView alloc] init];
        bgView.backgroundColor=[UIColor clearColor];
        bgView.clipsToBounds=YES;
        [self addSubview:bgView];
        
        titleLabel=[[UILabel alloc] init];
        titleLabel.numberOfLines=0;
        titleLabel.font=[UIFont boldSystemFontOfSize:19.0f];
        titleLabel.backgroundColor=[UIColor clearColor];
        titleLabel.textColor=[UIColor blackColor];
        [bgView addSubview:titleLabel];
        
        
        contentLabel=[[UILabel alloc] init];
        contentLabel.numberOfLines=0;
        contentLabel.font=[UIFont systemFontOfSize:16.0f];
        contentLabel.backgroundColor=[UIColor clearColor];
        contentLabel.textColor=[UIColor blackColor];
        [bgView addSubview:contentLabel];
        
        isReadLabel=[[UILabel alloc] init];
        isReadLabel.numberOfLines=1;
        isReadLabel.textAlignment=NSTextAlignmentRight;
        isReadLabel.font=[UIFont boldSystemFontOfSize:15.0f];
        isReadLabel.backgroundColor=[UIColor clearColor];
        isReadLabel.textColor=[UIColor blackColor];
        [bgView addSubview:isReadLabel];
        
        
        lineView=[[UIView alloc] init];
        lineView.backgroundColor=[UIColor lightGrayColor];
        [bgView addSubview:lineView];
        

        timeLabel=[[UILabel alloc] init];
        timeLabel.numberOfLines=1;
        timeLabel.textAlignment=NSTextAlignmentRight;
        timeLabel.font=[UIFont systemFontOfSize:15.0f];
        timeLabel.backgroundColor=[UIColor clearColor];
        timeLabel.textColor=[UIColor blackColor];
        [bgView addSubview:timeLabel];
        
    }
    return self;
}

+(float)cellHeight:(NSString*)title content:(NSString*)content width:(float)w{
    
    float offset=OFFSET;
    CGRect isReadLabelFrame=CGRectMake(w-35.0f-OFFSET, 10.0f, 35.0f, 25.0f);

    UILabel* titleLabel=[[UILabel alloc] init];
    titleLabel.numberOfLines=0;
    titleLabel.font=[UIFont boldSystemFontOfSize:19.0f];
    
    titleLabel.frame=CGRectMake(offset, 10.0f, CGRectGetMinX(isReadLabelFrame)-offset, 25.0f);
    titleLabel.text=title;
    [titleLabel sizeToFit];
    
    UILabel* contentLabel=[[UILabel alloc] initWithFrame:CGRectMake(offset, CGRectGetMaxY(titleLabel.frame)+5.0f, w-offset*2.0f, 0.0f)];
    contentLabel.numberOfLines=0;
    contentLabel.font=[UIFont systemFontOfSize:16.0f];
    contentLabel.text=content;
    [contentLabel sizeToFit];

    
    float height=CGRectGetMaxY(contentLabel.frame)+3.0f+35.0f;
    titleLabel=nil;
    contentLabel=nil;
    return height;
    
}

-(void)title:(NSString*)title content:(NSString*)content time:(NSDate*)time isRead:(BOOL)isRead {
    titleLabel.text=title;
    contentLabel.text=content;
    
    if(!isRead){
        isReadLabel.text=@"未读";
        isReadLabel.textColor = [UIColor redColor];
    }else{
        isReadLabel.text=@"已读";
        isReadLabel.textColor = [UIColor blackColor];
    }
    
    NSTimeInterval timeGap = [[NSDate date] timeIntervalSinceDate:time];
    
    if(timeGap < 60){
        
        [timeLabel setText:[NSString stringWithFormat:@"%d 秒前",(int)timeGap]];
    }
    
    else if(timeGap > 60 && timeGap < 60*60){
        
        [timeLabel setText:[NSString stringWithFormat:@"%d 分钟前",(int)(timeGap/60)]];
    }
    
    else if(timeGap >  60*60 && timeGap < 60*60*24){
        
        [timeLabel setText:[NSString stringWithFormat:@"%d 小时前",(int)(timeGap/(60*60))]];
    }
    
    else{
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm"];
        timeLabel.text=[df stringFromDate:time];

    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect rect=self.bounds;
    rect.size.height-=15.0f;
    bgView.frame=rect;

    float w=self.frame.size.width;
    
    if(self.showingDeleteConfirmation){
        w-=50.0f;
    }
    
    float offset=OFFSET;
    if(self.editing){
        offset+=40.0f;
    }
    
    
    isReadLabel.frame=CGRectMake(w-35.0f-OFFSET, 10.0f, 35.0f, 25.0f);
    titleLabel.frame=CGRectMake(offset, 10.0f, CGRectGetMinX(isReadLabel.frame)-offset, 0.0f);
    [titleLabel sizeToFit];
    
    if(!self.editing)
        lineView.frame=CGRectMake(offset,CGRectGetMaxY(titleLabel.frame)+2.0f,w-offset*2.0f,1);
    else
        lineView.frame=CGRectMake(offset,CGRectGetMaxY(titleLabel.frame)+2.0f,w-OFFSET*2.0f-40.0f,1);

    contentLabel.frame=CGRectMake(offset, CGRectGetMaxY(titleLabel.frame)+5.0f, w-offset*2.0f, 0.0f);
    [contentLabel sizeToFit];
    
    timeLabel.frame=CGRectMake(w-150.0f-OFFSET, CGRectGetMaxY(contentLabel.frame)+3.0f, 150.0f, 20.0f);

}

@end
