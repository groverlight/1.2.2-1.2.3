
//! \file   TypingView.m
//! \brief  UIView based class that contains an editor to create the falling texts.
//__________________________________________________________________________________________________

#import "TypingView.h"
#import "Alert.h"
#import "WhiteButton.h"
#import "EditView.h"
#import "GlobalParameters.h"
#import "PopLabel.h"
#import "StillImageCapture.h"
#import "Tools.h"
#import "TopBarView.h"
#import "Mixpanel.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Colors.h"
//__________________________________________________________________________________________________

#define FACE_BUTTON_ALERT_FLAG_DEFAULTS_KEY @"FaceButtonAlertFlag"  //!< The key to retrieve the FACE button alert flag in the user defaults.
#define GO_BUTTON_ALERT_FLAG_DEFAULTS_KEY   @"GoButtonAlertFlag"    //!< The key to retrieve the GO button alert flag in the user defaults.
//
//__________________________________________________________________________________________________

//! UIView based class that contains an editor to create the falling texts.
@implementation TypingView
{
  CGFloat               KeyboardHeight;             //!< The height of the currently displayed keyboard.
  CGFloat               KeyboardTop;                //!< The vertical position of the top of the keyboard.
  PopLabel*             CharactersLeftLabel;        //!< Label displaying the number of character available to add to the current text.
  //EditView*             TextView;                   //!< The text editor view.
  WhiteButton*          FaceButton;                 //!< The FACE white button.
  NSInteger             NumCharactersLeft;          //!< Number of character available to add to the current text.
  NSInteger             FaceCount;
  BOOL                  ChangingReturnButtonType;
  SystemSoundID         soundEffect;
  BOOL permission;



}
@synthesize snapshots;
//____________________

- (void)reset
{
  GlobalParameters* parameters  = GetGlobalParameters();
  [snapshots  removeAllObjects];
  FaceCount                    = 0;
  TextView.largeFontSize      = parameters.typingLargeFontSize;
  TextView.smallFontSize      = parameters.typingSmallFontSize;
  TextView.disableTextEdition = NO;

  [self updateUI];

}


