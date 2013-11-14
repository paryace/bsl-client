# RCPopoverView

RCPopoverView is a drop-in cocoa class used to display a generic or custom UIView that slides horizontally. The view is easily dismissed by the user by swiping to the right.  Inspired by the Shows app by Sam Vermette.

## Installation

### From CocoaPods

- Add `pod 'RCPopoverView'` to your Podfile

### Manually

- Drag the `RCPopoverView/RCPopoverView` folder into your project.
- Add the **QuartzCore** framework to your project.

## Usage

Show the popover

```objective-c
+ (void)show;
// Or use a custom view
+ (void)showWithView:(UIView *)popover;
```

Dismiss the view

```objective-c
+ (void)dismiss;
```

## Credits

RCPopoverView is created by Robin Chou and inspired by SVProgressHUD and the Shows app by Sam Vermette.