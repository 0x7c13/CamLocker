//
//  CLMarkerCreationViewController.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLUtilities.h"
#import "CLMarkerManager.h"
#import "CLMarkerCreationViewController.h"
#import "PECropViewController.h"
#import "SWSnapshotStackView.h"
#import "UIColor+MLPFlatColors.h"
#import "SIAlertView.h"
#import "TSMessage.h"

@interface CLMarkerCreationViewController () <PECropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    BOOL hasEdited;
}

@property (strong, nonatomic) IBOutlet SWSnapshotStackView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextStepButton;

@end

@implementation CLMarkerCreationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [CLUtilities addBackgroundImageToView:self.view withImageName:@"bg_4.jpg"];
    
    self.imageView.contentMode = UIViewContentModeRedraw;
    self.imageView.displayAsStack = NO;
    self.imageView.hidden = YES;
    
    hasEdited = NO;
    
    self.addImageButton.layer.cornerRadius = 15;
}

- (void)viewDidLayoutSubviews
{
    if (self.addImageButton.layer.sublayers.count != 2) {
        [self.addImageButton.layer addSublayer:[CLUtilities addDashedBorderToView:self.addImageButton
                                                                    withColor:[UIColor flatWhiteColor].CGColor]];
    }
}

- (IBAction)addMarkerButtonPressed:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    
#if TARGET_IPHONE_SIMULATOR
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#else
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
#endif
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (IBAction)editButtonPressed:(id)sender {
    
    if (!self.imageView.image) {
        
        [TSMessage showNotificationInViewController:self
                                              title:@"Oops"
                                           subtitle:@"Please add a photo first."
                                               type:TSMessageNotificationTypeError
                                           duration:1.5f
                               canBeDismissedByUser:YES];
        
        return;
    }
    
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = self.imageView.image;
    
    UIImage *image = self.imageView.image;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:NULL];
    hasEdited = YES;
}

- (IBAction)nextStepButtonPressed:(id)sender {
    
    if (!self.imageView.image) {
        
        [TSMessage showNotificationInViewController:self title:@"Oops"
                                           subtitle:@"Please add a marker image!"
                                               type:TSMessageNotificationTypeError
                                           duration:1.5f
                               canBeDismissedByUser:YES];
        
        return;
    } else if (!hasEdited) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Hint" andMessage:@"To make your marker easier to be detected, you may need to crop your image. Press edit button to manipulate if you need."];
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDestructive
                              handler:nil];
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
        alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
        alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
        
        [alertView show];
        hasEdited = YES;
        return;
    } else {
        [self performSegueWithIdentifier:@"markerChosenSegue" sender:sender];
    }
}

- (IBAction)retakeButtonPressed:(id)sender {
    [self addMarkerButtonPressed:sender];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [[CLMarkerManager sharedManager] setTempMarkerImage:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)executeAnimation
{
    NSLog(@"Start animation");
    CGRect initRect = self.imageView.frame;
    self.imageView.frame = CGRectMake(initRect.origin.x - 25, initRect.origin.y - 25, initRect.size.width + 50, initRect.size.height + 50);
    
    [UIView animateWithDuration:1.0f delay:.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.imageView.alpha = 1.0f;
        self.imageView.frame = initRect;
    }completion:nil];
    
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
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

    [picker dismissViewControllerAnimated:NO completion:nil];
    [self executeAnimation];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:NO completion:nil];
    self.imageView.image = croppedImage;
    self.imageView.alpha = 0.0f;
    [self executeAnimation];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [CLMarkerManager sharedManager].tempMarkerImage = self.imageView.image;
}

@end
