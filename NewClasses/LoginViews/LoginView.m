//! \file   LoginView.m
//! \brief  Class that handle user registration and login.
//__________________________________________________________________________________________________

#import "GlobalParameters.h"
#import "IntlPhonePrefixPicker.h"
#import "LoginView.h"
#import "Parse.h"
#import "RollDownView.h"
#import "Tools.h"
#import "Colors.h"
#import "Mixpanel.h"
#import <AudioToolbox/AudioToolbox.h>

//__________________________________________________________________________________________________

#define LOGIN_STATE_DEFAULTS_KEY              @"LoginState"             //!< The key to retrieve the login state in the user defaults.
#define LOGIN_COUNTRY_NAME_DEFAULTS_KEY       @"LoginCountryName"       //!< The key to retrieve the country prefix in the user defaults.
#define LOGIN_PHONE_NUMBER_DEFAULTS_KEY       @"LoginPhoneNumber"       //!< The key to retrieve the phone number in the user defaults.
#define LOGIN_VERIFICATION_CODE_DEFAULTS_KEY  @"LoginVerificationCode"  //!< The key to retrieve the verification code in the user defaults.
#define LOGIN_USER_OBJECT_ID_DEFAULTS_KEY     @"LoginUserObjectId"      //!< The key to retrieve the user objectId in the user defaults.
#define LOGIN_USER_NAME_DEFAULTS_KEY          @"LoginUsername"          //!< The key to retrieve the username in the user defaults.
#define LOGIN_FULL_NAME_DEFAULTS_KEY          @"LoginFullName"          //!< The key to retrieve the user's full name in the user defaults.
//__________________________________________________________________________________________________

#define FIRST_LABEL_TOP_OFFSET        40  //!< Position of the top of the first label.
#define SECOND_LABEL_TOP_OFFSET       FIRST_LABEL_TOP_OFFSET + 34  //!< Position of the top of the second label.
#define SEPARATOR_END_MARGIN          20  //!< Right margin of the separator lines.
#define SEPARATOR_LINE_WIDTH          0.40   //!< Width of the separator lines.
#define FIRST_SEPARATOR_TOP_OFFSET    130 //!< Vertical position of the first separator line.
#define SECOND_SEPARATOR_TOP_OFFSET   170 //!< Vertical position of the second separator line.
#define EDITOR_VERTICAL_CENTER        ((FIRST_SEPARATOR_TOP_OFFSET + SECOND_SEPARATOR_TOP_OFFSET) / 2)  //!< Vertical position of the phone number editor center line.
#define PREFIX_LEFT_MARGIN            40  //!< Phone number prefix label left margin.
#define PREFIX_WIDTH                  60  //!< Phone number prefix label width.
#define EDITOR_GAP                    8   //!< Gap between the prefix label and the phone number editor.
#define EDITOR_RIGHT_MARGIN           40  //!< Phone number editor right margin.
#define BUTTON_BOTTOM_MARGIN          45  //!< Distance from the keyboard top position for the left and right buttons.
#define BUTTON_MARGIN                 20  //!< Distance from the border for the left and right buttons.
#define BUTTON_WIDTH                  100 //!< Width of the left and right buttons.
#define POLICY_TEXT_TOP_MARGIN        180 //!< Vertical position of the policy text.
#define POLICY_TEXT_WIDTH             300 //!< Width of the policy text.
#define POLICY_TEXT_HEIGHT            60  //!< Height of the policy text.
#define DEFAULT_KEYBOARD_HEIGHT       216 //!< Default keyboard height.
#define ROLL_DOWN_VIEW_HEIGHT         60  //!< Roll down error message view height.
#define PARSE_ERROR_CODE              141 //!< Error code specific to the Parse library.
#define PREFIX_LABEL_TAP_MARGIN       6  //!< Margin to make easier to tap on the country code label.
#define THIRD_SEPARATOR_TOP_OFFSET    90


// NEW SHIT

#define ONE_LABEL_TOP_OFFSET          14
#define TWO_LABEL_TOP_OFFSET          14
#define THREE_LABEL_TOP_OFFSET        14

#define PROGRESS_LIGHT_BOTTOM_OFFSET  30
#define PROGRESS_DARK_BOTTOM_OFFSET   30



//__________________________________________________________________________________________________

//! States of the login state machine.
typedef enum
{
    E_LoginState_LoggedOut = 0,
    E_LoginState_PhoneNumber,
    E_LoginState_VerificationCode,
    E_LoginState_Username,
    E_LoginState_LoggedIn
} LoginState;
//__________________________________________________________________________________________________

//! CardView based class that handle user registration and login.
@interface LoginView() <UIWebViewDelegate, UITextFieldDelegate>
{
}
//____________________

@end
//__________________________________________________________________________________________________

//! CardView based class that handle user registration and login.
@implementation LoginView
{
    LoginState              State;                  //!< Current state of the login state machine.
    RollDownView*           RollDownErrorView;      //!< The roll down error message view.
    UILabel*                FirstLabel;             //!< The label at the top of the view.
    UILabel*                SecondLabel;            //!< The second label from the top of the view.
    UIView*                 FirstSeparatorView;     //!< The first separator line view.

    UILabel*                OneLabel;
    UILabel*                TwoLabel;
    UILabel*                ThreeLabel;

    UIView*                 ProgressLight;
    UIView*                 ProgressDark;

    UILabel*                PrefixLabel;            //!< The country prefix label.
    UITextField*            UpperEditor;            //!< The user's full name editor.
    UITextField*            LowerEditor;            //!< The phone number, verification code and username editor.
    UIView*                 SecondSeparatorView;    //!< The second separator line view.
    UIView*                 ThirdSeparatorView;
    UIWebView*              PolicyText;             //!< The policy text view.
    IntlPhonePrefixPicker*  PickerView;             //!< The country selector view.
    UIButton*               LeftButton;             //!< The left button control.
    UIButton*               RightButton;            //!< The right button control.
    CGFloat                 KeyboardHeight;         //!< The height of the currently displayed keyboard.
    CGFloat                 KeyboardTop;            //!< The vertical position of the top of the keyboard.
    CGFloat                 EditorHeight;           //!< The height of the editor views.
    CGFloat                 UpperEditorTop;         //!< Vertical position of the top of the upper editor.
    CGFloat                 LowerEditorTop;         //!< Vertical position of the top of the lower editor.
    
    BlockBoolAction         LoginDoneAction;        //!< Action block called when the login process has terminated.
    
    NSInteger               SelectedCountryIndex;   //!< Index of the selected country.
    NSString*               SelectedCountryName;    //!< Name of the selected country.
    NSString*               SelectedCountryPrefix;  //!< Prefix code of the selected country.
    NSString*               PhoneNumber;            //!< The edited phone number.
    NSString*               FullPhoneNumber;        //!< The complete phone number with the country code.
    NSString*               VerificationCode;       //!< The edited verification code.
    NSString*               FullName;               //!< The edited user's full name.
    NSString*               Username;               //!< The edited username.
    NSString*               UserObjectId;           //!< The existing user objectId.
    ParseUser*              RecoveredUser;
    
    GlobalParameters*       GlobalParams;           //!< Copy of the global parameters object pointer.
    
    UIColor*                TextColor;              //!< Color of the user's full name texts.
    BOOL                    Animated;               //!< Temporary value for the animated flag for some methods when performed on main thread.
    SystemSoundID           soundEffect;



}

