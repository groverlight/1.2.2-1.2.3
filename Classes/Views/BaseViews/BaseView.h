
//! \file   BaseView.h
//! \brief  UIView based class that contain additions common to many views in the project.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
//__________________________________________________________________________________________________

@interface UIResponder (FirstResponder)

+(id)currentFirstResponder;
//__________________________________________________________________________________________________

@end
//==================================================================================================

@interface UIView (FrameHelper)

@property CGFloat left;
@property CGFloat top;
@property CGFloat right;
@property CGFloat bottom;
@property CGFloat width;
@property CGFloat height;
@property CGFloat centerX;
@property CGFloat centerY;
@property CGPoint origin;
@property CGSize  size;
//____________________

- (void)centerVertically;
- (void)centerHorizontally;
- (void)centerInSuperview;
//____________________

@end
//==================================================================================================

//! UIView based class that contain additions common to many views in the project.
@interface BaseView : UIView
{
}
//____________________

@property BOOL smartUserInteractionEnabled;  //!< When YES, disable user interaction if no subviews hit the touch point.
//____________________

//! Initialize the object however it has been created.
-(void)Initialize;
//____________________

//! Recalculate view layout independently of the system layout process.
- (void)layout;
//____________________

//! Perform some class specific activation action.
- (void)activate;
//____________________

@end
//__________________________________________________________________________________________________
