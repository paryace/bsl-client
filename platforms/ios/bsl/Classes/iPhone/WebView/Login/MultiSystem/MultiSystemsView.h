//
//  MultiSystemsView.h
//  bsl
//
//  Created by zhoujun on 13-11-13.
//
//

#import <UIKit/UIKit.h>
@protocol MultiSystemDelegate
-(void)itemDidSelected:(NSIndexPath*)indexPath;
@end
@interface MultiSystemsView : UIView<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_options;
    UITableView *_tableView;
    __unsafe_unretained id<MultiSystemDelegate> multiDelegate;
}
@property(nonatomic,assign)id<MultiSystemDelegate> multiDelegate;
-(void)initWithDataSource:(NSArray*)_items;
@end
