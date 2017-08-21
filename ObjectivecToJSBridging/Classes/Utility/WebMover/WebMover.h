
#import <Foundation/Foundation.h>

@interface WebMover : NSObject

+(NSString*)moveDirectoriesAndWebFilesOfType:(NSArray*)webFileTypes error:(NSError**)error;

@end
