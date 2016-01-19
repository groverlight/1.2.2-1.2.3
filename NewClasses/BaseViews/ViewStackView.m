
//! \file   ViewStackView.m
//! \brief  View class that stacks five views, from bottom to top:  Photo, liveCamera, text, blur.
//__________________________________________________________________________________________________

#import "ViewStackView.h"
#import "Colors.h"
#import "GlobalParameters.h"
#import "GradientView.h"
#import "StillImageCapture.h"
//__________________________________________________________________________________________________

//! View class that stacks four five, from bottom to top:  Photo, liveCamera, text, blur.
@implementation ViewStackView
{
  BaseView*     FlashView;      //!< The view used to simulate a front side flash.
  BlurView*     BlurringView;   //!< The blur view.
  BaseView*     BlurableView;   //!< The view that contains the elements that may be blurred.
  GradientView* Gradient;       //!< The gravient view above the photo or live view.
  CGSize        PreviousSize;
}
@synthesize photoView;
@synthesize liveView;
@synthesize textView;
@synthesize blurRadius;
//____________________

+ (instancetype)sharedInstance
{
  static ViewStackView* sharedObject;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^
  {
    sharedObject = [ViewStackView new];
  });
  return sharedObject;
}
//__________________________________________________________________________________________________

//! Initialize the object however it has been created.
- (void)Initialize
{
  [super Initialize];
  BlurableView      = [BaseView        new];
  photoView         = [UIImageView     new];
  liveView          = [CameraPreview   new];
  Gradient          = [GradientView    new];
  BlurringView      = [BlurView        new];
  textView          = [BaseView        new];
  FlashView         = [BaseView        new];
  [self         addSubview:BlurableView];
  [self         addSubview:BlurringView];
  [self         addSubview:textView];
  [self         addSubview:FlashView];
  [BlurableView addSubview:photoView];
  [BlurableView addSubview:liveView];
  [BlurableView addSubview:Gradient];
  [BlurringView SetBlurableView:BlurableView];
  BlurableView.smartUserInteractionEnabled    = YES;
  textView.smartUserInteractionEnabled        = YES;
  BlurringView.userInteractionEnabled         = NO;
  FlashView.userInteractionEnabled            = NO;
  FlashView.backgroundColor                   = [White colorWithAlphaComponent:0.2];
  FlashView.alpha                             = 0.0;
  self.blurRadius                             = 2;
  self.backgroundColor                        = White;
  self.clipsToBounds                          = YES;
  liveView->UseViewFrame                      = YES;
  [self unblurAnimated:NO];       // By default, the blur view is not blurred.
//  [self hideLiveViewAnimated:NO]; // By default, do not show the live view.
  GlobalParameters* parameters  = GetGlobalParameters();
  Gradient.color1               = parameters.gradientTopColor;
  Gradient.color2               = parameters.gradientBottomColor;
  Gradient.alpha                = parameters.gradientAlpha;
}
//__________________________________________________________________________________________________

- (void)dealloc
{
  [self cleanup];
}
//__________________________________________________________________________________________________

- (void)cleanup
{
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
  [super layoutSubviews];
  CGRect bounds                 = self.bounds;
  CGSize size = self.size;
  if ((size.width != PreviousSize.width) && (size.height != PreviousSize.height))
  {
    PreviousSize = size;
    BlurableView.frame            = bounds;
    photoView.frame               = bounds;
    liveView.frame                = bounds;
    Gradient.frame                = bounds;
    textView.frame                = bounds;
    BlurringView.frame            = bounds;
    FlashView.frame               = bounds;
    ((BaseView*)textView.subviews.firstObject).frame        = bounds;
  }
}
//__________________________________________________________________________________________________

- (void)showView:(UIView*)view animated:(BOOL)animated alpha:(CGFloat)alpha
{
  if (animated)
  {
//    NSLog(@"startAnimation");
    [UIView animateWithDuration:0.5 animations:^
    {
//      NSLog(@"initAnimation");
      view.alpha = alpha;
    } completion:^(BOOL finished)
    {
//      NSLog(@"completeAnimation");
    }];
  }
  else
  {
    view.alpha = alpha;
  }
}
//__________________________________________________________________________________________________

- (void)hideView:(UIView*)view animated:(BOOL)animated withCompletion:(BlockAction)completion
{
  NSLog(@"hideView animated with completion");
  if (animated)
  {
    [UIView animateWithDuration:0.5 animations:^
    {
      view.alpha = 0.0;
    } completion:^(BOOL finished)
    {
      completion();
    }];
  }
  else
  {
    view.alpha = 0.0;
    completion();
  }
}
//__________________________________________________________________________________________________

