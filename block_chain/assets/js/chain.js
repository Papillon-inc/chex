let Chain = {
    join:function(socket){
        socket.connect()
        let channel = socket.channel("chain:new",{})
        channel.join()
        .receive("ok", resp => { console.log("Joined successfully", resp) })
        .receive("error", resp => { console.log("Unable to join", resp) })

        channel.on("new", payload =>{
            console.log(payload)
        })

        channel.on("get", payload =>{
            console.log(payload)
        })

        let id = document.getElementById("ID")
        document.getElementById("push").onclick = () =>{this.newChain(channel, id.value)}
        document.getElementById("get").onclick = () =>{this.getChain(channel, id.value)}
    },

    newChain:function(channel, id){
        console.log("aaa")
        let i = 0
        channel.push("new",{body:"aaa", id: id})
        
    },
    getChain:function(channel, id){
        console.log("aaa")
        channel.push("get",{body:"aaa", id: id})
        
    }
}

export default Chain