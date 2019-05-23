# ParseAudioDuration AudioFileStream解析在线音频

1、初始化AudioFileStream
- (void)openAudioFileStreamWithError:(NSError **)error;

2、要拿到文件数据就可以进行解析
- (BOOL)parseData:(NSData *)originalData parseError:(NSError **)error;

3、对解析音频结果进行处理
- (void)handleParseAudioFileStreamProperty:(AudioFileStreamPropertyID)propertyID
                                   ioFlags:(AudioFileStreamPropertyFlags *)flags

4、音频数据的字节总量audioDataByteCount可以通过kAudioFileStreamProperty_AudioDataByteCount获取:
//获取音频数据的字节总量
- (void)parsedAudioDataByteCount;

5、码率bitRate可以通过kAudioFileStreamProperty_BitRate获取:
//获取音频码率
- (void)parsedBitRate;

根据  double duration = (audioDataByteCount * 8) / bitRate 计算在线音频时长
