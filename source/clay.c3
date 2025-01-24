module clay;

import std::core::cinterop;
import carray;

def UIntArray = carray::Array(<uint>) @private;

struct ClayString
{
    CInt length;
    char *chars;
}

def ClayStringArray = carray::Array(<ClayString>);

struct Arena
{
    CULongLong nextAllocation;
    CULongLong capacity;
    char *memory;
}

struct Dimensions
{
    float width, height;
}

struct ClayVector2
{
    float x, y;
}

struct ClayColor
{
    float r, g, b, a;
}

struct BoundingBox
{
    float x, y, width, height;
}

struct ElementId
{
    CUInt id;
    CUInt offset;
    CUInt baseId;
    ClayString stringId;
}

struct CornerRadius
{
    float topLeft;
    float topRight;
    float bottomLeft;
    float bottomRight;
}

fn CornerRadius cornerRadius(float uniform) @inline
{
    return {uniform, uniform, uniform, uniform};
}

distinct ElementConfigType = char;
const ElementConfigType ELEMENT_CONFIG_TYPE_NONE                = 0;
const ElementConfigType ELEMENT_CONFIG_TYPE_RECTANGLE           = 1;
const ElementConfigType ELEMENT_CONFIG_TYPE_BORDER_CONTAINER    = 2;
const ElementConfigType ELEMENT_CONFIG_TYPE_FLOATING_CONTAINER  = 4;
const ElementConfigType ELEMENT_CONFIG_TYPE_SCROLL_CONTAINER    = 8;
const ElementConfigType ELEMENT_CONFIG_TYPE_IMAGE               = 16;
const ElementConfigType ELEMENT_CONFIG_TYPE_TEXT                = 32;
const ElementConfigType ELEMENT_CONFIG_TYPE_CUSTOM              = 64;

// Element Configs ---------------------------
// Layout
enum LayoutDirection : char 
{
    LEFT_TO_RIGHT,
    TOP_TO_BOTTOM,
}

enum AlignX : char 
{
    LEFT,
    RIGHT,
    CENTER,
}

enum AlignY : char 
{
    TOP,
    BOTTOM,
    CENTER,
}

enum SizingType : char 
{
    FIT,
    GROW,
    PERCENT,
    FIXED,
}

struct ChildAlignment
{
    AlignX x;
    AlignY y;
}

struct SizingMinMax
{
    float min;
    float max;
}

struct SizingAxis
{
    union size
    {
        SizingMinMax minMax;
        float percent;
    }
    SizingType type;
}

fn SizingAxis sizingFit() @inline
{
    return { .size.minMax = {0, 0}, .type = SizingType.FIT };
}

fn SizingAxis sizingGrow() @inline
{
    return { .size.minMax = {0, 0}, .type = SizingType.GROW }; 
}

fn SizingAxis sizingFixed(float pixels) @inline
{
    return { .size.minMax = {pixels, pixels}, .type = SizingType.FIXED };
}

fn SizingAxis sizingPercent(float percent) @inline
{
    return { .size.percent = percent, .type = SizingType.PERCENT };
}

struct Sizing
{
    SizingAxis width;
    SizingAxis height;
}

struct Padding
{
    CUShort left;
    CUShort right;
    CUShort top;
    CUShort bottom;
}

fn Padding paddingUni(CUShort uniform) @inline
{
    return {uniform, uniform, uniform, uniform};
}

fn Padding padding(CUShort horizontal, CUShort vertical) @inline
{
    return {horizontal, horizontal, vertical, vertical};
}

struct LayoutConfig
{
    Sizing sizing;
    Padding padding;
    CUShort childGap;
    ChildAlignment childAlignment;
    LayoutDirection layoutDirection;
}

struct RectangleElementConfig
{
    ClayColor color;
    CornerRadius cornerRadius;
    // #ifdef CLAY_EXTEND_CONFIG_RECTANGLE
    // CLAY_EXTEND_CONFIG_RECTANGLE
    // #endif
}

enum WrapMode
{
    WORDS,
    NEWLINES,
    NONE,
}

struct TextElementConfig
{
    ClayColor textColor;
    CUShort fontId;
    CUShort fontSize;
    CUShort letterSpacing;
    CUShort lineHeight;
    WrapMode wrapMode;
    // #ifdef CLAY_EXTEND_CONFIG_TEXT
    // CLAY_EXTEND_CONFIG_TEXT
    // #endif
}

