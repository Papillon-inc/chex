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
        let sender = document.getElementById("sender")
        let reci = document.getElementById("recipient")
        let amount = document.getElementById("amount")
        document.getElementById("new").onclick = () =>{this.newChain(channel, id.value)}
        document.getElementById("get").onclick = () =>{this.getChain(channel, id.value)}
        document.getElementById("push").onclick = () =>{this.pushChain(channel, id.value, sender.value, reci.value, amount.value)}
    },

    newChain:function(channel, id){
        let i = 0
        channel.push("new",{body:"aaa", id: id})
        
    },
    getChain:function(channel, id){
        channel.push("get",{body:"aaa", id: id})
        
    },

    pushChain:function(channel, id, sender, reci, amount){
        channel.push("push", {id: id, sender: sender, recipient: reci, amount: amount})
    },
}

export default Chain