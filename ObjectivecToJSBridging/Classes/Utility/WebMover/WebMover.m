
#import "WebMover.h"

@interface WebMover ()

+(NSString*)moveWebFiles:(NSArray*)movableFileTypes error:(NSError**)error;
+(NSString*)moveDirectoriesSearchingForIndexHTML:(BOOL)searchFlag error:(NSError**)error;
+(NSString*)searchForIndexHTMLFile:(NSMutableArray*)resources atIndex:(int)curIndex usingManager:(NSFileManager*)fileManager error:(NSError**)error;

@end

@implementation WebMover

+(NSString*)moveDirectoriesAndWebFilesOfType:(NSArray*)webFileTypes error:(NSError**)error{
    NSString *indexHTMLPath = nil;
    if (webFileTypes != nil) {
        NSError *moveError = nil;
        indexHTMLPath = [WebMover moveWebFiles:webFileTypes error:&moveError];
        if (moveError != nil) {
            *error = moveError;
            return nil;
        }
    }
    NSError *moveError = nil;
    NSString *foundIndexPath = [WebMover moveDirectoriesSearchingForIndexHTML:(indexHTMLPath == nil) error:&moveError];
    if (moveError != nil) {
        *error = moveError;
        return nil;
    }
    if (indexHTMLPath == nil) {
        indexHTMLPath = foundIndexPath;
    }
    return indexHTMLPath;
}


+(NSString*)moveWebFiles:(NSArray*)movableFileTypes error:(NSError**)error{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *indexPath = nil;
    NSString *resourcesPath = [NSBundle mainBundle].resourcePath;
    NSString *tempPath = NSTemporaryDirectory();
    NSError *anError = nil;
    NSArray *resourcesList = [fileManager contentsOfDirectoryAtPath:resourcesPath error:&anError];
    if (anError != nil) {
        *error = anError;
        return nil;
    }
    for (NSString *resourceName in resourcesList) {
        BOOL isMovableType = NO;
        for (NSString *fileType in movableFileTypes) {
            if ([resourceName.lowercaseString hasSuffix:fileType]) {
                isMovableType = YES;
                break;
            }
        }
        if (isMovableType) {
            NSString *destinationPath = [tempPath stringByAppendingPathComponent:resourceName];
            if ([fileManager fileExistsAtPath:destinationPath]) {
                NSError *removeError = nil;
                [fileManager removeItemAtPath:destinationPath error:&removeError];
                if (removeError != nil) {
                    *error = removeError;
                    return nil;
                }
            }
            NSString *resourcePath = [resourcesPath stringByAppendingPathComponent:resourceName];
            NSError *copyError = nil;
            [fileManager copyItemAtPath:resourcePath toPath:destinationPath error:&copyError];
            if (copyError != nil) {
                *error = copyError;
                return nil;
            }
            if ([resourceName isEqualToString:@"index.html"]) {
                indexPath = destinationPath;
            }
        }
    }
    
    return indexPath;
}
+(NSString*)moveDirectoriesSearchingForIndexHTML:(BOOL)searchFlag error:(NSError**)error{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *indexPath = nil;
    NSString *resourcesPath = [NSBundle mainBundle].resourcePath;
    NSString *tempPath = NSTemporaryDirectory();
    NSError *anError = nil;
    NSArray *resourcesList = [fileManager contentsOfDirectoryAtPath:resourcesPath error:&anError];
    if (anError != nil) {
        *error = anError;
        return nil;
    }
    for (NSString *resourceName in resourcesList) {
        BOOL isDirectoryType = NO;
        NSString *resourcePath = [resourcesPath stringByAppendingPathComponent:resourceName];
        NSString *destinationPath = [tempPath stringByAppendingPathComponent:resourceName];
        [fileManager fileExistsAtPath:resourcePath isDirectory:&isDirectoryType];
        if (isDirectoryType && ![resourceName hasSuffix:@".lproj"]
            && ![resourceName isEqualToString:@"Frameworks"]
            && ![resourceName isEqualToString:@"META-INF"]
            && ![resourceName isEqualToString:@"_CodeSignature"]) {
            
            if ([fileManager fileExistsAtPath:destinationPath]) {
                NSError *removeError = nil;
                [fileManager removeItemAtPath:destinationPath error:&removeError];
                if (removeError != nil) {
                    *error = removeError;
                    return nil;
                }
            }
            NSError *copyError = nil;
            [fileManager copyItemAtPath:resourcePath toPath:destinationPath error:&copyError];
            if (copyError != nil) {
                *error = copyError;
                return nil;
            }
            else if(searchFlag){
                NSMutableArray *resources = [NSMutableArray array];;
                NSError *contentsError = nil;
                NSArray *childResourcesList = [fileManager contentsOfDirectoryAtPath:destinationPath error:&contentsError];
                if (contentsError != nil) {
                    continue;
                }
                for (NSString *childResource in childResourcesList) {
                    [resources addObject:@[destinationPath,childResource]];
                }
                NSError *searchError = nil;
                NSString *indexHTMLFilePath = [WebMover searchForIndexHTMLFile:resources atIndex:0 usingManager:fileManager error:&searchError];
                if (indexHTMLFilePath != nil) {
                    indexPath = indexHTMLFilePath;
                    searchFlag = NO;
                }
            }
        }
    }
    
    return indexPath;
}


+(NSString*)searchForIndexHTMLFile:(NSMutableArray*)resources atIndex:(int)curIndex usingManager:(NSFileManager*)fileManager error:(NSError**)error{
    NSString *resource = resources[curIndex][1];
    NSString *directoryPath = resources[curIndex][0];
    NSString *resourcePath = [directoryPath stringByAppendingPathComponent:resource];
    NSError *anError = nil;
    if ([resource.lowercaseString isEqualToString:@"index.html"]) {
        return resourcePath;
    }
    else{
        BOOL isDirectoryType = NO;
        [fileManager fileExistsAtPath:resourcePath isDirectory:&isDirectoryType];
        if (isDirectoryType) {
            NSArray *resourceList = [fileManager contentsOfDirectoryAtPath:resourcePath error:&anError];
            if (anError != nil) {
                *error = anError;
                return nil;
            }
            for (NSString *childResource in resourceList) {
                [resources addObject:@[resourcePath, childResource]];
            }
        }
    }
    return [WebMover searchForIndexHTMLFile:resources atIndex:curIndex + 1 usingManager:fileManager error:error];
}
@end