//_______________________________

//! Initialize the object however it has been created.
-(void)Initialize
{
    [super Initialize];

    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    KeyboardHeight  = DEFAULT_KEYBOARD_HEIGHT;
    GlobalParams    = GetGlobalParameters();
    
    //  [self.gradientView setInitialGradientColors:[UIColor orangeColor] bottomcolor:[UIColor brownColor]];
    
    set_myself;
    
    LoginDoneAction = ^(BOOL newUser)
    { // Default action: do nothing.
    };
    
    RollDownErrorView         = [RollDownView          new];
    FirstLabel                = [UILabel               new];
    SecondLabel               = [UILabel               new];

    OneLabel                  = [UILabel               new];
    TwoLabel                  = [UILabel               new];
    ThreeLabel                = [UILabel               new];

    ProgressLight             = [UIView                new];
    ProgressDark              = [UIView                new];

    FirstSeparatorView        = [UIView                new];
    ThirdSeparatorView        = [UIView                new];
    PrefixLabel               = [UILabel               new];
    UpperEditor               = [UITextField           new];
    LowerEditor               = [UITextField           new];
    SecondSeparatorView       = [UIView                new];
    PolicyText                = [UIWebView             new];
    PickerView                = [IntlPhonePrefixPicker new];
    LeftButton                = [UIButton buttonWithType:UIButtonTypeSystem];
    RightButton               = [UIButton buttonWithType:UIButtonTypeSystem];



    //Define all properties that ONLY stay the same

    FirstLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:21];
    FirstLabel.numberOfLines = 2;
    FirstLabel.textAlignment  = NSTextAlignmentCenter;
    FirstLabel.textColor = WarmGrey;

    
    SecondLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:13];
    SecondLabel.numberOfLines = 1;
    SecondLabel.textAlignment = NSTextAlignmentCenter;
    SecondLabel.textColor = [WarmGrey colorWithAlphaComponent:0.4];
    
    PrefixLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:19];
    PrefixLabel.hidden    = NO;
    PrefixLabel.textColor = WarmGrey;


    OneLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:12];
    OneLabel.numberOfLines = 1;
    OneLabel.textAlignment  = NSTextAlignmentCenter;
    OneLabel.textColor = WarmGrey;

    TwoLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:12];
    TwoLabel.numberOfLines = 1;
    TwoLabel.textAlignment  = NSTextAlignmentCenter;
    TwoLabel.textColor = WarmGrey;

    ThreeLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:12];
    ThreeLabel.numberOfLines = 1;
    ThreeLabel.textAlignment  = NSTextAlignmentCenter;
    ThreeLabel.textColor = WarmGrey;

    
    UpperEditor.placeholder        = GlobalParams.fullNamePlaceholder;

    UpperEditor.delegate           = self;
    UpperEditor.keyboardType       = UIKeyboardTypeASCIICapable;
    //UpperEditor.keyboardAppearance = UIKeyboardAppearanceDark;
    UpperEditor.enabled            = NO;
    UpperEditor.autocorrectionType = UITextAutocorrectionTypeNo;
    UpperEditor.spellCheckingType  = UITextSpellCheckingTypeNo;
    
    [UpperEditor addTarget:self action:@selector(editorTextChanged:) forControlEvents:UIControlEventEditingChanged];
    [UpperEditor setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:19]];
    [UpperEditor setAdjustsFontSizeToFitWidth:NO];
    [UpperEditor setTextColor:WarmGrey];

