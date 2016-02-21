//
//  ViewController.m
//  WeddingVideoBooth
//
//  Created by Frédéric Mouza on 15/07/13.
//  Copyright (c) 2013 Frédéric Mouza. All rights reserved.
//  Test Github

#import "ViewController.h"
#import "MobileCoreServices/UTCoreTypes.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "DIYCam.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize MainView;
@synthesize tog_camera,counter1,counter2,counter3,counterVideo,info;
@synthesize but_play, but_record,but_trash;

@synthesize cam             = _cam;
@synthesize previewLayer;
@synthesize stillImage;
@synthesize captureSession;
@synthesize captureInput;
@synthesize captureImageOutput;
@synthesize captureAudioOutput;
@synthesize captureVideoOutput;
@synthesize captureDevice;
@synthesize imageViewTest;
@synthesize cacheBlanc;


@synthesize captureManager;
@synthesize library;


// Initialisation du système

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    // Capture Management
    [self setCaptureSession:[[AVCaptureSession alloc] init]];
    // Fin Capture Management

    self.library = [[ALAssetsLibrary alloc] init];

    CaptureStatus=0;
    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    captureSession = [[AVCaptureSession alloc] init];
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    for (AVCaptureDevice *device in devices){
        if ([device position] == AVCaptureDevicePositionFront) {
            frontCamera = device;
        }
    }
    
    if ([frontCamera isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
        NSError *error=nil;
        if ([frontCamera lockForConfiguration:&error]){
            [frontCamera unlockForConfiguration];
        }
    }

    AVCaptureDevice *audioDevice;
    NSArray *AudioDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    for (AVCaptureDevice *device in AudioDevices){
        audioDevice=device;
    }

    NSError *error = nil;
    AVCaptureDeviceInput *frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    
    [captureSession addInput:frontFacingCameraDeviceInput];
    [captureSession addInput:audioInput];
    [captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    captureVideoOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureImageOutput =[[AVCaptureStillImageOutput alloc] init];
    captureAudioOutput=[[AVCaptureAudioDataOutput alloc] init];
    [captureSession addOutput:captureVideoOutput];
    [captureSession addOutput:captureAudioOutput];
    [captureSession addOutput:captureImageOutput];
        
}



// Gestion des phases d'enregistrement

- (void)countup {
    MainInt -=1;
    
    if (MainInt == 3)  {
        UIImage *counter3img = [UIImage imageNamed:@"3_rouge.png"];
        UIImage *counter2img = [UIImage imageNamed:@"2_blanc.png"];       
        UIImage *counter1img = [UIImage imageNamed:@"1_blanc.png"];
        
        [counter3 setImage:counter3img];
        [counter2 setImage:counter2img];
        [counter1 setImage:counter1img];
    }
    
    if (MainInt == 2)  {
        UIImage *counter3img = [UIImage imageNamed:@"3_blanc.png"];
        UIImage *counter2img = [UIImage imageNamed:@"2_rouge.png"];
        UIImage *counter1img = [UIImage imageNamed:@"1_blanc.png"];
        
        [counter3 setImage:counter3img];
        [counter2 setImage:counter2img];
        [counter1 setImage:counter1img];
    }
    
    if (MainInt == 1)  {
        UIImage *counter3img = [UIImage imageNamed:@"3_blanc.png"];
        UIImage *counter2img = [UIImage imageNamed:@"2_blanc.png"];
        UIImage *counter1img = [UIImage imageNamed:@"1_rouge.png"];
        
        [counter3 setImage:counter3img];
        [counter2 setImage:counter2img];
        [counter1 setImage:counter1img];
    }
    
    
    if (MainInt == 0)  {
        [counter3 setHidden:YES];
        [counter2 setHidden:YES];
        [counter1 setHidden:YES];
        
        [timer invalidate];
        timer = nil;
        
        if (tog_camera.selectedSegmentIndex==0) {
            CaptureMode=1;
            // on prend la photo et on l'affiche dans le cadre
            self.but_trash.hidden=NO;
            self.but_save.hidden=NO;
            
            [captureSession stopRunning];

            AVCaptureConnection *videoConnection = nil;
            for (AVCaptureConnection *connection in captureImageOutput.connections)
            {
                for (AVCaptureInputPort *port in [connection inputPorts])
                {
                    if ([[port mediaType] isEqual:AVMediaTypeVideo] )
                    {
                        videoConnection = connection;
                        break;
                    }
                }
                if (videoConnection) { break; }
            }
            
            [captureSession startRunning];            
            [captureImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
             {
                 CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                 if (exifAttachments)
                 {
                     // Do something with the attachments.
                     NSLog(@"attachements: %@", exifAttachments);
                 }
                 else
                     NSLog(@"no attachments");
                 
                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                 stillImage = [[UIImage alloc] initWithData:imageData];

             }];
            
            [captureSession stopRunning];
            timerPhoto= [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countUpPhoto) userInfo:nil repeats:NO];

            
        }
        
        if (tog_camera.selectedSegmentIndex==1) {
            CaptureMode=2;
            CaptureStatus=1;
            self.counterVideo.hidden=NO;
            MainIntVideo = 20;
            counterVideo.text=[NSString stringWithFormat:@"%i",MainIntVideo];
            self.but_record.enabled=YES;
            
            self.aView.hidden=YES;
            [self.cam setupWithOptions:@{DIYAVSettingCameraPosition : [NSNumber numberWithInt:AVCaptureDevicePositionFront] }];
            [self.cam setCamMode:DIYAVModeVideo];
            [self.cam captureVideoStart];
            timerVideo = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countupVideo) userInfo:nil repeats:YES];

        }
        
    }
    
}

