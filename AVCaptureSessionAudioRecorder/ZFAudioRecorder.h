//
//  ZFAudioRecorder.h
//  AVCaptureSessionAudioRecorder
//
//  Created by 钟凡 on 2019/10/31.
//  Copyright © 2019 钟凡. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ZFAudioRecorder;

@protocol ZFAudioRecorderDelegate <NSObject>

///获取到音频数据
- (void)audioRecorder:(ZFAudioRecorder *)audioRecorder didRecoredAudioData:(void *)data length:(unsigned int)length;

@end


@interface ZFAudioRecorder : NSObject

@property (nonatomic, weak) id<ZFAudioRecorderDelegate> delegate;

- (void)startRecord;
- (void)stopRecord;

@end

NS_ASSUME_NONNULL_END
