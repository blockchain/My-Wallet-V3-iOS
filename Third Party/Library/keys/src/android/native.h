#ifndef NATIVE_H
#define NATIVE_H

#include <jni.h>

typedef struct {
    char *class;
    const JNINativeMethod *methods;
    jint count;
} native_methods;

#define METHODS(CLASS, METHODS) {                           \
    .class     = "com/lambdaworks/keys/" CLASS,             \
    .methods   = METHODS,                                   \
    .count     = sizeof(METHODS) / sizeof(JNINativeMethod), \
}

#endif /* NATIVE_H */
