//
//  ContactListView.h
//  cube-ios
//
//  Created by apple2310 on 13-9-12.
//
//

#import <UIKit/UIKit.h>
@class TouchTableView;
@class ContactListView;
@class UserInfo;
@protocol ContactListViewDelegate <NSObject>
-(void)contactListDidTouch:(ContactListView*)contactList;
-(void)contactListDidSearchShouldBeginEditing:(ContactListView*)contactList searchBar:(UISearchBar*)searchBar;
-(void)contactListSearchBarSearchButtonClicked:(ContactListView*)contactList searchBar:(UISearchBar*)searchBar;
-(void)contactListSearchBarCancelButtonClicked:(ContactListView*)contactList searchBar:(UISearchBar*)searchBar;
-(void)contactListSearchBarTextChanged:(ContactListView*)contactList searchBar:(UISearchBar*)searchBar;

-(void)contactListDidSelected:(ContactListView*)contactList userInfo:(UserInfo*)userInfo;
@end

@interface ContactListView : UIView

@property(nonatomic,weak) id<ContactListViewDelegate> delegate;
-(void)syncFriends;
-(void)clear;
@end