struct ImageElementConfig
{
    void *imageData;
    Dimensions sourceDimensions;
    // #ifdef CLAY_EXTEND_CONFIG_IMAGE
    // CLAY_EXTEND_CONFIG_IMAGE
    // #endif
}

enum AttachPoint : char
{
    LEFT_TOP,
    LEFT_CENTER,
    LEFT_BOTTOM,
    CENTER_TOP,
    CENTER_CENTER,
    CENTER_BOTTOM,
    RIGHT_TOP,
    RIGHT_CENTER,
    RIGHT_BOTTOM,
}

struct FloatingAttachPoints
{
    AttachPoint element;
    AttachPoint parent;
}

enum PointerCaptureMode
{
    CAPTURE,
    PARENT, 
    // MODE_PASSTHROUGH,
}

struct FloatingElementConfig
{
    ClayVector2 offset;
    Dimensions expand;
    CUShort zIndex;
    CUInt parentId;
    FloatingAttachPoints attachment;
    PointerCaptureMode pointerCaptureMode;
}


struct CustomElementConfig
{        
    // #ifndef CLAY_EXTEND_CONFIG_CUSTOM
    void *customData;
    // #else
    // CLAY_EXTEND_CONFIG_CUSTOM 
    // #endif
}

struct ScrollElementConfig
{
    bool horizontal;
    bool vertical;
}

// Border
struct Border
{
    CUInt width;
    ClayColor color;
}

struct BorderElementConfig
{
    Border left;
    Border right;
    Border top;
    Border bottom;
    Border betweenChildren;
    CornerRadius cornerRadius;
    // #ifdef CLAY_EXTEND_CONFIG_BORDER
    // CLAY_EXTEND_CONFIG_BORDER
    // #endif
}

union ElementConfigUnion
{
    RectangleElementConfig *rectangleElementConfig;
    TextElementConfig *textElementConfig;
    ImageElementConfig *imageElementConfig;
    FloatingElementConfig *floatingElementConfig;
    CustomElementConfig *customElementConfig;
    ScrollElementConfig *scrollElementConfig;
    BorderElementConfig *borderElementConfig;
}

struct ElementConfig
{
    ElementConfigType type;
    ElementConfigUnion config;
}

// Miscellaneous Structs & Enums ---------------------------------
struct ScrollContainerData
{
    // Note: This is a pointer to the real internal scroll position, mutating it may cause a change in final layout.
    // Intended for use with external functionality that modifies scroll position, such as scroll bars or auto scrolling.
    ClayVector2 *scrollPosition;
    Dimensions scrollContainerDimensions;
    Dimensions contentDimensions;
    ScrollElementConfig config;
    // Indicates whether an actual scroll container matched the provided ID or if the default struct was returned.
    bool found;
}

struct ElementData
{
    BoundingBox boundingBox;
    // Indicates whether an actual Element matched the provided ID or if the default struct was returned.
    bool found;
}

enum RenderCommandType : char
{
    NONE,
    RECTANGLE,
    BORDER,
    TEXT,
    IMAGE,
    SCISSOR_START,
    SCISSOR_END,
    CUSTOM,
}

struct RenderCommand
{
    BoundingBox boundingBox;
    ElementConfigUnion config;
    ClayString text;
    CUInt id;
    RenderCommandType commandType;
}

def RenderCommandArray = carray::Array(<RenderCommand>);

enum PointerState
{
    PRESSED_THIS_FRAME,
    PRESSED,
    RELEASED_THIS_FRAME,
    RELEASED,
}

struct PointerData
{
    ClayVector2 position;
    PointerState state;
}

enum ErrorType
{
    TEXT_MEASUREMENT_FUNCTION_NOT_PROVIDED,
    ARENA_CAPACITY_EXCEEDED,
    ELEMENTS_CAPACITY_EXCEEDED,
    TEXT_MEASUREMENT_CAPACITY_EXCEEDED,
    DUPLICATE_ID,
    FLOATING_CONTAINER_PARENT_NOT_FOUND,
    INTERNAL_ERROR,
}

struct ErrorData
{
    ErrorType errorType;
    ClayString errorText;
    CULongLong userData;
}

