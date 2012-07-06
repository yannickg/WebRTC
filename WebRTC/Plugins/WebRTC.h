//
//  UIControls.h
//  Cordova
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

#ifdef CORDOVA_FRAMEWORK
    #import <Cordova/CDVPlugin.h>
#else
    #import "CDVPlugin.h"
#endif


@interface WebRTC : CDVPlugin <AVCaptureVideoDataOutputSampleBufferDelegate> 
{
	AVCaptureSession *_captureSession;
	AVCaptureVideoPreviewLayer *_prevLayer;
}

/*!
 @brief	The capture session takes the input from the camera and capture it
 */
@property (nonatomic, retain) AVCaptureSession *captureSession;

/*!
 @brief	The CALAyer customized by apple to display the video corresponding to a capture session
 */
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *prevLayer;

@property (nonatomic, retain) UIView* childView;

- (void)createView;

- (void)getUserMedia:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
