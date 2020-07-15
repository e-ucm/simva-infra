var roles = Java.from(new java.util.ArrayList(user.roleMappings));
var attValues = new java.util.ArrayList();
var ATTRIBUTE_NAME = 'policy';
var FLATTEN_IF_ONLY_ONE_VALUE = true;

for (var r in roles) {
    var attrs = roles[r].attributes;
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
attValues;