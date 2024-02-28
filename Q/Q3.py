def get_value_by_nested_key(obj, key):
    # Split the input key string into a list of nested keys
    keys = key.split('/')

    # Initialize the value to the input object
    value = obj

    try:
        # Traverse the dictionary using the nested keys
        for k in keys:
            value = value[k]
            print(value)
        return value
    except (KeyError):
        return None  # Key not found or object is not subscriptable


# Example usage:
object1 = {"a": {"b": {"c": "d"}}}
key1 = 'a/b/c'
print(get_value_by_nested_key(object1, key1))  # Output: d

object2 = {"x": {"y": {"z": "a"}}}
key2 = 'x/y/z'
print(get_value_by_nested_key(object2, key2))  # Output: a