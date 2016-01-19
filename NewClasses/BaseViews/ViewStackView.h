
//! \file   ViewStackView.h
//! \brief  View class that stacks five views, from bottom to top:  Photo, liveCamera, text, blur.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "BaseView.h"
#import "BlurView.h"
#import "CameraPreview.h"
//__________________________________________________________________________________________________

//! View class that stacks five views, from bottom to top:  Photo, liveCamera, text, blur.
@interface ViewStackView : BaseView
{
}
//____________________

@property (readonly) UIImageView*         photoView;        //!< The fixed image view.
@property (readonly) CameraPreview*       liveView;         //!< The live camera preview view.
@property (readonly) BaseView*            textView;         //!< The view that will contain the text editor and the messages display.
@property            CGFloat              blurRadius;       //!< The intensity of the blur effect.
//____________________

+ (instancetype)sharedInstance;
//____________________

- (void)showPhotoViewAnimated:(BOOL)animated;
- (void)hidePhotoViewAnimated:(BOOL)animated;
//____________________

- (void)showLiveViewAnimated:(BOOL)animated;
- (void)hideLiveViewAnimated:(BOOL)animated;
- (void)cleanupLiveView;
- (void)restoreLiveView;
//____________________

- (void)showTextViewAnimated:(BOOL)animated;
- (void)hideTextViewAnimated:(BOOL)animated;
//____________________

- (void)setPhoto:(UIImage*)image;
//____________________

- (void)setTextViewContent:(UIView*)contentView animated:(BOOL)animated fromLeft:(BOOL)fromLeft;
//____________________

- (void)blurAnimated:(BOOL)animated;
//____________________

- (void)unblurAnimated:(BOOL)animated;
//____________________

- (void)blurWithFactor:(CGFloat)blurFactor;
//____________________

- (void)setGradientTopColor:(UIColor*)topColor BottomColor:(UIColor*)bottomColor alpha:(CGFloat)alpha;
//____________________

//! Display a white screen with max luminosity for the specified duration in seconds.
- (void)flashForDuration:(CGFloat)duration completion:(BlockAction)completion;
//____________________

@end
//__________________________________________________________________________________________________
