//
//  MultiSystemsView.m
//  bsl
//
//  Created by zhoujun on 13-11-13.
//
//
#import "RCPopoverView.h"
#import "MultiSystemsView.h"

@implementation MultiSystemsView
@synthesize multiDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)initWithDataSource:(NSArray*)_items
{
    _options= [_items copy];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 400)];
//    CGPoint point = CGPointMake(self.center.x, self.center.y - 44);
//    view.center = point;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 260 , 50)];
    label.text =@"你好！欢迎使用南航统一移动应用，请选择要登录的系统";
    label.backgroundColor = [UIColor whiteColor];
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.numberOfLines = 0;
    [view addSubview:label];
    view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(20, 50, 260, 280) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource= self;
    
    UILabel *cancellLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(tableView.frame)+5, 220, 44)];
    cancellLabel.layer.cornerRadius = 5;
    cancellLabel.layer.borderColor = [UIColor grayColor].CGColor;
    cancellLabel.layer.borderWidth = 3;
    cancellLabel.text =  @"取消";
    cancellLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:cancellLabel];
    [view addSubview:tableView];
    self.frame= view.frame;
    cancellLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(disMissView)];
    [cancellLabel addGestureRecognizer:gesture];
    [self addSubview:view];
}
-(void)disMissView
{
    [RCPopoverView dismiss];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [multiDelegate itemDidSelected:indexPath];
//    NSString *systemId = [[_options objectAtIndex:indexPath.row] valueForKey:@"sysId"];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString*identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 200, 35)];
    label.layer.cornerRadius = 5;
    label.layer.borderColor = [UIColor grayColor].CGColor;
    label.layer.borderWidth = 3;
    label.text =  [[_options objectAtIndex:indexPath.row] valueForKey:@"sysName"];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = indexPath.row+100;
    [cell addSubview:label];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _options.count;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
