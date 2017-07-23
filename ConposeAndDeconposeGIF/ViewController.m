//
//  ViewController.m
//  ConposeAndDeconposeGIF
//
//  Created by TeemoThegoddess on 2017/7/23.
//  Copyright © 2017年 Bryant_Fu. All rights reserved.
//

#import "ViewController.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Use deConposeGIF method
    //[self deConposeGIF];
    //[self playGIF];
    [self conposeGIF];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) deConposeGIF{
    //Get a GIF
    NSString *gifPath = [[NSBundle mainBundle] pathForResource:@"eyes" ofType:@".gif"];
    NSData *gifData = [NSData dataWithContentsOfFile:gifPath];
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)gifData, nil);
    //Get the number of frames of a gif image
    size_t count = CGImageSourceGetCount(source);
    //NSLog(@"count = %zu",count);
    //Get every frame of gif and convert it to UIImage.Remember release memory!
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for (size_t i = 0; i < count; i++) {
        CGImageRef frameImage = CGImageSourceCreateImageAtIndex(source, i, NULL);
        UIImage *image = [UIImage imageWithCGImage:frameImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        [imageArray addObject:image];
        CGImageRelease(frameImage);
    }
    CFRelease(source);
    for (int i = 0; i < imageArray.count; i++) {
        NSData *data = UIImagePNGRepresentation([imageArray objectAtIndex:i]);
        NSArray *savePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *savePath = savePaths[0];
        //If you want to konw the path image saved,you can add a breakpoint on line 51 and check the value of parameter 'savePaths'.Or you can use NSLog to print it,just like this:
        NSLog(@"savePath = %@",savePath);
        NSString *saveName = [savePath stringByAppendingString:[NSString stringWithFormat:@"%d.png",i]];
        [data writeToFile:saveName atomically:NO];
    }
}

- (void) playGIF{
    NSMutableArray *gifImageArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 60; i++) {
        UIImage *frameImage = [UIImage imageNamed:[NSString stringWithFormat:@"Documents%d",i]];
        [gifImageArray addObject:frameImage];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 250, 140)];
    imageView.animationImages = gifImageArray;
    imageView.animationDuration = 4;
    //if you set 0 ,it mean this gif can't stop
    imageView.animationRepeatCount = 0;
    [self.view addSubview:imageView];
    [imageView startAnimating];
    //if you want to stop gif,use this method
    //[imageView stopAnimating];
}

-(void) conposeGIF{
    //Get images you want to make a gif
    NSArray *imageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"LinkenPark1.jpg"], [UIImage imageNamed:@"LinkenPark2.jpg"],[UIImage imageNamed:@"LinkenPark3.jpg"], [UIImage imageNamed:@"LinkenPark4.jpg"], [UIImage imageNamed:@"LinkenPark5.jpg"], nil];
    //set a path to save your gif
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = paths[0];
    NSString *savePath = [path stringByAppendingString:@"/gif/"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:savePath withIntermediateDirectories:NO attributes:nil error:nil];
    NSString *saveName = [savePath stringByAppendingString:@"LinkenPark.gif"];
    //print the savepath
    NSLog(@"saveName = %@",saveName);
    //Conpose a gif
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)saveName, kCFURLPOSIXPathStyle, false);
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, imageArray.count, NULL);
    //set every frame's property of conposing the gif
    NSDictionary *frameDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:0.3] forKey:(NSString *)kCGImagePropertyGIFDelayTime];
    //set gif property
    NSMutableDictionary *gifPropertiesDic = [[NSMutableDictionary alloc] initWithCapacity:2];
    [gifPropertiesDic setObject:[NSNumber numberWithInteger:10] forKey:(NSString *)kCGImagePropertyDepth];
    [gifPropertiesDic setObject:(NSString *)kCGImagePropertyColorModelRGB forKey:(NSString *)kCGImagePropertyColorModel];
    [gifPropertiesDic setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCGImagePropertyGIFImageColorMap];
    [gifPropertiesDic setObject:[NSNumber numberWithInteger:10] forKey:(NSString *)kCGImagePropertyGIFLoopCount];
    NSDictionary *gifDic = [NSDictionary dictionaryWithObject:gifPropertiesDic forKey:(NSString *)kCGImagePropertyGIFDictionary];
    for (UIImage *image in imageArray) {
        CGImageDestinationAddImage(destination, image.CGImage , (__bridge CFDictionaryRef)frameDic);
    }
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)gifDic);
    CGImageDestinationFinalize(destination);
    CFRetain(destination);
}
@end
