//
//  ZHAudioFileStream.m
//  Parse
//
//  Created by zhanghan on 2019/5/22.
//  Copyright © 2019 zhanghan. All rights reserved.
//

#import "ZHAudioFileStream.h"

@interface ZHAudioFileStream ()
@property(nonatomic, weak) id<ZHAudioFileStreamDelegate> delegate;
@property(nonatomic, assign) NSInteger idx;
@property(nonatomic, assign) AudioFileStreamID mFileStreamID;
@property(nonatomic, assign) AudioFileTypeID mFileType;
@property(nonatomic, assign) NSInteger newAudioDuration;//音频数据的字节总量
@property(nonatomic, assign) int newBitRate;//音频码率
@end

@implementation ZHAudioFileStream

- (AudioFileTypeID)fileTypeID {
    return _mFileType;
}

- (AudioFileStreamID)fileStreamID {
    return _mFileStreamID;
}

- (instancetype)initWithFileType:(AudioFileTypeID)typeId idx:(NSInteger)idx delegate:(id)delegate {
    self = [super init];
    if (self) {
        _newAudioDuration = 0;
        _newBitRate = 0;
        _idx = idx;
        _delegate = delegate;
        _mFileType = typeId;
    }
    return self;
}

- (void)openAudioFileStreamWithError:(NSError **)error {
    void *inClientData = (__bridge void *) self;
    OSStatus status = AudioFileStreamOpen(inClientData, &ZHAudioFileStreamPropertyCallBack, &ZHAudioFileStreamPacketsCallBack, _mFileType, &_mFileStreamID);
    if (status != noErr) {
        _mFileStreamID = NULL;
    }
}

- (BOOL)parseData:(NSData *)originalData parseError:(NSError **)error {
    UInt32 dataByteSize = (UInt32)[originalData length];
    OSStatus status =  AudioFileStreamParseBytes(_mFileStreamID,dataByteSize,[originalData bytes],0);
    return  noErr == status;
}

- (void)closeAudioFileStream {
    if (_mFileStreamID != NULL) {
        AudioFileStreamClose(_mFileStreamID);
        _mFileStreamID = NULL;
    }
}

//解析音频处理
- (void)handleParseAudioFileStreamProperty:(AudioFileStreamPropertyID)propertyID
                                   ioFlags:(AudioFileStreamPropertyFlags *)flags {
    if (propertyID == kAudioFileStreamProperty_AudioDataByteCount) {
        [self parsedAudioDataByteCount];
    } else if (propertyID == kAudioFileStreamProperty_BitRate) {
        [self parsedBitRate];
    }
}

//获取音频数据的字节总量
- (void)parsedAudioDataByteCount {
    UInt64 audioDataByteCount;
    UInt32 byteCountSize = sizeof(audioDataByteCount);
    OSStatus status = AudioFileStreamGetProperty(_mFileStreamID, kAudioFileStreamProperty_AudioDataByteCount, &byteCountSize, &audioDataByteCount);
    if (status == noErr) {
        NSLog(@"audioDataByteCount =========== %ld",(long)audioDataByteCount);
        _newAudioDuration = audioDataByteCount;
        
        if (_newBitRate != 0 && _newAudioDuration != 0) {
            if ([_delegate respondsToSelector:@selector(audioFileStreamCallBackAudioDuration:byte:idx:)]) {
                [_delegate audioFileStreamCallBackAudioDuration:_newAudioDuration byte:_newBitRate idx:_idx];
            }
        }
    }
}

//获取音频码率
- (void)parsedBitRate {
    UInt32 bitRate;
    UInt32 bitRateSize = sizeof(bitRate);
    OSStatus status = AudioFileStreamGetProperty(_mFileStreamID, kAudioFileStreamProperty_BitRate, &bitRateSize, &bitRate);
    if (status == noErr)
    {
        NSLog(@"bitRate ============ %d",bitRate);
        _newBitRate = bitRate;
        
        if (_newBitRate != 0 && _newAudioDuration != 0) {
            if ([_delegate respondsToSelector:@selector(audioFileStreamCallBackAudioDuration:byte:idx:)]) {
                [_delegate audioFileStreamCallBackAudioDuration:_newAudioDuration byte:_newBitRate idx:_idx];
            }
        }
    }
}


#pragma mark ------ AudioFileStreamCallBack
static void ZHAudioFileStreamPropertyCallBack(void *inClientData,AudioFileStreamID inAudioFileStream,AudioFileStreamPropertyID inPropertyID,AudioFileStreamPropertyFlags *ioFlags) {
    ZHAudioFileStream *stream = (__bridge ZHAudioFileStream *)inClientData;
    if (inPropertyID == kAudioFileStreamProperty_AudioDataByteCount || inPropertyID == kAudioFileStreamProperty_BitRate) {
        [stream handleParseAudioFileStreamProperty:inPropertyID ioFlags:ioFlags];
    }
}


static void ZHAudioFileStreamPacketsCallBack(void *inClientData,UInt32 inNumberBytes,UInt32 inNumberPackets,const void *inInputData,AudioStreamPacketDescription *inPacketDescriptions) {
    
}

@end
