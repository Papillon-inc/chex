let Chain = {
    join:function(socket){
        socket.connect()
        let channel = socket.channel("chain:new",{})
        channel.join()
        .receive("ok", resp => { console.log("Joined successfully", resp) })
        .receive("error", resp => { console.log("Unable to join", resp) })

        let id = document.getElementById("ID")
        let sender = document.getElementById("sender")
        let reci = document.getElementById("recipient")
        let amount = document.getElementById("amount")
        let us = document.getElementById("user")
        channel.on("new", payload =>{
            console.log(payload.chain)
        })

        channel.on("get", payload =>{
            console.log(payload.chain)
            console.log(payload.tran)
        })

        channel.on("tran", payload =>{
            console.log(payload)
        })

        channel.on("chain", payload =>{
            console.log(payload)
        })

        channel.on("user", payload =>{
            console.log(payload)
        })

        channel.on("inform", payload => {
            console.log(payload)
            console.log(id.value)
            if(payload.mode == "0"){
                channel.push("newChain", {id: id.value})
            }else if(payload.mode == "1"){
                channel.push("newTran", {tran_id: payload.id, id: id.value})
            }else if(payload.mode == "2"){
                channel.push("errorUser",{id: id.value})
            }else if(payload.mode == "3"){
                channel.push("checkChain",{id: id.value})
            }
        })

        channel.on("errorTran", payload =>{
            console.log("Your Tran is error")
            console.log(payload.tran)
        })

        channel.on("point", payload => {
            console.log("aaaaaaaaaaaaaa")
            console.log(payload)
        })

        channel.on("getEC", payload =>{
            console.log("error:"+payload.error)
            console.log("chain:"+payload.chain)
            console.log("errorChain:"+payload.errorChain)
        })

        document.getElementById("new").onclick = () =>{this.newChain(channel, id.value)}
        document.getElementById("get").onclick = () =>{this.getChain(channel, id.value)}
        document.getElementById("push").onclick = () =>{this.pushChain(channel, id.value, sender.value, reci.value, amount.value)}
        document.getElementById("chain").onclick = () => {this.creatChain(channel, id.value)}
        document.getElementById("delete").onclick = () => {this.deleteUser(channel, id.value)}
        document.getElementById("setUser").onclick = () => {this.setUser(channel, id.value, us.value)}
        document.getElementById("e_new").onclick = () => {this.eNew(channel, id.value)}
        document.getElementById("point").onclick = () => {this.getPoint(channel, id.value)}
        document.getElementById("getEC").onclick = () => {this.getEC(channel, id.value)}
        document.getElementById("reset").onclick = () => {this.reset(channel, id.value)}
        document.getElementById("e_tran").onclick = () => {this.e_tran(channel, id.value, sender.value, reci.value, amount.value)}
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

    creatChain: function(channel, id){
        channel.push("chain", {id: id})
    },

    deleteUser: function(channel, id){
        channel.push("delete", {id: id})
    },

    setUser: function(channel, id, us){
        channel.push("setUser", {id: us})
    },

    eNew: function(channel, id){
        channel.push("e_new", {id: id})
    },

    getPoint: function(channel, id){
        channel.push("getPoint",{id: id})
    },

    getEC: function(channel, id){
        channel.push("getEC",{})
    },

    reset: function(channel, id){
        channel.push("reset",{})
    },

    e_tran: function(channel, id, sender, reci, amount){
        channel.push("e_tran", {id: id, sender: sender, recipient: reci, amount: amount})
    },
}

export default Chain