;
    LowerEditor.delegate            = self;
    LowerEditor.placeholder         = GlobalParams.phoneNumberPlaceholder;
    LowerEditor.keyboardType        = UIKeyboardTypePhonePad;
    //LowerEditor.keyboardAppearance = UIKeyboardAppearanceDark;
    LowerEditor.enabled             = NO;
    LowerEditor.autocorrectionType  = UITextAutocorrectionTypeNo;
    LowerEditor.spellCheckingType   = UITextSpellCheckingTypeNo;
    LowerEditor.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    
    [LowerEditor addTarget:self action:@selector(editorTextChanged:) forControlEvents:UIControlEventEditingChanged];
    [LowerEditor setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:19]];
    [LowerEditor setAdjustsFontSizeToFitWidth:NO];
    [LowerEditor setTextColor:WarmGrey];
    
    RightButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:20];
    LeftButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold"  size:20];
    
    LowerEditor.delegate            = self;
    LowerEditor.placeholder         = GlobalParams.phoneNumberPlaceholder;
    LowerEditor.keyboardType        = UIKeyboardTypePhonePad;
    LowerEditor.enabled             = NO;
    //  LowerEditor.autocorrectionType  = UITextAutocorrectionTypeNo;
    //  LowerEditor.spellCheckingType   = UITextSpellCheckingTypeNo;
    [LowerEditor addTarget:self action:@selector(editorTextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    
    PolicyText.delegate                 = self;
    PolicyText.backgroundColor          = [UIColor clearColor];
    PolicyText.opaque                   = NO;
    PolicyText.scrollView.scrollEnabled = NO;
    [self InitializeTermsAndPrivacyPolicyMessage];
    
    FirstSeparatorView.backgroundColor  = [UIColor clearColor];
    SecondSeparatorView.backgroundColor = [UIColor clearColor];
    //ThirdSeparatorView.backgroundColor = [UIColor clearColor];


    
    [LeftButton   setTitle:GlobalParams.loginLeftButtonLabel  forState:UIControlStateNormal];
    [RightButton  setTitle:GlobalParams.loginRightButtonLabel forState:UIControlStateNormal];
    LeftButton.tintColor = TextColor;
    RightButton.tintColor = TextColor;
    [LeftButton  addTarget:self action:@selector(leftButtonPressed:)  forControlEvents:UIControlEventTouchUpInside];
    [RightButton addTarget:self action:@selector(rightButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    LeftButton.hidden   = YES;
    RightButton.enabled = NO;
    
    [PickerView setBackgroundColor:White];

    
    [self addSubview:FirstLabel];
    [self addSubview:SecondLabel];
    [self addSubview:OneLabel];
    [self addSubview:TwoLabel];
    [self addSubview:ThreeLabel];
    [self addSubview:FirstSeparatorView];
    [self addSubview:ProgressLight];
    [self addSubview:ProgressDark];
    [self addSubview:UpperEditor];
    [self addSubview:LowerEditor];
    [self addSubview:SecondSeparatorView];
    [self addSubview:ThirdSeparatorView];
    [self addSubview:PrefixLabel];
    [self addSubview:PolicyText];
    [self addSubview:PickerView];
    [self addSubview:LeftButton];
    [self addSubview:RightButton];
    [self addSubview:RollDownErrorView];
    [self registerForKeyboardNotifications];
    
    NSUserDefaults* defaults  = [NSUserDefaults standardUserDefaults];
    PickerView.rowSelectedAction = ^(NSInteger row)
    {
        get_myself;
        myself->SelectedCountryIndex  = row;
        myself->SelectedCountryName   = [myself->PickerView getCountryNameAtRow:row];
        myself->SelectedCountryPrefix = [myself->PickerView getCountryPrefixAtRow:row];
        myself->SecondLabel.text      = myself->SelectedCountryName;
        myself->PrefixLabel.text      = myself->SelectedCountryPrefix;
        myself->UpperEditor.enabled   = YES;
        myself->LowerEditor.enabled   = YES;
        myself->FullPhoneNumber       = [myself->SelectedCountryPrefix stringByAppendingString:myself->PhoneNumber];
        [defaults setObject:myself->SelectedCountryName forKey:LOGIN_COUNTRY_NAME_DEFAULTS_KEY];
        [myself layoutEditorAnimated:NO];
        
        
    };
    
    UITapGestureRecognizer* prefixGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(prefixTapped:)];
    [PrefixLabel addGestureRecognizer:prefixGestureRecognizer];
    PrefixLabel.userInteractionEnabled = YES;
    //  self.backgroundColor = White;
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width             = self.frame.size.width;
    CGFloat height            = self.frame.size.height;
    EditorHeight              = [UpperEditor sizeThatFits:self.frame.size].height;
    UpperEditorTop            = SECOND_LABEL_TOP_OFFSET+ 40;
    LowerEditorTop            = UpperEditorTop + 30;
    KeyboardTop               = height - KeyboardHeight;
    RollDownErrorView.frame   = CGRectMake(0, 0, width, [RollDownErrorView sizeThatFits:self.frame.size].height);
    FirstLabel.frame          = CGRectMake(0, FIRST_LABEL_TOP_OFFSET , width, [FirstLabel  sizeThatFits:self.frame.size].height);
    SecondLabel.frame         = CGRectMake(0, SECOND_LABEL_TOP_OFFSET, width, [SecondLabel sizeThatFits:self.frame.size].height);

    //OneLabel.frame            = CGRectMake(30, ONE_LABEL_TOP_OFFSET, width, [OneLabel sizeThatFits:self.frame.size].height);
    //TwoLabel.frame            = CGRectMake(0, TWO_LABEL_TOP_OFFSET, width, [TwoLabel sizeThatFits:self.frame.size].height);
    //ThreeLabel.frame          = CGRectMake(-30, THREE_LABEL_TOP_OFFSET, width, [ThreeLabel sizeThatFits:self.frame.size].height);

    FirstSeparatorView.frame  = CGRectMake(SEPARATOR_END_MARGIN, FIRST_SEPARATOR_TOP_OFFSET , width - 2 * SEPARATOR_END_MARGIN, SEPARATOR_LINE_WIDTH);
    FirstSeparatorView.frame  = CGRectMake(SEPARATOR_END_MARGIN, FIRST_SEPARATOR_TOP_OFFSET , width - 2 * SEPARATOR_END_MARGIN, SEPARATOR_LINE_WIDTH);





    //  UpperEditor.frame         = CGRectMake(0, UpperEditorTop         , width, [UpperEditor sizeThatFits:self.frame.size].height);
    FirstSeparatorView.frame  = CGRectMake(SEPARATOR_END_MARGIN, FIRST_SEPARATOR_TOP_OFFSET , width - 2 * SEPARATOR_END_MARGIN, SEPARATOR_LINE_WIDTH);
    if (!self.hidden)
    {
        [self layoutEditorAnimated:NO];
    }
    //  PrefixLabel.frame         = CGRectMake(PREFIX_LEFT_MARGIN, EditorTop, PREFIX_WIDTH, EditorHeight);
    //  CGFloat prefixWidth       = PrefixLabel.frame.size.width;
    //  CGFloat editorWidth       = width - PREFIX_LEFT_MARGIN - prefixWidth - EDITOR_GAP - EDITOR_RIGHT_MARGIN;
    //  Editor.frame              = CGRectMake(PREFIX_LEFT_MARGIN + PrefixLabel.frame.size.width + EDITOR_GAP, EditorTop, editorWidth, EditorHeight);
    SecondSeparatorView.frame = CGRectMake(SEPARATOR_END_MARGIN, SECOND_SEPARATOR_TOP_OFFSET, width - 2 * SEPARATOR_END_MARGIN, SEPARATOR_LINE_WIDTH);
    ThirdSeparatorView.frame  = CGRectMake(SEPARATOR_END_MARGIN, THIRD_SEPARATOR_TOP_OFFSET, width - 2 * SEPARATOR_END_MARGIN, SEPARATOR_LINE_WIDTH);
    PolicyText.frame          = CGRectMake(10, POLICY_TEXT_TOP_MARGIN, POLICY_TEXT_WIDTH, POLICY_TEXT_HEIGHT);
    CGFloat pickerHeight      = [PickerView sizeThatFits:self.frame.size].height;
    PickerView.frame          = CGRectMake(0, height - pickerHeight, width, pickerHeight);
    CGFloat buttonHeight      = [LeftButton   sizeThatFits:self.frame.size].height;
    CGFloat leftButtonWidth   = [LeftButton   sizeThatFits:self.frame.size].width;
    CGFloat rightButtonWidth  = [RightButton  sizeThatFits:self.frame.size].width;
    LeftButton.frame          = CGRectMake(BUTTON_MARGIN, KeyboardTop - BUTTON_BOTTOM_MARGIN - buttonHeight, leftButtonWidth , buttonHeight);
    RightButton.frame         = CGRectMake(width - BUTTON_MARGIN - rightButtonWidth, KeyboardTop - BUTTON_BOTTOM_MARGIN - buttonHeight, rightButtonWidth, buttonHeight);
    LeftButton.titleLabel.textAlignment   = NSTextAlignmentLeft;
    RightButton.titleLabel.textAlignment  = NSTextAlignmentRight;
}
//__________________________________________________________________________________________________

- (void)recoverSavedState:(BlockAction)completion
{
    NSUserDefaults* defaults  = [NSUserDefaults standardUserDefaults];
    State                     = (LoginState)[defaults integerForKey:LOGIN_STATE_DEFAULTS_KEY];
    SelectedCountryName       = [defaults stringForKey:LOGIN_COUNTRY_NAME_DEFAULTS_KEY];
    PhoneNumber               = [defaults stringForKey:LOGIN_PHONE_NUMBER_DEFAULTS_KEY];
    VerificationCode          = [defaults stringForKey:LOGIN_VERIFICATION_CODE_DEFAULTS_KEY];
    UserObjectId              = [defaults stringForKey:LOGIN_USER_OBJECT_ID_DEFAULTS_KEY];
    Username                  = [defaults stringForKey:LOGIN_USER_NAME_DEFAULTS_KEY];
    FullName                  = [defaults stringForKey:LOGIN_FULL_NAME_DEFAULTS_KEY];
    if (UserObjectId != nil)
    {
        [ParseUser findUserWithObjectId:UserObjectId completion:^(ParseUser* user, NSError* error)
         {
             RecoveredUser = user;
             completion();
         }];
    }
    else
    {
        completion();
    }
}
//__________________________________________________________________________________________________

- (void)layoutEditorAnimatedInMainThread
{
    NSUserDefaults* defaults  = [NSUserDefaults standardUserDefaults];
    if (SelectedCountryName == nil)
    {
        SelectedCountryName = GlobalParams.initialCountry;
        PhoneNumber         = @"";
        VerificationCode    = @"";
        Username            = @"";
        FullName            = @"";
    }
    else
    {
        SecondLabel.text    = @"We'll text you a verification\n code to log you in";
        UpperEditor.enabled = YES;
        LowerEditor.enabled = YES;
    }
    SelectedCountryPrefix = [PickerView getCountryPrefixAtRow:[PickerView getRowForCountryName:SelectedCountryName]];
    if (PhoneNumber == nil)
    {
        PhoneNumber         = @"";
        VerificationCode    = @"";
        Username            = @"";
        FullName            = @"";
    }
    
    if (VerificationCode == nil)
    {
        VerificationCode    = @"";
        Username            = @"";
        FullName            = @"";
    }
    if (Username == nil)
    {
        Username = @"";
    }
    if (FullName == nil)
    {
        FullName = @"";
    }
    RightButton.enabled     = ![PhoneNumber isEqualToString:@""];
    switch (State)
    {
        case E_LoginState_LoggedOut:
            State = E_LoginState_PhoneNumber;
            [defaults setInteger:State forKey:LOGIN_STATE_DEFAULTS_KEY];
            // Fall into the next case!
        case E_LoginState_PhoneNumber:
            [PickerView selectRow:[PickerView getRowForCountryName:SelectedCountryName] inComponent:0 animated:NO];
            LowerEditor.keyboardType  = UIKeyboardTypePhonePad;
            LowerEditor.text  = PhoneNumber;
            LowerEditor.placeholder = GlobalParams.phoneNumberPlaceholder;
            break;
        case E_LoginState_VerificationCode:
            FullPhoneNumber = [SelectedCountryPrefix stringByAppendingString:PhoneNumber];
            LowerEditor.placeholder = GlobalParams.verificationCodePlaceholder;
            RightButton.enabled = NO;
            break;
        case E_LoginState_Username:
            LowerEditor.keyboardType  = UIKeyboardTypeASCIICapable;
            LowerEditor.placeholder   = GlobalParams.usernamePlaceholder;
            UpperEditor.placeholder   = GlobalParams.fullNamePlaceholder;
            RightButton.enabled = NO;
            break;
        case E_LoginState_LoggedIn:
            break;
    }
    
    // Now, we can really layout the view.
    CGFloat width   = self.frame.size.width;
    //  CGFloat height  = self.frame.size.height;
    CGFloat prefixAlpha;
    CGFloat policyAlpha;
    CGFloat prefixWidth;
    CGFloat editorWidth;
    CGFloat pickerAlpha;
    CGRect  prefixFrame;
    CGRect  upperEditorFrame;
    CGRect  lowerEditorFrame;
    switch (State)
    {
        case E_LoginState_PhoneNumber:
            UpperEditor.hidden  = YES;
            SecondLabel.hidden  = NO;
            
            if ([SelectedCountryPrefix isEqual:@""])
            {
                prefixWidth = 0;
            }
            else
            {
                prefixWidth = [PrefixLabel sizeThatFits:self.frame.size].width + EDITOR_GAP;
            }
            editorWidth = width - PREFIX_LEFT_MARGIN - EDITOR_RIGHT_MARGIN;
            prefixFrame = CGRectMake(PREFIX_LEFT_MARGIN - PREFIX_LABEL_TAP_MARGIN, LowerEditorTop - PREFIX_LABEL_TAP_MARGIN, prefixWidth + 2 * PREFIX_LABEL_TAP_MARGIN, EditorHeight + 2 * PREFIX_LABEL_TAP_MARGIN);
            upperEditorFrame = CGRectMake(PREFIX_LEFT_MARGIN, UpperEditorTop, editorWidth, EditorHeight);
            lowerEditorFrame = CGRectMake(PREFIX_LEFT_MARGIN, LowerEditorTop, editorWidth, EditorHeight);
            
            prefixAlpha = 1.0;
            policyAlpha = 0.0;
            pickerAlpha = 1.0;
            UpperEditor.textAlignment = NSTextAlignmentCenter;
            LowerEditor.textAlignment = NSTextAlignmentCenter;

            RightButton.tintColor = TypePink;
            LeftButton.tintColor = TypePink;

            FirstLabel.text     = @"Quickly sign in with \n your mobile number";
            FirstLabel.numberOfLines = 2;

            SecondLabel.text = @"";
            SecondLabel.numberOfLines = 2;


            OneLabel.text = @"1";
            OneLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:13];
            OneLabel.numberOfLines = 1;
            OneLabel.textAlignment  = NSTextAlignmentLeft;
            OneLabel.textColor = WarmGrey;


            OneLabel.frame = CGRectMake((width/3)/2, KeyboardTop - 30, width, [OneLabel sizeThatFits:self.frame.size].height);
            TwoLabel.frame = CGRectMake(0, KeyboardTop - 30, width, [TwoLabel sizeThatFits:self.frame.size].height);
            ThreeLabel.frame = CGRectMake(-(width/3)/2, KeyboardTop - 30, width, [ThreeLabel sizeThatFits:self.frame.size].height);

            TwoLabel.text = @"2";
            TwoLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:13];
            TwoLabel.numberOfLines = 1;
            TwoLabel.textAlignment  = NSTextAlignmentCenter;
            TwoLabel.textColor = [Grey colorWithAlphaComponent:0.4];
            ThreeLabel.text = @"3";
            ThreeLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:13];
            ThreeLabel.numberOfLines = 1;
            ThreeLabel.textAlignment  = NSTextAlignmentRight;
            ThreeLabel.textColor = [Grey colorWithAlphaComponent:0.4];

            FirstSeparatorView.hidden = YES;
            ThirdSeparatorView.hidden = YES;

            ProgressLight.hidden = NO;
            ProgressDark.hidden = NO;

            ProgressLight.frame =       CGRectMake(0, KeyboardTop - 5, width, 2);
            ProgressDark.frame =        CGRectMake(0, KeyboardTop -9, width/4, 9);

            ProgressLight.backgroundColor = [Grey colorWithAlphaComponent:0.4];
            ProgressDark.backgroundColor = TypePink;

            PrefixLabel.backgroundColor = [LightGrey colorWithAlphaComponent:0.4];
            PrefixLabel.textAlignment = NSTextAlignmentCenter;
            PrefixLabel.layer.borderWidth = 1;
            PrefixLabel.layer.cornerRadius = 10;
            PrefixLabel.layer.borderColor = Transparent.CGColor;
            [PrefixLabel.layer setMasksToBounds:YES];

            LowerEditor.attributedPlaceholder = [[NSAttributedString alloc] initWithString:GlobalParams.phoneNumberPlaceholder
                                                                                attributes:@{NSForegroundColorAttributeName: ColorWithAlpha( LightGrey, 0.8)}];


            [RightButton setTitle:@"NEXT" forState:UIControlStateNormal];
            [RightButton setTitleColor:[TypePink colorWithAlphaComponent: 0.25] forState:UIControlStateDisabled];


            break;
        case E_LoginState_VerificationCode:
            UpperEditor.hidden  = YES;
            
            editorWidth         = width - PREFIX_LEFT_MARGIN - EDITOR_RIGHT_MARGIN;
            prefixFrame         = PrefixLabel.frame;
            upperEditorFrame    = CGRectMake(PREFIX_LEFT_MARGIN, UpperEditorTop, editorWidth, EditorHeight);
            lowerEditorFrame    = CGRectMake(PREFIX_LEFT_MARGIN, LowerEditorTop, editorWidth, EditorHeight);
            prefixAlpha         = 0.0;
            policyAlpha         = 0.0;
            pickerAlpha         = 0.0;
            UpperEditor.textAlignment = NSTextAlignmentCenter;
            LowerEditor.textAlignment = NSTextAlignmentCenter;
            FirstLabel.text = @"Enter the verification \n code we texted you";
            FirstLabel.numberOfLines = 2;
            SecondLabel.text = @"We sent the verification code. \n";
            SecondLabel.hidden = YES;
            SecondLabel.numberOfLines = 0;
            LeftButton.hidden = NO;
            RightButton.tintColor = TypePink;
            LeftButton.tintColor = TypePink;

            OneLabel.text = @"1";
            OneLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:13];
            OneLabel.numberOfLines = 1;
            OneLabel.textAlignment  = NSTextAlignmentLeft;
            OneLabel.textColor = [LightGrey colorWithAlphaComponent:0.9];

            OneLabel.frame = CGRectMake((width/3)/2, KeyboardTop - 30, width, [OneLabel sizeThatFits:self.frame.size].height);
            TwoLabel.frame = CGRectMake(0, KeyboardTop - 30, width, [TwoLabel sizeThatFits:self.frame.size].height);
            ThreeLabel.frame = CGRectMake(-(width/3)/2, KeyboardTop - 30, width, [ThreeLabel sizeThatFits:self.frame.size].height);

            TwoLabel.text = @"2";
            TwoLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:13];
            TwoLabel.numberOfLines = 1;
            TwoLabel.textAlignment  = NSTextAlignmentCenter;
            TwoLabel.textColor = WarmGrey;
            ThreeLabel.text = @"3";
            ThreeLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:13];
            ThreeLabel.numberOfLines = 1;
            ThreeLabel.textAlignment  = NSTextAlignmentRight;
            ThreeLabel.textColor = [LightGrey colorWithAlphaComponent:0.9];

            FirstSeparatorView.hidden = YES;
            ThirdSeparatorView.hidden = YES;

            ProgressLight.hidden = NO;
            ProgressDark.hidden = NO;

            ProgressLight.frame =       CGRectMake(0, KeyboardTop - 5, width, 2);
            ProgressDark.frame =        CGRectMake(0, KeyboardTop -9, width/2, 9);


            ProgressLight.backgroundColor = [Grey colorWithAlphaComponent:0.4];
            ProgressDark.backgroundColor = TypePink;

            LowerEditor.attributedPlaceholder = [[NSAttributedString alloc] initWithString:GlobalParams.verificationCodePlaceholder
                                                                                attributes:@{NSForegroundColorAttributeName: ColorWithAlpha( LightGrey, 0.8)}];


            FirstSeparatorView.hidden = YES;
            ThirdSeparatorView.hidden = YES;
            [RightButton setTitle:@"NEXT" forState:UIControlStateNormal];
            [RightButton setTitleColor:[TypePink colorWithAlphaComponent: 0.25] forState:UIControlStateDisabled];
            break;
        case E_LoginState_Username:
            UpperEditor.hidden  = NO;
            SecondLabel.hidden  = YES;
            editorWidth       	= width - PREFIX_LEFT_MARGIN - EDITOR_RIGHT_MARGIN;
            prefixFrame         = PrefixLabel.frame;
            upperEditorFrame  	= CGRectMake(PREFIX_LEFT_MARGIN, UpperEditorTop, editorWidth, EditorHeight);
            lowerEditorFrame    = CGRectMake(PREFIX_LEFT_MARGIN, LowerEditorTop, editorWidth, EditorHeight);
            prefixAlpha         = 0.0;
            policyAlpha       	= 0.0;
            pickerAlpha         = 0.0;
            ThirdSeparatorView.hidden = NO;
            LeftButton.hidden = YES;
            UpperEditor.textAlignment = NSTextAlignmentCenter;
            LowerEditor.textAlignment = NSTextAlignmentCenter;
            FirstLabel.text = @"Enter your full name \n and short username";

            OneLabel.text = @"1";
            OneLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:13];
            OneLabel.numberOfLines = 1;
            OneLabel.textAlignment  = NSTextAlignmentLeft;
            OneLabel.textColor = [LightGrey colorWithAlphaComponent:0.9];

            OneLabel.frame = CGRectMake((width/3)/2, KeyboardTop - 30, width, [OneLabel sizeThatFits:self.frame.size].height);
            TwoLabel.frame = CGRectMake(0, KeyboardTop - 30, width, [TwoLabel sizeThatFits:self.frame.size].height);
            ThreeLabel.frame = CGRectMake(-(width/3)/2, KeyboardTop - 30, width, [ThreeLabel sizeThatFits:self.frame.size].height);

            TwoLabel.text = @"2";
            TwoLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:13];
            TwoLabel.numberOfLines = 1;
            TwoLabel.textAlignment  = NSTextAlignmentCenter;
            TwoLabel.textColor = [LightGrey colorWithAlphaComponent:0.9];
            ThreeLabel.text = @"3";
            ThreeLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:13];
            ThreeLabel.numberOfLines = 1;
            ThreeLabel.textAlignment  = NSTextAlignmentRight;
            ThreeLabel.textColor = WarmGrey;

            upperEditorFrame  = CGRectMake(PREFIX_LEFT_MARGIN, LowerEditorTop, editorWidth, EditorHeight);
            lowerEditorFrame  = CGRectMake(PREFIX_LEFT_MARGIN, LowerEditorTop + 30, editorWidth, EditorHeight);



            FirstSeparatorView.hidden = YES;
            ThirdSeparatorView.hidden = YES;

            ProgressLight.hidden = NO;
            ProgressDark.hidden = NO;

            ProgressLight.frame =       CGRectMake(0, KeyboardTop - 5, width, 2);
            ProgressDark.frame =        CGRectMake(0, KeyboardTop -9, width- (width)/4, 9);

            ProgressLight.backgroundColor = [Grey colorWithAlphaComponent:0.4];
            ProgressDark.backgroundColor = TypePink;

            LowerEditor.attributedPlaceholder = [[NSAttributedString alloc] initWithString:GlobalParams.usernamePlaceholder
                                                                                attributes:@{NSForegroundColorAttributeName: ColorWithAlpha( LightGrey, 0.8)}];


            UpperEditor.attributedPlaceholder = [[NSAttributedString alloc] initWithString:GlobalParams.fullNamePlaceholder
                                                                                attributes:@{NSForegroundColorAttributeName: ColorWithAlpha( LightGrey, 0.8)}];

            ThirdSeparatorView.hidden = YES;
            SecondSeparatorView.hidden = YES;
            FirstSeparatorView.hidden = NO;
            UpperEditor.autocapitalizationType = UITextAutocapitalizationTypeWords;
            LowerEditor.autocapitalizationType = UITextAutocapitalizationTypeNone;
            RightButton.tintColor = TypePink;
            [RightButton setTitle:@"NEXT" forState:UIControlStateNormal];
            [RightButton setTitleColor:[TypePink colorWithAlphaComponent: 0.25] forState:UIControlStateDisabled];
            break;
        case E_LoginState_LoggedIn:
            editorWidth       = width - PREFIX_LEFT_MARGIN - EDITOR_RIGHT_MARGIN;
            prefixFrame       = PrefixLabel.frame;
            upperEditorFrame  = CGRectMake(PREFIX_LEFT_MARGIN, UpperEditorTop, editorWidth, EditorHeight);
            lowerEditorFrame  = CGRectMake(PREFIX_LEFT_MARGIN, LowerEditorTop, editorWidth, EditorHeight);
            prefixAlpha       = 0.0;
            policyAlpha       = 0.0;
            pickerAlpha       = 0.0;

            ProgressLight.frame =       CGRectMake(0, KeyboardTop - 5, width, 2);
            ProgressDark.frame =        CGRectMake(0, KeyboardTop -9, width, 9);

            ProgressLight.backgroundColor = [Grey colorWithAlphaComponent:0.4];
            ProgressDark.backgroundColor = TypePink;
            break;
        case E_LoginState_LoggedOut:
            break;
    }
    if (Animated)
    {
        [UIView animateWithDuration:0.0 animations:^
         {
             PrefixLabel.frame = prefixFrame;
             UpperEditor.frame = upperEditorFrame;
             LowerEditor.frame = lowerEditorFrame;
             PrefixLabel.alpha = prefixAlpha;
             PolicyText.alpha  = policyAlpha;
             PickerView.alpha  = pickerAlpha;
         }];
    }
    else
    {
        PrefixLabel.frame = prefixFrame;
        UpperEditor.frame = upperEditorFrame;
        LowerEditor.frame = lowerEditorFrame;
        PrefixLabel.alpha = prefixAlpha;
        PolicyText.alpha  = policyAlpha;
        PickerView.alpha  = pickerAlpha;
    }
}
//__________________________________________________________________________________________________

