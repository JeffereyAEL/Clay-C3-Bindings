module clay;

import std::io;

extern fn LayoutElement* getOpenLayoutElement()          @extern("Clay__GetOpenLayoutElement") @private;

fault ClayExtensionFault
{
    GET_OPEN_ELEMENT_ID_ON_ANONYMOUS_ELEMENT
}

fn ElementId getOpenElementId() 
{
    uint element_id_id = getOpenLayoutElement().id;
    if (element_id_id == 0)
    {
        // io::printfn();
        io::printfn("Error: getOpenElementId() called on an anonymous element. Call clay::id() at the start of element configuration");
    }
    return { .id = element_id_id };
}

extern fn PointerData getPointerData()                  @extern("Clay__GetPointerData");

extern fn LayoutElementArray* getLayoutElementArrayFromContext() @extern("Clay__GetLayoutElementArrayFromContext");

macro float vector2DistanceSqrd(ClayVector2 a, ClayVector2 b)
{
    return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y);
}