
//! \file   AppViewController.m
//! \brief  The main ViewController of the application.
//__________________________________________________________________________________________________

#import "AppViewController.h"
#import "FriendRecord.h"
#import "Alert.h"
#import "BaseView.h"
#import "GlobalParameters.h"
#import "InitGlobalParameters.h"
#import "NavigationView.h"
#import "Parse.h"
#import "Tools.h"
#import "TypingView.h"
#import "UnreadMessages.h"
#import "ViewStackView.h"
#import "Mixpanel.h"
#import "VideoViewController.h"
#import "Reachability.h"
#import "CameraPreview.h"
#import "VideoCapture.h"
#import "Colors.h"
#import <Contacts/Contacts.h>
#import <addressbook/addressbook.h>
//__________________________________________________________________________________________________

#define BE_YOUR_BEST_FRIEND 0 //!< Define to 1 to declare the current user to be his own friend.
//__________________________________________________________________________________________________

static AppViewController* MainViewController = nil;
//__________________________________________________________________________________________________

//! The main ViewController of the application.
@interface AppViewController ()
{
@public
  GlobalParameters* GlobalParams;   //!< Pointer to the global parameters object.
}
//____________________

//@property (strong, nonatomic) IBOutlet CardNavigationView* cardNavigator;  //!< The view where everything is happening.
//____________________

@end
//__________________________________________________________________________________________________

@implementation AppViewController
{
  ViewStackView*  ViewStack;
  NavigationView* NavView;
  BOOL            LoadingMessages;
  VideoViewController *Intro;
  UILabel *noInternet;
  UIView *pinkbackground;
}
//@synthesize cardNavigator;
//____________________

- (instancetype)init
{
  self = [super init];
  if (self != nil)
  {
    LoadingMessages = NO;
  }


  return self;
}
//__________________________________________________________________________________________________

//! Tell if the status bar should be displayed or not.
- (BOOL)prefersStatusBarHidden
{
  return YES;
}
//__________________________________________________________________________________________________

- (void)loadReceivedMessages:(BlockBoolAction)completion
{
  // Load messages only if we are not currently loading them.
//  NSLog(@"1 loadReceivedMessages");
  if (!LoadingMessages)
  {
    LoadingMessages = YES;
//    NSLog(@"2 loadReceivedMessages");
    [NavView loadReceivedMessages:^(BOOL hasNewData)
    {
//      NSLog(@"3 loadReceivedMessages");
      LoadingMessages = NO;
      completion(hasNewData);
    }];
  }
//  NSLog(@"4 loadReceivedMessages");
}
//__________________________________________________________________________________________________

- (void)loginDone:(BOOL)newUser
{
    
    ParseUser* currentUser = GetCurrentParseUser();
    LoggedIn = YES;
    NSLog(@"LOGIN DONE %@",currentUser[@"phoneNumber"]);
    if (currentUser != nil)
    {

        CNAuthorizationStatus permissions = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusAuthorized) {
            
            if((permissions == CNAuthorizationStatusNotDetermined) || (!ParseCheckPermissionForRemoteNotifications())) {
                {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [self dismissViewControllerAnimated:NO completion:nil];
                        [self presentViewController:Intro animated:NO completion:^(){
                            [ViewStack.liveView  restorePreviewWithCompletion:^{
                            }];
                            

                            
                        }];
                    });
                    
                }
                // do your logic
            }
        }
       /*CNAuthorizationStatus permissions = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if((permissions != CNAuthorizationStatusAuthorized) || !ParseCheckPermissionForRemoteNotifications()) {
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self dismissViewControllerAnimated:NO completion:nil];
                [self presentViewController:Intro animated:NO completion:^(){
                    [ViewStack.liveView  restorePreviewWithCompletion:^{
                    
                    }];
                    
                }];
                
            });

    }*/
        PFQuery *friendquery = [PFUser query];
        
        [friendquery whereKey:@"friends" equalTo:[PFUser currentUser].objectId];
        [friendquery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects != nil)
                for (PFUser *user in objects)
                {
                    [[PFUser currentUser] addUniqueObject:user.objectId  forKey:@"friends"];
                }
        }];
    }