- (void)layoutEditorAnimated:(BOOL)animated
{
    Animated = animated;
    [self performSelectorOnMainThread:@selector(layoutEditorAnimatedInMainThread) withObject:nil waitUntilDone:YES];
}
//__________________________________________________________________________________________________

- (void)InitializeTermsAndPrivacyPolicyMessage
{
    NSString* htmlString = @"<STYLE TYPE='text/css'>\n<!--\nP { margin-left: 0.35cm; margin-right: 0.35cm; margin-bottom: 0.0cm; text-align:center; font-family:'Helvetica Neue'; font-size: 10pt }\n-->\n </STYLE>\n <P>";
    htmlString = [htmlString stringByAppendingString:GlobalParams.termsAndPrivacyPolicyMessage];
    [PolicyText loadHTMLString:htmlString baseURL:nil];
}
//__________________________________________________________________________________________________

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* str = request.URL.lastPathComponent;
    if ((navigationType == UIWebViewNavigationTypeLinkClicked) && (str != nil))
    {
        GlobalParams.termsAndPolicyLinkAction(str);
    }
    return YES;
}
//__________________________________________________________________________________________________

- (void)startVerification
{
    ParseStartVerification(FullPhoneNumber, ^(BOOL success, NSError* error)
                           {
                               if (success)
                               {
                                   
                                   Mixpanel *mixpanel = [Mixpanel sharedInstance];
                                   
                                   [mixpanel track:@"twillio sent"];

                                   [mixpanel identify:mixpanel.distinctId];
                                   
                                   [mixpanel.people increment:@"twillio sent" by:[NSNumber numberWithInt:1]];
                                   
                                   FirstLabel.text = @"YOOOO";

                                   LeftButton.hidden       = NO;
                                   RightButton.enabled     = NO;
                                   LowerEditor.placeholder = GlobalParams.verificationCodePlaceholder;
                                   LowerEditor.text        = @"";
                                   [LowerEditor becomeFirstResponder];
                                   State                   = E_LoginState_VerificationCode;
                                   [[NSUserDefaults standardUserDefaults] setInteger:State forKey:LOGIN_STATE_DEFAULTS_KEY];
                               }
                               else if (ParseExtractErrorCode(error) == 21211)
                               {
                                   [RollDownErrorView showWithTitle:GlobalParams.loginRollDownViewTitle andMessage:GlobalParams.loginRollDownPhoneNumberFormatErrorMessage];
                                   NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"rolldown10"ofType:@"aiff"];
                                   NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
                                   AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &soundEffect);
                                   
                                   AudioServicesPlaySystemSound(soundEffect);
                               }
                               else
                               {
                                   [RollDownErrorView showWithTitle:GlobalParams.loginRollDownViewTitle andMessage:GlobalParams.loginRollDownPhoneNumberErrorMessage];
                                   NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"rolldown10"ofType:@"aiff"];
                                   NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
                                   AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &soundEffect);
                                   
                                   AudioServicesPlaySystemSound(soundEffect);
                               }
                               [self layoutEditorAnimated:YES];
                           });
}
//__________________________________________________________________________________________________

