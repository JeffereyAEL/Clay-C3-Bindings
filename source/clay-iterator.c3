module clay;

const bool DEBUG_PRINT_HIERARCHY = true; // TOGGLES HIERARCHY PRINTING

import std::io @norecurse;
import carray;

distinct ClayIteratorFlags @private = ulong;
const ClayIteratorFlags ITER_FLAG_INITIAL_FLAGS @private        = 0; 
const ClayIteratorFlags ITER_FLAG_POST_CONFIGURED @private      = 1;
// TODO: these might not be necessary, unless I wanna through $assert()s all the time
// const ClayIteratorFlags CONTAINS_TEXT @private               = 2;
// const ClayIteratorFlags HAS_CHILDREN @private                = 4;
// const ClayIteratorFlags HAS_LAYOUT @private                  = 8;
// const ClayIteratorFlags HAS_RECTANGLE @private               = 16;
// const ClayIteratorFlags HAS_TEXT @private                    = 32;
// const ClayIteratorFlags HAS_IMAGE @private                   = 64;
// const ClayIteratorFlags HAS_FLOATING @private                = 128;

struct ClayIterator
{
    uint idx;
    ClayIteratorFlags flags;
    int parentIdx;
}

def ClayIteratorArray = carray::Array(<ClayIterator>) @private;
ClayIteratorArray clayIteratorBuffer @private = {0, 0, null};
ClayIterator* clayIteratorHead @private = null;


ulong debugFrameNum @private @if(DEBUG_PRINT_HIERARCHY) = 0;
long debugHierarchyDepth @private @if(DEBUG_PRINT_HIERARCHY) = 0;
bool debugFrameNumIsDirty @private @if(DEBUG_PRINT_HIERARCHY) = false;
fn void setDebugFrameDirty() @inline @if(DEBUG_PRINT_HIERARCHY) { debugFrameNumIsDirty = false; }

fn ClayIterator* createIterator(ClayIterator *parent) @private
{
    ClayIterator newIter = {
        clayIteratorBuffer.length,
        ITER_FLAG_INITIAL_FLAGS,
        parent == null ? -1 : parent.idx
    };
    return clayIteratorBuffer.append(newIter);
}

fn ClayIterator* ClayIterator.clay(ClayIterator *iter) // TODO: refactor this, it certainly doesn't need to be this messy
{ 
    if (iter == null)
    {
        clay::openElement();
        if (clayIteratorBuffer.data == null) clayIteratorBuffer = carray::@createArray(<ClayIterator>)(20);
        clayIteratorHead = createIterator(null);
        return clayIteratorHead;
    }
    else
    {
        ClayIterator *newIter;
        if (iter.flags & ITER_FLAG_POST_CONFIGURED) // creating a child
        {
            clay::openElement();
            newIter = createIterator(iter);
        }
        else    // creating a sibling
        {
            clay::elementPostConfiguration();
            clay::closeElement();
            clay::openElement();
            bool has_parent = iter.parentIdx >= 0;
            ClayIterator *parentIter = has_parent ? &clayIteratorBuffer[iter.parentIdx] : null;
            newIter = createIterator(parentIter);
        }
        clayIteratorHead = newIter;
        return newIter;
    } 
}
fn ClayIterator* clay() { return clayIteratorHead.clay(); }

fn ClayIterator* ClayIterator.close(ClayIterator *iter)
{
    if (!(iter.flags & ITER_FLAG_POST_CONFIGURED)) clay::elementPostConfiguration();
    clay::closeElement();
    iter = iter.parentIdx >= 0 ? &clayIteratorBuffer[iter.parentIdx] : null;
    clayIteratorHead = iter;
    return iter;
}
fn ClayIterator* close() { return clayIteratorHead.close(); }

fn ClayIterator* ClayIterator.layout(ClayIterator *iter, LayoutConfig layoutConfig)
{
$if DEBUG_PRINT_HIERARCHY:
    if (debugFrameNum == 0)
    { 
        for (int i  = 0; i < debugHierarchyDepth; ++i) std::io::printf("\t");
        std::io::printfn("LAYOUT CONFIG");
    }
$endif
    clay::attachLayoutConfig(clay::storeLayoutConfig( layoutConfig ));
    return iter;
}

fn ClayIterator* ClayIterator.rectangle(ClayIterator *iter, RectangleElementConfig rectangleConfig)
{
$if DEBUG_PRINT_HIERARCHY:
    if (debugFrameNum == 0)
    { 
        for (int i  = 0; i < debugHierarchyDepth; ++i) std::io::printf("\t");
        std::io::printfn("RECTANGLE CONFIG");
    }
$endif
    clay::attachElementConfig(
        { .rectangleElementConfig = clay::storeRectangleElementConfig( rectangleConfig ) }, 
        clay::ELEMENT_CONFIG_TYPE_RECTANGLE
    );
    return iter;
}
fn ClayIterator* rectangle(RectangleElementConfig rectangleConfig) { return clayIteratorHead.rectangle(rectangleConfig); }

fn ClayIterator* ClayIterator.text(ClayIterator *iter, String text, TextElementConfig textConfig)
{
    clay::openTextElement({(CInt)text.len, text}, clay::storeTextElementConfig(textConfig));
    return iter;
}
fn ClayIterator* text(String text, TextElementConfig textConfig) { return clayIteratorHead.text(text, textConfig); }

fn ClayIterator* ClayIterator.image(ClayIterator *iter, ImageElementConfig imageConfig)
{
$if DEBUG_PRINT_HIERARCHY:
    if (debugFrameNum == 0)
    { 
        for (int i  = 0; i < debugHierarchyDepth; ++i) std::io::printf("\t");
        std::io::printfn("IMAGE CONFIG");
    }
$endif
    clay::attachElementConfig(
        { .imageElementConfig = clay::storeImageElementConfig(imageConfig)},
        clay::ELEMENT_CONFIG_TYPE_IMAGE
    );
    return iter;
}
fn ClayIterator* image(ImageElementConfig config) { return clayIteratorHead.image(config); }

