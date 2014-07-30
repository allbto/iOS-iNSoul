//
//  ChatViewController.m
//  Breeze
//
//  Created by Allan BARBATO on 7/27/12.
//  Copyright (c) 2012 Epitech. All rights reserved.
//

#import "ChatViewController.h"
#import "Messages.h"
#import "User.h"
#import "MessageCell.h"

static NSString * kMessageCellReuseIdentifier = @"MessageCell";
static int chatInputStartingHeight = 40;

@interface ChatViewController ()
{
    SystemSoundID   _hReceiveMessageSound;
}

// -- Private methods -- //

/*!
 Send message to netsoul connection
 */
- (void)sendMessage:(NSString*)message;
- (NSUInteger)addMessageWithText:(NSString *)message;
//- (NSUInteger)removeMessageAtIndex:(NSUInteger)index;
//- (void)clearAll;


// -- View Properties -- //

@property (retain, nonatomic) ChatInput*        chatInput;
@property (retain, nonatomic) UICollectionView* collectionView;
@property (retain, nonatomic) UIImageView*      backgroundImageView;

@end

@implementation ChatViewController

@synthesize conversation = _hConversation;

#pragma mark - NSObject

- (id)init
{
    if ((self = [super init]))
    {
        _hReceiveMessageSound = 0;
        _chatInput = nil;
        _collectionView = nil;
        _backgroundImageView = nil;
        _hConversation = nil;
        _netSoulConnection = nil;
        _isTyping = NO;
    }
    return self;
}

- (void)dealloc
{
    if (_hReceiveMessageSound) AudioServicesDisposeSystemSoundID(_hReceiveMessageSound);
    
    [_chatInput release];
    [_collectionView release];
    [_backgroundImageView release];
    [_hConversation release];
    [_netSoulConnection release];
    
    [super dealloc];
}

#pragma mark - UIViewController

- (void)viewDidUnload
{
    _chatInput = nil;
    _collectionView = nil;
    _backgroundImageView = nil;
    _hConversation = nil;
    _netSoulConnection = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set navigation bar title
    self.title = self.conversation.title;
    
    // Change background color, shown during rotation
    self.view.backgroundColor = [UIColor whiteColor];

    // Custom initialization
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    // ChatInput
    self.chatInput = [[ChatInput alloc]init];
    _chatInput.stopAutoClose = NO;
    _chatInput.placeholderLabel.text = @"  Send A Message";
    _chatInput.delegate = self;
    _chatInput.backgroundColor = [UIColor colorWithWhite:1 alpha:0.825f];

    // Set Up Flow Layout
    UICollectionViewFlowLayout * flow = [[UICollectionViewFlowLayout alloc]init];
    flow.sectionInset = UIEdgeInsetsMake(80, 0, 10, 0);
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.minimumLineSpacing = 6;
    
    // Background View
    _backgroundImageView = [[UIImageView alloc] initWithImage:[self.conversation.receiver.avatar applyEasyLightEffect]];
    [_backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    _backgroundImageView.frame = CGRectMake(0, 0, ScreenWidth(), ScreenHeight());
    _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    // Set Up CollectionView
    CGRect myFrame = (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation])) ? CGRectMake(0, 0, ScreenHeight(), ScreenWidth() - height(_chatInput)) : CGRectMake(0, 0, ScreenWidth(), ScreenHeight() - height(_chatInput));
    _collectionView = [[UICollectionView alloc]initWithFrame:myFrame collectionViewLayout:flow];
    //_myCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    _collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 2, 0, -2);
    _collectionView.allowsSelection = YES;
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_collectionView registerClass:[MessageCell class]
          forCellWithReuseIdentifier:kMessageCellReuseIdentifier];

    // Listen for keyboard.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Google analytics screen name
    self.screenName = @"ChatViewController";
    
    // Add views here, or they will create problems when launching in landscape
    if (IS_IPAD)
        _backgroundImageView.frame = CGRectMake(0, 0, ScreenHeight(), ScreenWidth());
    [self.view addSubview:_backgroundImageView];
    [self.view addSubview:_collectionView];
    [self.view addSubview:_chatInput];
    
    // Scroll CollectionView Before We Start
    [self scrollToBottom];

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_chatInput resignFirstResponder];
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark CLEAN UP

