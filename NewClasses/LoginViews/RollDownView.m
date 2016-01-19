
//! \file   RollDownView.m
//! \brief  BaseView based class that roll down from the top of the parent view.
//__________________________________________________________________________________________________

#import "GlobalParameters.h"
#import "RollDownView.h"
#import "Colors.h"
//__________________________________________________________________________________________________

#define TITLE_TOP_MARGIN              23  //!< Vertical position ot the top of the title label.
#define MESSAGE_TOP_MARGIN            36  //!< Vertical position ot the top of the message label.
#define BUTTON_TOP_MARGIN             75  //!< Vertical position ot the top of the button.
#define TITLE_HEIGHT                  24  //!< Height of the title label.
#define MESSAGE_HEIGHT                30  //!< Height of the message label.
#define BUTTON_HEIGHT                 20  //!< Height of the button.
#define BEST_VIEW_HEIGHT              74  //!< Preferred height of the roll down view.
#define BEST_VIEW_HEIGHT_WITH_BUTTON 100  //!< Preferred height of the roll down view when button is visible.

//__________________________________________________________________________________________________

//! UIView based class that contain additions common to many views in the project.
@implementation RollDownView
{
  UIView*     ContentView;          //!< The content view.
  UILabel*    Title;                //!< The title label.
  UILabel*    Message;              //!< The message label.
  UIButton*   Button;               //!< The action button;
  BOOL        Shown;                //!< Flag indicating if the roll down view is currently shown.
  BlockAction ButtonPressedAction;  //!< Block to call when the button is pressed.
}
//____________________

//! Initialize the object however it has been created.
- (void)Initialize
{
  Shown                 = NO;
  ContentView           = [UIView  new];
  Title                 = [UILabel new];
  Message               = [UILabel new];
  Button                = [UIButton buttonWithType:UIButtonTypeSystem];
  Title.font            = [UIFont fontWithName:@"AvenirNext-Bold" size:13];
  Message.font          = [UIFont fontWithName:@"AvenirNext-Medium" size:13];
  Title.textAlignment   = NSTextAlignmentCenter;
  Message.textAlignment = NSTextAlignmentCenter;
  Title.textColor = TypeTealDark;
  Message.textColor = TypeTealDark;
  Message.numberOfLines = 2;
  Message.lineBreakMode = NSLineBreakByWordWrapping;
  self.backgroundColor  = [UIColor clearColor];
  self.hidden           = YES;
  Button.hidden         = YES;
  [self         addSubview:ContentView];
  [ContentView  addSubview:Title];
  [ContentView  addSubview:Message];
  [ContentView  addSubview:Button];
  ContentView.backgroundColor = GetGlobalParameters().rollDownViewBackgroundColor;
  [Button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
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

  CGFloat width         = self.frame.size.width;
  CGFloat height        = self.frame.size.height;
  ContentView.frame     = CGRectMake(0, Shown? 0: -height, width, height);
  Title.frame           = CGRectMake(0, TITLE_TOP_MARGIN  , width, TITLE_HEIGHT);
  Message.frame         = CGRectMake(0, MESSAGE_TOP_MARGIN, width, MESSAGE_HEIGHT);
  Button.frame          = CGRectMake(0, BUTTON_TOP_MARGIN , width, BUTTON_HEIGHT);
}
//__________________________________________________________________________________________________

- (CGSize)sizeThatFits:(CGSize)size
{
  CGSize fitSize = CGSizeMake(self.frame.size.width, (Button.hidden)? BEST_VIEW_HEIGHT: BEST_VIEW_HEIGHT_WITH_BUTTON);
//  NSLog(@"RollDownView fitSize: %f, %f", fitSize.width, fitSize.height);
  return fitSize;
}
//__________________________________________________________________________________________________

- (void)buttonPressed:(UIButton*)sender
{
  ButtonPressedAction();
}
//__________________________________________________________________________________________________

- (void)showWithTitle:(NSString*)title andMessage:(NSString*)message
{
  Title.text    = title;
  Message.text  = message;
  if (!Shown)
  {
    Shown           = YES;
    Button.hidden   = YES;
    CGSize size     = [self sizeThatFits:CGSizeZero];
    CGRect frame    = ContentView.frame;
    frame.size      = size;
    frame.origin.y  = 0;
    self.hidden     = NO;
    [UIView animateWithDuration:0.5 animations:^
    {
      ContentView.frame = frame;
    }];
  }
}
//__________________________________________________________________________________________________


//! Show the roll down view with the specified title, message and button label. Call completion block when the button is pressed.
- (void)showWithTitle:(NSString*)title message:(NSString*)message andButton:(NSString*)buttonLabel completion:(BlockAction)completion
{
  Title.text          = title;
  Message.text        = message;
  ButtonPressedAction = completion;
  [Button setTitle:buttonLabel forState:UIControlStateNormal];
  if (!Shown)
  {
    Shown           = YES;
    Button.hidden   = NO;
    CGSize size     = [self sizeThatFits:CGSizeZero];
    CGRect frame    = ContentView.frame;
    frame.size      = size;
    frame.origin.y  = 0;
    self.hidden     = NO;
    [UIView animateWithDuration:0.5 animations:^
    {
      ContentView.frame = frame;
    }];
  }
}
//__________________________________________________________________________________________________

- (void)hide
{
  if (Shown)
  {
    Shown           = NO;
    CGRect frame    = ContentView.frame;
    frame.origin.y  = -frame.size.height;
    [UIView animateWithDuration:0.5 animations:^
    {
      ContentView.frame = frame;
    } completion:^(BOOL finished)
    {
      self.hidden = YES;
    }];
  }
}
//__________________________________________________________________________________________________

@end