//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{

  [super Initialize];
  permission = NO;
  CharactersLeftLabel = [PopLabel     new];
  TextView            = [EditView     new];
  FaceButton          = [WhiteButton  new];
  [self       addSubview:TextView];
  [self       addSubview:FaceButton];
  [FaceButton addSubview:CharactersLeftLabel];

  KeyboardTop     = -1;
  KeyboardHeight  = 0;
  [self registerForKeyboardNotifications];

  GlobalParameters* parameters      = GetGlobalParameters();

  ChangingReturnButtonType          = NO;
  TextView.ignoreReturnKey          = YES;
  FaceButton.title                  = parameters.typingFaceButtonTitle;
  FaceButton.enabled                = NO;
  CharactersLeftLabel.text          = [NSString stringWithFormat:@"%d", (int)parameters.typingMaxCharacterCount];
  CharactersLeftLabel.textColor     = parameters.typingCharacterCountColor;
  CharactersLeftLabel.outline       = NO;
  CharactersLeftLabel.textAlignment = NSTextAlignmentRight;
  CharactersLeftLabel.font          = [UIFont fontWithName:@"AvenirNext-Bold" size:parameters.typingCharacterCountFontSize];
  CharactersLeftLabel.size          = CalculateTextSize(@"999", CGSizeMake(100, 100), CharactersLeftLabel.font);



  snapshots = [[NSMutableArray alloc] initWithCapacity:10];
  [self reset];

  set_myself;
  GoButtonPressed = ^
  { // Default action: do nothing!
  };

  PleaseFlashForDuration = ^(CGFloat duration, BlockAction completion)
  { // Default action: do nothing!
  };

    FaceButton.pressedAction = ^
    {
        get_myself;

        NSUserDefaults* defaults  = [NSUserDefaults standardUserDefaults];
        BOOL faceAlertAlreadyDone = [defaults boolForKey:FACE_BUTTON_ALERT_FLAG_DEFAULTS_KEY];

        if (faceAlertAlreadyDone)
        {

            [myself faceButtonPressed];



        }
        else
        {
            NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"beep_prompt_2x"ofType:@"aif"];
            NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
            AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &(myself->soundEffect));

            AudioServicesPlaySystemSound(myself->soundEffect);

            NSLog(@"Calls the selfie alert!");
            Alert(parameters.typingLeftButtonAlertTitle   , parameters.typingLeftButtonAlertMessage,
                  parameters.typingLeftButtonAlertOkString, parameters.typingLeftButtonAlertCancelString,
                  ^(NSInteger pressedButtonIndex)
                  {
                      [defaults setBool:YES forKey:FACE_BUTTON_ALERT_FLAG_DEFAULTS_KEY];
                      if (pressedButtonIndex == 1)
                      {
                          [myself faceButtonPressed];

                          NSLog(@"YES SELFIE");

                          Mixpanel *mixpanel = [Mixpanel sharedInstance];

                          [mixpanel track:@"selfie understood"];

                          [mixpanel identify:mixpanel.distinctId];

                          [mixpanel.people increment:@"Selfie Understood" by:[NSNumber numberWithInt:1]];
                      }
                      else {

                          NSLog(@"NO SELFIE");

                          Mixpanel *mixpanel = [Mixpanel sharedInstance];

                          [mixpanel track:@"selfie NOT understood"];

                          [mixpanel identify:mixpanel.distinctId];

                          [mixpanel.people increment:@"selfie NOT understood" by:[NSNumber numberWithInt:1]];

                      }

                  });

        }
    };
    TextView->DidBeginEditingAction = ^
    {

        get_myself;

       // NSLog(@"Kylie");

        if (myself->TextView.totalNumCharacters == 0) {
            myself->FaceButton.backgroundColor = TypePink;
            myself->CharactersLeftLabel.textColor = [Black colorWithAlphaComponent:0.2];
            myself->FaceButton.title = @"START TYPING";
            myself->FaceButton.enabled = NO;

        }

        else {
//                    FaceButton.backgroundColor = [UIColor clearColor];
//                    FaceButton.layer.borderWidth = 2;
//                    FaceButton.layer.borderColor = TypePink.CGColor;
//                    CharactersLeftLabel.textColor = TypePink;
//                    FaceButton.title = @"K";

        }

    };
    TextView->TextDidChangeAction = ^
    {
        NSLog(@"Kendall");

        get_myself;


        if (myself->TextView.totalNumCharacters == 0) {
            myself->FaceButton.backgroundColor = TypePink;
            myself->CharactersLeftLabel.textColor = [Black colorWithAlphaComponent:0.2];
            myself->FaceButton.title = @"START TYPING";
            myself->FaceButton.enabled = NO;

        }

        else {
            myself->FaceButton.backgroundColor = [UIColor clearColor];
            myself->FaceButton.layer.borderWidth = 2;
            myself->FaceButton.layer.borderColor = TypePink.CGColor;
            myself->CharactersLeftLabel.textColor = TypePink;
            myself->FaceButton.title = @"TAKE SELFIE";
            myself->FaceButton.enabled = YES;
        }


        myself->TextView.disableTextEdition = NO;
        myself->TextView.useSmallFont       = (myself->TextView.totalNumCharacters > parameters.typingFontSizeCharacterCountTrigger);

        //myself->FaceButton.enabled = (myself->TextView.numUnvalidatedChars > 0);

        myself->ChangingReturnButtonType = YES;
        [myself->TextView showGoKey:((myself->TextView.numUnvalidatedChars == 0) && (myself->TextView.textRecords.count > 0))];
        myself->ChangingReturnButtonType = NO;
        [myself updateUI];

    };
    TextView->SelectionDidChangeAction = ^
    {


    };
    TextView->DidEndEditingAction = ^
    {

    };
    TextView->ShouldBeginEditingAction = ^BOOL()
    {
        return YES;
    };
    TextView->DidDeleteLastChunk = ^
    { 
        get_myself;
        if (myself->FaceCount > 0)
        {
            [myself removeSnapshot];
            --myself->FaceCount;
        }
    };
    TextView->DidPressGoButton = ^
    {

        get_myself;
        [myself->TextView resignFirstResponder];
        NSUserDefaults* defaults  = [NSUserDefaults standardUserDefaults];
        BOOL goAlertAlreadyDone   = [defaults boolForKey:GO_BUTTON_ALERT_FLAG_DEFAULTS_KEY];
        if (goAlertAlreadyDone)
        {
            [myself goButtonPressed];
        }
        else
        {
            NSLog(@"Calls send message alert");

            NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"beep_prompt_2x"ofType:@"aif"];
            NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
            AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &(myself->soundEffect));

            AudioServicesPlaySystemSound(myself->soundEffect);

            Alert(parameters.typingRightButtonAlertTitle   , parameters.typingRightButtonAlertMessage,
                  parameters.typingRightButtonAlertOkString, parameters.typingRightButtonAlertCancelString,
                  ^(NSInteger pressedButtonIndex)
                  {
                      [defaults setBool:YES forKey:GO_BUTTON_ALERT_FLAG_DEFAULTS_KEY];
                      if (pressedButtonIndex == 1)
                      {
                          [myself goButtonPressed];
                          Mixpanel *mixpanel = [Mixpanel sharedInstance];

                          [mixpanel track:@"go understood"];

                          [mixpanel identify:mixpanel.distinctId];

                          [mixpanel.people increment:@"Go understood" by:[NSNumber numberWithInt:1]];
                      }
                      else
                      {
                          [myself->TextView becomeFirstResponder];
                          Mixpanel *mixpanel = [Mixpanel sharedInstance];
                          
                          [mixpanel track:@"go NOT understood"];
                          
                          [mixpanel identify:mixpanel.distinctId];
                          
                          [mixpanel.people increment:@"go NOT understood" by:[NSNumber numberWithInt:1]];
                      }
                  });
        }
    };
}
//__________________________________________________________________________________________________