- (void) removeFromParentViewController
{
    // Removing subview and delegates
    [_chatInput removeFromSuperview];
    [_collectionView removeFromSuperview];
    [_backgroundImageView removeFromSuperview];
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [super removeFromParentViewController];
}

#pragma mark ROTATION CALLS

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Help Animation
    [_chatInput willRotate];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_chatInput isRotating];
    _collectionView.frame = (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) ? CGRectMake(0, 0, ScreenHeight(), ScreenWidth() - height(_chatInput)) : CGRectMake(0, 0, ScreenWidth(), ScreenHeight() - chatInputStartingHeight);
    [_collectionView reloadData];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_chatInput didRotate];
    [self scrollToBottom];
}

#pragma mark CHAT INPUT DELEGATE

- (void) chatInputNewMessageSent:(NSString *)messageString
{
    [self sendMessage:messageString];
}

- (void) chatInputDidChange:(NSString *)text
{
    [self.netSoulConnection sendTypingEvent:!(text.length == 0) to:self.conversation.title];
}

#pragma mark KEYBOARD NOTIFICATIONS

- (void)hideKeyboard
{
    [_chatInput resignFirstResponder];
}

- (void) keyboardWillShow:(NSNotification *)note
{
    if (!_chatInput.shouldIgnoreKeyboardNotifications) {
        
        NSDictionary *keyboardAnimationDetail = [note userInfo];
        UIViewAnimationCurve animationCurve = [keyboardAnimationDetail[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        CGFloat duration = [keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        
        NSValue* keyboardFrameBegin = [keyboardAnimationDetail valueForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
        int keyboardHeight = (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication]statusBarOrientation])) ? keyboardFrameBeginRect.size.height : keyboardFrameBeginRect.size.width;
        
        _collectionView.scrollEnabled = NO;
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        [UIView animateWithDuration:duration delay:0.0 options:(animationCurve << 16) animations:^{
            
            _collectionView.frame = (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation])) ? CGRectMake(0, 0, ScreenHeight(), ScreenWidth() - height(_chatInput) - keyboardHeight) : CGRectMake(0, 0, ScreenWidth(), ScreenHeight() - height(_chatInput) - keyboardHeight);
            
        } completion:^(BOOL finished) {
            if (finished) {
                
                [self scrollToBottom];
                _collectionView.scrollEnabled = YES;
                _collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
            }
        }];
    }
}