set_myself;
#if BE_YOUR_BEST_FRIEND


  // Add ourself as friend to be able to test push notifications with a single user. Do nothing if we are already in the friends list.
  [currentUser addFriend:currentUser completion:^(BOOL success, NSError *error)
  {
#endif
      
    [GetCurrentParseUser() loadFriendsListWithCompletion:^(NSArray* friends, NSError* loadError)
    {

        PFQuery *findMessages = [PFQuery queryWithClassName:@"ParseMessage"];
        [findMessages whereKey:@"placeHolder" equalTo:currentUser[@"phoneNumber"]];
        [findMessages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                NSMutableArray *fromUsers = [[NSMutableArray alloc]init];
                
                for (PFObject *object in objects)
                {
                    [fromUsers addObject: object[@"fromUser"]];
                    object[@"toUser"] = currentUser;
                    [object saveInBackground];
                }
                fromUsers = (NSMutableArray*)[[NSOrderedSet orderedSetWithArray:fromUsers] array];
                /*for (NSString* objectID in fromUsers)
                {
                    PFQuery *pushQuery = [PFInstallation query];
                    [pushQuery whereKey:@"user" equalTo:objectID];
                    NSString * Name = [[PFUser currentUser] objectForKey:@"fullName"];
                    
                    // Send push notification to query
                    NSDictionary *data = @{
                                           @"alert" : [NSString stringWithFormat:@"%@ just read your blurbs!" ,Name],
                                           @"p" :[PFUser currentUser].objectId,
                                           @"t" :[PFUser currentUser][@"phoneNumber"]
                                           };
                    
                    PFPush *push = [[PFPush alloc] init];
                    [push setQuery:pushQuery];
                    [push setMessage:@"this works"];
                    [push setData:data];
                    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *sendError)
                     {
                         NSLog(@"Sending Push");
                     }];
                }*/
            }
            else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
      get_myself;
      if (loadError == nil)
      {
        UpdateFriendRecordListForFriends(friends);
        [myself loadReceivedMessages:^(BOOL hasNewData)
        {
          [NavView updateFriendsLists];
        }];

        if (newUser)
        {

              //  [NavView showLoginFromStart:YES];


          /*if (!ParseCheckPermissionForRemoteNotifications())
          {
            Alert(NSLocalizedString(@"Want Notifications?", @""), NSLocalizedString(@"To be alerted when your friends message you, please allow push notifications", @""), NSLocalizedString(@"OK", @""), nil, ^(NSInteger pressedButton)
            {
              ParseRegisterForRemoteNotifications(^(BOOL notificationsAreEnabled)
              {
              });
            });
          }*/
        }
          
        else
        {
          /*ParseRegisterForRemoteNotifications(^(BOOL notificationsAreEnabled)
          {
            if (!notificationsAreEnabled)
            {
              Alert(NSLocalizedString(@"Want Notifications?", @""), NSLocalizedString(@"To be alerted when your friends message you, please allow push notifications", @""), NSLocalizedString(@"OK", @""), nil, ^(NSInteger pressedButton)
              {
              });
            }
          });*/
        }
          
      }
      else
      {
        NSLog(@"Failed to load the friends : %@, %@", loadError, GetCurrentParseUser());
      }
    }];
#if BE_YOUR_BEST_FRIEND
  }];
#endif
}
//__________________________________________________________________________________________________

- (void)loadView
{

    //  NSLog(@"1 loadView");
    MainViewController = self;
    // The global parameters should be set as soon as possible, at last before loading the user interface.
    GlobalParams = InitGlobalParameters(self);
    //  NSLog(@"2 loadView");
    
    // The global parameters have been initialized. Now we can load the User Interface.
    [super loadView];
    //  NSLog(@"3 loadView");
    pinkbackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GetScreenWidth(), GetScreenHeight())];
    pinkbackground.backgroundColor = TypePink;
    ViewStack = [ViewStackView sharedInstance];
    self.view = ViewStack;
    [self.view addSubview:pinkbackground ];
    [self.view bringSubviewToFront:pinkbackground];

    NSLog(@"4 loadView");
    NavView = [NavigationView new];
    //NavView.hidden = YES;
    NavView.frame = CGRectMake(0, 0, GetScreenWidth(), GetScreenHeight());
    set_myself;
      NSLog(@"5 loadView");
    NavView->PleaseBlurByThisFactorAction = ^(CGFloat blurFactor)
    {
        get_myself;
        [myself->ViewStack blurWithFactor:blurFactor];
    };
    NavView->PleaseFlashForDuration = ^(CGFloat duration, BlockAction completion)
    {
        get_myself;
        [myself->ViewStack flashForDuration:duration completion:completion];
    };
    
    //  NSLog(@"6 loadView");
    [ViewStack setTextViewContent:NavView animated:NO fromLeft:YES];
    [ViewStack activate];
    //  NSLog(@"7 loadView");

        
}
//__________________________________________________________________________________________________

