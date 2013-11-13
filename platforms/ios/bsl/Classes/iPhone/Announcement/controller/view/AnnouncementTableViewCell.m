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
#import "AttachmentImageView.h"
#import "AttachMents.h"
#import "KxMenueItemExt.h"
@implementation AnnouncementTableViewCell
@synthesize  delegate;
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
        attachView = [[UIView alloc]init];
        attachView.backgroundColor =[UIColor clearColor];
        [bgView addSubview:attachView];
        
        
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

    
    float height=CGRectGetMaxY(contentLabel.frame)+3.0f+40.0f+30.0f;
    titleLabel=nil;
    contentLabel=nil;
    return height;
    
}
-(void)title:(NSString*)title content:(NSString*)content time:(NSDate*)time isRead:(BOOL)isRead withAttachment:(NSString*)files
{
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
    if(!files || files.length==0)
    {
        attachView.hidden =YES;
    }
    else{
        
        NSMutableArray *filesArray = [files objectFromJSONString];
        int i=0;
        for (NSDictionary *dict in filesArray) {
//            NSDictionary *dict1 = [@"{\"fileId\":\"T1IaETBXZT1RCvBVdK\",\"fileName\":\"120.png\",\"fileSize\":22}" objectFromJSONString];
            if([[dict JSONString]objectFromJSONString] == nil)
            {
                NSLog(@"不是json 字符串");
                return;
            }
            NSString*fileName = [dict valueForKey:@"fileName"];
            NSString*fileId = [dict valueForKey:@"fileId"];
            NSString*fileSize =  [dict valueForKey:@"fileSize"];
            AttachMents *attachment = [AttachMents getByPredicate:[NSPredicate predicateWithFormat:@"fileId=%@",fileId]];
            if(!attachment)
            {
                attachment = [AttachMents insert];
                attachment.fileName = fileName;
                attachment.fileId = fileId;
                attachment.fileSize = [NSNumber numberWithFloat:[fileSize floatValue]];
                [attachment downloadFile:fileId];
            }
            //判断文件类型
            UIImage *image;
            if([fileName hasSuffix:@"pdf"])
            {
                image = [UIImage imageNamed:@"pdf_default.png"];
            }
            else if ([fileName hasSuffix:@"txt"])
            {
                image = [UIImage imageNamed:@"txt_default.png"];
            }
            else if ([fileName hasSuffix:@"jpg"] || [fileName hasSuffix:@"png"] || [fileName hasSuffix:@"jpeg"])
            {
                image = [UIImage imageNamed:@"image_default.png"];
            }
            else if([fileName hasSuffix:@"doc"] || [fileName hasSuffix:@"docx"])
            {
                image = [UIImage imageNamed:@"word_default.png"];
            }
            else if ([fileName hasSuffix:@"xls"] || [fileName hasSuffix:@"xlsx"])
            {
                image = [UIImage imageNamed:@"xls_default.png"];
            }
            else
            {
                image = [UIImage imageNamed:@"default_default.png"];
            }
            
            AttachmentImageView *imageview = [[AttachmentImageView alloc]initWithImage:image];
            imageview.fileId = fileId;
            imageview.fileName = fileName;
            imageview.fileSize = fileSize;
            CGRect frame = imageview.frame;
            frame.origin.x = 35*i;
            i++;
            frame.origin.y = 3.5f;
            frame.size.width = 30;
            frame.size.height = 30;
            imageview.frame = frame;
            imageview.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
            tapGesture.numberOfTapsRequired=1;
            [imageview addGestureRecognizer:tapGesture];
            [attachView addSubview:imageview];
            
        }
    }
}

-(void)showMenu:(UITapGestureRecognizer*)sender
{
    AttachmentImageView *view = (AttachmentImageView*)sender.view;
    currentFileId = view.fileId;
    NSString *tips = [NSString stringWithFormat:@"你确定要打开%@?",[view.fileName stringByAppendingFormat:@"(%@kb)",view.fileSize]];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:tips delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alertView show];
//    KxMenueItemExt *item =[KxMenueItemExt menuItem:@"打开"
//                   image:[UIImage imageNamed:@"action_icon"]
//                  target:self
//                  action:@selector(pushMenuItem:)
//                                        attachName:view.fileName attachId:view.fileId attachSize:view.fileSize
//     
//                       ];
//    NSArray *menuItems =
//    @[
//      
//      [KxMenuItem menuItem:[view.fileName stringByAppendingFormat:@"(%@kb)",view.fileSize]
//                     image:nil
//                    target:nil
//                    action:NULL],
//      item
//      
//      ];
//    
//    KxMenuItem *first = menuItems[0];
//    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
//    first.alignment = NSTextAlignmentCenter;
//    CGRect frame = view.frame;
//    frame.origin.x +=frame.size.width;
//    frame.origin.y = view.superview.frame.origin.y;
//    [KxMenu showMenuInView:self
//                  fromRect:frame
//                 menuItems:menuItems];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [delegate openFile:currentFileId];
    }
}

//-(void)pushMenuItem:(id)sender
//{
//    KxMenueItemExt *item = (KxMenueItemExt*)sender;
//    [delegate openFile:item.fileId];
//}

-(void)title:(NSString*)title content:(NSString*)content time:(NSDate*)time isRead:(BOOL)isRead {
    [self title:title content:content time:time isRead:isRead withAttachment:nil];
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
    
    float __offset=0.0f;
    
    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad) {
        __offset=15.0f;
    }
    
    if(self.editing){
        offset+=40.0f;
    }
    
    
    isReadLabel.frame=CGRectMake(w-35.0f-OFFSET-__offset, 10.0f, 35.0f, 25.0f);
    titleLabel.frame=CGRectMake(__offset+offset, 10.0f, CGRectGetMinX(isReadLabel.frame)-offset*2.0f-__offset, 0.0f);
    [titleLabel sizeToFit];
    
    if(!self.editing)
        lineView.frame=CGRectMake(offset,CGRectGetMaxY(titleLabel.frame)+2.0f,w-offset*2.0f,1);
    else
        lineView.frame=CGRectMake(offset,CGRectGetMaxY(titleLabel.frame)+2.0f,w-OFFSET*2.0f-40.0f,1);

    contentLabel.frame=CGRectMake(__offset+offset, CGRectGetMaxY(titleLabel.frame)+5.0f, w-offset*2.0f-__offset, 0.0f);
    [contentLabel sizeToFit];
    
    timeLabel.frame=CGRectMake(w-150.0f-OFFSET-__offset, CGRectGetMaxY(contentLabel.frame)+8.0f, 150.0f, 20.0f);
    attachView.frame =CGRectMake(offset, CGRectGetMaxY(contentLabel.frame)+5.0f, 220, 32);

}

@end
