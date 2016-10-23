//
//  CloverGoStatusCode.h
//  CloverGo
//
//  Copyright © 2016 First Data Inc. All rights reserved.
//

typedef enum{
    CloverGoCardReaderEventTypeCardSwiped,
    CloverGoCardReaderEventTypeRemoveCard,
    CloverGoCardReaderEventTypeSwipeFailed,
    CloverGoCardReaderEventTypeEMVCardSwipedError,
    CloverGoCardReaderEventTypeEMVDipFailed3Attempts,
    CloverGoCardReaderEventTypeEMVCardDipFailed,
    CloverGoCardReaderEventTypeEMVCardInserted,
    CloverGoCardReaderEventTypeRemoveAnyUIUpdates,
    CloverGoCardReaderEventTypeReadingDataFromCard,
    CloverGoCardReaderEventTypeTransactionSentOnline,
    CloverGoCardReaderEventTypeTransactionOffline,
    CloverGoCardReaderEventTypeReadingCardWithAIDSelected,
    CloverGoCardReaderEventTypeSwipeOrDipCardNow,
    CloverGoCardReaderEventTypeReadError,
    CloverGoCardReaderEventTypeConnectivityErrorVolumeLimitON,
    CloverGoCardReaderEventTypeConnectivityErrorMicrophoneAccessOFF,
    CloverGoCardReaderEventTypeTransactionCancelled,
    CloverGoCardReaderEventTypeReaderTimeout,
    CloverGoCardReaderEventTypeTimeoutExpired,
    CloverGoCardReaderEventTypeCardReaderGeneralError,
    CloverGoCardReaderEventTypeNonEMVCardOrCardError,
    CloverGoCardReaderEventTypeRSAKeyNotFound,
    CloverGoCardReaderEventTypeApplicationBlocked,
    CloverGoCardReaderEventTypeCardBlocked,
    CloverGoCardReaderEventTypeCardExpired,
    CloverGoCardReaderEventTypeTrackReadError,
    CloverGoCardReaderEventTypeCardNotSupported,
    CloverGoCardReaderEventTypeUnknown
} CloverGoCardReaderEventType;

typedef enum{
    CloverGoCardReaderResetStatusCodeInitializationStarted,
    CloverGoCardReaderResetStatusCodeClearAIDPublicKeysComplete,
    CloverGoCardReaderResetStatusCodeAidFlushComplete,
    CloverGoCardReaderResetStatusCodePublickeyFlushComplete,
    CloverGoCardReaderResetStatusCodeDOLFlushComplete,
    CloverGoCardReaderResetStatusCodeInitializationComplete,
    CloverGoCardReaderResetStatusCodeFlushErrorNoData,
    CloverGoCardReaderResetStatusCodeInitializationFailed,
    CloverGoCardReaderResetStatusCodeUnknown
}CloverGoCardReaderResetStatusCode;

typedef enum{
    CloverGoCardReaderType350,
    CloverGoCardReaderType450,
    CloverGoCardReaderTypeUnknown
}CloverGoCardReaderType;

typedef enum{
    CloverGoEnvironmentTest,
    CloverGoEnvironmentStaging,
    CloverGoEnvironmentSandboxdev,
    CloverGoEnvironmentLive
}CloverGoEnvironment;

typedef enum {
    CloverGoTransactionEventTypeAVSFailure,
    CloverGoTransactionEventTypeDuplicateTransaction,
    CloverGoTransactionEventTypePartiallyApprovedTransaction,
    CloverGoTransactionEventTypeInvalidRequest
}CloverGoTransactionEventType;

typedef enum {
    CloverGoTransactionTypeKeyed,
    CloverGoTransactionTypeCardReader
}CloverGoTransactionType;