//! The UI has been loaded, do whatever else is required.
- (void)viewDidLoad
{
    
    CGFloat height = GetScreenHeight();
    CGFloat width = GetScreenWidth();
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(width/2, height/2, width/8, height/8)];
    iv.image = [UIImage imageNamed:@"logo_tut.png"];
    [pinkbackground addSubview:iv];
  [iv setTranslatesAutoresizingMaskIntoConstraints:NO];
  [self.view addConstraint:[NSLayoutConstraint      // center image horizontally
                              constraintWithItem:iv
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:pinkbackground
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1.0
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint    //center image vertically
                              constraintWithItem:iv
                              attribute:NSLayoutAttributeCenterY
                              relatedBy:NSLayoutRelationEqual
                              toItem:pinkbackground
                              attribute:NSLayoutAttributeCenterY
                              multiplier:1.0
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:iv      //height
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:62]];//adjust this
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:iv     //width
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1
                                                            constant:85 ]];// adjust this
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        [UIView animateWithDuration: 1
                              delay: 0.0            // DELAY
             usingSpringWithDamping: 0
              initialSpringVelocity: 0
                            options: 0
                         animations:^
         {
             iv.transform = CGAffineTransformMakeScale(0.5, 0.5);
         }
                         completion:nil];
    //iv.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView animateWithDuration: 1.5
                          delay: 0            // DELAY
         usingSpringWithDamping: 0.5
          initialSpringVelocity: 0.5
                        options:(UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat)
                               animations:^
                               {
                                   iv.transform = CGAffineTransformMakeScale(1, 1);
                               }
                     completion:nil];
    });



//  NSLog(@"1 viewDidLoad");
  [super viewDidLoad];
//  NSLog(@"2 viewDidLoad");
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkNetwork];
    });
    Intro = [[VideoViewController alloc]init];
  // Parse stuff.
  ParseInitialization(^(PFUser* user, BOOL newUser, BOOL restart, NSError *error)
  {
    [NavView updateFriendsLists];
    if (error == nil)
    {
      if (newUser)
      {
          CNAuthorizationStatus permissions = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
          
          
          AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
          if((authStatus == AVAuthorizationStatusAuthorized) &&
             ((permissions == CNAuthorizationStatusNotDetermined) || (!ParseCheckPermissionForRemoteNotifications())
              )) {
                 [pinkbackground removeFromSuperview];
                 [NavView showLoginFromStart:YES];
             } else if(authStatus == AVAuthorizationStatusDenied){
                 // denied
             } else if(authStatus == AVAuthorizationStatusRestricted){
                 // restricted, normally won't happen
             } else if(authStatus == AVAuthorizationStatusNotDetermined){
                 // not determined?!
                 dispatch_async(dispatch_get_main_queue(), ^(void){
                     
                     [self dismissViewControllerAnimated:NO completion:nil];
                     [self presentViewController:Intro animated:NO completion:^(){
                         [pinkbackground removeFromSuperview];
                         [NavView showLoginFromStart:YES];
                     }];
                 });
                 
                 
             }
          
             else {
                 // impossible, unknown authorization status
             }
         
          
      }
      else
      {
        PFInstallation* currentInstallation = [PFInstallation currentInstallation];
        if (currentInstallation.badge > 0)
        {
            [NavView ScrollToPageAtIndex:0 animated:NO];
        }
        else {
            [NavView ScrollToTypingPageAnimated:NO];

        }
        [pinkbackground removeFromSuperview];
        GlobalParams.loginDone(NO);
          
      }
    }
    else
    {
      NSLog(@"Parse initialization completed, but failed: %@, %@", user, error);
    }
  });
}
//__________________________________________________________________________________________________

- (void)viewWillAppear:(BOOL)animated
{
}
//__________________________________________________________________________________________________

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewdidappear");
    if ((GetCurrentParseUser() != nil) && MainViewController->LoggedIn)
    {
        //[NavView layoutSubviews];
        [NavView->TypingMessageView->TextView->Editor becomeFirstResponder];
    }
}
//__________________________________________________________________________________________________

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  CGRect bounds = self.view.bounds;
  ViewStack.frame = bounds;
}
//__________________________________________________________________________________________________

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
}
//__________________________________________________________________________________________________

