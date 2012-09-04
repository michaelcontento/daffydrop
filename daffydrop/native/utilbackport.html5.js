function utilBackport() {
}

utilBackport.GetTimestamp = function() {
    var ts = Math.round((new Date()).getTime() / 1000);
    return ts;
}

utilBackport.OpenUrl = function(url) {
    window.open(url);
};
