//
//  CLHiddenTextViewController.m
//  CamLocker
//
//  Created by FlyinGeek on 3/21/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLUtilities.h"
#import "CLMarkerManager.h"
#import "CLDataHandler.h"
#import "CLHiddenTextViewController.h"
#import "UIColor+MLPFlatColors.h"
#import "SIAlertView.h"
#import "JDStatusBarNotification.h"
#import "MHNatGeoViewControllerTransition.h"
#import "TSMessage.h"
#import "THProgressView.h"
#import "ANBlurredImageView.h"
#import "ETActivityIndicatorView.h"

@interface CLHiddenTextViewController () {
    BOOL isKeyboardShown;
    BOOL canExit;
}

@property (weak, nonatomic) IBOutlet UIView *masterView;
@property (weak, nonatomic) IBOutlet UIButton *addTextButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *textViewContainer;
@property (weak, nonatomic) IBOutlet ANBlurredImageView *imageView;
@property (weak, nonatomic) IBOutlet THProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation CLHiddenTextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [CLUtilities addBackgroundImageToView:self.masterView withImageName:@"bg_4.jpg"];
    
    canExit = NO;
    isKeyboardShown = NO;
    
    self.textView.font = [UIFont fontWithName:@"OpenSans" size:15];
    self.textViewContainer.hidden = YES;
    
    self.progressView.borderTintColor = [UIColor whiteColor];
    self.progressView.progressTintColor = [UIColor whiteColor];
    self.progressView.hidden = YES;

    self.addTextButton.layer.cornerRadius = 15;
    
    [_imageView setHidden:YES];
    [_imageView setFramesCount:8];
    [_imageView setBlurAmount:1];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews
{
    if (self.addTextButton.layer.sublayers.count != 2) {
        [self.addTextButton.layer addSublayer:[CLUtilities addDashedBorderToView:self.addTextButton
                                                                   withColor:[UIColor flatWhiteColor].CGColor]];
    }
}

- (IBAction)doneButtonPressed:(id)sender {
    
    if (canExit) {
        [CLMarkerManager sharedManager].tempMarkerImage = nil;
        [self.navigationController dismissNatGeoViewController];
        self.navigationController.navigationBar.userInteractionEnabled = YES;
        return;
    }
    
    if (self.textView.text.length == 0) {
        [TSMessage showNotificationInViewController:self title:@"Oops"
                                           subtitle:@"Please add some text first."
                                               type:TSMessageNotificationTypeError
                                           duration:1.5f
                               canBeDismissedByUser:YES];
        return;
    }
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Almost there" andMessage:@"Are you ready to create this marker?"];
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                          }];
    [alertView addButtonWithTitle:@"Yes"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              
                              if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                                  self.navigationController.interactivePopGestureRecognizer.enabled = NO;
                              }
                              self.navigationController.navigationBar.userInteractionEnabled = NO;
                              self.textView.userInteractionEnabled = NO;
                              self.doneButton.enabled = NO;
                              
                              [JDStatusBarNotification showWithStatus:@"Encrypting Data..." styleName:JDStatusBarStyleError];
                              
                              self.imageView.hidden = NO;
                              self.imageView.image = [CLUtilities snapshotViewForView:self.masterView];
                              self.imageView.baseImage = self.imageView.image;
                              [self.imageView setBlurTintColor:[UIColor colorWithWhite:0.f alpha:0.5]];
                              [self.imageView generateBlurFramesWithCompletionBlock:^{
                                  
                                  [self.imageView blurInAnimationWithDuration:0.3f];
                                  ETActivityIndicatorView *etActivity = [[ETActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 30, self.view.frame.size.height/2 -30, 60, 60)];
                                  etActivity.color = [UIColor flatWhiteColor];
                                  [etActivity startAnimating];
                                  [self.view addSubview:etActivity];

                                  [[CLMarkerManager sharedManager] addTextMarkerWithMarkerImage:[CLMarkerManager sharedManager].tempMarkerImage
                                                                                    hiddenText:self.textView.text
                                                                             withCompletionBlock:^{
                                                                                 
                                                                                 [JDStatusBarNotification dismiss];
                                                                                 [self uploadMarker];
                                                                                 [etActivity removeFromSuperview];
                                                                                 
                                                                             }];
                                  
                              }];
                              
                              
                          }];

    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
    alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
    alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
    
    [alertView show];
}