fn ClayIterator* ClayIterator.floating(ClayIterator *iter, FloatingElementConfig floatingConfig)
{
$if DEBUG_PRINT_HIERARCHY:
    if (debugFrameNum == 0)
    { 
        for (int i  = 0; i < debugHierarchyDepth; ++i) std::io::printf("\t");
        std::io::printfn("FLOATING CONFIG");
    }
$endif
    clay::attachElementConfig(
        { .floatingElementConfig = clay::storeFloatingElementConfig(floatingConfig)},
        clay::ELEMENT_CONFIG_TYPE_FLOATING_CONTAINER
    );
    return iter;
}
fn ClayIterator* floating(FloatingElementConfig config) { return clayIteratorHead.floating(config); }

fn ClayIterator* ClayIterator.customElement(ClayIterator *iter, CustomElementConfig customConfig)
{
$if DEBUG_PRINT_HIERARCHY:
    if (debugFrameNum == 0)
    { 
        for (int i  = 0; i < debugHierarchyDepth; ++i) std::io::printf("\t");
        std::io::printfn("CUSTOM CONFIG");
    }
$endif
    clay::attachElementConfig(
        { .customElementConfig = clay::storeCustomElementConfig(customConfig)},
        clay::ELEMENT_CONFIG_TYPE_CUSTOM
    );
    return iter;
}
fn ClayIterator* customElement(CustomElementConfig config) { return clayIteratorHead.customElement(config); }

fn ClayIterator* ClayIterator.scroll(ClayIterator *iter, ScrollElementConfig scrollConfig)
{
$if DEBUG_PRINT_HIERARCHY:
    if (debugFrameNum == 0)
    { 
        for (int i  = 0; i < debugHierarchyDepth; ++i) std::io::printf("\t");
        std::io::printfn("SCROLL CONFIG");
    }
$endif
    clay::attachElementConfig(
        { .scrollElementConfig = clay::storeScrollElementConfig(scrollConfig)},
        clay::ELEMENT_CONFIG_TYPE_SCROLL_CONTAINER
    );
    return iter;
}
fn ClayIterator* scroll(ScrollElementConfig config) { return clayIteratorHead.scroll(config); }

fn ClayIterator* ClayIterator.id(ClayIterator *iter, String label)
{
$if DEBUG_PRINT_HIERARCHY:
    if (debugFrameNum == 0)
    { 
        for (int i  = 0; i < debugHierarchyDepth; ++i) std::io::printf("\t");
        std::io::printfn("ID CONFIG: '%s'", label);
    }
$endif
    clay::attachId(hashString({(CInt)label.len, label}, 0, 0));
    return iter;
}
fn ClayIterator* id(String label) { return clayIteratorHead.id(label); }

fn ClayIterator* ClayIterator.children(ClayIterator *iter)
{
    clay::elementPostConfiguration();
    return iter;
}
fn ClayIterator* children() { return clayIteratorHead.children(); }


fn void beginLayout()
{
$if DEBUG_PRINT_HIERARCHY:
    if (debugFrameNum == 0) std::io::printfn("BEGIN LAYOUT");
$endif
    __beginLayout();
}

fn RenderCommandArray endLayout()
{
    if (!(clayIteratorHead.flags & ITER_FLAG_POST_CONFIGURED)) clay::elementPostConfiguration();
    while (clayIteratorHead.parentIdx >= 0)
    {
        clay::closeElement();
        clayIteratorHead = &clayIteratorBuffer[clayIteratorHead.parentIdx];
    }
    clay::closeElement();
    clayIteratorBuffer.length = 0;
    clayIteratorHead = null;

$if DEBUG_PRINT_HIERARCHY:
    if (debugFrameNum++ == 0) std::io::printfn("END LAYOUT");
    if (debugFrameNumIsDirty) debugFrameNum = 0;
$endif

    return __endLayout();
}

fn void openElement() @private
{
$if DEBUG_PRINT_HIERARCHY:
    if (debugFrameNum == 0) 
    {
        for (int i  = 0; i < debugHierarchyDepth; ++i) std::io::printf("\t");
        std::io::printfn("OPEN ELEMENT");
    }
    debugHierarchyDepth++;
$endif
    __openElement(); 
}

fn void closeElement() @private
{
$if DEBUG_PRINT_HIERARCHY:
    debugHierarchyDepth--;
    if (debugFrameNum == 0) 
    {
        for (int i  = 0; i < debugHierarchyDepth; ++i) std::io::printf("\t");
        std::io::printfn("CLOSE ELEMENT");
    }
$endif
    __closeElement(); 
}

fn void openTextElement(ClayString text, TextElementConfig *textConfig) @private
{
$if DEBUG_PRINT_HIERARCHY:
    if (debugFrameNum == 0) 
    {
        for (int i  = 0; i < debugHierarchyDepth; ++i) std::io::printf("\t");
        std::io::printfn("OPEN TEXT ELEMENT");
    }
$endif
    __openTextElement(text, textConfig);
}

fn void elementPostConfiguration() @private
{
$if DEBUG_PRINT_HIERARCHY:
    if (debugFrameNum == 0) 
    {
        for (int i  = 0; i < debugHierarchyDepth; ++i) std::io::printf("\t");
        std::io::printfn("POST-CONFIG ELEMENT");
    }
$endif
    clayIteratorHead.flags |= ITER_FLAG_POST_CONFIGURED;
    __elementPostConfiguration();
}
