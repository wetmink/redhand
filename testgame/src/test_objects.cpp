#include "test_objects.hpp"

house::house(
    std::shared_ptr<redhand::texture2D> texture,
    std::shared_ptr<redhand::shader> shade
){

    auto settings = redhand::DEFAULT_GAME_OBJECT_PROPERTIES;

    settings.attached_shader = shade;
    settings.attached_texture = texture;
    settings.name = "house";

    settings.points_coordinates = {
        {1.0f, 0.55f},  // top right
        {1.0f, 0.0f},  // bottom right
        {0.0f, 0.0f},  // bottom left
        {0.0f, 0.55f},  // top left 
        {0.5f, 1.0f}  // top middle
    };

    settings.triangle_indices = {
        {0, 1, 3},   // first triangle
        {1, 2, 3},    // second triangle
        {0, 3, 4}     //third triangle
    };

    settings.point_colors = {
        {1.0f, 1.0f, 1.0f},
        {1.0f, 1.0f, 1.0f},
        {1.0f, 1.0f, 1.0f},
        {1.0f, 1.0f, 1.0f},
        {1.0f, 1.0f, 1.0f} 
    };

    settings.postition = {-0.1f,-0.1f};
    settings.scale = {0.5f,0.5f};

    object_properties = settings;
    updateBuffers();

}

void house::onLoop(redhand::game_loop_event evt){
    //move the house

    if( redhand::input_system::static_isKeyPressed(redhand::KEY_RIGHT) ){
        this->move({0.02f,0.0f});
    }else if(redhand::input_system::static_isKeyPressed(redhand::KEY_LEFT)){
        this->move({-0.02f,0.0f});
    }

    if(redhand::input_system::static_isKeyPressed(redhand::KEY_UP)){
        this->move({0.0f,0.02f});
    }else if(redhand::input_system::static_isKeyPressed(redhand::KEY_DOWN)){
        this->move({0.0f,-0.02f});
    } 

    //check for button presses and change rotation

    if(redhand::input_system::static_isKeyPressed(redhand::KEY_E)){
        this->rotate(-2.5f);
    }else if(redhand::input_system::static_isKeyPressed(redhand::KEY_Q)){
        this->rotate(2.5f);
    }

    return;

}