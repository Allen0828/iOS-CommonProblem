//
//  FileDownloadManager.m
//  iOS_note
//
//  Created by allen0828 on 2022/6/27.
//

#import "FileDownloadManager.h"
#import <UIKit/UIKit.h>

@interface FileDownloadManager() <NSURLSessionDownloadDelegate, NSURLSessionDataDelegate>

/** 下载文件名称 */
@property (copy, nonatomic) NSString *fileName;
/** 下载路径 */
@property (copy, nonatomic) NSString *urlString;
/** 下载对象 */
@property (strong, nonatomic) NSURLSession *urlSession;
/** 下载任务 */
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
/** 下载任务 */
@property (nonatomic, strong) NSURLSessionDataTask *supportDownloadTask;
/** 文件句柄对象 */
@property (nonatomic, strong) NSFileHandle *fileHandle;
/** 保存上次的下载信息 */
@property (nonatomic, strong) NSData *resumeData;
/** 当前下载大小 */
@property (assign, nonatomic) NSInteger currentLength;
/** 文件大小 */
@property (assign, nonatomic) NSInteger fileLength;
@property (assign, nonatomic) URLSessionDownload SessionDownload;

@property (nonatomic,copy) NSString *savePath;


@end



@implementation FileDownloadManager

static NSString *FileName = @"AllenDownload";

- (NSString *)savePath {
    if (_savePath == nil) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        _savePath = [NSString stringWithFormat:@"%@/%@",path,FileName];
        BOOL isDir = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL existed = [fileManager fileExistsAtPath:_savePath isDirectory:&isDir];
        if (!(isDir == YES && existed == YES)) {
            [fileManager createDirectoryAtPath:_savePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _savePath;
}


- (NSURLSession*)urlSession{
    if ( _urlSession == nil ) {
        _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _urlSession;
}
 
- (NSURLSessionDataTask*)supportDownloadTask{
    if ( _supportDownloadTask == nil ) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", self.currentLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        _supportDownloadTask = [self.urlSession dataTaskWithRequest:request];
    }
    return _supportDownloadTask;
}
 
/// 开始下载文件
- (void)startDownload:(NSString *)urlString withType:(URLSessionDownload)SessionDownload {
    // 判断文件是否存在
    NSString *file = [FileDownloadManager base64EncodeString:urlString];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", self.savePath,file];
    if ([fileManager fileExistsAtPath:filePath]) {
        if (self.downloadFinishBlock) {
            self.downloadFinishBlock(filePath);
        }
        return;
    }
    _fileName = file;
    _urlString = urlString;
    _SessionDownload = SessionDownload;
    if ( _SessionDownload == URLSessionDownloadDefault ) {
        // 不支持挂起
        NSURLSessionDownloadTask *downloadTask = [self.urlSession downloadTaskWithURL:[NSURL URLWithString:urlString]];
        [downloadTask resume];
    } else if ( _SessionDownload == URLSessionDownloadNotSupport ) {
        //不支持离线下载
        if ( _downloadTask == nil ) {
            if ( _resumeData ) {//存在断点
                _downloadTask = [self.urlSession downloadTaskWithResumeData:_resumeData];
                [_downloadTask resume];
                _resumeData = nil;
            } else {//不存在，直接重新下载
                _downloadTask = [self.urlSession downloadTaskWithURL:[NSURL URLWithString:urlString]];
                [_downloadTask resume];
            }
        }
    } else if ( _SessionDownload == URLSessionDownloadSupport ) {
        //支持离线下载
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:_fileName];
        NSInteger currentLength = [self fileLengthForPath:path];
        if ( currentLength > 0 ) {
            _currentLength = currentLength;
        }
        [self.supportDownloadTask resume];
    }
 
}
 
/// 缓存的文件大小
- (NSInteger)fileLengthForPath:(NSString *)path{
    NSInteger fileLength = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ( [fileManager fileExistsAtPath:path] ) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if ( error != nil && fileDict ) {
            fileLength = [fileDict fileSize];
        }
    }
    return fileLength;
}
 
#pragma mark - 不支持离线下载
// 下载完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    if (self.SessionDownload == URLSessionDownloadSupport) {
        return;
    }
    NSString *file = [FileDownloadManager base64EncodeString:self.urlString];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", self.savePath,file];
    NSString *temPath = [location path];
    NSData *data = [NSData dataWithContentsOfFile:temPath];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    [fileManage createFileAtPath:filePath contents:data attributes:nil];
    if (self.downloadFinishBlock) {
        self.downloadFinishBlock(filePath);
    }
    NSLog(@"downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL");
}


// 下载进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask  didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if ( _SessionDownload != URLSessionDownloadSupport ) {
        float progress = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;
        if (self.downloadProgressBlcok) {
            self.downloadProgressBlcok(progress);
        }
    }
}
 
#pragma mark - 支持离线下载
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    if ( _SessionDownload == URLSessionDownloadSupport ) {
        // 文件将要移动到的指定目录
        _fileLength = response.expectedContentLength;
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        // 新文件路径
        NSString *newFilePath = [documentsPath stringByAppendingPathComponent:_fileName];
        NSFileManager *filemanager = [NSFileManager defaultManager];
        if ( ![filemanager fileExistsAtPath:newFilePath] ) {
            [filemanager createFileAtPath:newFilePath contents:nil attributes:nil];
        }
        self.fileHandle =  [NSFileHandle fileHandleForWritingAtPath:newFilePath];
        completionHandler(NSURLSessionResponseAllow);
    }
    NSLog(@"dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler");
}
 

// 把数据写入沙盒文件中
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if ( _SessionDownload == URLSessionDownloadSupport ) {
        // 下载进度
        // 指定数据的写入位置 -- 文件内容的最后面
        [self.fileHandle seekToEndOfFile];
        // 向沙盒写入数据
        [self.fileHandle writeData:data];
        // 拼接文件总长度
        self.currentLength += data.length;
        NSLog(@"%ld",self.currentLength);
        float progress = 1.0 * _currentLength / _fileLength;
//        NSString *propressString = [NSString stringWithFormat:@"当前下载进度:%.2f%%",100.0 * _currentLength / _fileLength];
        if (self.downloadProgressBlcok) {
            self.downloadProgressBlcok(progress);
        }
    }
    NSLog(@"dataTask:(NSURLSessionDataTask *)dataTask didReceiveData");
}
 
// 恢复下载
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"URLSession:(NSURLSession *)session downloadTask:didResumeAtOffset");
}
 
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if ( _SessionDownload == URLSessionDownloadSupport ) {
        [self.fileHandle closeFile];
        self.fileHandle = nil;
        _currentLength = 0;
        _fileLength = 0;
    }
//    if (!_progressFinishBlock) {
//        _progressFinishBlock();
//    }
    NSLog(@"URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:");
}
 
- (void)stopDownlod {
    if ( _SessionDownload == URLSessionDownloadSupport ) {
        [self.supportDownloadTask suspend];
        self.supportDownloadTask = nil;
    } else if (  _SessionDownload == URLSessionDownloadNotSupport  ){
        __weak typeof(self) weakSelf = self;
        [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            weakSelf.resumeData = resumeData;
            weakSelf.downloadTask = nil;
        }];
    }
}

+ (NSString *)base64EncodeString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

+ (NSString *)base64DecodeString:(NSString *)string {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:string options:0];
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

@end
