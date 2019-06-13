//
//  DragView.m
//  encrypt
//
//  Created by 张继东 on 2019/6/12.
//  Copyright © 2019 idanielz. All rights reserved.
//

#import "DragView.h"
#import <CommonCrypto/CommonCryptor.h>

static NSString * const key = @"$X&#ADvF";

@interface DragView ()
@property(nonatomic, assign)BOOL isDragIn;
@property(nonatomic, strong)NSTextField *tipLabel;
@property(nonatomic, strong)NSTextView *textView;
@end
@implementation DragView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,nil]];
        _tipLabel = [[NSTextField alloc]initWithFrame:CGRectMake(0, frame.size.height/2 - 50, frame.size.width, 100)];
        _tipLabel.font = [NSFont systemFontOfSize:50];
        _tipLabel.stringValue = @"✨目录拖到这里✨";
        _tipLabel.alignment = NSTextAlignmentCenter;
        [_tipLabel setBezeled:NO];
        [_tipLabel setDrawsBackground:NO];
        [_tipLabel setEditable:NO];
        [_tipLabel setSelectable:NO];
        [self addSubview:_tipLabel];
        _textView = [[NSTextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 50)];
        [self addSubview:_textView];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if(_isDragIn) {
        
        NSLog(@"拖拽了");
        
    }
    // Drawing code here.
}
- (NSDragOperation)draggingEntered:(id)sender
{
    _isDragIn=YES;
    
    [self setNeedsDisplay:YES];
    
    return NSDragOperationCopy;
    
}

- (void)draggingExited:(id)sender
{
    _isDragIn=NO;
    
    [self setNeedsDisplay:YES];
    
}

- (BOOL)prepareForDragOperation:(id)sender

{
    
    _isDragIn=NO;
    
    [self setNeedsDisplay:YES];
    
    return YES;
    
}

- (BOOL)performDragOperation:(id)sender

{
    
    if([sender draggingSource] !=self)
        
    {
        
        NSString* filePath= [[[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType] objectAtIndex:0];
        
        NSLog(@"文件地址%@",filePath);
        
        NSString *docPath = [[[[NSProcessInfo processInfo] environment] objectForKey:@"HOME"] stringByAppendingPathComponent:@"Documents"];
        _textView.string = [NSString stringWithFormat:@"打开\"终端\", 输入以下命令, 找到encryptLanmao目录\nopen %@", docPath];
        NSString *destPath = [docPath stringByAppendingPathComponent:@"encryptLanmao"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:destPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:destPath error:nil];
        }
        BOOL filesPresent =[[NSFileManager defaultManager] copyItemAtPath:filePath toPath:destPath error:NULL];
        if (filesPresent) {
            [self showAllFileWithPath:destPath];
        }
    }
    
    return YES;
    
}



- (void)showAllFileWithPath:(NSString *) path {
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:nil];
            NSString * subPath = nil;
            for (NSString * str in dirArray) {
                subPath  = [path stringByAppendingPathComponent:str];
                BOOL issubDir = NO;
                [fileManger fileExistsAtPath:subPath isDirectory:&issubDir];
                [self showAllFileWithPath:subPath];
            }
        }else{
            NSString *fileName = [[path componentsSeparatedByString:@"/"] lastObject];
            if (![fileName containsString:@"check.json"]) {
                if ([fileName hasSuffix:@".json"]
                    ||[fileName hasSuffix:@".lua"]
                    ||[fileName hasSuffix:@".file"]) {
                    NSLog(@"fileName:%@",fileName);
                    [self encryptWithFile:path];
                }
            }
            
        }
    }
}

-(void)encryptWithFile:(NSString*)filepath
{
    NSString *imagePath = filepath;
    NSData *ecryptedata = [NSData dataWithContentsOfFile:imagePath];
    NSData *codenew = [self ecryptUseDES:ecryptedata key:key];
    
    [[NSFileManager defaultManager] createFileAtPath:filepath contents:codenew attributes:nil];
}

-(NSData *)ecryptUseDES:(NSData *)plainData key:(NSString *)key
{
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    size_t bufferSize = (plainData.length + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);;
    NSMutableData *cypherData = [NSMutableData dataWithLength:bufferSize];
    size_t movedBytes = 0;
    
    CCCryptorStatus ccStatus;
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithmDES,
                       kCCOptionPKCS7Padding|kCCOptionECBMode,
                       keyData.bytes,
                       kCCKeySizeDES,
                       NULL,
                       plainData.bytes,
                       plainData.length,
                       cypherData.mutableBytes,
                       cypherData.length,
                       &movedBytes);
    
    cypherData.length = movedBytes;
    if( ccStatus == kCCSuccess ) {
        return cypherData;
    } else {
        NSLog(@"Failed DES ecrypt, status: %d", ccStatus);
        return nil;
    }
}

@end
