
#import "PCMplayer.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation PCMplayer

FILE *gPCMFile;
#define NUM_BUFFERS 3
static UInt32 gBufferSizeBytes=0x1000;
AudioQueueRef gQueue;

-(id)init
{
    self = [super init];
    if (self) {
        self.isPlaying = NO;
        self.isPCMplayerCompletelyFinished = NO;
        return self;
    }else
    {
        NSLog(@"PCMPlayer init fail");
        return nil;
    }
}


void BufferCallback(void *inUserData,AudioQueueRef inAQ,AudioQueueBufferRef buffer)
{
    PCMplayer* player=(__bridge PCMplayer*)inUserData;
    [player readPacketsIntoBuffer:buffer andQueue:inAQ];
}

-(void)playPCMFileWithPath:(NSString *) path{
    
    if (self.isPlaying == YES) {
        return;
    }
    
    gPCMFile=fopen([path cStringUsingEncoding:NSASCIIStringEncoding], "rb");
    if (gPCMFile==NULL) {
        printf("open PCM File error in current file %s,in line %d",__FILE__,__LINE__);
        return ;
    }
    

    AudioStreamBasicDescription dataFormat;
    dataFormat.mSampleRate=8000;
    dataFormat.mFormatID=kAudioFormatLinearPCM;
    dataFormat.mFormatFlags=kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    dataFormat.mFramesPerPacket=1;
    dataFormat.mChannelsPerFrame=1;
    dataFormat.mBitsPerChannel=16;
    dataFormat.mBytesPerFrame=2;
    dataFormat.mBytesPerPacket=2;
    dataFormat.mFramesPerPacket=1;
    dataFormat.mChannelsPerFrame=1;
    dataFormat.mBitsPerChannel=16;
    dataFormat.mReserved=0;
    
    OSStatus status = 0;
    
    status = AudioQueueNewOutput(&dataFormat, BufferCallback, (__bridge_retained void *)(self),nil,nil, 0, &gQueue);
    
    AudioQueueBufferRef buffers[NUM_BUFFERS];
    for (int i=0; i<NUM_BUFFERS; i++) {
        AudioQueueAllocateBuffer(gQueue, gBufferSizeBytes, &buffers[i]);
        if ([self readPacketsIntoBuffer:buffers[i] andQueue:gQueue]==1) {
            break;
        }
    }
    
    Float32 gain=0.5;
    AudioQueueSetParameter(gQueue, kAudioQueueParam_Volume, gain);
    AudioQueueStart(gQueue, nil);
    
    return ;
}


-(UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer andQueue:(AudioQueueRef) Queue {
    uint8_t *inbuf;
    UInt32 numBytes;
    inbuf=(uint8_t *)malloc(gBufferSizeBytes);
    numBytes=(UInt32)fread(inbuf, 1, gBufferSizeBytes,gPCMFile);
    NSData *aData=[[NSData alloc]initWithBytes:inbuf length:numBytes];
    
    if(numBytes>0){
        self.isPlaying = YES;
        self.isPCMplayerCompletelyFinished = NO;
        
        memcpy(buffer->mAudioData, aData.bytes, aData.length);
        buffer->mAudioDataByteSize=numBytes;
        AudioQueueEnqueueBuffer(Queue, buffer, 0, nil);
        
    }else{
        self.isPlaying = NO;
        self.isPCMplayerCompletelyFinished = YES;
        
        OSStatus result = AudioQueueStop(Queue, NO);
        if (result == noErr) {
            result = AudioQueueDispose(Queue, NO);
            if (result == noErr) {
                NSLog(@"has no data to play");
            }else
            {
                NSLog(@"return AudioQueueDispose");
            }
        }else
        {
            NSLog(@"return fail:AudioQueueStop");
        }
        
        
        return 1;
    }
    return 0;
}


-(void)stopImmediately
{
    if (self.isPlaying == NO) {
        return;
    }
    self.isPCMplayerCompletelyFinished = NO;
    OSStatus result = AudioQueueStop(gQueue, YES);
    
    if (result == noErr) {
        self.isPlaying = NO;
        NSLog(@"has no data to play");
    }else
    {
        NSLog(@"Fatal error%s",__FUNCTION__);
    }
}







@end

