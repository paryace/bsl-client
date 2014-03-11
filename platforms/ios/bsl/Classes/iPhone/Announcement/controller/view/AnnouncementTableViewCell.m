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
    
    return [self cellHeight:title content:content width:w attachments:nil];
}
+(float)cellHeight:(NSString*)title content:(NSString*)content width:(float)w attachments:(NSString *)attachments{
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
    
    
    float height=CGRectGetMaxY(contentLabel.frame)+3.0f;
    titleLabel=nil;
    contentLabel=nil;
    if(attachments)
    {
        NSArray *array = [attachments objectFromJSONString];
        return height + 35 * array.count + 15;
    }
    else
    {
        return height + 35.0;
    }
    
    
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
        for(UIView *view in [attachView subviews])
        {
            [view removeFromSuperview];
        }
//        [attachView removeFromSuperview];
//        attachView = nil;
    }
    else{
        for(UIView *view in [attachView subviews])
        {
            [view removeFromSuperview];
        }
        NSMutableArray *filesArray = [files objectFromJSONString];
        int i=0;
        for (NSDictionary *dict in filesArray) {
//            NSDictionary *dict1 = [@"{\"fileId\":\"T1IaETBXZT1RCvBVdK\",\"fileName\":\"120.png\",\"fileSize\":22}" objectFromJSONString];
            if([[dict JSONString]objectFromJSONString] == nil)
            {
                NSLog(@"不是json 字符串");
                return;
            }
            NSLog(@"%@",[dict valueForKey:@"fileName"]);
            NSString*fileName = [[dict valueForKey:@"fileName"] lowercaseString];
            NSString*fileId = [dict valueForKey:@"fileId"];
            NSString*fileSize =  [dict valueForKey:@"fileSize"];
//            NSLog(@"=======%@",fileName);
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
            [imageview setUserInteractionEnabled: YES];
            [imageview setMultipleTouchEnabled:YES];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
            tapGesture.numberOfTapsRequired=1;
            tapGesture.delegate = self;
            [imageview addGestureRecognizer:tapGesture];
//
            imageview.fileId = fileId;
            imageview.fileName = fileName;
            imageview.fileSize = fileSize;
            CGRect frame = imageview.frame;
            frame.origin.x = 0.0f;
            frame.origin.y = 35*i;
            frame.size.width = 30;
            frame.size.height = 30;
            imageview.frame = frame;
            
            imageview.backgroundColor = [UIColor clearColor];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(32, 35*i, 150, 30)];
            label.text = [fileName stringByAppendingFormat:@"(%@kb)",fileSize];
            label.font = [UIFont systemFontOfSize:12];
            label.backgroundColor = [UIColor clearColor];
            [attachView addSubview:label];
            [attachView addSubview:imageview];
            i++;
        }
        
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
//    NSLog(@"---%@", NSStringFromClass([touch.view class]));
    
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"AnnouncementTableViewCell"]) {
        return NO;
    }
    return  YES;
}

-(void)showMenu:(UITapGestureRecognizer*)sender
{
    AttachmentImageView *view = (AttachmentImageView*)sender.view;
    currentFileId = view.fileId;
    AttachMents *attachment = [AttachMents getByPredicate:[NSPredicate predicateWithFormat:@"fileId=%@",currentFileId]];
//    attachment = nil;
    if(!attachment)
    {
        attachment = [AttachMents insert];
        attachment.fileName = view.fileName;
        attachment.fileId = currentFileId;
        attachment.fileSize = [NSNumber numberWithFloat:[view.fileSize floatValue]];
        [attachment downloadFile:currentFileId];
//        [attachment save];
//        NSString *tips = [NSString stringWithFormat:@"你确定要打开:%@?",[view.fileName stringByAppendingFormat:@"(%@kb)",view.fileSize]];
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:tips delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
//        [alertView show];
    }
    else
    {
        [self.delegate openFile:currentFileId];
    }
    
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
    
    timeLabel.frame=CGRectMake(w-150.0f-OFFSET-__offset, bgView.frame.size.height - 20, 150.0f, 20.0f);
    attachView.frame =CGRectMake(offset, CGRectGetMaxY(contentLabel.frame)+5.0f, 220, 35*5);

}

@end
