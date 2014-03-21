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

@interface CLHiddenTextViewController ()

@property (weak, nonatomic) IBOutlet UIButton *addTextButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation CLHiddenTextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [CLUtilities addBackgroundImageToView:self.view];
    
    self.textView.font = [UIFont fontWithName:@"OpenSans" size:15];
    self.textView.hidden = YES;
}

- (void)viewDidLayoutSubviews
{
    [self.addTextButton.layer addSublayer:[CLUtilities addDashedBorderToView:self.addTextButton
                                                                   withColor:[UIColor flatWhiteColor].CGColor]];
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
    self.textView.hidden = NO;
    [self.textView becomeFirstResponder];
}

- (IBAction)userDidTapOnBackground:(id)sender {
    [self.textView resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
