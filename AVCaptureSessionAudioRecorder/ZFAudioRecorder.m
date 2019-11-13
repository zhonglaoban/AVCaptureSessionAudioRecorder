//
//  ZFAudioRecorder.m
//  AVCaptureSessionAudioRecorder
//
//  Created by 钟凡 on 2019/10/31.
//  Copyright © 2019 钟凡. All rights reserved.
//

#import "ZFAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>

@interface ZFAudioRecorder()<AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;

@end


@implementation ZFAudioRecorder
{
    dispatch_queue_t _queue;
}
- (instancetype)init{
    if (self = [super init]) {
        _queue = dispatch_queue_create("zf.audioRecorder", DISPATCH_QUEUE_SERIAL);
        _session = [[AVCaptureSession alloc] init];
        dispatch_async(_queue, ^{
            [self configureSession];
        });
    }
    
    return self;
}
- (BOOL)canDeviceOpenMicrophone {
    //判断应用是否有使用麦克风的权限
    NSString *mediaType = AVMediaTypeAudio;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    BOOL result = NO;
    switch (authStatus) {
        case AVAuthorizationStatusRestricted:
            result = NO;
            break;
        case AVAuthorizationStatusDenied:
            result = NO;
            break;
        case AVAuthorizationStatusAuthorized:
            result = YES;
            break;
        default:
            result = NO;
            break;
    }
    return result;
}
- (void)checkAudioAuthorization:(void (^)(int code, NSString *message))completeBlock {
    BOOL result = [self canDeviceOpenMicrophone];
    if (result) {
        completeBlock(0, @"可以使用麦克风");
        return;
    }
    dispatch_suspend(_queue);
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        if (granted == NO) {
            completeBlock(-1, @"用户拒绝使用麦克风");
        }else {
            completeBlock(0, @"可以使用麦克风");
        }
        dispatch_resume(self->_queue);
    }];
}
- (void)configureSession {
    NSError *error = nil;
    
    //输入设备
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    
    //数据输出
    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [audioOutput setSampleBufferDelegate:self queue:_queue];
    
    if (error) {
        NSLog(@"Error getting audio input device: %@", error.description);
        return;
    }
    
    [self.session beginConfiguration];
    // 添加输入
    if ([self.session canAddInput:audioInput]) {
        [self.session addInput:audioInput];
    }
    // 添加输出
    if ([self.session canAddOutput:audioOutput]) {
        [self.session addOutput:audioOutput];
        self.audioOutput = audioOutput;
    }
    [self.session commitConfiguration];
}
- (void)startRecord {
    [self checkAudioAuthorization:^(int code, NSString *message) {
        NSLog(@"checkAudioAuthorization code: %d, message: %@", code, message);
    }];
    dispatch_async(_queue, ^{
        [self.session startRunning];
    });
}
- (void)stopRecord {
    dispatch_async(_queue, ^{
        [self.session stopRunning];
    });
}

#pragma mark - delegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    // 这里的sampleBuffer就是采集到的数据了，但它是Video还是Audio的数据，得根据captureOutput来判断
    if (captureOutput != self.audioOutput) {
        return;
    }
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t lengthAtOffset;
    size_t totalLength;
    char *data;
    CMBlockBufferGetDataPointer(blockBuffer, 0, &lengthAtOffset, &totalLength, &data);

    if ([_delegate respondsToSelector:@selector(audioRecorder:didRecoredAudioData:length:)]) {
        [_delegate audioRecorder:self didRecoredAudioData:data length:(unsigned int)totalLength];
    }
}

@end
