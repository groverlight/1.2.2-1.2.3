
//! \file   GlobalParameters.m
//! \brief  All the App parameters are defined here.
//__________________________________________________________________________________________________

#import <CoreMotion/CMMotionManager.h>

#import "GlobalParameters.h"
//__________________________________________________________________________________________________

static GlobalParameters* Global = nil;
//__________________________________________________________________________________________________

GlobalParameters* GetGlobalParameters(void)
{
  static GlobalParameters* sharedGlobalParameters = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^
  {
    sharedGlobalParameters = [[GlobalParameters alloc] init];
  });
  return sharedGlobalParameters;
}
//==================================================================================================

//! All the App parameters are defined here.
@implementation GlobalParameters
{
  BlockIdAction     TermsAndPolicyLinkAction;             //!< Action block for displaying of the terms and policy pages.
  BlockAction       InvalidParseSessionToken;             //!< Action block to notify the app of an invalid Parse session token.
  BlockBlockAction  MissingInternetConnection;            //!< Action block to notify the app of an invalid Parse session token.
  BlockStringAction UserIsBlocked;                        //!< Action block to notify the app that the current user is blocked.
  BlockBoolAction   LoginDone;                            //!< Action block to notify the app that the login process has terminated. Param is YES if this is the first login of a new user.
  BlockAction       FindUserMessagingNotSupportedAction;  //!< Action block to notify the app that the device does not support iMessage.
  BlockAction       FindUserFailedToSendMessageAction;    //!< Action block to notify the app that sending the iMessage has failed.
}
@synthesize dimmedGradientAlpha;
@synthesize jpegCompressionQuality;
@synthesize customizableLoginLabel;
@synthesize selectCountryMessage;
@synthesize phoneNumberPlaceholder;
@synthesize verificationCodePlaceholder;
@synthesize fullNamePlaceholder;
@synthesize usernamePlaceholder;
@synthesize termsAndPrivacyPolicyMessage;
@synthesize loginLeftButtonLabel;
@synthesize loginRightButtonLabel;
@synthesize initialCountry;
#if 0
@synthesize findUserLabel;
@synthesize findUsernamePlaceholder;
@synthesize findUserLeftButtonLabel;
@synthesize findUserRightButtonLabel;
@synthesize findUserMessagingSampleText;
#endif
@synthesize rollDownViewBackgroundColor;
//@synthesize username;

- (id)init
{
  self = [super init];
  if (self != nil)
  {
    dimmedGradientAlpha     = 0.85;
    jpegCompressionQuality  = 0.8;

    TermsAndPolicyLinkAction = ^(id obj)
    { // Default action: do nothing.
    };

    InvalidParseSessionToken = ^
    { // Default action: do nothing.
    };

    MissingInternetConnection = ^(BlockAction retry)
    { // Default action: do nothing.
    };

    FindUserMessagingNotSupportedAction = ^
    { // Default action: do nothing.
    };

    FindUserFailedToSendMessageAction = ^
    { // Default action: do nothing.
    };
  }
  return self;
}
//__________________________________________________________________________________________________

//! return the single and only instance of this class.
+ (GlobalParameters*) sharedGlobalParameters
{
  if (Global == nil)
  {
    Global = [[GlobalParameters alloc] init];
  }
  return Global;
}
//__________________________________________________________________________________________________

- (void)setTermsAndPolicyLinkAction:(BlockIdAction)termsAndPolicyLinkAction
{
  TermsAndPolicyLinkAction = termsAndPolicyLinkAction;
}
//__________________________________________________________________________________________________

- (BlockIdAction)termsAndPolicyLinkAction
{
  return TermsAndPolicyLinkAction;
}
//__________________________________________________________________________________________________

- (void)setUserIsBlocked:(BlockStringAction)userIsBlocked
{
  UserIsBlocked = userIsBlocked;
}
//__________________________________________________________________________________________________

- (BlockStringAction)userIsBlocked
{
  return UserIsBlocked;
}
//__________________________________________________________________________________________________

- (void)setLoginDone:(BlockBoolAction)loginDone
{
  LoginDone = loginDone;
}
//__________________________________________________________________________________________________

- (BlockBoolAction)loginDone
{
  return LoginDone;
}
//__________________________________________________________________________________________________

- (void)setInvalidParseSessionToken:(BlockAction)invalidParseSessionToken
{
  InvalidParseSessionToken = invalidParseSessionToken;
}
//__________________________________________________________________________________________________

- (BlockAction)invalidParseSessionToken
{
  return InvalidParseSessionToken;
}
//__________________________________________________________________________________________________

- (void)setMissingInternetConnection:(BlockBlockAction)missingInternetConnection
{
  MissingInternetConnection = missingInternetConnection;
}
//__________________________________________________________________________________________________

- (BlockBlockAction)missingInternetConnection
{
  return MissingInternetConnection;
}
//__________________________________________________________________________________________________

- (void)setFindUserMessagingNotSupportedAction:(BlockAction)findUserMessagingNotSupportedAction
{
  FindUserMessagingNotSupportedAction = findUserMessagingNotSupportedAction;
}
//__________________________________________________________________________________________________

- (BlockAction)findUserMessagingNotSupportedAction
{
  return FindUserMessagingNotSupportedAction;
}
//__________________________________________________________________________________________________

- (void)setFindUserFailedToSendMessageAction:(BlockAction)findUserFailedToSendMessageAction
{
  FindUserFailedToSendMessageAction = findUserFailedToSendMessageAction;
}
//__________________________________________________________________________________________________

- (BlockAction)findUserFailedToSendMessageAction
{
  return FindUserFailedToSendMessageAction;
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________
