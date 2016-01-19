
//! \file   GradientView.h
//! A UIView class that adds some common features.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "Tools.h"
#import "HsvGradient.h"
#import "BaseView.h"
//__________________________________________________________________________________________________

//! A UIView class that adds some common features.
@interface GradientView : BaseView
{
}
//____________________

@property UIColor*          defaultColor1;
@property UIColor*          defaultColor2;
@property UIColor*          color1;
@property UIColor*          color2;
@property BOOL              horizontal;
@property GradientType      gradientType;
@property InterpolationMode mode;
//____________________

@end
//__________________________________________________________________________________________________

GradientView* GetAppGradientBackgroundView(void);
//__________________________________________________________________________________________________
