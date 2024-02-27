// Fetch the effective role mappings
var roleMappings = Java.from(new java.util.ArrayList(user.getRoleMappings()));

// Initialize variables
var attValues = new java.util.ArrayList();
var ATTRIBUTE_NAME = 'policy';
var FLATTEN_IF_ONLY_ONE_VALUE = true;

// Iterate over effective roles and extract attributes
for (var r in roleMappings) {
    var attrs = roleMappings[r].attributes;
    if (attrs[ATTRIBUTE_NAME] != null) {
        var value = attrs[ATTRIBUTE_NAME];
        if (FLATTEN_IF_ONLY_ONE_VALUE) {
            var forEach = Array.prototype.forEach;
            forEach.call(value, function (v) {
                attValues.add(v);
            });
        } else {
            attValues.add(value);
        }
    }
}

// Return attribute values
attValues;