def ErrorHandleFunc = fn void(ErrorData errorText);

struct ErrorHandler
{
    ErrorHandleFunc errorHandler;
    CULongLong userData;
}

struct BooleanWarnings
{
    bool maxElementsExceeded;
    bool maxRenderCommandsExceeded;
    bool maxTextMeasureCacheExceeded;
}

struct Warning
{
    ClayString baseMessage;
    ClayString dynamicMessage;
}

def WarningArray = carray::Array(<Warning>);

struct LayoutElementChildren
{ 
    CInt *elements;
    CUShort length;
}

struct LayoutElement
{
    union childrenOrTextContent {
        LayoutElementChildren children;
        TextElementData *textElementData;
    }
    Dimensions dimensions;
    Dimensions minDimensions;
    LayoutConfig *layoutConfig;
    ElementConfigArraySlice elementConfigs;
    CUInt configsEnabled;
    CUInt id;
}

struct WrappedTextLine
{
    Dimensions dimensions;
    ClayString line;
}

struct WrappedTextLineArraySlice
{
	CInt length;
	WrappedTextLine *internalArray;
}

struct TextElementData
{
    ClayString text;
    Dimensions preferredDimensions;
    CInt elementIndex;
    WrappedTextLineArraySlice wrappedLines;
}

struct ElementConfigArraySlice
{
	CInt length;
	ElementConfig *internalArray;
}


def DebugElementData = bool[<2>];

struct LayoutElementHashMapItem
{ 
    BoundingBox boundingBox;
    ElementId elementId;
    LayoutElement* layoutElement;
    OnHoverEvent onHoverFunction;
    CLongLong hoverFunctionUserData;
    CInt nextIndex;
    CULongLong generation;
    DebugElementData *debugData;
}
 
struct LayoutElementTreeRoot @private
{
    CInt layoutElementIndex;
    CUInt parentId; // This can be zero in the case of the root layout tree
    CUInt clipElementId; // This can be zero if there is no clip element
    CInt zIndex;
    ClayVector2 pointerOffset; // Only used when scroll containers are managed externally
}

struct LayoutElementTreeNode @private
{
    LayoutElement *layoutElement;
    ClayVector2 position;
    ClayVector2 nextChildOffset;
}

struct MeasuredWord @private
{
    CInt startOffset;
    CInt length;
    float width;
    CInt next;
}

struct MeasureTextCacheItem @private
{
    Dimensions unwrappedDimensions;
    CInt measuredWordsStartIndex;
    bool containsNewlines;
    // Hash map data
    CUInt id;
    CInt nextIndex;
    CUInt generation;
}

def LayoutElementArray = carray::Array(<LayoutElement>);
def CIntArray = carray::Array(<CInt>);
def TextElementDataArray = carray::Array(<TextElementData>);
def RectangleElementConfigArray = carray::Array(<RectangleElementConfig>);
def TextElementConfigArray = carray::Array(<TextElementConfig>);
def ImageElementConfigArray = carray::Array(<ImageElementConfig>);
def FloatingElementConfigArray = carray::Array(<FloatingElementConfig>);
def ScrollElementConfigArray = carray::Array(<ScrollElementConfig>);
def CustomElementConfigArray = carray::Array(<CustomElementConfig>);
def BorderElementConfigArray = carray::Array(<BorderElementConfig>);
def LayoutElementPointerArray = carray::Array(<LayoutElement*>);
def LayoutConfigArray = carray::Array(<LayoutConfig>);
def ElementConfigArray = carray::Array(<ElementConfig>);
def WrappedTextLineArray = carray::Array(<WrappedTextLine>);
def LayoutElementTreeNodeArray = carray::Array(<LayoutElementTreeNode>);
def LayoutElementTreeRootArray = carray::Array(<LayoutElementTreeRoot>);
def LayoutElementHashMapItemArray = carray::Array(<LayoutElementHashMapItem>);
def MeasureTextCacheItemArray = carray::Array(<MeasureTextCacheItem>);
def MeasuredWordArray = carray::Array(<MeasuredWord>);
def ElementIdArray = carray::Array(<ElementId>);
def ScrollContainerDataInternalArray = carray::Array(<ScrollContainerData>);
def BoolArray = carray::Array(<bool>);
def CharArray = carray::Array(<char>);
def DebugElementDataArray = carray::Array(<DebugElementData>);

