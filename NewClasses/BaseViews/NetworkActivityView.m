
//! \file   NetworkActivityView.m
//! \brief  A custom network activity view with a dark background.
//__________________________________________________________________________________________________

#import "NetworkActivityView.h"
#import "Colors.h"
#import "GlobalParameters.h"
#import "Tools.h"
//__________________________________________________________________________________________________

//! A custom activity view with a dark background.
@implementation NetworkActivityView
{
  UIActivityIndicatorView*  ActivView;
}
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  [super Initialize];

  GlobalParameters* parameters          = GetGlobalParameters();
  self.backgroundColor                  = ColorWithAlpha(parameters.networkActivityBackgroundColor, parameters.networkActivityBackgroundOpacity);
  ActivView                             = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  ActivView.activityIndicatorViewStyle  = UIActivityIndicatorViewStyleWhiteLarge;
  ActivView.color                       = parameters.networkActivityWheelColor;
  [self addSubview:ActivView];
  self.alpha = 0.0;
}
//__________________________________________________________________________________________________

- (void)dealloc
{
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
  [super layoutSubviews];
  CGRect frame    = self.superview.bounds;
  self.frame      = frame;
  CGSize viewSize = frame.size;
  CGSize size     = [ActivView sizeThatFits:viewSize];
  frame.origin.x  = (viewSize.width   - size.width)   / 2;
  frame.origin.y  = (viewSize.height  - size.height)  / 2;
  frame.size      = size;
  ActivView.frame = frame;
}
//__________________________________________________________________________________________________

//! Make this view visible.
- (void)showAnimated:(BOOL)animated
{
  dispatch_async(dispatch_get_main_queue(), ^
  {
    if (animated)
    {
      [UIView animateWithDuration:0.3 animations:^
       {
         self.alpha = 1.0;
       }];
    }
    else
    {
      self.alpha = 1.0;
    }
    [ActivView startAnimating];
  });
}
//__________________________________________________________________________________________________

//! Make this view invisible.
- (void)hideAnimated:(BOOL)animated
{
  dispatch_async(dispatch_get_main_queue(), ^
  {
    [ActivView stopAnimating];
    if (animated)
    {
      [UIView animateWithDuration:0.3 animations:^
      {
        self.alpha = 0.0;
      }];
    }
    else
    {
      self.alpha = 0.0;
    }
  });
}
//__________________________________________________________________________________________________

//! Make this view visible with implicit animation.
- (void)showWithAnimation
{
  [self showAnimated:YES];
}
//__________________________________________________________________________________________________

//! Make this view invisible with implicit animation.
- (void)hideWithAnimation
{
  [self hideAnimated:YES];
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________
