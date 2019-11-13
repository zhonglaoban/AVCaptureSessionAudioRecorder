//
//  ViewController.m
//  AVCaptureSessionAudioRecorder
//
//  Created by 钟凡 on 2019/10/31.
//  Copyright © 2019 钟凡. All rights reserved.
//

#import "ViewController.h"
#import "ZFAudioRecorder.h"
#import "ZFAudioFileManager.h"

@interface ViewController ()<ZFAudioRecorderDelegate>
@property (strong, nonatomic) ZFAudioRecorder *audioRecorder;
@property (strong, nonatomic) ZFAudioFileManager *audioWriter;
@end

@implementation ViewController
- (IBAction)playAndRecord:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    if (sender.isSelected) {
        [self.audioRecorder startRecord];
    }else {
        [self.audioRecorder stopRecord];
        [_audioWriter closeFile];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    AudioStreamBasicDescription absd = {0};
    absd.mSampleRate = 44100;
    absd.mFormatID = kAudioFormatLinearPCM;
    absd.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    absd.mBytesPerPacket = 8;
    absd.mFramesPerPacket = 1;
    absd.mBytesPerFrame = 8;
    absd.mChannelsPerFrame = 4;
    absd.mBitsPerChannel = 16;
    
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [NSString stringWithFormat:@"%@/test.aif", directory];
    NSLog(@"%@", filePath);
    _audioWriter = [[ZFAudioFileManager alloc] initWithAsbd:absd];
    [_audioWriter openFileWithFilePath:filePath];
}

- (void)audioRecorder:(ZFAudioRecorder *)audioRecorder didRecoredAudioData:(void *)data length:(unsigned int)length {
    [self.audioWriter writeData:data length:length];
}

- (ZFAudioRecorder *)audioRecorder {
    if (_audioRecorder == nil) {
        _audioRecorder = [[ZFAudioRecorder alloc] init];
        _audioRecorder.delegate = self;
    }
    return _audioRecorder;
}

@end
