var img = "ImagePath";

function sendCount()
{
    var message = {"img":img}
    window.webkit.messageHandlers.interOp.postMessage(message)
    
    // initiallising image source as nil
    document.getElementById("imageDisplay").src = "";
}

function showImage(imagePath)
{
    var resultDisplayDiv = document.getElementById("resultDisplay")
    document.getElementById("imageDisplay").src = imagePath
    
    return imagePath
}
