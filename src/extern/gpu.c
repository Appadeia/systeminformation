#include <GL/glew.h>
#include <GL/glut.h>

char* get_gl_version() {
    // Initialise GLFW
    glewExperimental = true; // Needed for core profile
    if (!glfwInit())
    {
        return "";
    }

    // We are rendering off-screen, but a window is still needed for the context
    // creation. There are hints that this is no longer needed in GL 3.3, but that
    // windows still wants it. So just in case.
    glfwWindowHint(GLFW_VISIBLE, GL_FALSE); //dont show the window

    // Open a window and create its OpenGL context
    GLFWwindow* window;
    window = glfwCreateWindow(100, 100, "Dummy window", NULL, NULL);
    if (window == NULL) {
        return "";
    }
    glfwMakeContextCurrent(window); // Initialize GLEW
    if (glewInit() != GLEW_OK)
    {
        return "";
    }
    return glGetString(GL_VERSION);
}

char* get_gl_renderer() {
    // Initialise GLFW
    glewExperimental = true; // Needed for core profile
    if (!glfwInit())
    {
        return "";
    }

    // We are rendering off-screen, but a window is still needed for the context
    // creation. There are hints that this is no longer needed in GL 3.3, but that
    // windows still wants it. So just in case.
    glfwWindowHint(GLFW_VISIBLE, GL_FALSE); //dont show the window

    // Open a window and create its OpenGL context
    GLFWwindow* window;
    window = glfwCreateWindow(100, 100, "Dummy window", NULL, NULL);
    if (window == NULL) {
        return "";
    }
    glfwMakeContextCurrent(window); // Initialize GLEW
    if (glewInit() != GLEW_OK)
    {
        return "";
    }
    return glGetString(GL_RENDERER);
}