- (void)prefixTapped:(UIGestureRecognizer *)gestureRecognizer
{
    [LowerEditor resignFirstResponder];
    SecondLabel.text = @"We need to text you a verification \n code to log you in.";
    //  [RollDownErrorView performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
    [RollDownErrorView hide];
}
//__________________________________________________________________________________________________

-(void)editorTextChanged:(UITextField *)textField
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    switch (State)
    {
        case E_LoginState_PhoneNumber:
            PhoneNumber = textField.text;
            [defaults setObject:PhoneNumber forKey:LOGIN_PHONE_NUMBER_DEFAULTS_KEY];
            if ([PhoneNumber isEqualToString:@""])
            {
                RightButton.enabled = NO;
            }
            else
            {
                RightButton.enabled = YES;
            }
            FullPhoneNumber = [SelectedCountryPrefix stringByAppendingString:PhoneNumber];
            FullPhoneNumber = [FullPhoneNumber stringByReplacingOccurrencesOfString:@" "withString:@""]; // Remove all blank spaces from the string.
            break;
        case E_LoginState_VerificationCode:
            VerificationCode = textField.text;
            [defaults setObject:VerificationCode forKey:LOGIN_VERIFICATION_CODE_DEFAULTS_KEY];
            if ([VerificationCode isEqualToString:@""])
            {
                RightButton.enabled = NO;
            }
            else
            {
                RightButton.enabled = YES;
            }
            break;
        case E_LoginState_Username:
            
            if (textField == UpperEditor)
            {
                [UpperEditor setAutocapitalizationType:UITextAutocapitalizationTypeWords];
                NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "] invertedSet];
                NSString *text = [[UpperEditor.text componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
                
                UpperEditor.text = text;
                
                FullName  = UpperEditor.text;
                
                [defaults setObject:FullName forKey:LOGIN_FULL_NAME_DEFAULTS_KEY];
            }
            else if (textField == LowerEditor)
            {

                // take away upppercase and spaces
                
                NSCharacterSet *invalidCharSet2 = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz1234567890"] invertedSet];
                NSString *text2 = [[LowerEditor.text componentsSeparatedByCharactersInSet:invalidCharSet2] componentsJoinedByString:@""];
                
                LowerEditor.text = text2;
                Username = LowerEditor.text;
                [defaults setObject:Username forKey:LOGIN_USER_NAME_DEFAULTS_KEY];
            }
            
            if ([FullName containsString:@" "])
            {
                NSLog(@"FirstName: %@ and LastName: %@",[FullName componentsSeparatedByString:@" "][0],[FullName componentsSeparatedByString:@" "][1]);
                if (![Username isEqualToString:@""] && ([FullName componentsSeparatedByString:@" "][0].length > 1) && ([FullName componentsSeparatedByString:@" "][1].length > 1))
                {
                    RightButton.enabled = YES;//
                }
                else
                {
                    RightButton.enabled = NO;
                }
                
            }

            
            else
            {
                RightButton.enabled = NO;
            }
            break;
        case E_LoginState_LoggedIn:
            break;
        case E_LoginState_LoggedOut:
            break;
    }

    //  [RollDownErrorView performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
    [RollDownErrorView hide];
    //  NSLog(@"editorTextChanged: %@", FullPhoneNumber);
}
//__________________________________________________________________________________________________

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}
//__________________________________________________________________________________________________

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}
//__________________________________________________________________________________________________

