//
//  CLHiddenTextViewController.m
//  CamLocker
//
//  Created by FlyinGeek on 3/21/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLUtilities.h"
#import "CLMarkerManager.h"
#import "CLHiddenTextViewController.h"
#import "UIColor+MLPFlatColors.h"
#import "SIAlertView.h"
#import "JDStatusBarNotification.h"

@interface CLHiddenTextViewController () {
    BOOL isKeyboardShown;
}

@property (weak, nonatomic) IBOutlet UIButton *addTextButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *textViewContainer;

@end

@implementation CLHiddenTextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [CLUtilities addBackgroundImageToView:self.view withImageName:@"bg_4.jpg"];
    
    isKeyboardShown = NO;
    self.textView.font = [UIFont fontWithName:@"OpenSans" size:15];
    self.textViewContainer.hidden = YES;

    self.addTextButton.layer.cornerRadius = 15;
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
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Almost there" andMessage:@"Are you ready to create this marker?"];
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                          }];
    [alertView addButtonWithTitle:@"Yes"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              
                              [JDStatusBarNotification showWithStatus:@"Encrypting Data..." styleName:JDStatusBarStyleError];
                              
                              [[CLMarkerManager sharedManager] addTextMarkerWithMarkerImage:[CLMarkerManager sharedManager].tempMarkerImage hiddenText:self.textView.text];
                              
                              [JDStatusBarNotification showWithStatus:@"New marker created!" dismissAfter:1.0f styleName:JDStatusBarStyleSuccess];
                              [CLMarkerManager sharedManager].tempMarkerImage = nil;
                              [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
