// Don't load OpenGL
#define GLFW_INCLUDE_NONE

// Include GLFW's header from the system's location (e.g., `/usr/local/include`). The proper search
// path is provided by a `.pc` file parsed by Swift PM.
#include "GLFW/glfw3.h"

#include <OpenGL/gl3.h>
#include <OpenGL/gl3ext.h>
