//
//  ZHAudioFileStream.h
//  Parse
//
//  Created by zhanghan on 2019/5/22.
//  Copyright © 2019 zhanghan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZHAudioFileStreamDelegate <NSObject>

- (void)audioFileStreamCallBackAudioDuration:(NSInteger)byteCount byte:(int)byte idx:(NSInteger)idx;

@end

@interface ZHAudioFileStream : NSObject
- (instancetype)initWithFileType:(AudioFileTypeID)typeId idx:(NSInteger)idx delegate:(id)delegate;
- (void)openAudioFileStreamWithError:(NSError **)error;
- (BOOL)parseData:(NSData *)originalData parseError:(NSError **)error;
- (void)closeAudioFileStream;
@end

NS_ASSUME_NONNULL_END
