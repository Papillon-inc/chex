// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import socket from "./socket"
import Chain from "./chain"

document.getElementById("join").onclick = function(){
    Chain.join(socket)
}


// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
