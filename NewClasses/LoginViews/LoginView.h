
//! \file   LoginView.h
//! \brief  Class that handle user registration and login.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>

#import "BaseView.h"
//__________________________________________________________________________________________________

//! CardView based class that handle user registration and login.
@interface LoginView : BaseView
{
}
//____________________

@property BlockBoolAction loginDoneAction;  //!< Action block called when the login process has terminated.
//____________________

- (void)showAnimated:(BOOL)animated fromStart:(BOOL)fromStart;  //!< Show the login view.
- (void)hideAnimated:(BOOL)animated;                            //!< Hide the login view.
//____________________

- (void)recoverSavedState:(BlockAction)completion;
//____________________


@end
//__________________________________________________________________________________________________
