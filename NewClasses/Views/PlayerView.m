
//! \file   PlayerView.m
//! \brief  BaseView based class that plays the messages.
//__________________________________________________________________________________________________

#import "PlayerView.h"
#import "Colors.h"
#import "GlobalParameters.h"
#import "GradientView.h"
#import "HeaderBarView.h"
#import "PagedScrollView.h"
#import "PopLabel.h"
#import "PopScreenToCircleView.h"
#import "TypingView.h"
#import "Tools.h"
//__________________________________________________________________________________________________

//! \brief  BaseView based class that plays the messages.
@interface PhotoContainerView : BaseView
{
}
//____________________

@property UIImageView* photo;
//____________________

@end
//__________________________________________________________________________________________________

//! \brief  BaseView based class that plays the messages.
@implementation PhotoContainerView
{
  UIImageView* Photo;
}
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  self.clipsToBounds = YES;
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
  [super layoutSubviews];
  if ((self.height > 0.0) && (Photo.image.size.height))
  {
    CGFloat viewRatio   = self.width              / self.height;
    CGFloat photoRatio  = Photo.image.size.width  / Photo.image.size.height;
    CGFloat ratio       = viewRatio               / photoRatio;
    if (ratio > 1.0)
    {
      Photo.width   = self.width;
      Photo.height  = self.height * ratio;
      Photo.left    = 0;
      Photo.top     = (self.height - Photo.height) / 2;
    }
    else
    {
      Photo.width   = self.width / ratio;
      Photo.height  = self.height;
      Photo.left    = (self.width - Photo.width) / 2;
      Photo.top     = 0;
    }
  }
}
//__________________________________________________________________________________________________

- (void)setPhoto:(UIImageView*)photo
{
  [Photo removeFromSuperview];
  Photo = photo;
  [self addSubview:Photo];
  [self setNeedsLayout];
}
//__________________________________________________________________________________________________

- (UIImageView*)photo
{
  return Photo;
}
//__________________________________________________________________________________________________

@end
//==================================================================================================

//! \brief  BaseView based class that plays the messages.
@interface PlayerView()
{
  PopScreenToCircleView*  CircleToScreen;
  PopLabel*               TextLabel;
  UIImageView*            Photo;
  PhotoContainerView*     PhotoContainer;
  GradientView*           Gradient;       //!< The gravient view above the photo or live view.
  Message*                Msg;
  NSInteger               CurrentBlock;
  UIColor*                TransparentColor;
  BOOL                    StopRequested;
}
@end
//__________________________________________________________________________________________________

//! \brief  BaseView based class that plays the messages.
@implementation PlayerView

//! Initialize the object however it has been created.
-(void)Initialize
{
  [super Initialize];
  CircleToScreen  = [PopScreenToCircleView  new];
  TextLabel       = [PopLabel               new];
  Gradient        = [GradientView           new];
  Photo           = [UIImageView            new];
  PhotoContainer  = [PhotoContainerView     new];
  [self addSubview:CircleToScreen];
  [self addSubview:Gradient];
  [self addSubview:TextLabel];
  GlobalParameters* parameters  = GetGlobalParameters();
  PhotoContainer.photo          = Photo;
  CircleToScreen.contentView    = PhotoContainer;
  CircleToScreen.animParameters = parameters.playerCircleToScreenAnimParameters;

  StopRequested               = NO;
  self.userInteractionEnabled = NO;
  TransparentColor            = ColorWithAlpha(parameters.playerTextColor, 0);
  TextLabel.numberOfLines     = 0;
  TextLabel.textAlignment     = NSTextAlignmentCenter;
  TextLabel.textColor         = TransparentColor;

  Photo.layer.masksToBounds = YES;

  CircleToScreen.alpha  = 0.0;
  Photo.alpha           = 0.0;
  TextLabel.alpha       = 0.0;
  Gradient.alpha        = 0.0;
  CircleToScreen.backgroundColor = [Black colorWithAlphaComponent: 0.8];
  CircleToScreen.animationValue = 1.0;
  Gradient.color1               = parameters.gradientTopColor;
  Gradient.color2               = parameters.gradientBottomColor;
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
//  NSLog(@"CardNavigationOverlayView layoutSubviews");
  [super layoutSubviews];
  GlobalParameters* parameters  = GetGlobalParameters();
  CircleToScreen.frame          = self.bounds;
  Gradient.frame                = self.bounds;
  TextLabel.width               = self.width - 2 * parameters.playerLabelLateralMargin;
  TextLabel.height              = 2 * parameters.playerLabelCenterOffsetFromBottom;
  TextLabel.centerY             = self.height - parameters.playerLabelCenterOffsetFromBottom;
  TextLabel.left                = (self.width - TextLabel.width) / 2;
}
//__________________________________________________________________________________________________

- (void)setText:(NSString *)text
{
  GlobalParameters* parameters = GetGlobalParameters();
  TextLabel.text = text;
  BOOL longText = (text.length > parameters.playerFontSizeCharacterCountTrigger);
  TextLabel.font = [UIFont systemFontOfSize:(longText? parameters.playerLongTextFontSize: parameters.playerShortTextFontSize)];
}
//__________________________________________________________________________________________________

- (NSString*)text
{
  return TextLabel.text;
}
//__________________________________________________________________________________________________

- (void)prepareForFirstChunkWithMessage:(Message*)message
{
  StopRequested = NO;
  Msg           = message;
  Photo.image   = [Msg->Snapshots firstObject];
  if (Msg->Texts.count > 0)
  {
    TextLabel.text  = [Msg->Texts     firstObject];
  }
  CurrentBlock = 0;
}
//__________________________________________________________________________________________________

