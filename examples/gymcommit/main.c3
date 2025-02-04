import clay;
import raylib5::rl;
import gymcommit;
import std::io @norecurse;

fn void errorHandler(ErrorData errorData)
{
    // if (errorData.errorType != ErrorType.INTERNAL_ERROR) 
    std::io::printfn("ERROR: \"%s\"\n", (ZString)errorData.errorText.chars);
}

bool isDebugModeEnabled = false;

fn void main()
{
    rl::setConfigFlags(
        rl::FLAG_VSYNC_HINT
        | rl::FLAG_WINDOW_RESIZABLE
        | rl::FLAG_WINDOW_HIGHDPI
        | rl::FLAG_MSAA_4X_HINT);
    rl::initWindow(800, 800, "Raylib-C3 Demo");

    uint min_memory_size = clay::minMemorySize();
    Arena clay_memory = clay::createArena(min_memory_size, malloc(min_memory_size));

    clay::setMeasureTextFunction(&clay::renderer::raylibMeasureText);
    clay::renderer::raylibFonts[gc::FONT_ID_BODY_16] = { 
        gc::FONT_ID_BODY_16, 
        rl::loadFontEx("resources/Lexend-Regular.ttf", 48, null, 400)
    };
    
    // TODO:find out why text rendering is broken as shit
    // TODO: you might have to write the renderer yourself
    rl::setTextureFilter(
        clay::renderer::raylibFonts[gc::FONT_ID_BODY_16].font.texture, 
        TextureFilter.BILINEAR
    );

    clay::initialize(clay_memory, { rl::getScreenWidth(), rl::getScreenHeight() }, { &errorHandler, 0 });

    
    gc::currentPage = &wp::page;

    while (!rl::windowShouldClose())
    {
        clay::setLayoutDimensions({rl::getScreenWidth(), rl::getScreenHeight()});
        Vector2 mouse_position = rl::getMousePosition();
        Vector2 scroll_delta = rl::getMouseWheelMoveV();
        clay::setPointerState({mouse_position.x, mouse_position.y}, rl::isMouseButtonDown(rl::MouseButton.LEFT));
        // io::printfn("setPos: {%d, %d}", mouse_position.x, mouse_position.y);
        // if (widgets::currentPanningElement.state != PannerDataState.PANNING) 
        // {
        clay::updateScrollContainer(false, {scroll_delta.x, scroll_delta.y}, rl::getFrameTime());
        // }

        if (rl::isKeyReleased(rl::KEY_D)) 
        {
            isDebugModeEnabled = !isDebugModeEnabled; 
            clay::setDebugModeEnabled(isDebugModeEnabled);
        }

        // LAYOUT
        clay::beginLayout(); 
        
        clay::@clay(
            clay::id("OuterContainerBuffer"),
            clay::rectangle({ .color = gc::GRAY_DARK}),
            clay::layout({ 
                .sizing = {
                    .width = clay::sizingGrow(), 
                    .height = clay::sizingGrow()
                },
                .layoutDirection = clay::LayoutDirection.TOP_TO_BOTTOM,
                .padding = { 8, 8, 8, 8 },
                .childGap = 5
            }),
        ) {
            gc::currentPage(); // a call away to rendering a page element

            foreach (Popup popup : gc::activePopups)
            {
                popup.layout();
            }
        };

        RenderCommandArray render_commands = clay::endLayout();
        // widgets::updatePannerWidget(render_commands);
        
        // DRAWING
        rl::beginDrawing();
        rl::clearBackground(rl::ORANGE);
        //... do drawing
        clay::renderer::raylibRender(render_commands);
        rl::endDrawing();
    }
    rl::closeWindow();
}