// Action when the left button (BACK) is pressed.
-(void)leftButtonPressed:(UIButton*)button
{
    

    
    NSLog(@"leftButtonPressed");

    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"back30"ofType:@"aiff"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &soundEffect);

    AudioServicesPlaySystemSound(soundEffect);
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"didn't see code"];

    [mixpanel identify:mixpanel.distinctId];
    
    [mixpanel.people increment:@"didn't see code" by:[NSNumber numberWithInt:1]];
    
    switch (State)
    {
        case E_LoginState_PhoneNumber:
            // Should never happen.
            break;
        case E_LoginState_VerificationCode:
            LeftButton.hidden       = YES;
            RightButton.enabled     = YES;
            UpperEditor.placeholder = GlobalParams.fullNamePlaceholder;
            UpperEditor.text        = @"";
            LowerEditor.placeholder = GlobalParams.phoneNumberPlaceholder;
            LowerEditor.text        = PhoneNumber;
            State                   = E_LoginState_PhoneNumber;
            FirstLabel.text           = @"Welcome to Typeface! 🙆🏼";
            SecondLabel.text = @"We need to text you a code \n to verify your identity";
            [[NSUserDefaults standardUserDefaults] setInteger:State forKey:LOGIN_STATE_DEFAULTS_KEY];
            break;
        case E_LoginState_Username:
            [LowerEditor resignFirstResponder];  // Resign first responder to let change keyboard type.
            UpperEditor.placeholder   = GlobalParams.fullNamePlaceholder;
            UpperEditor.text          = FullName;
            LowerEditor.placeholder   = GlobalParams.verificationCodePlaceholder;
            LowerEditor.text          = VerificationCode;
            LowerEditor.keyboardType  = UIKeyboardTypePhonePad;
            State                     = E_LoginState_VerificationCode;
            [[NSUserDefaults standardUserDefaults] setInteger:State forKey:LOGIN_STATE_DEFAULTS_KEY];
            [LowerEditor becomeFirstResponder];  // Becomes first responder with the new keyboard type.
            break;
        case E_LoginState_LoggedIn:
            break;
        case E_LoginState_LoggedOut:
            break;
    }
    [self layoutEditorAnimated:YES];
}
//__________________________________________________________________________________________________