- (void)handleRemoteNotification:(NSString*)notificationMessage
{
}
//__________________________________________________________________________________________________

//! The application did just become active.
- (void)applicationDidBecomeActive
{

    NSLog(@"app launched from background");
    

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd MMM YYYY HH:mm:ss";
    NSString *string = [formatter stringFromDate:[NSDate date]];

    Mixpanel *mixpanel = [Mixpanel sharedInstance];

    [mixpanel track:@"last seen"];

    [mixpanel identify:mixpanel.distinctId];

    [mixpanel.people set:@{@"$last_seen": string}];

    [mixpanel flush];


  if ((GetCurrentParseUser() != nil) && MainViewController->LoggedIn)
  {
      NSLog(@"logged in");
    
    [self loadReceivedMessages:^(BOOL hasNewData)
    { // Do nothing!
        
      [NavView updateFriendsLists];
    }];
    if (ViewStack != nil)
    {
        
      [ViewStack restoreLiveView];
    }
  }
  else
  {
      
     [ViewStack showLiveViewAnimated:NO];
  }
}
//__________________________________________________________________________________________________

//! The application will become inactive.
- (void)applicationWillResignActive
{
//  NSLog(@"applicationWillResignActive");
  if (ViewStack != nil)
  {
    [ViewStack cleanupLiveView];
  }
}
//__________________________________________________________________________________________________

//! Perform background data fetch.
- (void)performBackgroundFetch:(BlockBoolAction)completion
{
//  NSLog(@"performBackgroundFetch Start");
  [self loadReceivedMessages:^(BOOL hasNewData)
  {
//    NSLog(@"performBackgroundFetch End: %d\n\n", hasNewData);
    completion(hasNewData);
  }];
}
//__________________________________________________________________________________________________
-(void) checkNetwork
{
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]
                                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    activityView.center=self.view.center;
    activityView.backgroundColor = [UIColor whiteColor];
    [activityView startAnimating];
    while(1){
        Reachability *myNetwork = [Reachability reachabilityWithHostname:@"www.google.com"];
        NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
        if (myStatus == NotReachable)
        {
           
                dispatch_async(dispatch_get_main_queue(), ^{
               // NavView.hidden = YES;

                self.view = activityView;
               // [self.view addSubview:activityView];
                    });
            
        }
        else
        {
            if(self.view !=ViewStack)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                ViewStack = [ViewStackView sharedInstance];
                self.view = ViewStack;
                    });
            }
        }

    }
}
@end

//! Present in a custom view the data contained in the remote notification userInfo dictionary.
void DidReceiveRemoteNotification(NSDictionary* userInfo, BlockBoolAction completion)
{
//  NSLog(@"1 DidReceiveRemoteNotification");
  if (MainViewController != nil)
  {
//    NSLog(@"2 DidReceiveRemoteNotification");
    NSDictionary* aps = [userInfo objectForKey:@"aps"];
    id alert = [aps objectForKey:@"alert"];
    if ([alert isKindOfClass:[NSDictionary class]])
    {
      alert = [alert objectForKey:@"body"];
    }
    [MainViewController handleRemoteNotification:alert];
  }
  else
  {
    ParseDidReceiveRemoteNotification(userInfo);
  }
//  NSLog(@"3 DidReceiveRemoteNotification");
  [MainViewController loadReceivedMessages:^(BOOL hasNewData)
  {
//    NSLog(@"4 DidReceiveRemoteNotification");
    completion(hasNewData);
  }];
}
//__________________________________________________________________________________________________

//! The application did just become active.
void ApplicationDidBecomeActive(void)
{
  NSLog(@"ApplicationDidBecomeActive");
  if (MainViewController != nil)
  {
    
    [MainViewController applicationDidBecomeActive];
  }
}
//__________________________________________________________________________________________________

//! The application wil become inactive.
void ApplicationWillResignActive(void)
{
//  NSLog(@"ApplicationWillResignActive");
  if (MainViewController != nil)
  {
    
    [MainViewController applicationWillResignActive];
  }
}
//__________________________________________________________________________________________________

//! Perform background data fetch.
void PerformBackgroundFetch(BlockBoolAction completion)
{
  if (MainViewController != nil)
  {
    [MainViewController performBackgroundFetch:^(BOOL hasNewData)
    {
      completion(hasNewData);
    }];
  }
  else
  {
    completion(NO);
  }
}


//__________________________________________________________________________________________________

