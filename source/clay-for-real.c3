module clay;
import std::io;
import carray;

interface IConfig {
    fn void attach();
    fn void printType();
}

// TODO: parametarize this? so instead of calling macros you just reference the parameter
// would be a lot nicer to look at, and can still do all the same shinanigans I've been up to
macro @clay(...; @body())
{
    clay::openElement(); 

    // TODO: use compiler type checking to assert that passed structs are IConfigs
    $for (var $idx = 0; $idx < $vacount; ++$idx) 
        $vaconst[$idx].attach();
    $endfor

    clay::elementPostConfiguration();

    @body();
    
    clay::closeElement();
}

macro RectangleElementConfig @rectangle(ClayColor $color = {0, 0, 0, 0}, CornerRadius $cornerRadius = {0, 0, 0, 0})
{
    return RectangleElementConfig{$color, $cornerRadius};
}

macro LayoutConfig @layout(
    Sizing $sizing = { clay::@sizingFit(), clay::@sizingFit() },
    Padding $padding = {0, 0, 0, 0},
    CUShort $childGap = 0,
    ChildAlignment $childAlignment = {AlignX.LEFT, AlignY.TOP},
    LayoutDirection $layoutDirection = LayoutDirection.LEFT_TO_RIGHT
    )
{
    return LayoutConfig{$sizing, $padding, $childGap, $childAlignment, $layoutDirection};
}

macro String @id($label)
{
    return $label;
}


fn void RectangleElementConfig.attach(RectangleElementConfig *rectangleConfig)  @dynamic
{
    clay::attachElementConfig(
        { .rectangleElementConfig = clay::storeRectangleElementConfig(*rectangleConfig) }, 
        clay::ELEMENT_CONFIG_TYPE_RECTANGLE
    );
}

fn void RectangleElementConfig.printType(RectangleElementConfig *rectangleConfig)  @dynamic
{
    std::io::printfn("RectangleConfig");
}

fn void LayoutConfig.attach(LayoutConfig *layoutConfig)  @dynamic
{
    clay::attachLayoutConfig(clay::storeLayoutConfig(*layoutConfig));
}

fn void LayoutConfig.printType(LayoutConfig *layoutConfig)  @dynamic
{
    std::io::printfn("LayoutConfig");
}

fn void ImageElementConfig.attach(ImageElementConfig *imageConfig)  @dynamic
{
    clay::attachElementConfig(
        { .imageElementConfig = clay::storeImageElementConfig(*imageConfig)},
        clay::ELEMENT_CONFIG_TYPE_IMAGE
    );
}

fn void FloatingElementConfig.attach(FloatingElementConfig *floatingConfig)  @dynamic
{
    clay::attachElementConfig(
        { .floatingElementConfig = clay::storeFloatingElementConfig(*floatingConfig)},
        clay::ELEMENT_CONFIG_TYPE_FLOATING_CONTAINER
    );
}

fn void CustomElementConfig.attach(CustomElementConfig *customConfig)  @dynamic
{
    clay::attachElementConfig(
        { .customElementConfig = clay::storeCustomElementConfig(*customConfig)},
        clay::ELEMENT_CONFIG_TYPE_CUSTOM
    );
}

fn void ScrollElementConfig.attach(ScrollElementConfig *scrollConfig)  @dynamic
{
    clay::attachElementConfig(
        { .scrollElementConfig = clay::storeScrollElementConfig(*scrollConfig)},
        clay::ELEMENT_CONFIG_TYPE_SCROLL_CONTAINER
    );
}

fn void BorderElementConfig.attach(BorderElementConfig *borderConfig)  @dynamic
{
    clay::attachElementConfig(
        { .borderElementConfig = clay::storeBorderElementConfig(*borderConfig)},
        clay::ELEMENT_CONFIG_TYPE_SCROLL_CONTAINER
    );
}

fn void ClayString.attach(ClayString *label)  @dynamic
{
    clay::attachId(hashString(*label, 0, 0));
}

fn void String.attach(String *label)  @dynamic
{
    clay::attachId(hashString({(CInt)label.len, *label}, 0, 0));
}