struct Context @extern ("Clay_Context") 
{
    CInt maxElementCount;
    CInt maxMeasureTextCacheWordCount;
    bool warningsEnabled;
    ErrorHandler errorHandler;
    BooleanWarnings booleanWarnings;
    WarningArray warnings;

    PointerData pointerInfo;
    Dimensions layoutDimensions;
    ElementId dynamicElementIndexBaseHash;
    CUInt dynamicElementIndex;
    bool debugModeEnabled;
    bool disableCulling;
    bool externalScrollHandlingEnabled;
    CUInt debugSelectedElementId;
    CUInt generation;
    CULongLong arenaResetOffset;
    Arena internalArena;

    // Layout Elements / Render Commands
    LayoutElementArray layoutElements;
    RenderCommandArray renderCommands;
    CIntArray openLayoutElementStack;
    CIntArray layoutElementChildren;
    CIntArray layoutElementChildrenBuffer;
    TextElementDataArray textElementData;
    LayoutElementPointerArray imageElementPointers;
    CIntArray reusableElementIndexBuffer;
    CIntArray layoutElementClipElementIds;

    // Configs
    LayoutConfigArray layoutConfigs;
    ElementConfigArray elementConfigBuffer;
    ElementConfigArray elementConfigs;
    RectangleElementConfigArray rectangleElementConfigs;
    TextElementConfigArray textElementConfigs;
    ImageElementConfigArray imageElementConfigs;
    FloatingElementConfigArray floatingElementConfigs;
    ScrollElementConfigArray scrollElementConfigs;
    CustomElementConfigArray customElementConfigs;
    BorderElementConfigArray borderElementConfigs;
    
    // Misc Data Structures
    ClayStringArray layoutElementIdStrings;
    WrappedTextLineArray wrappedTextLines;
    LayoutElementTreeNodeArray layoutElementTreeNodeArray1;
    LayoutElementTreeRootArray layoutElementTreeRoots;
    LayoutElementHashMapItemArray layoutElementsHashMapInternal;
    CIntArray layoutElementsHashMap;
    MeasureTextCacheItemArray measureTextHashMapInternal;
    CIntArray measureTextHashMapInternalFreeList;
    CIntArray measureTextHashMap;
    MeasuredWordArray measuredWords;
    CIntArray measuredWordsFreeList;
    CIntArray openClipElementStack;
    ElementIdArray pointerOverIds;
    ScrollContainerDataInternalArray scrollContainerDatas;
    BoolArray treeNodeVisited;
    CharArray dynamicStringData;
    DebugElementDataArray debugElementData;
}

def OnHoverEvent = fn void(ElementId elementId, PointerData pointerData, CLongLong userData);
def MeasureTextFunc = fn Dimensions(ClayString *text, TextElementConfig *config);
def QueryScrollOffsetFunc = fn ClayVector2(CUInt elementId);

fn ElementId getElementId(String idString) @inline { return __getElementId({idString.len, idString}); }