// Action when the right button (NEXT) is pressed.
-(void)rightButtonPressed:(UIButton*)button
{
    
    NSLog(@"rightButtonPressed");


    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"next30"ofType:@"aiff"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &soundEffect);

    AudioServicesPlaySystemSound(soundEffect);

    
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Next"];

    [mixpanel identify:mixpanel.distinctId];
    
    [mixpanel.people increment:@"Next" by:[NSNumber numberWithInt:1]];
    
    switch (State)
    {
        case E_LoginState_PhoneNumber:
            // Transition from phone number to verification code.
        {
            [self startVerification];
        }
            break;
        case E_LoginState_VerificationCode:
            // Transition from verification code to username.
        {
            ParseCompleteVerification(VerificationCode, ^(BOOL success, NSError* error)
                                      {
                                          if (success)
                                          { // The verification code has been validated.
                                              ParseFindUserByPhoneNumber(PhoneNumber, ^(id obj, NSError* find_error)
                                                                         {
                                                                             RecoveredUser             = obj;
                                                                             NSUserDefaults* defaults  = [NSUserDefaults standardUserDefaults];
                                                                             [defaults setObject:RecoveredUser.objectId forKey:LOGIN_USER_NAME_DEFAULTS_KEY];
                                                                             if (RecoveredUser != nil)
                                                                             {
                                                                                 Username  = RecoveredUser.username;
                                                                                 FullName  = RecoveredUser.fullName;
                                                                                 if ((RecoveredUser.fullName != nil) && (![RecoveredUser.fullName isEqualToString:@""]))
                                                                                 {
                                                                                     [self loginExistingUser];
                                                                                 }
                                                                                 else
                                                                                 {
                                                                                     LeftButton.enabled  = YES;
                                                                                     RightButton.enabled = NO;
                                                                                 }
                                                                                 [LowerEditor resignFirstResponder];
                                                                                 LowerEditor.keyboardType  = UIKeyboardTypeASCIICapable;
                                                                                 LowerEditor.placeholder   = GlobalParams.usernamePlaceholder;
                                                                                 LowerEditor.text          = Username;
                                                                                 UpperEditor.placeholder   = GlobalParams.fullNamePlaceholder;
                                                                                 UpperEditor.text          = FullName;
                                                                                 
                                                                                 if ([Username isEqualToString:@""])
                                                                                 {
                                                                                     LowerEditor.enabled = YES;
                                                                                     [LowerEditor becomeFirstResponder];
                                                                                 }
                                                                                 else
                                                                                 {
                                                                                     LowerEditor.enabled = NO;
                                                                                     [UpperEditor becomeFirstResponder];
                                                                                 }
                                                                             }
                                                                             else
                                                                             {
                                                                                 [LowerEditor resignFirstResponder];  // Resign first responder to let change keyboard type.
                                                                                 LeftButton.enabled        = YES;
                                                                                 RightButton.enabled       = NO;
                                                                                 UpperEditor.placeholder   = GlobalParams.fullNamePlaceholder;
                                                                                 UpperEditor.text          = @"";
                                                                                 LowerEditor.placeholder   = GlobalParams.usernamePlaceholder;
                                                                                 LowerEditor.text          = @"";
                                                                                 LowerEditor.keyboardType  = UIKeyboardTypeASCIICapable;
                                                                                 [LowerEditor becomeFirstResponder];  // Becomes first responder with the new keyboard type.
                                                                             }
                                                                             State = E_LoginState_Username;
                                                                             [[NSUserDefaults standardUserDefaults] setInteger:State forKey:LOGIN_STATE_DEFAULTS_KEY];
                                                                             [self layoutEditorAnimated:YES];
                                                                             
                                                                         });
                                          }
                                          else if ((error != nil) && ([error.domain isEqualToString:@"Parse"]) && (error.code == PARSE_ERROR_CODE))
                                          {
                                              // The verification code is wrong.
                                              LeftButton.enabled  = YES;
                                              RightButton.enabled = NO;
                                              [RollDownErrorView showWithTitle:GlobalParams.loginRollDownViewTitle andMessage:GlobalParams.loginRollDownVerificationCodeErrorMessage];
                                              NSString *soundPath2 = [[NSBundle mainBundle] pathForResource:@"rolldown10"ofType:@"aiff"];
                                              NSURL *soundURL2 = [NSURL fileURLWithPath:soundPath2];
                                              AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL2), &soundEffect);
                                              
                                              AudioServicesPlaySystemSound(soundEffect);
                                              
                                              [mixpanel track:@"wrong twillio code"];
                                              
                                              [self layoutEditorAnimated:YES];
                                          }
                                          else
                                          {
                                              NSLog(@"Success: %d, error: %@", success, error);
                                          }
                                      });
        }
            break;
        case E_LoginState_Username:
            
            // Transition from username to LoggedIn.
            if ((RecoveredUser != nil))
            {
                [self loginExistingUser];
            }
            else
            {
                [self loginNewUser];
            }
            break;
        case E_LoginState_LoggedIn:
            // Transition from logged in to ...?
            // Should never happen.
            break;
        case E_LoginState_LoggedOut:
            // Transition from logged out to ...?
            // Should never happen here. Should happen only in the Initialize method.
            break;
    }
}
//__________________________________________________________________________________________________

