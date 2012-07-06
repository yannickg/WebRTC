//
//  Cordova
//
//

#import "WebRTC.h"

#ifdef CORDOVA_FRAMEWORK
    // PhoneGap >= 1.2.0
    #import <Cordova/JSONKit.h>
#else
    // https://github.com/johnezang/JSONKit
    #import "JSONKit.h"
#endif

@implementation WebRTC

@synthesize captureSession = _captureSession;
@synthesize prevLayer = _prevLayer;

@synthesize childView;


-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (WebRTC*)[super initWithWebView:theWebView];
    return self;
}

/**
 * Create a native map view
 */
- (void)createView
{
	/*We setup the input*/
	AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput 
										  deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] 
										  error:nil];
	/*We setupt the output*/
	AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    
	/*While a frame is processes in -captureOutput:didOutputSampleBuffer:fromConnection: delegate methods no other frames are added in the queue.
	 If you don't want this behaviour set the property to NO */
	captureOutput.alwaysDiscardsLateVideoFrames = YES; 
    
	/*We specify a minimum duration for each frame (play with this settings to avoid having too many frames waiting
	 in the queue because it can cause memory issues). It is similar to the inverse of the maximum framerate.
	 In this example we set a min frame duration of 1/10 seconds so a maximum framerate of 10fps. We say that
	 we are not able to process more than 10 frames per second.*/
	//captureOutput.minFrameDuration = CMTimeMake(1, 10);
	
	/*We create a serial queue to handle the processing of our frames*/
	dispatch_queue_t queue;
	queue = dispatch_queue_create("cameraQueue", NULL);
	[captureOutput setSampleBufferDelegate:self queue:queue];
	dispatch_release(queue);
    
	// Set the video output to store frame in BGRA (It is supposed to be faster)
	NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey; 
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]; 
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
	[captureOutput setVideoSettings:videoSettings]; 
    
	/*And we create a capture session*/
	self.captureSession = [[AVCaptureSession alloc] init];
	/*We add input and output*/
	[self.captureSession addInput:captureInput];
	[self.captureSession addOutput:captureOutput];
    /*We use medium quality, ont the iPhone 4 this demo would be laging too much, the conversion in UIImage and CGImage demands too much ressources for a 720p resolution.*/
    [self.captureSession setSessionPreset:AVCaptureSessionPresetMedium];
    
	/*We add the preview layer*/
	self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession: self.captureSession];
    // TODO: make position dynamic, not hard coded.
	self.prevLayer.frame = CGRectMake(8, 8, 200, 200);
	self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

	self.childView = [[UIView alloc] init];
	[self.childView.layer addSublayer: self.prevLayer];
    
	[ [ [ self viewController ] view ] addSubview:self.childView];  

	/*We start the capture*/
	[self.captureSession startRunning];	
    
}

- (void)mapView:(MKMapView *)theMapView regionDidChangeAnimated: (BOOL)animated 
{ 
    float currentLat = theMapView.region.center.latitude; 
    float currentLon = theMapView.region.center.longitude; 
    float latitudeDelta = theMapView.region.span.latitudeDelta; 
    float longitudeDelta = theMapView.region.span.longitudeDelta; 
    
    NSString* jsString = nil;
	jsString = [[NSString alloc] initWithFormat:@"geo.onMapMove(\'%f','%f','%f','%f\');", currentLat, currentLon, latitudeDelta, longitudeDelta];
	[self.webView stringByEvaluatingJavaScriptFromString:jsString];
	[jsString autorelease];
}

- (void)getUserMedia:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if (!self.childView) 
	{
		[self createView];
	}
    
	if ([options objectForKey:@"successCallback"]) 
	{
		NSString *successCallback = [[options objectForKey:@"successCallback"] description];
        NSString* jsString = [NSString stringWithFormat:@"%@(\"%s\");", successCallback, "blob:http%3A//172.25.96.83/22c5b1af-1b82-419b-b13c-76705432b852"];
        [self.webView stringByEvaluatingJavaScriptFromString:jsString];
	}

    // TODO.
//	if ([options objectForKey:@"errorCallback"]) 
//	{
//		NSString *errorCallback = [[options objectForKey:@"errorCallback"] description];
//        NSString* jsString = [NSString stringWithFormat:@"%@(\"%i\");", errorCallback, -1];
//        [self.webView stringByEvaluatingJavaScriptFromString:jsString];
//	}
}

- (void)dealloc
{
	if(childView)
	{
		[ self.childView removeFromSuperview];
        self.childView = nil;
	}

    [super dealloc];
}

@end
