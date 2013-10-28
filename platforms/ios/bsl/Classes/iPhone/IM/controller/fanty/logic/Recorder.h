//
//  Recorder.h
//  cube-ios
//
//  Created by apple2310 on 13-9-9.
//
//

#import <Foundation/Foundation.h>

@class AVAudioRecorder;
@class AVAudioPlayer;
@class Recorder;


@protocol RecorderDelegate <NSObject>

-(void)recordDidPlayFinish:(Recorder*)recorder;
-(void)recordDidPlayError:(Recorder*)recorder;
-(void)refreshAudioPower:(Recorder*)recorder level:(int)level;
-(void)recordTimeout:(Recorder*)record;
@end

@interface Recorder : NSObject{
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer*  audioPlayer;
    int recordEncoding;
    
    NSTimer* recordTimer;

}

@property(nonatomic,assign) float addInterval;
@property(nonatomic,assign) id<RecorderDelegate> delegate;
@property(nonatomic,strong) NSString*  recordId;


+(NSString*)recordFile:(NSString*)recordId;

+(NSString*)downloadVoiceFile:(NSString*)uqID;

-(void)record;

-(BOOL)isRecording;

-(void)stop;

-(void)play:(NSString*)content;

-(void)removeRecord;

@end