// Function Forward Declarations ---------------------------------
// Public API functions ---
extern fn CUInt minMemorySize() @extern("Clay_MinMemorySize");
extern fn Arena createArena(CUInt capacity, void* offset) @extern("Clay_CreateArenaWithCapacityAndMemory");
extern fn void setPointerState(ClayVector2 position, bool pointerDown) @extern("Clay_SetPointerState");
extern fn Context* initialize(Arena arena, Dimensions layoutDimensions, ErrorHandler errorHandler) @extern("Clay_Initialize");
extern fn Context* getCurrentContext() @extern("Clay_GetCurrentContext");
extern fn void setCurrentContext(Context* context) @extern("Clay_SetCurrentContext");
extern fn void updateScrollContainer(bool enableDragScrolling, ClayVector2 scrollDelta, float deltaTime) @extern("Clay_UpdateScrollContainers");
extern fn void setLayoutDimensions (Dimensions dimensions) @extern("Clay_SetLayoutDimensions");
extern fn ElementId getElementIdWithIndex(ClayString idString, CUInt index) @extern("Clay_GetElementIdWithIndex");
extern fn ElementData getElementData(ElementId id) @extern("Clay_GetElementData");
extern fn bool hovered() @extern("Clay_Hovered");
extern fn void onHovered(OnHoverEvent onHover, CLongLong userData) @extern("Clay_OnHover");
extern fn bool pointerOver(ElementId elementId) @extern("Clay_PointerOver");
extern fn ScrollContainerData getScrollContainerData(ElementId id) @extern("Clay_GetScrollContainerData");
extern fn void setMeasureTextFunction(MeasureTextFunc measureText) @extern("Clay_SetMeasureTextFunction");
extern fn void setQueryScrollOffsetFunction(QueryScrollOffsetFunc queryScrollOffset) @extern("Clay_SetQueryScrollOffsetFunction");
extern fn RenderCommand * RenderCommandArray.get(RenderCommandArray* array, CInt index) @extern("Clay_RenderCommandArray_Get");
extern fn void setDebugModeEnabled(bool enabled) @extern("Clay_SetDebugModeEnabled");
extern fn bool isDebugModeEnabled() @extern("Clay_IsDebugModeEnabled");
extern fn void setCullingEnabled(bool enabled) @extern("Clay_SetCullingEnabled");
extern fn CInt getMaxMeasuredTextCachedWordCount() @extern("Clay_GetMaxElementCount");
extern fn void setMaxElementCount(CInt maxElementCount) @extern("Clay_SetMaxElementCount");
extern fn CInt getMaxElementCount() @extern("Clay_GetMaxMeasureTextCacheWordCount");
extern fn void setMaxMeasureTextCacheWordCount(CInt maxMeasureTextCacheWordCount) @extern("Clay_SetMaxMeasureTextCacheWordCount");
extern fn void resetMeasureTextCache() @extern("Clay_ResetMeasureTextCache");

// External API functions that now have wrappers to incporate C3's builtin 'String' type
extern fn ElementId __getElementId(ClayString idString) @extern("Clay_GetElementId") @private;

// External API functions that now have wrappers for ClayIterator behaviour
extern fn void __beginLayout() @extern("Clay_BeginLayout") @private;
extern fn RenderCommandArray __endLayout() @extern("Clay_EndLayout") @private;

// Internal API functions required by macros
extern fn void __openElement() @extern ("Clay__OpenElement") @private;
extern fn void __closeElement() @extern("Clay__CloseElement") @private;
extern fn void __openTextElement(ClayString text, TextElementConfig *textConfig) @extern("Clay__OpenTextElement") @private;
extern fn void __elementPostConfiguration() @extern("Clay__ElementPostConfiguration") @private;
extern fn LayoutConfig * storeLayoutConfig(LayoutConfig config) @extern("Clay__StoreLayoutConfig") @private;
extern fn void attachId(ElementId id) @extern("Clay__AttachId") @private;
extern fn void attachLayoutConfig(LayoutConfig *config) @extern("Clay__AttachLayoutConfig") @private;
extern fn void attachElementConfig(ElementConfigUnion config, ElementConfigType type) @extern("Clay__AttachElementConfig") @private;
extern fn RectangleElementConfig * storeRectangleElementConfig(RectangleElementConfig config) @extern("Clay__StoreRectangleElementConfig") @private;
extern fn TextElementConfig * storeTextElementConfig(TextElementConfig config) @extern("Clay__StoreTextElementConfig") @private;
extern fn ImageElementConfig * storeImageElementConfig(ImageElementConfig config) @extern("Clay__StoreImageElementConfig") @private;
extern fn FloatingElementConfig * storeFloatingElementConfig(FloatingElementConfig config) @extern("Clay__StoreFloatingElementConfig") @private;
extern fn CustomElementConfig * storeCustomElementConfig(CustomElementConfig config) @extern("Clay__StoreCustomElementConfig") @private;
extern fn ScrollElementConfig * storeScrollElementConfig(ScrollElementConfig config) @extern("Clay__StoreScrollElementConfig") @private;
extern fn BorderElementConfig * storeBorderElementConfig(BorderElementConfig config) @extern("Clay__StoreBorderElementConfig") @private;
extern fn ElementId hashString(ClayString key, CUInt offset, CUInt seed) @extern("Clay__HashString") @private;
extern fn CUInt getParentElementId() @extern("Clay__GetParentElementId") @private;