//
//  ViewController.h
//  WeddingVideoBooth
//
//  Created by Frédéric Mouza on 15/07/13.
//  Copyright (c) 2013 Frédéric Mouza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Libraries/CaptureSessionManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "DIYCam.h"
#import <MediaPlayer/MediaPlayer.h>

#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"

@interface ViewController : UIViewController

<DIYCamDelegate, UIGestureRecognizerDelegate>

{
    IBOutlet UIImageView *counter3;
    IBOutlet UIImageView *counter2;
    IBOutlet UIImageView *counter1;
    IBOutlet UISegmentedControl *tog_camera;
    IBOutlet UILabel *counterVideo;
    IBOutlet UILabel *info;
    
    IBOutlet UILabel *infoBut;
    IBOutlet UIImageView *imageViewTest;
    
    IBOutlet UIImageView *cacheBlanc;
    IBOutlet UIImageView *MainView;
    
    NSTimer *timer;
    int MainInt;
    NSTimer *timerVideo;
    int MainIntVideo;
    int MainIntSave;
    int CaptureStatus;
    int CaptureMode;
    NSTimer *timerPhoto;
    NSTimer *timerRecord;
    
}

@property (strong, nonatomic) IBOutlet UIView *aView;

@property IBOutlet DIYCam *cam;

@property (retain) CaptureSessionManager *captureManager;
@property (strong, atomic) ALAssetsLibrary* library;

// Capture Management
@property (retain) AVCaptureSession *captureSession;
@property (retain) AVCaptureDevice *captureDevice;
@property (retain) AVCaptureDeviceInput *captureDeviceInput;
@property (retain) AVCaptureVideoDataOutput *captureVideoOutput;
@property (retain) AVCaptureStillImageOutput *captureImageOutput;
@property (retain) AVCaptureAudioDataOutput *captureAudioOutput;
@property (retain) AVCaptureInput *captureInput;
@property (retain) AVCaptureMovieFileOutput *movieOutput;
@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, retain) UIImage *stillImage;

- (void)addVideoPreviewLayer;
- (void)addStillImageOutput;
- (void)captureStillImage;
- (void)addVideoInputFrontCamera:(BOOL)front;

// Fin Capture Management


@property (strong, nonatomic) IBOutlet UIImageView *imageViewTest;
@property (strong, nonatomic) IBOutlet UIImageView *cacheBlanc;




@property (strong, nonatomic) IBOutlet UIImageView *MainView;

@property (nonatomic,retain) IBOutlet UIImageView *counter3;
@property (nonatomic,retain) IBOutlet UIImageView *counter2;
@property (nonatomic,retain) IBOutlet UIImageView *counter1;
@property (nonatomic,retain) IBOutlet UILabel *counterVideo;
@property (nonatomic,retain) IBOutlet UILabel *info;
@property (nonatomic,retain) IBOutlet UILabel *infoBut;


@property (nonatomic,retain) IBOutlet UISegmentedControl *tog_camera;
@property (nonatomic,retain) IBOutlet UIButton *but_record;
@property (strong, nonatomic) IBOutlet UIButton *but_play;
@property (strong, nonatomic) IBOutlet UIButton *but_save;
@property (strong, nonatomic) IBOutlet UIButton *but_trash;

- (IBAction)but_record:(UIButton *)sender;
- (IBAction)but_play:(UIButton *)sender;
- (IBAction)but_save:(UIButton *)sender;
- (IBAction)but_trash:(UIButton *)sender;

- (void)countup;
- (void)countupVideo;
- (void)countUpPhoto;
- (void)countUpRecord;



@end