- (void)dealloc
{
  [self unregisterFromKeyboardNotifications];
  [self cleanup];
}
//__________________________________________________________________________________________________

- (void)cleanup
{
}
//__________________________________________________________________________________________________

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
                                           selector:@selector(keyboardWillChangedFrame:)
                                               name:UIKeyboardWillChangeFrameNotification object:nil];
}
//__________________________________________________________________________________________________

- (void)unregisterFromKeyboardNotifications
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification         object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification          object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification         object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification          object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification  object:nil];
}
//__________________________________________________________________________________________________

//! Called when the UIKeyboardDidChangeFrameNotification is sent:
- (void)keyboardWillChangedFrame:(NSNotification*)notification
{
  NSDictionary* info        = [notification userInfo];
  CGRect keyboard_frame     = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
  keyboard_frame            = [self convertRect:keyboard_frame fromView:nil];
//  if ((keyboard_frame.origin.x == 0) && (keyboard_frame.origin.y != self.bounds.size.height))
  if (keyboard_frame.origin.x == 0)
  {
    KeyboardHeight  = keyboard_frame.size.height;
    KeyboardTop     = keyboard_frame.origin.y;
    if (!ChangingReturnButtonType)
    {
      [self layout];
    }
  }
//  NSLog(@"keyboard_frame: %f, %f, %f, %f", keyboard_frame.origin.x, keyboard_frame.origin.y, keyboard_frame.size.width, keyboard_frame.size.height);
}
//__________________________________________________________________________________________________

//! Called when the UIKeyboardWillShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)notification
{
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
}
//__________________________________________________________________________________________________

//! Called when the UIKeyboardWillHideNotification is sent:
- (void)keyboardDidHide:(NSNotification*)notification
{
}
//__________________________________________________________________________________________________

- (void)friendsSwiped:(UISwipeGestureRecognizer*)gesture
{
  NSLog(@"friendsSwiped");
}
//__________________________________________________________________________________________________

- (void)faceButtonPressed
{



  [TextView setChunkIsComplete];
  [self addSnapshot];
  ++FaceCount;
  GlobalParameters* parameters  = GetGlobalParameters();
  NumCharactersLeft = parameters.typingMaxCharacterCount - TextView.numUnvalidatedChars;
  ChangingReturnButtonType = YES;
  [TextView showGoKey:YES];
  ChangingReturnButtonType = NO;

  FaceButton.backgroundColor = TypePink;
  CharactersLeftLabel.textColor = [Black colorWithAlphaComponent:0.2];
  FaceButton.title = @"KEEP TYPING";
  FaceButton.enabled = NO;
  [self updateUI];
}
//__________________________________________________________________________________________________

