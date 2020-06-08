#include "redhand/engine.hpp"
#include "redhand/game_object.hpp"
#include "redhand/shader.hpp"
#include "redhand/texture.hpp"
#include "redhand/complex_world.hpp"

using namespace redhand;

redhand::engine::engine(){
    setConfig(DEFAULT_ENGINE_CONFIG);
}

redhand::engine::~engine(){
    glfwSetWindowShouldClose(window, true);

    //try clearing up
    activeWorld.reset();

    //close the window + clean up
    glfwTerminate();
}

void redhand::engine::setConfig(redhand::engine_config conf){
    configuration = conf;
    configuration.redhand_version = redhand::REDHAND_HEADER_VERSION;
}

redhand::engine_config redhand::engine::getConfig(){
    return configuration;
}

void redhand::engine::init(){
    //init glfw
    glfwInit(); 
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, configuration.OPENGL_VERSION_MAJOR);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, configuration.OPENGL_VERSION_MINOR);
    glfwWindowHint(GLFW_OPENGL_PROFILE, configuration.OPENGL_PROFILE);
    glfwWindowHint(GLFW_RESIZABLE, configuration.RESIZABLE);
    glfwWindowHint(GLFW_SAMPLES, configuration.SAMPLES);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, configuration.OPENGL_FORWARD_COMPAT); //needed for mac
  
    //create window
    window = glfwCreateWindow(configuration.window_width, configuration.window_height, configuration.title.c_str(), NULL, NULL);
    if (window == NULL){
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        errorCode = -1;
        return;
    }
    glfwMakeContextCurrent(window);

    //register callback function for viewport
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);  

    //make sure glad works
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)){
        std::cout << "Failed to initialize GLAD" << std::endl;
        errorCode = -2;
        return;
    }

    //init stb
    initSTB();

    //enable multisampling
    glEnable(GL_MULTISAMPLE);

    //create an empty world
    activeWorld = std::shared_ptr<complex_world> (new complex_world());

    if(activeWorld == nullptr){
        errorCode = -4;
        return;
    }

}

std::shared_ptr<redhand::complex_world> redhand::engine::getActiveWorld(){
    if(errorCode < 0){
        return nullptr;
    }

    return std::shared_ptr<redhand::complex_world>(activeWorld);
}

void redhand::engine::clearBuffers(){
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}

GLFWwindow* redhand::engine::getWindow(){
    return window;
}

int redhand::engine::getErrorCode(){
    return errorCode;
}

void redhand::engine::addGameLoopHandler(std::function < int ( redhand::game_loop_event<engine> ) > handle){
    addGameLoopHandler(handle,"func");
}

void redhand::engine::addGameLoopHandler(std::function < int ( redhand::game_loop_event<engine> ) > handle, std::string handler_key){
    game_loop_handlers.insert(std::make_pair<>(handler_key,handle));
}

int redhand::engine::removeGameLoopHandler(std::string handler_key){
    auto it = game_loop_handlers.find(handler_key);

    if(it == game_loop_handlers.end()){
        return -1;
    }

    game_loop_handlers.erase(it);
    return 0;
}

bool redhand::engine::isRunning(){
    runningReadMutex.lock_shared();

    if (running && glfwWindowShouldClose(this->window) == 0){
        runningReadMutex.unlock_shared();
        return true;
    }
    runningReadMutex.unlock_shared();
    
    return false;

}


void redhand::engine::stopGame(int error){
    std::scoped_lock<std::shared_mutex> lock(runningReadMutex);

    if(error != 0){
        errorCode = error;
    }

    running = false;
}


int redhand::engine::changeWorld(std::shared_ptr<complex_world> newWorld){
    //if not a nullptr change world
    if(newWorld == nullptr){
        return -5;
    }

    nextWorld = newWorld;

    return 0;
}

int redhand::engine::runGame(){
    running = true;

    //start the physics thread
    std::thread physicsThread([&](){
        while (isRunning()){

            std::this_thread::sleep_for(std::chrono::milliseconds(1));

            //Set the last time
            static auto last_time = std::chrono::system_clock::now();
            
            auto this_time = std::chrono::system_clock::now();

            auto diff = this_time-last_time;

            auto evt = game_loop_event<redhand::engine>(this, diff);

            //get the new error
            int localErrorCode = 0;

            activeWorld->tick(evt);

            for(auto x : game_loop_handlers){
                if(localErrorCode < 0){break;};
                localErrorCode = x.second(evt);
            }

            //if there was an error terminate the game
            if(localErrorCode < 0){
                stopGame(localErrorCode);
                break;
            }

            //if not a nullptr change world
            if(nextWorld != nullptr){
                activeWorld.reset();
                activeWorld = nextWorld;
                nextWorld = nullptr;
            }

        }
    });

    //while there is no error run the game loop
    while(isRunning()){

        //draw the game
        
        //Clear up
        clearBuffers();

        //clear the bg color
        glClearColor(0.2f,0.3f,0.3f,1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        //draw the active world
        getActiveWorld()->draw();

        //Update the window buffers
        glfwSwapBuffers(getWindow());
        glfwPollEvents(); 

        std::this_thread::sleep_for(std::chrono::milliseconds(4));
          
    }

    physicsThread.join();

    return errorCode;
}

void redhand::framebuffer_size_callback(GLFWwindow*, int width, int height){
    glViewport(0, 0, width, height);
}