
//! \file   NetworkActivityView.h
//! \brief  A custom network activity view with a dark background.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "BaseView.h"
//__________________________________________________________________________________________________

//! A custom activity view with a dark background.
@interface NetworkActivityView : BaseView
{
}
//____________________

//! Make this view visible.
- (void)showAnimated:(BOOL)animated;
//____________________

//! Make this view invisible.
- (void)hideAnimated:(BOOL)animated;
//____________________

//! Make this view visible with implicit animation.
- (void)showWithAnimation;
//____________________

//! Make this view invisible with implicit animation.
- (void)hideWithAnimation;
//____________________

@end
//__________________________________________________________________________________________________
