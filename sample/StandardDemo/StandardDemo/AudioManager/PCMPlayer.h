

#import <Foundation/Foundation.h>

@interface PCMplayer : NSObject
@property(nonatomic, assign)BOOL isPlaying;
@property (nonatomic) BOOL isPCMplayerCompletelyFinished;
-(void)playPCMFileWithPath:(NSString *) path;
-(void)stopImmediately;
@end
