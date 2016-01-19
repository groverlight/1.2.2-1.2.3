//__________________________________________________________________________________________________
//
// Copyright © 2014 Bernie                                              
//__________________________________________________________________________________________________
//
// 
//__________________________________________________________________________________________________
//
//! \file   UserSearchCardView.m
//! \brief  CardView based class that handle interactive serach for usernames.
//!
//! \author Bernie
//__________________________________________________________________________________________________

#import <MessageUI/MessageUI.h>

#import "GlobalParameters.h"
#import "UserSearchCardView.h"
#import "HeaderView.h"
#import "Parse.h"
#import "RollDownView.h"
//__________________________________________________________________________________________________

#define SEPARATOR_END_MARGIN          20  //!< Right margin of the separator lines.
#define SEPARATOR_LINE_WIDTH          1   //!< Width of the separator lines.
#define EDITOR_VERTICAL_CENTER        180 //!< Vertical position of the editor center line.
#define EDITOR_LEFT_MARGIN            40  //!< Left margin of the editor view.
#define EDITOR_RIGHT_MARGIN           40  //!< Right margin of the editor view.
#define SEPARATOR_TOP_OFFSET          200 //!< Vertical position of the separator line.
#define BUTTON_BOTTOM_MARGIN          10  //!< Distance from the keyboard top position for the left and right buttons.
#define BUTTON_MARGIN                 20  //!< Distance from the border for the left and right buttons.
#define BUTTON_WIDTH                  100 //!< Width of the left and right buttons.
#define BOTTOM_BUTTON_BOTTOM_OFFSET   20  //!< Distance from the screen bottom to the bottom of the bottom button.
#define DEFAULT_KEYBOARD_HEIGHT       216 //!< Default keyboard height.
//__________________________________________________________________________________________________

//! CardView based class that handle user registration and login.
@interface UserSearchCardView() <UITextFieldDelegate, MFMessageComposeViewControllerDelegate>
{
}
//____________________

@end
//__________________________________________________________________________________________________

//! CardView based class that handle interactive serach for usernames.
@implementation UserSearchCardView
{
  RollDownView*     RollDownErrorView;  //!< The roll down error message view.
  UITextField*      Editor;             //!< The editor view.
  UIView*           SeparatorView;      //!< The separator line view.
  UILabel*          FoundUserLabel;     //!< Label displaying the found username.
  UIButton*         LeftButton;         //!< The left button control.
  UIButton*         RightButton;        //!< The right button control.
  UIButton*         BottomButton;       //!< The bottom button control.
  CGFloat           KeyboardHeight;     //!< The height of the currently displayed keyboard.
  CGFloat           KeyboardTop;        //!< The vertical position of the top of the keyboard.
  CGFloat           EditorHeight;       //!< The height of the editor view.
  CGFloat           EditorTop;          //!< Vertical position of the top of the editor.

  NSString*         SearchedUsername;   //!< The edited searched username.
  NSString*         FoundUserName;      //!< The found username.

  GlobalParameters* Parameters;         //!< Copy of the global parameters object pointer.

//  HeaderView*       Header;             //!< The header view that is overlaid over this view.
  UIColor*          TextColor;          //!< Color of the animation group name texts.
  UIFont*           TextFont;           //!< Font used for the animation group name texts.
}
//@synthesize cardNavigator;
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  [super Initialize];

  KeyboardHeight    = DEFAULT_KEYBOARD_HEIGHT;
  Parameters      = GetGlobalParameters();

//  Header            = [HeaderView      new];
//  Header.headerType = E_HeaderViewType_FindUser;

//  [self addSubview:Header];

#if 0
  UserSearchCardView* myself = self;

  self.gradientView.globalGradientChangedAction = ^
  {
    myself->TextColor               = myself.gradientView.textColor;
    myself->LeftButton.tintColor    = myself->TextColor;
    myself->RightButton.tintColor   = myself->TextColor;
    myself->BottomButton.tintColor  = myself->TextColor;
  };
#endif

  RollDownErrorView = [RollDownView  new];
  SeparatorView     = [UIView        new];
  Editor            = [UITextField   new];
  FoundUserLabel    = [UILabel       new];
  LeftButton        = [UIButton buttonWithType:UIButtonTypeSystem];
  RightButton       = [UIButton buttonWithType:UIButtonTypeSystem];
  BottomButton      = [UIButton buttonWithType:UIButtonTypeContactAdd];

  Editor.placeholder    = Parameters.findUsernamePlaceholder;
  Editor.delegate       = self;
  Editor.keyboardType   = UIKeyboardTypeASCIICapable;
