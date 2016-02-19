
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
NSMutableArray*      recentListUsers;
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

    if (currentUser[@"phoneNumber"] != nil)
    {

        CNAuthorizationStatus permissions = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (permissions == CNAuthorizationStatusAuthorized){
        [self contactsync];
        }

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
    
    pinkbackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
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
    
    
        [UIView animateWithDuration: 1
                              delay: 0.0            // DELAY
             usingSpringWithDamping: 1
              initialSpringVelocity: 1
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

            dispatch_async(dispatch_get_main_queue(), ^(void){
                if (permissions == CNAuthorizationStatusAuthorized && authStatus == AVAuthorizationStatusAuthorized)
                {
                    [pinkbackground removeFromSuperview];
                    [NavView showLoginFromStart:YES];
                }
                else
                {
                     [self dismissViewControllerAnimated:NO completion:nil];
                     [self presentViewController:Intro animated:NO completion:^(){
                     [pinkbackground removeFromSuperview];
                    [NavView showLoginFromStart:YES];
                 }];
                }
            });
            
                 
                 
             
          

          
      }
      else
      {
        [pinkbackground removeFromSuperview];
        PFInstallation* currentInstallation = [PFInstallation currentInstallation];
        if (currentInstallation.badge > 0)
        {
            [NavView ScrollToPageAtIndex:0 animated:NO];
        }
        else {
            [NavView ScrollToTypingPageAnimated:NO];

        }
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

  [NavView updateFriendsLists];
  if ((GetCurrentParseUser() != nil) && MainViewController->LoggedIn)
  {
      NSLog(@"logged in");
    
    [self loadReceivedMessages:^(BOOL hasNewData)
    { // Do nothing!
        
     // [NavView updateFriendsLists];
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

-(void) contactsync
{

    NSMutableArray *fullName = [[NSMutableArray alloc]init];
    NSMutableArray *phoneNumber = [[NSMutableArray alloc]init];
    if (1)
    {
        NSLog(@"INITIATING CONTACT SYNC"); // IMPORTANT
        
        // NSMutableArray *contacts = [[NSMutableArray alloc]init];
        
        if([CNContactStore class]) // this is where you say yes or noiOS 9 or later
        {
            
            
            CNContactStore* addressBook = [[CNContactStore alloc]init];
            CNAuthorizationStatus permissions = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
            if(permissions == CNAuthorizationStatusNotDetermined || permissions == CNAuthorizationStatusAuthorized) {
                
                [addressBook requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable contactError) {
                    
                    if (granted)
                    {
                        NSLog(@"Said YES to Contacts Sync");
                        
                        Mixpanel *mixpanel = [Mixpanel sharedInstance];
                        
                        [mixpanel track:@"Said YES to Contacts Sync"];
                        
                        [mixpanel identify:mixpanel.distinctId];
                        
                        [mixpanel.people increment:@"Said YES to Contacts Sync" by:[NSNumber numberWithInt:1]];
                        
                        
                        [addressBook containersMatchingPredicate:[CNContainer predicateForContainersWithIdentifiers: @[addressBook.defaultContainerIdentifier]] error:&contactError];
                        
                        
                        NSArray * keysToFetch =@[CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPostalAddressesKey];
                        CNContactFetchRequest * request = [[CNContactFetchRequest alloc]initWithKeysToFetch:keysToFetch];
                        
                        
                        [addressBook enumerateContactsWithFetchRequest:request error:&contactError usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop){
                            
                            NSString *name = [NSString stringWithFormat:@"%@ %@",contact.givenName,contact.familyName];
                            NSString *phone = [NSString string];
                            
                            for (CNLabeledValue *value in contact.phoneNumbers) {
                                
                                if ([value.label isEqualToString:@"_$!<Mobile>!$_"])
                                {
                                    CNPhoneNumber *phoneNum = value.value;
                                    phone = phoneNum.stringValue;
                                }
                                
                                if ([phone isEqualToString:@""])
                                {
                                    if ([value.label isEqualToString:@"_$!<Home>!$_"])
                                    {
                                        CNPhoneNumber *phoneNum = value.value;
                                        phone = phoneNum.stringValue;
                                    }
                                }
                                if ([phone isEqualToString:@""])
                                {
                                    if ([value.label isEqualToString:@"_$!<Work>!$_"])
                                    {
                                        CNPhoneNumber *phoneNum = value.value;
                                        phone = phoneNum.stringValue;
                                    }
                                }
                                
                            }
                            
                            [fullName addObject:name];
                            [phoneNumber addObject:[self formatNumber:phone]];
                            
                            
                            
                        }];
                        
                        [self updateTable:fullName phone:phoneNumber];
                        
                        
                    }
                    
                    else
                        
                    {
                        
                        NSLog(@"You said NO to Contacts");
                        
                        Mixpanel *mixpanel = [Mixpanel sharedInstance];
                        
                        [mixpanel track:@"Said NO to Contacts Sync"];
                        
                        [mixpanel identify:mixpanel.distinctId];
                        
                        [mixpanel.people increment:@"Said NO to Contacts Sync" by:[NSNumber numberWithInt:1]];
                        
                        
                    }
                    
                    
                    
                }];
                
            }
            
            else
            {
                NSLog(@"did not ask permissions");
            }
        }
        
        
        else
        {
            
            __block NSString *firstName;
            __block NSString *lastName;
            ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
            if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
            {
                
                CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
                CFIndex numberOfPeople = CFArrayGetCount(allPeople);
                NSLog(@"%lu", numberOfPeople);
                for(int  i = 0; i < numberOfPeople; i++) {
                    
                    ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
                    // Use a general Core Foundation object.
                    CFTypeRef generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
                    
                    // Get the first name.
                    if (generalCFObject) {
                        firstName =(__bridge NSString *)generalCFObject;
                        CFRelease(generalCFObject);
                    }
                    
                    // Get the last name.
                    generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
                    if (generalCFObject) {
                        lastName =(__bridge NSString *)generalCFObject;
                        CFRelease(generalCFObject);
                    }
                    [fullName addObject: [NSString stringWithFormat:@"%@ %@", firstName, lastName]];
                    NSLog(@"%@", [fullName objectAtIndex:i]);
                    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                    
                    for (CFIndex j = 0; j < ABMultiValueGetCount(phoneNumbers); j++) {
                        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phoneNumbers, j);
                        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phoneNumbers, j);
                        
                        if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                            [phoneNumber addObject:[self formatNumber:(__bridge NSString *)currentPhoneValue]];
                        }
                        
                        else if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                            [phoneNumber addObject:[self formatNumber:(__bridge NSString *)currentPhoneValue]];                 }
                        else if (CFStringCompare(currentPhoneLabel, kABWorkLabel, 0) == kCFCompareEqualTo) {
                            [phoneNumber addObject:[self formatNumber:(__bridge NSString *)currentPhoneValue]];
                        }
                        
                        CFRelease(currentPhoneLabel);
                        CFRelease(currentPhoneValue);
                    }
                    CFRelease(phoneNumbers);
                    
                }
                
                
            }
            
            
            [self updateTable:fullName phone:phoneNumber];
            
            
            
            
        }
        
        [[PFUser currentUser] setObject:@YES forKey:@"didContactSync"];
        [[PFUser currentUser]saveInBackground];
    }
    
    
}
-(void)updateTable:(NSArray*)fullName phone:(NSArray*)phoneNumber
{
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFUser query];
    
    [query whereKey:@"phoneNumber" containedIn:phoneNumber];
    // NSLog(@" this %@ ", [query findObjects]);
    //NSLog(@"%@, %@",fullName, phoneNumber);
    NSInteger index = 0;
    if(recentListUsers == nil)
    {
        recentListUsers = [[NSMutableArray alloc]init];
    }
    else
    {
        [recentListUsers removeAllObjects];
    }
    
    for (NSString* name in fullName)
    {
        BOOL containsLetter = NSNotFound != [name rangeOfCharacterFromSet:NSCharacterSet.letterCharacterSet].location;
        if(containsLetter)
        {
            // if (![name isEqualToString:@""];
            //NSLog( @"timestampstring:%@ timestampdouble:%f",timeStamp, [[NSDate date] timeIntervalSince1970]);
            FriendRecord * newUser = [FriendRecord new];
            newUser.fullName = name;
            newUser.phoneNumber = [phoneNumber objectAtIndex:index];
            newUser.lastActivityTime = [[NSDate date] timeIntervalSince1970];
            
            
            
            
            [recentListUsers addObject:newUser];
        }
        index++;
    }
    // clear duplicate contacts
    NSMutableArray *uniqueArray = [NSMutableArray array];
    NSMutableSet *names = [NSMutableSet set];
    
    //for (FriendRecord* record in recentListUsers) {
    for (NSInteger i = 0; i < [recentListUsers count]; i ++){
        
        // NSLog(@"Timestamp : %f", record.lastActivityTime);
        FriendRecord *record = recentListUsers[i];
        NSString *destinationName = record.phoneNumber;
        if (![names containsObject:destinationName]) {
            if (destinationName != nil)
            {
                
                
                [uniqueArray addObject:record];
                [names addObject:destinationName];
            }
        }
        else
        {
            if (record.user != nil)
            {
                for (NSInteger j = 0; j < [uniqueArray count]; j++)
                {
                    FriendRecord *record2 = uniqueArray[j];
                    if ([record2.phoneNumber isEqualToString: record.phoneNumber])
                    {
                        uniqueArray[j] = record;
                    }
                }
            }
        }
        
    }
    recentListUsers = uniqueArray;
    // clear contacts with no phone numbers
    NSMutableArray *filterArray = [[NSMutableArray alloc]init];
    
    //for (FriendRecord *record in recentListUsers)
    for (NSInteger i = 0; i < [recentListUsers count]; i++)
    {
        FriendRecord *record = recentListUsers[i];
        if ([[self formatNumber:record.phoneNumber] length] == 10)
        {
            [filterArray addObject: record];
        }
    }
    
    recentListUsers = filterArray;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            if(objects != nil)
            {NSLog(@"The find succeeded");
                // NSLog(@"%@", objects);
            }
            
            
            for (PFUser* object in objects)
            {
                NSLog(@"%@", object.username);
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"user" equalTo:object];
                NSString * Name = [[PFUser currentUser] objectForKey:@"fullName"];
                NSString * Username = [[PFUser currentUser] objectForKey:@"username"];
                
                // Send push notification to query
                NSDictionary *data = @{
                                       
                                       @"content-available": @"1",
                                       @"alert" : [NSString stringWithFormat:@"Uh-oh! %@ (%@) is using Typeface! 🙈" ,Name, Username],
                                       @"sound" : @"digi_blip_hi_2x.aif",
                                       @"p" :[PFUser currentUser].objectId,
                                       @"t" :[PFUser currentUser][@"phoneNumber"],
                                       
                                       };
                
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery];
                [push setMessage:@"this works"];
                [push setData:data];
                /*[push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *sendError)
                 {
                 NSLog(@"Sending Push");
                 }];*/
                
                //[[PFUser currentUser] addUniqueObject:object.objectId forKey:@"friends"];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *saveerror) {
                }];
                
            }
            
            [GetCurrentParseUser() loadFriendsListWithCompletion:^(NSArray* friends, NSError* loadError)
             {
                 
                 PFObject* localDatastore = [PFObject objectWithClassName:@"localDatastore"];
                 
                 UpdateFriendRecordListForFriends(friends);
                 
                 
                 for (NSInteger i=0; i < [recentListUsers count]; i++)
                 {
                     
                     FriendRecord *temprecord = [recentListUsers objectAtIndex:i];
                     for (FriendRecord *record in GetNameSortedFriendRecords())
                     {
                         
                         if ([temprecord.phoneNumber isEqualToString: record.phoneNumber] )
                         {
                             recentListUsers[i] = record;
                             break;
                         }
                         
                     }
                     
                     FriendRecord *anothertemprecord = recentListUsers[i];
                     NSMutableDictionary *contact;
                     if (anothertemprecord.user == nil)
                     {
                         contact = [[NSMutableDictionary alloc] initWithObjects:@[anothertemprecord.fullName, anothertemprecord.phoneNumber, [NSString stringWithFormat:@"%f",anothertemprecord.lastActivityTime], ] forKeys:@[@"fullName", @"phoneNumber", @"lastActivityTime"]];
                     }
                     else
                     {
                         contact = [[NSMutableDictionary alloc] initWithObjects:@[anothertemprecord.fullName, anothertemprecord.phoneNumber, [NSString stringWithFormat:@"%f",anothertemprecord.lastActivityTime], anothertemprecord.user] forKeys:@[@"fullName", @"phoneNumber", @"lastActivityTime", @"user"]];
                     }
                     
                     
                     //NSLog(@"contact:%@", contact);
                     
                     
                     [contacts addObject:contact];
                 }
                 [recentListUsers sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
                  {
                      FriendRecord* record1 = (FriendRecord*)obj1;
                      FriendRecord* record2 = (FriendRecord*)obj2;
                      
                      return ([record1.fullName caseInsensitiveCompare:record2.fullName]);
                  }];
                 
                 [localDatastore addUniqueObjectsFromArray:contacts forKey:@"FriendsList"];
                 
                 [localDatastore pinInBackgroundWithBlock:^(BOOL succeeded, NSError *pinError) {
                     NSLog(@"pinned");
                 }];
                 [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *saveerror2) {
                 }];
                 NSLog(@"contacts");
                 
                 
                 // NSLog(@"contacts: %@", contacts);
                 
                 //[self updateFriendsLists];
             }];
        }
        
        
        
        else {
            NSLog(@"Did not find anyone");
            
        }
       // [self updateFriendsLists];
        if ([PFUser currentUser] != nil)
        {
            PFQuery *friendquery = [PFUser query];
            
            [friendquery whereKey:@"friends" equalTo:[PFUser currentUser].objectId];
            [friendquery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable friends, NSError * _Nullable error1) {
                if (friends != nil)
                    for (PFUser *user in friends)
                    {
                        [[PFUser currentUser] addUniqueObject:user.objectId  forKey:@"friends"];
                    }
            }];
        }
        PFQuery *queryLocal = [PFQuery queryWithClassName:@"localDatastore"];
        
        [queryLocal fromLocalDatastore];
        
        //NSLog(@"temp %@", temp);
        
        if( recentListUsers == nil)
        {
            recentListUsers = [[NSMutableArray alloc]init];
        }
        if (1)
        {
            
            
            NSArray* friends = [PFUser currentUser][@"friends"];
            //NSLog(@"friends: %@", friends);
            for (NSString * objectId in friends)
            {
                //NSLog(@"hi");
                [ParseUser findUserWithObjectId:objectId completion:^(ParseUser* user, NSError* error2)
                 {
                     
                     NSLog(@"USER YO:%@", user);
                     FriendRecord *record = [FriendRecord new];
                     record.fullName = user.fullName;
                     record.phoneNumber = user.phoneNumber;
                     record.user = user;
                     NSInteger flag = 0;
                     for (NSInteger i = 0; i < [recentListUsers count]; i++)
                     {
                         FriendRecord *friend =  recentListUsers[i];
                         // NSLog(@"friend: %@ record: %@", friend.phoneNumber, record.phoneNumber);
                         if ([friend.phoneNumber isEqualToString: record.phoneNumber])
                         {
                             // NSLog(@"found");
                             record.lastActivityTime = friend.lastActivityTime;
                             recentListUsers[i] = record;
                             //NSLog(@"record:%@",record.user);
                         }
                         else{
                             flag++;
                         }
                         
                     }
                     if (flag == [recentListUsers count])
                     {
                         [recentListUsers addObject:record];
                     }
                 }];
            }
            
            
            
            
            [recentListUsers sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
             {
                 FriendRecord* record1 = (FriendRecord*)obj1;
                 FriendRecord* record2 = (FriendRecord*)obj2;
                 
                 return ([record1.fullName caseInsensitiveCompare:record2.fullName]);
             }];
            
            //NSLog(@"recentListUsers udpated: %@", recentListUsers);
            
        }
        
        
    }];
    
    
    
    
    
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"." withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"\u00a0" withString:@""];
    
    
    
    
    NSInteger length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        
    }
    
    
    return mobileNumber;
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

