#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBCNeuralTTSBridge : NSObject {
@private
    void *_ttsHandle;
}

- (nullable instancetype)initWithModelPath:(NSString *)modelPath
                                tokensPath:(NSString *)tokensPath
                             dataDirectory:(NSString *)dataDirectory
    NS_SWIFT_NAME(init(modelPath:tokensPath:dataDirectory:));

- (BOOL)writeSpeechForText:(NSString *)text
                    toPath:(NSString *)outputPath
                     speed:(float)speed
    NS_SWIFT_NAME(writeSpeech(text:outputPath:speed:));

@end

NS_ASSUME_NONNULL_END
