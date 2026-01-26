#include <jni.h>
#include "nitroiosalarmkitOnLoad.hpp"

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm, void*) {
  return margelo::nitro::nitroiosalarmkit::initialize(vm);
}
