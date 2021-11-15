

var Action = function() {};

Action.prototype = {
    
run: function(parameters) {
    
    parameters.completionFunction({"URL": document.URL, "title": document.title});
},
    
finilize: function(parameters) {
    
    var customJavaScript = parameters["customJavaScript"];
    eval(customJavaScript)
    
}
    
};

var ExtensionPreprocessingJS = new Action