- (void) keyboardWillHide:(NSNotification *)note
{
    if (!_chatInput.shouldIgnoreKeyboardNotifications) {
        NSDictionary *keyboardAnimationDetail = [note userInfo];
        UIViewAnimationCurve animationCurve = [keyboardAnimationDetail[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        CGFloat duration = [keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        
        _collectionView.scrollEnabled = NO;
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        [UIView animateWithDuration:duration delay:0.0 options:(animationCurve << 16) animations:^{
            
            _collectionView.frame = (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation])) ? CGRectMake(0, 0, ScreenHeight(), ScreenWidth() - height(_chatInput)) : CGRectMake(0, 0, ScreenWidth(), ScreenHeight() - height(_chatInput));
            
        } completion:^(BOOL finished) {
            if (finished) {
                _collectionView.scrollEnabled = YES;
                _collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
                [self scrollToBottom];
            }
        }];
    }
}

#pragma mark COLLECTION VIEW DELEGATE

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Messages* message = _hConversation.messages[[indexPath indexAtPosition:1]];
    
    static int offset = 20;
    
    if (!message.size) {
        NSString * content = message.text;
        
        NSMutableDictionary * attributes = [[NSMutableDictionary new] autorelease];
        attributes[NSFontAttributeName] = [UIFont systemFontOfSize:15.0f];
        attributes[NSStrokeColorAttributeName] = [UIColor darkTextColor];
        
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithString:content
                                                                       attributes:attributes];
        
        // Here's the maximum width we'll allow our outline to be // 260 so it's offset
        int maxTextLabelWidth = maxBubbleWidth - outlineSpace;
        
        // set max width and height
        // height is max, because I don't want to restrict it.
        // if it's over 100,000 then, you wrote a fucking book, who even does that?
        CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(maxTextLabelWidth, 100000)
                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            context:nil];
        
        message.size = [NSValue valueWithCGSize:rect.size];
        
        return CGSizeMake(width(_collectionView), rect.size.height + offset);
    }
    else {
        return CGSizeMake(_collectionView.bounds.size.width, [message.size CGSizeValue].height + offset);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return _hConversation.messages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Get Cell
    MessageCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMessageCellReuseIdentifier
                                                                  forIndexPath:indexPath];

    Messages* message = _hConversation.messages[[indexPath indexAtPosition:1]];
    
    NSMutableDictionary * newMessageOb = [[NSMutableDictionary new] autorelease];
    newMessageOb[kMessageContent] = message.text;
    newMessageOb[kMessageTimestamp] = TimeStamp();
    newMessageOb[kMessageSize] = message.size;

    if (message.type == MessageSent) {
        newMessageOb[kMessageRuntimeSentBy] = [NSNumber numberWithInt:kSentByUser];
    }
    else {
        newMessageOb[kMessageRuntimeSentBy] = [NSNumber numberWithInt:kSentByOpponent];
    }

    // Set the cell
    //cell.opponentImage = _opponentImg;
    //if (_opponentBubbleColor) cell.opponentColor = _opponentBubbleColor;
    //if (_userBubbleColor) cell.userColor = _userBubbleColor;
    cell.message = newMessageOb;
    
    return cell;
    
}

#pragma mark COLLECTION VIEW METHODS

- (void) scrollToBottom
{
    @try {
        if (_hConversation.messages.count > 0) {
            static NSInteger section = 0;
            NSInteger item = [self collectionView:_collectionView numberOfItemsInSection:section] - 1;
            if (item < 0) return;
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
            [_collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        }
    }
    @catch (NSException* e)
    {
        //TODO: Under why an exeption is thrown
        NSLog(@"E : %@", e);
    }
}

#pragma mark - Message

- (void)sendMessage:(NSString*)message
{
    NSString *rightTrimmedMessage = [message stringByTrimmingTrailingWhitespaceAndNewlineCharacters];
    
    // Don't send blank messages.
    if (rightTrimmedMessage.length == 0) { return; }
    
    // Adding the message to the tableView and reloading it
    [self addMessageWithText:rightTrimmedMessage];
    [_collectionView reloadData];
    
    // Playing send sound
    NSString *sendPath = [[NSBundle mainBundle] pathForResource:@"basicsound" ofType:@"wav"];
    CFURLRef baseURL = (CFURLRef)[NSURL fileURLWithPath:sendPath];
    AudioServicesCreateSystemSoundID(baseURL, &_hReceiveMessageSound);
    AudioServicesPlaySystemSound(_hReceiveMessageSound);
}

- (NSUInteger)addMessageWithText:(NSString *)message
{
    // Adding just sent message to conversation
    [_hConversation addMessageWithText:message];

    // Stop user typing and send message
    [self.netSoulConnection sendTypingEvent:NO to:self.conversation.title];
    [self.netSoulConnection sendMessage:message to:_hConversation.title];
    
    return 1;
}

#pragma mark - Utils

- (void)reloadData
{
    [_collectionView reloadData];
    [self scrollToBottom];
}

#pragma mark - Setter/Getter

- (void)setIsTyping:(BOOL)isTyping
{
    _isTyping = isTyping;
    self.title = (isTyping ? @"Is typing" : self.conversation.title);
}

@end