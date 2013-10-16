//
//  FaviorContactView.h
//  cube-ios
//
//  Created by apple2310 on 13-9-12.
//
//

#import "TouchScroller.h"

@class FaviorContactView;
@class UserInfo;
@protocol FaviorContactViewDelegate <NSObject>
-(void)faviorContactViewDidSelected:(FaviorContactView*)recentTalkView userInfo:(UserInfo*)userInfo;
-(void)faviorContactViewDidDelete:(FaviorContactView*)recentTalkView userInfo:(UserInfo*)userInfo;
@end


@interface FaviorContactView : TouchTableView{
    NSMutableArray* list;
    
    NSTimer* laterReloadTimer;
}
@property(nonatomic,weak) id<FaviorContactViewDelegate> faviorDelegate;
-(void)loadData;

-(void)layoutTableCell;

@end