- (IBAction)addTextButtonPressed:(id)sender {
    
    [self.addTextButton setTitle:@"" forState:UIControlStateNormal];
    self.addTextButton.userInteractionEnabled = NO;
    self.textViewContainer.hidden = NO;
    [self.textView becomeFirstResponder];
}

- (IBAction)userDidTapOnBackground:(id)sender {
    [self.textView resignFirstResponder];
}

- (void)uploadMarker
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Share" andMessage:@"Would you like to share this marker with your friends? You can upload it to our server and share it with your friends!"];
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                              [JDStatusBarNotification showWithStatus:@"New marker created!" dismissAfter:1.5f styleName:JDStatusBarStyleSuccess];
                              [CLMarkerManager sharedManager].tempMarkerImage = nil;
                              [self.navigationController dismissNatGeoViewController];
                              
                          }];
    [alertView addButtonWithTitle:@"Upload"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              
                              ETActivityIndicatorView *etActivity = [[ETActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 30, self.view.frame.size.height/2 -30, 60, 60)];
                              etActivity.color = [UIColor flatWhiteColor];
                              [etActivity startAnimating];
                              [self.view addSubview:etActivity];
                              
                              self.progressView.progress = 0.0f;
                              [self.progressView setProgress:0.0f animated:NO];
                              self.progressView.alpha = 0.0f;
                              self.progressView.hidden = NO;
                              [UIView animateWithDuration:0.5f animations:^{
                                  self.progressView.alpha = 1.0f;
                              }];
                              
                              [JDStatusBarNotification showWithStatus:@"Uploading marker..." styleName:JDStatusBarStyleError];
                              
                              self.progressView.progress = 0.0f;
                              self.progressView.alpha = 0.0f;
                              self.progressView.hidden = NO;
                              [UIView animateWithDuration:0.3f animations:^{
                                  self.progressView.alpha = 1.0f;
                              }];
                              
                              [CLDataHandler uploadMarker:[[CLMarkerManager sharedManager].markers lastObject]
                                                 progress:^(NSUInteger bytesWritten, NSInteger totalBytesWritten){
                                                     [self.progressView setProgress:(double)bytesWritten/(double)totalBytesWritten animated:YES];
                                                 }
                                          completionBlock:^(CLDataHandlerOption option, NSURL *markerURL, NSError *error){
                                              
                                              [etActivity removeFromSuperview];
                                              [JDStatusBarNotification showWithStatus:@"Marker uploaded!" dismissAfter:2.0f styleName:JDStatusBarStyleSuccess];
                                              
                                              [UIView animateWithDuration:0.3f animations:^{
                                                  self.progressView.alpha = 0.0f;
                                                  self.progressView.hidden = YES;
                                              }];
                                              
                                              if (option == CLDataHandlerOptionSuccess) {
                                                  
                                                  NSLog(@"%@", markerURL);
                                              } else {
                                                  NSLog(@"%@", error.localizedDescription);
                                              }
                                              
                                              [self showShareMenuWithDownloadURL:markerURL];
                                          }];
                              
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
    alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
    alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
    
    [alertView show];
}

- (void)showShareMenuWithDownloadURL:(NSURL *)markerURL
{
    canExit = YES;
    self.doneButton.enabled = YES;
    
    [super showShareMenuWithDownloadURL:markerURL];
}

#pragma mark keyboard settings

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up {
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = self.textView.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    if (DEVICE_IS_4INCH_IPHONE) {
        keyboardFrame.size.height -= self.navigationController.toolbar.frame.size.height;
    }
    newFrame.size.height -= keyboardFrame.size.height * (up?1:-1);
    self.textView.frame = newFrame;
    
    [UIView commitAnimations];
}

- (void)keyboardWillShown:(NSNotification*)aNotification
{
    if (!isKeyboardShown) {
        isKeyboardShown = YES;
        [self moveTextViewForKeyboard:aNotification up:YES];
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    if (isKeyboardShown) {
        [self moveTextViewForKeyboard:aNotification up:NO];
        isKeyboardShown = NO;
    }
}

@end
