
#import "RNReactLogging.h"

@implementation RNReactLogging

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE();

NSString *tag = @"RNReactLogging";
BOOL consoleLog = YES;
BOOL fileLog = NO;
long maxFileSize = 512 * 1024; // 512 kb

RCT_EXPORT_METHOD(printLog:(NSString *)content) {
    if (consoleLog) {
        NSLog(@"%@",content);
    }
    if (fileLog) {
        [self writeLogToFile:content];
    }
}

RCT_EXPORT_METHOD(writeLogToFile: (NSString*) content) {
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *logFolder = [documentDir stringByAppendingPathComponent:@"rn-loggings"];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    BOOL isExist = [fm fileExistsAtPath:logFolder isDirectory:&isDir];
    if (!isExist) {
        // create folder
        NSError *error = nil;
        BOOL success = [fm createDirectoryAtPath:logFolder withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success) {
            // An error has occurred, do something to handle it
            NSLog(@"Failed to create directory \"%@\". Error: %@", logFolder, error);
            return;
        }
    }

    NSString *lastLogFile = [self getLastFilesFromFolder:logFolder];
    if (lastLogFile == nil) {
        lastLogFile = [self createFile:logFolder fileName:@"log0.txt"];
    }
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:lastLogFile error:nil] fileSize];

    if (fileSize > maxFileSize) {
        
        NSInteger newNumber = [self getLogNumber:lastLogFile].integerValue + 1;
        lastLogFile = [self createFile:logFolder fileName:[NSString stringWithFormat:@"log%ld.txt", (long)newNumber]];
    }
    if (lastLogFile == nil) {
        NSLog(@"Cannot create log file");
        return;
    }
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyy HH:mm:ss"];
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:lastLogFile];
    if (fileHandle) {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[[NSString stringWithFormat:@"%@ - %@ - %@", tag, currentDate, content] dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }
    else {
        [[NSString stringWithFormat:@"%@ - %@ - %@", tag, currentDate, content] writeToFile:lastLogFile
                  atomically:NO
                    encoding:NSStringEncodingConversionAllowLossy
                       error:nil];
    }
}

RCT_EXPORT_METHOD(listAllLogFiles: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *logFolder = [documentDir stringByAppendingPathComponent:@"rn-loggings"];
    NSFileManager *fm = [NSFileManager defaultManager];

    BOOL isDir = NO;
    BOOL isExist = [fm fileExistsAtPath:logFolder isDirectory:&isDir];
    if (!isExist) {
        resolve([[NSArray alloc] init]);
        return;
    }
    NSArray* filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logFolder error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF EndsWith '.txt'"];
    filesArray =  [filesArray filteredArrayUsingPredicate:predicate];
    
    // sort by creation date
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:[filesArray count]];
    
    for(NSString* file in filesArray) {
        
        if (![file isEqualToString:@".DS_Store"]) {
            NSString* filePath = [logFolder stringByAppendingPathComponent:file];
            [result addObject:filePath];
        }
    }
    resolve(result);

}

RCT_EXPORT_METHOD(setTag: (NSString*)tag) {
    // do nothing here
}

RCT_EXPORT_METHOD(setConsoleLogEnabled: (BOOL)enabled) {
    consoleLog = enabled;
}

RCT_EXPORT_METHOD(setFileLogEnabled: (BOOL)enabled) {
    fileLog = enabled;
}

RCT_EXPORT_METHOD(setMaxFileSize: (NSInteger)maxSize) {
    maxFileSize = maxSize;
}

- (NSString *)getLogNumber: (NSString*) filePath {
    return [[[filePath lastPathComponent] stringByReplacingOccurrencesOfString:@"log" withString:@""] stringByReplacingOccurrencesOfString:@".txt" withString:@""];
}


-(NSString*)createFile: (NSString*)folderPath fileName: (NSString*)fileName {
    
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    NSData *fileContents = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileContents attributes:nil];
    return filePath;
}

-(NSString*)getLastFilesFromFolder: (NSString*)folderPath
{
    NSError *error = nil;
    NSArray* filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF EndsWith '.txt'"];
    filesArray =  [filesArray filteredArrayUsingPredicate:predicate];
    
    // sort by creation date
    NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
    
    for(NSString* file in filesArray) {
        
        if (![file isEqualToString:@".DS_Store"]) {
            NSString* filePath = [folderPath stringByAppendingPathComponent:file];
            NSDictionary* properties = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
            NSDate* modDate = [properties objectForKey:NSFileModificationDate];
            [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys: filePath, @"path", modDate, @"lastModDate", nil]];
            
        }
    }
    
    // Sort using a block - order inverted as we want latest date first
    NSArray* sortedFiles = [filesAndProperties sortedArrayUsingComparator:
                            ^(id path1, id path2)
                            {
                                // compare
                                NSComparisonResult comp = [[path1 objectForKey:@"lastModDate"] compare:[path2 objectForKey:@"lastModDate"]];
//                                // invert ordering
//                                if (comp == NSOrderedDescending) {
//                                    comp = NSOrderedAscending;
//                                }
//                                else if(comp == NSOrderedAscending){
//                                    comp = NSOrderedDescending;
//                                }
                                return comp;
                            }];
    if (sortedFiles.count > 0) {
        return [sortedFiles[sortedFiles.count - 1] objectForKey:@"path"];
    }
    return nil;
    
}

@end