- (void)loginExistingUser
{
    ParseUser* user = GetCurrentParseUser();
    // First, delete the temporary anonymous user.
    NSLog(@"0 loginExistingUser");
    [user deleteInBackgroundWithBlock:^(BOOL success, NSError* deleteError)
     {
         NSLog(@"success: %d, error: %@", success, deleteError);
     }];
    // Try to login using the phone number as password.
    [ParseUser logInWithUsernameInBackground:Username password:FullPhoneNumber block:^(PFUser* loginUser, NSError* loginError)
     {
         NSLog(@"1 loginExistingUser");
         if (loginError == nil)
         {
             NSLog(@"2 loginExistingUser");
             ParseUser* loggedUser = (ParseUser*)loginUser;

             Mixpanel *mixpanel = [Mixpanel sharedInstance];

             [mixpanel identify:@"$phone"];

             [mixpanel flush];

             if ((loggedUser.fullName == nil) && (FullName != nil) && (![FullName isEqualToString:@""]))
             {
                 NSLog(@"3 loginExistingUser");
                 loggedUser.fullName = FullName;
                 [loggedUser saveEventually];
             }
             [self terminateLogin:NO];
         }
         else
         { // This username is binded to another phone number.
             NSLog(@"4 loginExistingUser");
             [RollDownErrorView showWithTitle:GlobalParams.loginRollDownViewTitle andMessage:GlobalParams.loginRollDownUsernameErrorMessage];
             NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"rolldown10"ofType:@"aiff"];
             NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
             AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &soundEffect);

             AudioServicesPlaySystemSound(soundEffect);
         }
     }];
}
//__________________________________________________________________________________________________

- (void)loginNewUser
{
    NSLog(@"0 loginNewUser");
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd MMM YYYY HH:mm:ss";
    NSString *string = [formatter stringFromDate:[NSDate date]];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];

    [mixpanel identify:mixpanel.distinctId];

    [mixpanel createAlias:@"$phone" forDistinctID:mixpanel.distinctId];

    [mixpanel.people set:@{@"$name": FullName, @"username": Username, @"$phone": PhoneNumber, @"$created": string}];

    [mixpanel flush];


    ParseIsUsernameAlreadyInUse(Username, ^(BOOL alreadyExists, NSError* error)
                                {
                                    NSLog(@"ParseIsUsernameAlreadyInUse success: %d, error: %@", alreadyExists, error);
                                    ParseUser* user = GetCurrentParseUser();
                                    if (alreadyExists)
                                    { // This username is already bound to another phone number.
                                        [RollDownErrorView showWithTitle:GlobalParams.loginRollDownViewTitle andMessage:GlobalParams.loginRollDownUsernameErrorMessage];
                                        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"rolldown10"ofType:@"aiff"];
                                        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
                                        AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &soundEffect);
                                        
                                        AudioServicesPlaySystemSound(soundEffect);
                                    }
                                    else
                                    {
                                        user.username     = Username;
                                        user.password     = FullPhoneNumber;
                                        user.fullName     = FullName;
                                        user.phoneNumber  = PhoneNumber;
                                        [user setObject:SelectedCountryPrefix forKey:@"CountryPrefix"];
                                        NSLog(@"%@",SelectedCountryPrefix);
                                        [user saveInBackgroundWithBlock:^(BOOL success, NSError* save_error)
                                         {
                                             if (success)
                                             {
                                                 [self terminateLogin:YES];
                                             }
                                             else
                                             {
                                                 NSLog(@"failed to save username in user object: %@", error);
                                             }
                                             [self layoutEditorAnimated:YES];
                                         }];
                                    }
                                });
}
//__________________________________________________________________________________________________


- (void)terminateLogin:(BOOL)newUser
{
    ParseFinalizeLogIn();
    State = E_LoginState_LoggedIn;
    [[NSUserDefaults standardUserDefaults] setInteger:State forKey:LOGIN_STATE_DEFAULTS_KEY];
    [UpperEditor resignFirstResponder];
    [LowerEditor resignFirstResponder];
    LoginDoneAction(newUser);
}
//__________________________________________________________________________________________________

- (void)setLoginDoneAction:(BlockBoolAction)loginDoneAction
{
    LoginDoneAction = loginDoneAction;
}
//__________________________________________________________________________________________________

- (BlockBoolAction)loginDoneAction
{
    return LoginDoneAction;
}
//__________________________________________________________________________________________________

//! Show the login view.
- (void)showAnimated:(BOOL)animated fromStart:(BOOL)fromStart
{
    if (fromStart)
    {
        State = E_LoginState_LoggedOut;
    }
    [self recoverSavedState:^
     {
         [self layoutEditorAnimated:NO];
         [LowerEditor becomeFirstResponder];
         if (animated)
         {
             self.alpha  = 0.0;
             self.hidden = NO;
             [UIView animateWithDuration:0.5 animations:^
              {
                  self.alpha = 1.0;
              } completion:^(BOOL finished)
              {
              }];
         }
         else
         {
             self.hidden = NO;
             self.alpha  = 1.0;
         }
     }];
}
//__________________________________________________________________________________________________

//! Hide the login view.
- (void)hideAnimated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.5 animations:^
         {
             self.alpha = 0.0;
         } completion:^(BOOL finished)
         {
             self.hidden = YES;
         }];
    }
    else
    {
        self.hidden = YES;
        self.alpha  = 0.0;
    }
}
//__________________________________________________________________________________________________

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
@end


