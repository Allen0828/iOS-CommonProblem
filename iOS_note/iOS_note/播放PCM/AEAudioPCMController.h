//
//  AEAudioPCMController.h
//  iOS_note
//
//  Created by allen0828 on 2022/7/7.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>


@interface AEAudioPCMController : UIViewController


- (void)checkUsedQueueBuffer:(AudioQueueBufferRef) qbuf;
- (void)readPCMAndPlay:(AudioQueueRef)outQ buffer:(AudioQueueBufferRef)outQB;


@end


