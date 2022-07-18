//
//  AEAudioSwift.swift
//  iOS_note
//
//  Created by allen0828 on 2022/7/8.
//

import UIKit
import AVFoundation


extension Data {
    func convertedTo(_ format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let streamDesc = format.streamDescription.pointee
        let frameCapacity = UInt32(count) / streamDesc.mBytesPerFrame
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else { return nil }

        buffer.frameLength = buffer.frameCapacity
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers

        withUnsafeBytes { (bufferPointer) in
            guard let addr = bufferPointer.baseAddress else { return }
            audioBuffer.mData?.copyMemory(from: addr, byteCount: Int(audioBuffer.mDataByteSize))
        }
        return buffer
    }
}


@objc class AEAudioSwift: UIViewController {
    /*
     streamDesc.mSampleRate = 44100
     streamDesc.mFormatID = kAudioFormatLinearPCM
     streamDesc.mChannelsPerFrame = 2;
     streamDesc.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
     streamDesc.mBitsPerChannel = 16;
     streamDesc.mBytesPerFrame = (streamDesc.mBitsPerChannel/8) * streamDesc.mChannelsPerFrame;
     streamDesc.mBytesPerPacket = streamDesc.mBytesPerFrame;
     streamDesc.mFramesPerPacket = 1;
     */
    private var audioFormat = AVAudioFormat(settings:[
        AVFormatIDKey: AVAudioCommonFormat.pcmFormatInt16,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        AVEncoderBitRateKey: 16,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 44100]
                                            as [String : AnyObject])
    
    private var audioPlayer = AVAudioPlayerNode()
    
    private lazy var audioEngine: AVAudioEngine = {
        let engine = AVAudioEngine()
        // Must happen only once.
        engine.attach(self.audioPlayer)
        return engine
    }()
    
    override func viewDidLoad() {
        guard let filefullpathstr = Bundle.main.path(forResource: "alove", ofType: "pcm") else { return  }
        guard let audioFormat = self.audioFormat else { return  }
        
        do {
            let url = URL(fileURLWithPath: filefullpathstr)
            let data = try Data(contentsOf: url)
            guard let audioFileBuffer = data.convertedTo(audioFormat) else {return}
            
            
            audioEngine.connect(audioPlayer, to: audioEngine.mainMixerNode, format: audioFormat)
            try audioEngine.start()
            audioPlayer.scheduleBuffer(audioFileBuffer);
            //audioPlayer.volume = 1
            audioPlayer.play()
        } catch let error  {
            print("!! error \(error.localizedDescription)")
        }
        
    }

}
