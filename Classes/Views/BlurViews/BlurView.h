
//! \file   BlurView.h
//! \brief  UIView based class that implement blurred snapshots.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
//__________________________________________________________________________________________________

//! Type definition for parameterless blocks.
typedef void (^BlurAction)(void);
//__________________________________________________________________________________________________

//! \brief  UIView based class that implement blurred snapshots.
@interface BlurView : UIView
{
}
//____________________

@property NSTimeInterval  transitionDuration;     //!< Duration of the transition to blur and unblur.
@property UIColor*        tintColor;              //!< The color to ting the blurred view.
@property CGFloat         blurRadius;             //!< The amount of blur.
@property CGFloat         saturationDeltaFactor;  //!< Saturation of the blurred image: 0.0 -> grey level, 1.0 -> normal saturation, > 1.0 -> oversaturation.

//! Initialize the object however it has been created.
- (void)Initialize;
//____________________

//! Specify the view that should be blurred.
- (void)SetBlurableView:(UIView*)view;
//____________________

//! Specify the block to call before starting the blur operation.
- (void)setWillBlurAction:(BlurAction)action;
//____________________

//! Specify the block to call before starting the unblur operation.
- (void)setWillUnblurAction:(BlurAction)action;
//____________________

//! Specify the block to call after ending the blur operation.
- (void)setDidBlurAction:(BlurAction)action;
//____________________

//! Specify the block to call after ending the unblur operation.
- (void)setDidUnblurAction:(BlurAction)action;
//____________________

//! Hold the animation and blur the view.
- (void)holdAndBlur:(BOOL)animate;
//____________________

//! When hold, restart the animation at the start of the current timeline. Otherwise, do nothing.
- (void)unholdAndUnblur:(BOOL)animate;
//____________________

//! Apply the specified blur factor.
- (void)blurWithFactor:(CGFloat)blurFactor;
//____________________

@end
//__________________________________________________________________________________________________