- (void) countUpRecord{
    [timerRecord invalidate];
    timerRecord = nil;
    self.but_record.enabled=YES;
    self.tog_camera.enabled=YES;
}

-(void)countUpPhoto{
    [timerPhoto invalidate];
    timerPhoto = nil;
    imageViewTest.image=stillImage;
    imageViewTest.transform= CGAffineTransformMakeScale(-1, 1);
    imageViewTest.hidden=NO;
}




- (void)countupVideo {
    
    MainIntVideo -=1;
    self.counterVideo.text=[NSString stringWithFormat:@"%i",MainIntVideo];
    
    if (MainIntVideo==0){
        self.counterVideo.hidden=YES;
        [timerVideo invalidate];
        timerVideo = nil;
        CaptureStatus=0;
        [self.cam captureVideoStop];
        self.cacheBlanc.hidden=NO;
        self.but_record.enabled=NO;
        self.but_trash.hidden=NO;
        self.but_save.hidden=NO;
        self.but_play.hidden=NO;
        self.infoBut.hidden=NO;

    }
    
    
    
}




// Gestion des boutons de l'interface

- (IBAction)but_play:(UIButton *)sender {

    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc]init];
    [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop){
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets]-1)] 
                                options:0
                             usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            if (alAsset){
                ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                NSURL *url = [representation url];
                MPMoviePlayerViewController *playercontroller = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
                [self presentMoviePlayerViewControllerAnimated:playercontroller];
                playercontroller.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
                [playercontroller.moviePlayer play];
                playercontroller = nil;
            }
        }];
    }
    failureBlock:^(NSError *error){ }];
    
}

- (IBAction)but_save:(UIButton *)sender {
    self.but_trash.hidden=YES;
    self.but_save.hidden=YES;
    self.but_play.hidden=YES;
    self.infoBut.hidden=YES;
    
    if (CaptureMode==1){
      [self.library saveImage:stillImage toAlbum:@"MariageJR" withCompletionBlock:^(NSError *error) {
        if (error!=nil) {
            NSLog(@"Big error: %@", [error description]);
        }
      }];}
    
    else if (CaptureMode==2){
        __block ALAssetsGroup* groupToAddTo;
        NSString *albumName = @"MariageJR";
        [self.library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                    usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                        if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:albumName]) {
                                            NSLog(@"found album %@", albumName);
                                            groupToAddTo = group;
                                        }
                                    }
                                  failureBlock:^(NSError* error) {
                                      NSLog(@"failed to enumerate albums:\nError: %@", [error localizedDescription]);
                                  }];
        
        
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc]init];
        [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop){
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets]-1)]
                                    options:0
                                 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                                     if (alAsset){
                                         ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                                         NSURL *url = [representation url];
                                         
                                         [self.library assetForURL:url
                                                       resultBlock:^(ALAsset *asset) {
                                                           // assign the photo to the album
                                                           [groupToAddTo addAsset:asset];
                                                           NSLog(@"Added %@ to %@", [[asset defaultRepresentation] filename], albumName);
                                                       }
                                                      failureBlock:^(NSError* error) {
                                                          NSLog(@"failed to retrieve image asset:\nError: %@ ", [error localizedDescription]);
                                                      }];
                                     }
                                 }];
        }
                         failureBlock:^(NSError *error){ }];
        
        
        
    };
    
    CaptureMode=0;
    cacheBlanc.hidden=NO;
    info.hidden=NO;
    self.aView.hidden=NO;
    
    timerRecord = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countUpRecord) userInfo:nil repeats:NO];
    

    
}