//  Editor.enabled        = NO;
  Editor.textAlignment  = NSTextAlignmentCenter;
  [Editor addTarget:self action:@selector(editorTextChanged:) forControlEvents:UIControlEventEditingChanged];

  SeparatorView.backgroundColor = [UIColor blackColor];

  FoundUserLabel.textAlignment  = NSTextAlignmentCenter;

  LeftButton.tintColor                  = TextColor;
  RightButton.tintColor                 = TextColor;
  LeftButton.titleLabel.textAlignment   = NSTextAlignmentLeft;
  RightButton.titleLabel.textAlignment  = NSTextAlignmentRight;
  [LeftButton   setTitle:Parameters.findUserLeftButtonLabel  forState:UIControlStateNormal];
  [RightButton  setTitle:Parameters.findUserRightButtonLabel forState:UIControlStateNormal];
  [LeftButton   addTarget:self action:@selector(leftButtonPressed:)   forControlEvents:UIControlEventTouchUpInside];
  [RightButton  addTarget:self action:@selector(rightButtonPressed:)  forControlEvents:UIControlEventTouchUpInside];
  [BottomButton addTarget:self action:@selector(bottomButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

  RightButton.enabled = NO;

  [self addSubview:Editor];
  [self addSubview:SeparatorView];
  [self addSubview:FoundUserLabel];
  [self addSubview:LeftButton];
  [self addSubview:RightButton];
  [self addSubview:BottomButton];
  [self addSubview:RollDownErrorView];
  [self registerForKeyboardNotifications];
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
  CGRect frame              = self.bounds;
//  Header.frame              = frame;
  CGFloat width             = frame.size.width;
  CGFloat height            = frame.size.height;
  EditorHeight              = [Editor sizeThatFits:self.frame.size].height;
  EditorTop                 = EDITOR_VERTICAL_CENTER - EditorHeight / 2;
  KeyboardTop               = height - KeyboardHeight;
  RollDownErrorView.frame   = CGRectMake(0, 0, width, [RollDownErrorView sizeThatFits:self.frame.size].height);
  SeparatorView.frame       = CGRectMake(SEPARATOR_END_MARGIN, SEPARATOR_TOP_OFFSET , width - 2 * SEPARATOR_END_MARGIN, SEPARATOR_LINE_WIDTH);
  Editor.frame              = CGRectMake(EDITOR_LEFT_MARGIN, EditorTop, width - EDITOR_LEFT_MARGIN - EDITOR_RIGHT_MARGIN, EditorHeight);
  CGFloat foundUserLabelTop = SEPARATOR_TOP_OFFSET + (SEPARATOR_TOP_OFFSET - EditorTop - EditorHeight);
  FoundUserLabel.frame      = CGRectMake(EDITOR_LEFT_MARGIN, foundUserLabelTop, width - EDITOR_LEFT_MARGIN - EDITOR_RIGHT_MARGIN, EditorHeight);

  CGFloat buttonHeight      = [LeftButton   sizeThatFits:self.frame.size].height;
  CGFloat leftButtonWidth   = [LeftButton   sizeThatFits:self.frame.size].width;
  CGFloat rightButtonWidth  = [RightButton  sizeThatFits:self.frame.size].width;
  LeftButton.frame          = CGRectMake(BUTTON_MARGIN                           , KeyboardTop - buttonHeight, leftButtonWidth , buttonHeight);
  RightButton.frame         = CGRectMake(width - BUTTON_MARGIN - rightButtonWidth, KeyboardTop - buttonHeight, rightButtonWidth, buttonHeight);
  CGSize bottom_button_size = [BottomButton sizeThatFits:frame.size];
  BottomButton.frame        = CGRectMake((width - bottom_button_size.width) / 2, height - BOTTOM_BUTTON_BOTTOM_OFFSET - bottom_button_size.height, bottom_button_size.width, bottom_button_size.height);
}
//__________________________________________________________________________________________________

-(void)editorTextChanged:(UITextField *)textField
{
  SearchedUsername = textField.text;
  if ([SearchedUsername isEqualToString:@""])
  {
    LeftButton.enabled  = YES;
    RightButton.enabled = NO;
  }
  else
  {
    LeftButton.enabled  = NO;
    RightButton.enabled = YES;
  }
  [RollDownErrorView hide];
//  NSLog(@"editorTextChanged: %@", SearchedUsername);
}
//__________________________________________________________________________________________________

// Action when the left button (BACK) is pressed.
-(void)leftButtonPressed:(UIButton*)button
{
//  NSLog(@"leftButtonPressed");
  [Editor resignFirstResponder];
}
//__________________________________________________________________________________________________

// Action when the right button (NEXT) is pressed.
-(void)rightButtonPressed:(UIButton*)button
{
//  NSLog(@"rightButtonPressed");
  ParseIsUsernameAlreadyInUse(SearchedUsername, ^(BOOL alreadyExists, NSError* error)
  {
    if (alreadyExists)
    {
      FoundUserName       = SearchedUsername;
      FoundUserLabel.text = FoundUserName;
      Editor.text         = @"";
      [self editorTextChanged:Editor];
      [ParseUser findUsersWithUsername:FoundUserName completion:^(NSArray* array, NSError* findError)
      {
        ParseUser* newFriend = [array objectAtIndex:0];
        [GetCurrentParseUser() addFriend:newFriend completion:^(BOOL value, NSError* addError)
        {
//          [cardNavigator addAnimationGroupForUser:newFriend];
//          [cardNavigator addAnimationGroupNameForUser:newFriend];
        }];
      }];
    }
    else
    {
      [RollDownErrorView showWithTitle:Parameters.rollDownViewTitle andMessage:Parameters.rollDownUnknownUsernameErrorMessage];
    }
  });
}
//__________________________________________________________________________________________________

- (UIViewController*)viewController
{
  UIResponder *responder = self;
  while (![responder isKindOfClass:[UIViewController class]])
  {
    responder = [responder nextResponder];
    if (nil == responder)
    {
      break;
    }
  }
  return (UIViewController*)responder;
}
//__________________________________________________________________________________________________

// Action when the bottom button (+) is pressed.
-(void)bottomButtonPressed:(UIButton*)button
{
  if(![MFMessageComposeViewController canSendText])
  {
    Parameters.findUserMessagingNotSupportedAction();
  }
  else
  {
    NSArray*  recipents = @[];
    NSString* message   = [NSString stringWithFormat:Parameters.findUserMessagingSampleText, Parameters.username];

    MFMessageComposeViewController* messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];

    // Present message view controller on screen.
    [[self viewController] presentViewController:messageController animated:YES completion:nil];
  }
}
//__________________________________________________________________________________________________

