
//! \file   RollDownView.h
//! \brief  UIView based class that contain additions common to many views in the project.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "BaseView.h"
//__________________________________________________________________________________________________

//! UIView based class that contain additions common to many views in the project.
@interface RollDownView : BaseView
{
}
//____________________

//! Initialize the object however it has been created.
- (void)Initialize;
//____________________

//! Show the roll down view with the specified title and message.
- (void)showWithTitle:(NSString*)title andMessage:(NSString*)message;
//____________________

//! Show the roll down view with the specified title, message and button label. Call completion block when the button is pressed.
- (void)showWithTitle:(NSString*)title message:(NSString*)message andButton:(NSString*)buttonLabel completion:(BlockAction)completion;
//____________________

//! Hide the roll down view.
- (void)hide;
//____________________

@end
//__________________________________________________________________________________________________