- (IBAction)but_trash:(UIButton *)sender {
    self.but_trash.hidden=YES;
    self.but_save.hidden=YES;
    self.but_play.hidden=YES;
    self.infoBut.hidden=YES;

    
        if (CaptureMode==1){
    [self.library saveImage:stillImage toAlbum:@"MariageJRDeleted" withCompletionBlock:^(NSError *error) {
        if (error!=nil) {
            NSLog(@"Big error: %@", [error description]);
        }
    }];
        }
    
        else if (CaptureMode==2){
            __block ALAssetsGroup* groupToAddTo;
            NSString *albumName = @"MariageJRDeleted";
            [self.library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                        usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                            if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:albumName]) {
                                                NSLog(@"found album %@", albumName);
                                                groupToAddTo = group;
                                            }
                                        }
                                      failureBlock:^(NSError* error) {
                                          NSLog(@"failed to enumerate albums:\nError: %@", [error localizedDescription]);
                                      }];
            
            
            ALAssetsLibrary *lib = [[ALAssetsLibrary alloc]init];
            [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop){
                [group setAssetsFilter:[ALAssetsFilter allVideos]];
                [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets]-1)]
                                        options:0
                                     usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                                         if (alAsset){
                                             ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                                             NSURL *url = [representation url];
                                             
                                             [self.library assetForURL:url
                                                           resultBlock:^(ALAsset *asset) {
                                                               // assign the photo to the album
                                                               [groupToAddTo addAsset:asset];
                                                               NSLog(@"Added %@ to %@", [[asset defaultRepresentation] filename], albumName);
                                                           }
                                                          failureBlock:^(NSError* error) {
                                                              NSLog(@"failed to retrieve image asset:\nError: %@ ", [error localizedDescription]);
                                                          }];
                                         }
                                     }];
            }
                             failureBlock:^(NSError *error){ }];
            
            
            
        };
    
    
    
    
    
    CaptureMode=0;
            
    cacheBlanc.hidden=NO;
    info.hidden=NO;
    self.aView.hidden=NO;

    timerRecord = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countUpRecord) userInfo:nil repeats:NO];


}

- (IBAction)but_record:(UIButton *)sender {
    
    imageViewTest.hidden=YES;
    
    if (CaptureStatus==0){
        
        cacheBlanc.hidden=YES;
        
        self.but_record.enabled=NO;
        self.tog_camera.enabled=NO;
        
        self.but_trash.hidden=YES;
        self.but_save.hidden=YES;
        self.but_play.hidden=YES;
        info.hidden=YES;
        imageViewTest.hidden=YES;
    
        MainInt = 4;
        
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countup) userInfo:nil repeats:YES];
        [counter3 setHidden:NO];
        [counter2 setHidden:NO];
        [counter1 setHidden:NO];
        
        UIImage *counter3img = [UIImage imageNamed:@"3_blanc.png"];
        UIImage *counter2img = [UIImage imageNamed:@"2_blanc.png"];
        UIImage *counter1img = [UIImage imageNamed:@"1_blanc.png"];
        
        [counter3 setImage:counter3img];
        [counter2 setImage:counter2img];
        [counter1 setImage:counter1img];
        
        previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:captureSession];
        previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        CGRect rect = CGRectMake(0, 0, self.aView.bounds.size.width, self.aView.bounds.size.height);
        previewLayer.frame = rect;
        [self.aView.layer addSublayer:previewLayer];
        [captureSession startRunning];
        
    }
    else if (CaptureStatus==1){
        
        self.but_record.enabled=NO;
        self.counterVideo.hidden=YES;
        [timerVideo invalidate];
        timerVideo = nil;
        CaptureStatus=0;
        
        [self.cam captureVideoStop];
        self.cacheBlanc.hidden=NO;
        self.but_trash.hidden=NO;
        self.but_save.hidden=NO;
        self.but_play.hidden=NO;
        self.infoBut.hidden=NO;


        
    
    }
    
    

    
    
}







// Gestion des ressources du système

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    //[captureManager release], captureManager = nil;
    //[super dealloc];
}




@end
