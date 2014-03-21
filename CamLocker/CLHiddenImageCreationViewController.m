//
//  CLHiddenImageCreationViewController.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLUtilities.h"
#import "CLMarkerManager.h"
#import "CLHiddenImageCreationViewController.h"
#import "SWSnapshotStackView.h"
#import "JDStatusBarNotification.h"
#import "ETActivityIndicatorView.h"
#import "UIColor+MLPFlatColors.h"
#import "SIAlertView.h"

@interface CLHiddenImageCreationViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    BOOL isEncrypting;
}

@property (weak, nonatomic) IBOutlet SWSnapshotStackView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addMoreButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation CLHiddenImageCreationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [CLUtilities addBackgroundImageToView:self.view];
    
    isEncrypting = NO;
    self.imageView.contentMode = UIViewContentModeRedraw;
    self.imageView.displayAsStack = NO;
    self.imageView.hidden = YES;
}

- (void)viewDidLayoutSubviews
{
    [self.addImageButton.layer addSublayer:[CLUtilities addDashedBorderToView:self.addImageButton
                                                                    withColor:[UIColor flatWhiteColor].CGColor]];
}

- (IBAction)addImageButtonPressed:(id)sender {
    
    if (isEncrypting) return;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)addMoreButtonPressed:(id)sender {
    
}


- (IBAction)doneButtonPressed:(id)sender {
    
    if (isEncrypting) return;
    if (!self.imageView.image) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Oops" andMessage:@"Please add a photo."];
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDestructive
                              handler:nil];
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
        alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
        alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
        
        [alertView show];
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
                              
                              isEncrypting = YES;
                              ETActivityIndicatorView *etActivity = [[ETActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 30, self.view.frame.size.height/2 -30, 60, 60)];
                              [etActivity startAnimating];
                              [self.view addSubview:etActivity];
                              [JDStatusBarNotification showWithStatus:@"Encrypting Data..." styleName:JDStatusBarStyleError];
                              
                              [[CLMarkerManager sharedManager] addImageMarkerWithMarkerImage:[CLMarkerManager sharedManager].tempMarkerImage
                                                                                hiddenImages:@[self.imageView.image]
                                                                         withCompletionBlock:^{
                                                                             [JDStatusBarNotification showWithStatus:@"New marker created!" dismissAfter:1.0f styleName:JDStatusBarStyleSuccess];
                                                                             [CLMarkerManager sharedManager].tempMarkerImage = nil;
                                                                             [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                                             [etActivity stopAnimating];
                                                                             [etActivity removeFromSuperview];
                                                                             isEncrypting = NO;
                              
                                                                            }];
    }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
    alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
    alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
    
    [alertView show];
}

- (void)executeAnimation
{
    CGRect initRect = self.imageView.frame;
    self.imageView.frame = CGRectMake(initRect.origin.x - 25, initRect.origin.y - 25, initRect.size.width + 50, initRect.size.height + 50);
    [UIView animateWithDuration:1.2f animations:^{
        self.imageView.alpha = 1.0f;
        self.imageView.frame = initRect;
    } completion:^(BOOL finished){
    }];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = chosenImage;
    self.imageView.alpha = 0.0f;
    self.imageView.hidden = NO;
    self.addImageButton.hidden = YES;
    
    [self executeAnimation];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}



@end