- (void)goButtonPressed
{
  GoButtonPressed();
}
//__________________________________________________________________________________________________

- (void)updateUI
{
  NumCharactersLeft           = GetGlobalParameters().typingMaxCharacterCount - TextView.numUnvalidatedChars;
  CharactersLeftLabel.text    = [NSString stringWithFormat:@"%d", (int)NumCharactersLeft];
  TextView.disableTextEdition = (NumCharactersLeft <= 0);


}
//__________________________________________________________________________________________________

- (void)layout
{
//  NSLog(@"layout!\n\n");
  if (KeyboardTop == -1)
  {
    KeyboardTop = self.height;
  }
  GlobalParameters* parameters  = GetGlobalParameters();
  FaceButton.size               = [FaceButton  sizeThatFits:self.size];
  FaceButton.width              = parameters.faceButtonWidth;
  FaceButton.bottom             = KeyboardTop - parameters.typingFaceButtonGap;
  //FaceButton.left               = parameters.typingFaceButtonLateralMargin;


  TextView.width                = self.width - 2 * parameters.typingEditorLateralMargin;
  TextView.height               = FaceButton.top - parameters.headerHeight - parameters.typingTopOffset - parameters.typingFaceButtonGap;
    //TextView.bottom               = FaceButton.top - parameters.typingTextBlockGap;
    TextView.bottom               = FaceButton.top - 30;
  TextView.left                 = parameters.typingEditorLateralMargin;
    //TextView.backgroundColor = [UIColor grayColor];
    
  // The CharactersLeftLabel is positioned relative to its superview, the face button.
  CharactersLeftLabel.right     = FaceButton.width - parameters.typingCharacterCountRightMargin;
  [CharactersLeftLabel centerVertically];
  [FaceButton     centerHorizontally];
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
  [super  layoutSubviews];
  [self   layout];
}
//__________________________________________________________________________________________________

- (void)addSnapshot
{
  GlobalParameters* parameters = GetGlobalParameters();
  BOOL hideKeyboard = parameters.typingHideKeyboardDuringFlash;
//  NSLog(@"addSnapshot");
  CGFloat duration = parameters.typingSnapshotFlashDuration;
  if (hideKeyboard)
  {
    [TextView resignFirstResponder];
  }
//  NSLog(@"Start flash!");
  PleaseFlashForDuration(duration, ^
  {
//    NSLog(@"Flash ended!\n\n");
    if (!TextView.isFirstResponder)
    {
//      NSLog(@"TextView was not first responder!\n\n");
      [TextView becomeFirstResponder];
      [self setNeedsLayout];
    }
  });
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration / 2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
  {
//    NSLog(@"takeSnapshot");
    [[StillImageCapture sharedCapture] takeSnapshot:^(id obj)
    {
      if (obj != nil)
      {
//        NSLog(@"snapshot taken!");
        [snapshots addObject:obj];
      }
    }];
  });
}
//__________________________________________________________________________________________________

- (void)removeSnapshot
{
  if (snapshots.count > 0)
  {
    [snapshots removeLastObject];
  }
}
//__________________________________________________________________________________________________

- (NSArray*)textRecords
{
  return TextView.textRecords;
}
//__________________________________________________________________________________________________

//! Clear the editing string.
- (void)clearText
{
  [TextView   clearText];
  [snapshots  removeAllObjects];
  [self       updateUI];
}
//__________________________________________________________________________________________________

//! Build a message from currently edited texts and snapshots.
- (Message*)buildTheMessage
{
  Message* msg    = [Message new];
  msg->Snapshots  = [NSMutableArray arrayWithArray:snapshots];
  msg->Texts      = [NSArray arrayWithArray:TextView.textRecords];
  msg->Timestamp  = [NSDate date].timeIntervalSince1970;
  return msg;
}
//__________________________________________________________________________________________________

- (void)activate
{
    //NSLog(@"activate text view");
  [TextView activate];
}
//__________________________________________________________________________________________________

@end
