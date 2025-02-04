module gymcommit::gc::widgets;

import clay;
import std::io;

macro ChildAlignment alignmentButton() { return { AlignX.CENTER, AlignY.CENTER }; }

fn void verticalScrollBar(String scrollLabel, uint parentId, int width)
{
}

macro void floatingButton(String label, OnHoverEvent event, ClayVector2 offset, FloatingAttachPoints attachment)
{
    @clay(
        clay::id(label.tconcat("Button")),
        clay::floating({
            .attachment = attachment,
            .offset = offset,
        }),
        clay::rectangle({
            .color = clay::hovered() ? gc::ORANGE_FIRE : gc::PURPLE,
            .cornerRadius = clay::cornerRadiusUni(8),
        }),
        clay::layout({
            .padding = clay::padding(16, 8),
        }),
    ) {
        clay::onHover(event, 0);
        clay::text(
            label,
            clay::textConfig({
                .fontId = gc::FONT_ID_BODY_16,
                .textColor = clay::hovered() ? gc::BLACK : gc::BEIGE,
                .fontSize = 24,
        }));
    };
}

struct PannerElemenetDirection
{
    bool enabled;
    // TODO: add bounds information and method triggers, etc.
}

struct PannerElementConfig
{
    PannerElemenetDirection left;
    PannerElemenetDirection right;
    PannerElemenetDirection up;
    PannerElemenetDirection down;
}

enum PannerDataState
{
    NONE,
    INTERMEDIATE,
    PANNING,
}

struct PannerElementData
{
    ClayVector2 pressedStartPosition;
    PannerElementConfig config;
    ElementId elementId;
    // whether this struct indicates an element currently being panned
    PannerDataState state;
}
PannerElementData currentPanningElement;

macro void panner(PannerElementConfig config)
{
    PointerData pointer_data = clay::getPointerData();
    ElementId element_id = clay::getOpenElementId();

    if (pointer_data.state == PointerState.PRESSED_THIS_FRAME
        && clay::pointerOver(element_id))
    {
        currentPanningElement = {
            .pressedStartPosition = pointer_data.position,
            .config = config,
            .elementId = element_id,
            .state = INTERMEDIATE,
        };
    }
}

fn void appendChildIds(LayoutElementArray* array, int* dependantRenderCommands, int index, bool isRoot = true)
{
    LayoutElement layout_element = array.getAt(index);
    if (layout_element.configsEnabled & (uint)clay::ELEMENT_CONFIG_TYPE_FLOATING_CONTAINER > 0) return;

    bool contains_text = layout_element.configsEnabled & (uint)clay::ELEMENT_CONFIG_TYPE_TEXT > 0;

    bool has_render_command = 
        (layout_element.configsEnabled & (uint)clay::ELEMENT_CONFIG_TYPE_RECTANGLE > 0)
        || (layout_element.configsEnabled & (uint)clay::ELEMENT_CONFIG_TYPE_IMAGE > 0)
        || (layout_element.configsEnabled & (uint)clay::ELEMENT_CONFIG_TYPE_BORDER_CONTAINER > 0)
        || (layout_element.configsEnabled & (uint)clay::ELEMENT_CONFIG_TYPE_CUSTOM > 0)
        || contains_text;
    if (has_render_command && !isRoot)
    {
        *dependantRenderCommands += 1;
        // childIds.append(!is_excluded);
        // io::printfn("idx:%d offset:%s", index, !is_excluded);
    }
     
    if (contains_text) return;
    for (int i = 0; i < layout_element.childrenOrTextContent.children.length; ++i)
    {
        int new_index = layout_element.childrenOrTextContent.children.elements[i];
        appendChildIds(array, dependantRenderCommands, new_index, false);
    }
}

fn void updatePannerWidget(RenderCommandArray renderCommands)
{
    PointerData pointer_data = clay::getPointerData();
    if (pointer_data.state == PointerState.RELEASED_THIS_FRAME
    || pointer_data.state == PointerState.RELEASED
    || currentPanningElement.state == PannerDataState.NONE) {
        currentPanningElement.state = PannerDataState.NONE;
        return;
    }

    // if (currentPanningElement.state == PannerDataState.INTERMEDIATE
    //     && clay::vector2DistanceSqrd(pointer_data.position, currentPanningElement.pressedStartPosition) > 25)
    // {
    //     io::printfn("Setting PANNING");
    //     currentPanningElement.state = PannerDataState.PANNING;
    // }
    // else
    // {
    //     io::printfn("Setting INTERMEDIATE");
    //     currentPanningElement.state = PannerDataState.INTERMEDIATE;
    // }
    
    if (currentPanningElement.state != PannerDataState.PANNING) return;
    // io::printfn("Passed state check");
    for (int i = 0; i < renderCommands.length; ++i)
    {
        RenderCommand* render_command = renderCommands.get(i);
        if (render_command.id == currentPanningElement.elementId.id)
        {  
            ClayBoundingBox bbox = render_command.boundingBox;
            if (currentPanningElement.config.left.enabled)
            {
                float offset = $$max(currentPanningElement.pressedStartPosition.x - pointer_data.position.x, (float)0.0);
                render_command.boundingBox.x -= offset;

                LayoutElementArray* layout_elements = clay::getLayoutElementArrayFromContext();
                int numDependantRenderCommands = 0;
                foreach(int index, LayoutElement layout_element : layout_elements)
                {
                    if (layout_element.id != render_command.id) continue;
                    // io::printfn("Start Index: %d", index);
                    appendChildIds(layout_elements, &numDependantRenderCommands, index);
                    break;
                }
                // io::printfn("Num dependant Render Commands: %d", numDependantRenderCommands);
                // io::printfn("RenderArrayLen: %d", renderCommands.length);
                for (int o = i+1; o < $$min(i+numDependantRenderCommands+2, renderCommands.length); ++o)
                {
                    // io::printfn("dependant RenderCommand Index: %d", o-i-1);
                    render_command = renderCommands.get(o);
                    render_command.boundingBox.x -= offset;
                }
            }
            // TODO: add checks for the other directions, and add execution of methods based on offset
            break;
        }
    }
}