- (void)showPhotoViewAnimated:(BOOL)animated
{
  [self showView:photoView animated:animated alpha:1];
}
//__________________________________________________________________________________________________

- (void)hidePhotoViewAnimated:(BOOL)animated
{
  [self hideView:photoView animated:animated withCompletion:^
  {
  }];
}
//__________________________________________________________________________________________________

- (void)showLiveViewAnimated:(BOOL)animated
{
  [liveView startPreviewWithCompletion:^
  {
    // Make sure the AVCaptureStillImageOutput object is allocated well before taking the first snapshot.
    [StillImageCapture sharedCapture];
    [self showView:liveView animated:animated alpha:1];
  }];
}
//__________________________________________________________________________________________________

- (void)hideLiveViewAnimated:(BOOL)animated
{
  NSLog(@"hideLiveViewAnimated");
#if 0
  [liveView stopPreviewWithCompletion:^
  {
    [self hideView:liveView animated:animated withCompletion:^
    {
    }];
  }];
#endif
}
//__________________________________________________________________________________________________

- (void)cleanupLiveView
{
#if 0
  [liveView cleanupPreviewWithCompletion:^
  {
  }];
#endif
}
//__________________________________________________________________________________________________

- (void)restoreLiveView
{
#if 0
  [liveView restorePreviewWithCompletion:^
  {
    // Make sure the AVCaptureStillImageOutput object is allocated well before taking the first snapshot.
    [StillImageCapture sharedCapture];
  }];
#endif
}
//__________________________________________________________________________________________________

- (void)showTextViewAnimated:(BOOL)animated
{
  [self showView:textView animated:animated alpha:1];
}
//__________________________________________________________________________________________________

- (void)hideTextViewAnimated:(BOOL)animated
{
  [self hideView:textView animated:animated withCompletion:^
  {
  }];
}
//__________________________________________________________________________________________________

- (void)setPhoto:(UIImage*)image
{
  photoView.image = image;
}
//__________________________________________________________________________________________________

- (void)setTextViewContent:(UIView*)contentView animated:(BOOL)animated fromLeft:(BOOL)fromLeft
{
  if (textView.subviews.count == 0)
  {
    [textView addSubview:contentView];
    if (animated)
    {
      contentView.alpha = 0.0;
      [UIView animateWithDuration:0.5 animations:^
      {
        contentView.alpha = 1.0;
      }];
    }
  }
  else
  {
    UIView* currentView = textView.subviews.firstObject;
    [textView addSubview:contentView];
    CGRect frame = self.bounds;
    frame.origin.x = (fromLeft? -self.width: self.width);
    contentView.frame = frame;
    [UIView animateWithDuration:0.5 animations:^
    {
      CGRect anim_frame = self.bounds;
      anim_frame.origin.x = 0;
      contentView.frame = anim_frame;
      anim_frame = self.bounds;
      anim_frame.origin.x = (fromLeft? self.width: -self.width);
      currentView.frame = anim_frame;
    } completion:^(BOOL finished)
    {
      [currentView removeFromSuperview];
    }];
  }
  contentView.frame = self.bounds;
}
//__________________________________________________________________________________________________

- (void)blurAnimated:(BOOL)animated
{
  BlurringView.blurRadius = blurRadius;
  [BlurringView holdAndBlur:animated];
}
//__________________________________________________________________________________________________

- (void)unblurAnimated:(BOOL)animated
{
  [BlurringView unholdAndUnblur:animated];
}
//__________________________________________________________________________________________________

- (void)blurWithFactor:(CGFloat)blurFactor
{
  [BlurringView blurWithFactor:blurFactor];
}
//__________________________________________________________________________________________________

- (void)setGradientTopColor:(UIColor*)topColor BottomColor:(UIColor*)bottomColor alpha:(CGFloat)alpha;
{
  Gradient.color1 = topColor;
  Gradient.color2 = bottomColor;
  Gradient.alpha  = alpha;
}
//__________________________________________________________________________________________________

//! Display a white screen with max luminosity for the specified duration in seconds.
- (void)flashForDuration:(CGFloat)duration completion:(BlockAction)completion
{
  FlashView.alpha                   = 0.6;
  CGFloat savedBrightness           = [UIScreen mainScreen].brightness;
  [UIScreen mainScreen].brightness  = 1.0;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
  {
    [UIScreen mainScreen].brightness = savedBrightness;
    FlashView.alpha = 0.0;
    completion();
  });
}
//__________________________________________________________________________________________________

- (void)activate
{
  [[textView.subviews firstObject] activate];
}
//__________________________________________________________________________________________________

@end
