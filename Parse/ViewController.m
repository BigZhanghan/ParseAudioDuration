//
//  ViewController.m
//  Parse
//
//  Created by zhanghan on 2019/5/22.
//  Copyright © 2019 zhanghan. All rights reserved.
//

#import "ViewController.h"
#import "ZHAudioFileStream.h"

@interface ViewController ()
@property (nonatomic, strong) ZHAudioFileStream *audioFileStream;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //在线音频地址
    NSString *url = @"http://47.100.182.128/group1/M00/00/1D/rBO6Z1ziXT-AXOROAA3PrhojZrs091.mp3";
    [self parseAudioFile:url idx:0];
}


- (void)parseAudioFile:(NSString *)url idx:(NSInteger)idx {
    _audioFileStream = [[ZHAudioFileStream alloc] initWithFileType:kAudioFileMP3Type idx:idx delegate:self];
    NSError *error = nil;
    [_audioFileStream openAudioFileStreamWithError:&error];
    if (error) {
        _audioFileStream = nil;
        NSLog(@"create audio file stream failed, error: %@",[error description]);
    } else {
        NSLog(@"audio file opened.");
        //解析音频文件
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        [_audioFileStream parseData:data parseError:&error];
        [_audioFileStream closeAudioFileStream];
        _audioFileStream = nil; 
        NSLog(@"audio file closed.");
    }
}

- (void)audioFileStreamCallBackAudioDuration:(NSInteger)byteCount byte:(int)byte idx:(NSInteger)idx {
    float duration = byteCount * 8.0 / byte;
    NSLog(@"音频时长 ====== %f",duration);
}

@end
