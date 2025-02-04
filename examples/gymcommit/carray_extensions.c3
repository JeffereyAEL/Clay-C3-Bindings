module clay::carray(<ElementType>);

import std::io;

macro Array @createArray(#capacity)
{
    return carray::Array(<ElementType>)
    {
        .capacity = #capacity,
        .length = 0,
        .data = malloc(ElementType.sizeof * (#capacity))
    };
}

fn void Array.extendCapacity(Array *array, uint capacity)
{
    array.capacity += capacity;
    ElementType *new_data = (ElementType *)malloc(ElementType.sizeof * (array.capacity));

    for (int i = 0; i < array.length; ++i)
    {
        new_data[i] = array.data[i];
    }

    free(array.data);
    array.data = new_data;
}

fn ElementType* Array.append(Array *array, ElementType element)
{
    if (array.data == null) {
        array.capacity = 10;
        array.data = malloc(ElementType.sizeof * (10));
    } else if (array.length == array.capacity) array.extendCapacity(array.capacity);
    
    array.data[array.length] = element;
    return &(array.data[array.length++]);
}

fn ElementType* Array.getReferenceAt(Array *array, uint index) @operator(&[])
{
    // if (array.data == null && index >= array.length) $error("Accessing out of bounds");
    return &array.data[index];
}

fn ElementType Array.getAt(Array *array, uint index) @operator([])
{
    // if (array.data == null && index >= array.length) $error("Accessing out of bounds");
    return array.data[index];
}

fn uint Array.len(Array *array) @operator(len)
{
    return array.length;
}