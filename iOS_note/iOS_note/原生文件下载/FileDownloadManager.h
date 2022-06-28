//
//  FileDownloadManager.h
//  iOS_note
//
//  Created by allen0828 on 2022/6/27.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, URLSessionDownload) {
    URLSessionDownloadDefault,    //默认下载方式，不支持离线和暂停
    URLSessionDownloadNotSupport, //支持暂停断点下载，不支持离线
    URLSessionDownloadSupport,    //支持暂停断点下载，支持离线
};

@interface FileDownloadManager : NSObject


@property (nonatomic,copy) void(^downloadProgressBlcok)(float progress);
@property (nonatomic,copy) void(^downloadFinishBlock)(NSString*filePath);
 

- (void)startDownload:(NSString*)urlString withType:(URLSessionDownload)SessionDownload;
- (void)stopDownlod;


@end


