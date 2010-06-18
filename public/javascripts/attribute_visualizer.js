// TODO: quick poc, come back.
function VisualizeAttribute(id) {
    $.getJSON(window.location + '.js', function(data) {
        var attributeGraph = Raphael(id);
        var graphData = [];
    
        $.each(data, function(index, commit) {
            attributeValue = parseInt(commit["commit_attribute"].value, 10);
            graphData.push(attributeValue);
        });
    
        attributeGraph.g.linechart(10, 10, 900, 220, [1, 5, 10, 15, 20, 25, 30, 35], [graphData]);
    });
}