- (void)messageComposeViewController:(MFMessageComposeViewController*)controller didFinishWithResult:(MessageComposeResult)result
{
  switch (result)
  {
  case MessageComposeResultCancelled:
    break;
  case MessageComposeResultSent:
    break;
  case MessageComposeResultFailed:
    Parameters.findUserFailedToSendMessageAction();
    break;
  }
  [[self viewController] dismissViewControllerAnimated:YES completion:nil];
}
//__________________________________________________________________________________________________

#if 0
- (void)WillScrollIn
{
//  NSLog(@"AnimationGroupsListView WillScrollIn");
  [self.gradientView restoreGradientFromGlobalGradient];
//  Header.title    = Parameters.username;
//  Header.subtitle = Parameters.findUserLabel;
}
//__________________________________________________________________________________________________

- (void)WillScrollOut
{
//  NSLog(@"AnimationGroupsListView WillScrollOut");
  [Editor resignFirstResponder];
}
//__________________________________________________________________________________________________

- (void)HasScrolledIn
{
//  NSLog(@"AnimationGroupsListView HasScrolledIn");
  [self.gradientView setShowLivePreview:YES animated:YES];
}
//__________________________________________________________________________________________________

- (void)HasScrolledOut
{
//  NSLog(@"AnimationGroupsListView HasScrolledOut");
}
//__________________________________________________________________________________________________
#endif

//================================ Keyboard notification methods ===================================

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardDidShow:)
                                               name:UIKeyboardDidShowNotification object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillBeHidden:)
                                               name:UIKeyboardWillHideNotification object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardDidHide:)
                                               name:UIKeyboardDidHideNotification object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardHasChangedFrame:)
                                               name:UIKeyboardDidChangeFrameNotification object:nil];
}
//__________________________________________________________________________________________________

- (void)unregisterFromKeyboardNotifications
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification       object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification        object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification       object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification        object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}
//__________________________________________________________________________________________________

//! Called when the UIKeyboardDidChangeFrameNotification is sent:
- (void)keyboardHasChangedFrame:(NSNotification*)notification
{
  NSDictionary* info        = [notification userInfo];
  CGRect keyboard_frame     = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
  keyboard_frame            = [self convertRect:keyboard_frame fromView:nil];
  if ((keyboard_frame.origin.x == 0) && (keyboard_frame.origin.y != self.bounds.size.height))
  {
    KeyboardHeight  = keyboard_frame.size.height;
    KeyboardTop     = keyboard_frame.origin.y;
    [self setNeedsLayout];
  }
  //  NSLog(@"keyboard_frame: %f, %f, %f, %f", keyboard_frame.origin.x, keyboard_frame.origin.y, keyboard_frame.size.width, keyboard_frame.size.height);
}
//__________________________________________________________________________________________________

//! Called when the UIKeyboardWillShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)notification
{
  CGRect leftFrame    = LeftButton.frame;
  CGRect rightFrame   = RightButton.frame;
  leftFrame.origin.y  = KeyboardTop - leftFrame.size.height;
  rightFrame.origin.y = KeyboardTop - rightFrame.size.height;
  [UIView animateWithDuration:0.25 animations:^
  {
    LeftButton.frame   = leftFrame;
    RightButton.frame  = rightFrame;
  }];
}
//__________________________________________________________________________________________________

//! Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardDidShow:(NSNotification*)notification
{
}
//__________________________________________________________________________________________________

//! Called when the UIKeyboardWillHideNotification is sent:
- (void)keyboardWillBeHidden:(NSNotification*)notification
{
  CGRect leftFrame    = LeftButton.frame;
  CGRect rightFrame   = RightButton.frame;
  leftFrame.origin.y  = self.frame.size.height;
  rightFrame.origin.y = self.frame.size.height;
  [UIView animateWithDuration:0.25 animations:^
  {
    LeftButton.frame   = leftFrame;
    RightButton.frame  = rightFrame;
  }];
}
//__________________________________________________________________________________________________

//! Called when the UIKeyboardWillHideNotification is sent:
- (void)keyboardDidHide:(NSNotification*)notification
{
}
//__________________________________________________________________________________________________
@end
