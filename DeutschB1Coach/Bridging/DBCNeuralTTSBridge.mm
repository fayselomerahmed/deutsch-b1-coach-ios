#import "DBCNeuralTTSBridge.h"

#include <algorithm>
#include <cstring>

#include "sherpa-onnx/c-api/c-api.h"

@implementation DBCNeuralTTSBridge

- (nullable instancetype)initWithModelPath:(NSString *)modelPath
                                tokensPath:(NSString *)tokensPath
                             dataDirectory:(NSString *)dataDirectory {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    SherpaOnnxOfflineTtsConfig config;
    std::memset(&config, 0, sizeof(config));
    config.model.vits.model = modelPath.UTF8String;
    config.model.vits.tokens = tokensPath.UTF8String;
    config.model.vits.data_dir = dataDirectory.UTF8String;
    config.model.vits.noise_scale = 0.667f;
    config.model.vits.noise_scale_w = 0.8f;
    config.model.vits.length_scale = 1.0f;
    config.model.num_threads = 2;
    config.model.provider = "cpu";
    config.max_num_sentences = 1;
    config.silence_scale = 0.2f;

    const SherpaOnnxOfflineTts *tts = SherpaOnnxCreateOfflineTts(&config);
    if (tts == nullptr) {
        return nil;
    }

    _ttsHandle = const_cast<SherpaOnnxOfflineTts *>(tts);
    return self;
}

- (void)dealloc {
    if (_ttsHandle != nullptr) {
        SherpaOnnxDestroyOfflineTts(
            static_cast<const SherpaOnnxOfflineTts *>(_ttsHandle)
        );
        _ttsHandle = nullptr;
    }
}

- (BOOL)writeSpeechForText:(NSString *)text
                    toPath:(NSString *)outputPath
                     speed:(float)speed {
    if (_ttsHandle == nullptr || text.length == 0 || outputPath.length == 0) {
        return NO;
    }

    SherpaOnnxGenerationConfig config;
    std::memset(&config, 0, sizeof(config));
    config.silence_scale = 0.2f;
    config.speed = std::max(0.65f, std::min(speed, 1.35f));
    config.sid = 0;

    const SherpaOnnxGeneratedAudio *audio =
        SherpaOnnxOfflineTtsGenerateWithConfig(
            static_cast<const SherpaOnnxOfflineTts *>(_ttsHandle),
            text.UTF8String,
            &config,
            nullptr,
            nullptr
        );
    if (audio == nullptr || audio->samples == nullptr || audio->n <= 0) {
        if (audio != nullptr) {
            SherpaOnnxDestroyOfflineTtsGeneratedAudio(audio);
        }
        return NO;
    }

    const int32_t result = SherpaOnnxWriteWave(
        audio->samples,
        audio->n,
        audio->sample_rate,
        outputPath.UTF8String
    );
    SherpaOnnxDestroyOfflineTtsGeneratedAudio(audio);
    return result == 1;
}

@end
