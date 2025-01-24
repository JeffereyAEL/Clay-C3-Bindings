module carray(<ElementType>);

struct Array {
    CInt capacity;
    CInt length;
    ElementType *data;
}

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
    if (array.length == array.capacity) array.extendCapacity(array.capacity);
    array.data[array.length] = element;
    return &(array.data[array.length++]);
}

fn ElementType* Array.getReferenceAt(Array *array, uint index) @operator(&[])
{
    return &array.data[index];
}