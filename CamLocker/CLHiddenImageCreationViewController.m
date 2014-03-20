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

@interface CLHiddenImageCreationViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    BOOL isEncrypting;
}

@property (weak, nonatomic) IBOutlet SWSnapshotStackView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;

@end

@implementation CLHiddenImageCreationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    isEncrypting = NO;
    self.imageView.contentMode = UIViewContentModeRedraw;
    self.imageView.displayAsStack = NO;
    self.imageView.hidden = YES;
    self.doneButton.hidden = YES;
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.frame];
    background.image = [UIImage imageNamed:@"bg_3.jpg"];
    [self.view insertSubview:background atIndex:0];
    
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

- (IBAction)doneButtonPressed:(id)sender {
    
    if (isEncrypting) return;
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
    self.doneButton.hidden = NO;
    self.addImageButton.hidden = YES;
    
    [self executeAnimation];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}



@end
