//
//  functions.c
//  Janet (iOS)
//
//  Created by Omar Estrella on 1/5/24.
//

#include "functions.h"


FunctionEntryCallback initializeCallback(char *id, void *swiftClassPtr, Callback callback) {
  FunctionEntryCallback entryCallback;
  entryCallback.uuid = id;
  entryCallback.swiftClassPtr = swiftClassPtr;
  entryCallback.callback = callback;
  return entryCallback;
}

Janet janetFunction(int32_t argc, Janet *argv, FunctionEntryCallback *entry) {
  
  return janet_wrap_nil();
//  return entryCallback.callback(entryCallback.name, entryCallback.swiftClassPtr, argc, argv);
}

JanetCFunction wrapCallback(FunctionEntryCallback entryCallback) {
  return janetFunction;
}
