//
//  functions.h
//  Janet (iOS)
//
//  Created by Omar Estrella on 1/5/24.
//

#ifndef functions_h
#define functions_h

#include <stdlib.h>
#include "../Sources/janet.h"

typedef void(* Callback)(char*, void *);

typedef struct {
  void *swiftClassPtr;
  char *uuid;
  Callback callback;
} FunctionEntryCallback;

typedef struct {
  char *key;
  FunctionEntryCallback entry;
} CallbackDictionary;

FunctionEntryCallback initializeCallback(char *name, void *swiftClassPtr, Callback callback);
JanetCFunction wrapCallback(FunctionEntryCallback);

#endif /* functions_h */
