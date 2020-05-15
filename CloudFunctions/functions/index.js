const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

var msgData;

exports.createNotice = 
    functions
    .firestore
    .document('flat/{flat_id}/noticeboard/{id}')
    .onCreate((snapshot,context)=>{
        msgData = snapshot.data();
        
        admin.firestore().collection('user').where('flat_id' , '==' , context.params.flat_id).get().then((userSnapshots) => {
            var tokens = []
            var userName = "";
            if(userSnapshots.empty) {
                console.error("No User [DOCUMENT] /flat/" + context.params.flat_id + "/noticeboard/" + context.params.id);
            } else {
                for(var document of userSnapshots.docs) {
                    if(document.id==msgData.user_id) {
                        userName = document.data().name;
                    } else {
                        tokens.push(document.data().notification_token);
                    }
                }
                if(tokens.length==0) {
                    console.error("No Tokens [DOCUMENT] /flat/" + context.params.flat_id + "/noticeboard/" + context.params.id);
                } else {
                    var payload = {
                        "notification" : {
                            "title" : userName!="" 
                                        ? "New Notice Created By " + userName 
                                        : "New Notice",
                            "body" : msgData.note,
                            "sound" : "default"
                        },
                        "data" : {
                            "sendername" : userName,
                            "click_action": "FLUTTER_NOTIFICATION_CLICK",
                            "screen": "noticeboard",
                            "message": msgData.note
                        }
                    }
                    return admin.messaging().sendToDevice(tokens,payload).then((response) => {
                        console.log("Notice notification pushed [TYPE] onCreate [DOCUMENT] /flat/" + context.params.flat_id + "/noticeboard/" + context.params.id);
                    }).catch((err) => {
                        console.log(err);
                    });
                }   
            }
        });
});