- (void)animateLabelScale:(CGSize)scale parameters:(PopAnimParameters*)parameters completion:(BlockAction)completion
{
  [TextLabel setViewScale:scale parameters:parameters completion:completion];
}
//__________________________________________________________________________________________________

- (void)animateTextColor:(UIColor*)color parameters:(PopAnimParameters*)parameters completion:(BlockAction)completion
{
  [TextLabel setTextColor:color parameters:parameters completion:completion];
}
//__________________________________________________________________________________________________

- (void)displayChunk:(BlockBoolAction)completion
{
  if (!StopRequested)
  {
//    NSLog(@"1 displayChunk");
    if (CurrentBlock < Msg->Snapshots.count)
    {
      Photo.image                   = [Msg->Snapshots objectAtIndex:CurrentBlock];
//      NSLog(@"CameraPreview: imageSize: %f, %f, frame size: %f, %f", Photo.image.size.width, Photo.image.size.height, self.width, self.height);
    }
    TextLabel.text                = [Msg->Texts     objectAtIndex:CurrentBlock];
    GlobalParameters* parameters  = GetGlobalParameters();
    BOOL longText                 = (TextLabel.text.length > parameters.playerFontSizeCharacterCountTrigger);
    //TextLabel.font                = [UIFont systemFontOfSize:(longText? parameters.playerLongTextFontSize: parameters.playerShortTextFontSize)];
      TextLabel.font               = [parameters.playerFont fontWithSize:(longText? parameters.playerLongTextFontSize: parameters.playerShortTextFontSize)];

      [TextLabel setViewScale:CGSizeMake(0.5, 0.5) basicAnimateDuring:0];
    if (!StopRequested)
    {
      [self animateLabelScale:CGSizeMake(1.0, 1.0) parameters:parameters.playerChunkScaleIntroAnimParameters completion:^
      {
//        NSLog(@"1.1 displayChunk");
      }];
    }
    if (!StopRequested)
    {
      [self animateTextColor:parameters.playerTextColor parameters:parameters.playerChunkColorIntroAnimParameters completion:^
      {
//        NSLog(@"2 displayChunk");
        CGFloat delay = 1.0;
        CGFloat longTextLength  = TextLabel.text.length;
        CGFloat shortTextLength = parameters.playerShortTextLength;
        CGFloat adjustmentRatio = parameters.playerAdjustmentRatio;
        CGFloat at              = (longTextLength - shortTextLength) / adjustmentRatio;
        delay += MAX(0.0, at);
        if (!StopRequested)
        {
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
          {
//            NSLog(@"3 displayChunk");
            if (!StopRequested)
            {
              [self animateLabelScale:CGSizeMake(1.0, 1.0) parameters:parameters.playerChunkScaleLeaveAnimParameters completion:^
              {
//                NSLog(@"3.1 displayChunk");
              }];
            }
            if (!StopRequested)
            {
              [self animateTextColor:TransparentColor parameters:parameters.playerChunkColorLeaveAnimParameters completion:^
              {
//                NSLog(@"4 displayChunk");
                ++CurrentBlock;
                completion(CurrentBlock >= Msg->Texts.count);
              }];
            }
            else
            {
              completion(YES);
            }
          });
        }
      }];
    }
  }
  StopRequested = NO;
}
//__________________________________________________________________________________________________

- (void)displayFirstChunk:(BlockBoolAction)completion
{
  [self displayChunk:completion];
}
//__________________________________________________________________________________________________

- (void)displayNextChunk:(BlockBoolAction)completion
{
  NSLog(@"displayNextChunk: %d", (int)CurrentBlock);
  [self displayChunk:completion];
}
//__________________________________________________________________________________________________

- (void)stopPlayer
{
  StopRequested = YES;
}
//__________________________________________________________________________________________________

- (void)showAnimatedFromPoint:(CGPoint)point andInitialRadius:(CGFloat)radius completion:(BlockAction)completion
{
  CGPoint center = [CircleToScreen convertPoint:point fromView:self];
//  NSLog(@"showAnimatedFromPoint : %f, %f", center.x, center.y);
  CircleToScreen.circleCenter   = center;
  CircleToScreen.circleRadius   = radius;
  CircleToScreen.animationValue = 1.0;
  [UIView animateWithDuration:0.1 animations:^
  {
    CircleToScreen.alpha  = 1.0;
    Photo.alpha           = 1.0;
    Gradient.alpha        = GetGlobalParameters().gradientAlpha;
  }];
  [CircleToScreen animateToScreenWithCompletion:^(id obj)
  {
    [UIView animateWithDuration:0.1 animations:^
    {
      TextLabel.alpha = 1.0;
    }];
    completion();
  }];
}
//__________________________________________________________________________________________________

- (void)hideAnimatedToPoint:(CGPoint)point andInitialRadius:(CGFloat)radius completion:(BlockAction)completion
{
  CGPoint center = [CircleToScreen convertPoint:point fromView:self];
//  NSLog(@"1 hideAnimatedToPoint : %f, %f", center.x, center.y);
  CircleToScreen.circleCenter   = center;
  CircleToScreen.circleRadius   = radius;
  CircleToScreen.animationValue = 0.0;
  [UIView animateWithDuration:0.1 animations:^
  {
    TextLabel.alpha = 0.0;
  }];
  [CircleToScreen animateToCircleWithCompletion:^(id obj)
  {
//    NSLog(@"2 hideAnimatedToPoint : %f, %f", center.x, center.y);
    [UIView animateWithDuration:0.1 animations:^
    {
      CircleToScreen.alpha  = 0.0;
      Photo.alpha           = 0.0;
      Gradient.alpha        = 0.0;
    } completion:^(BOOL finished)
    {
      completion();
    }];
  }];
}
//__________________________________________________________________________________________________

@end
