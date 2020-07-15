const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

var msgData;

//////////////////////////////////////////////////////////////////////////////////////////
// Noticeboard  Notifications
//////////////////////////////////////////////////////////////////////////////////////////

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
                        console.error(err);
                    });
                }   
            }
        });
});

//////////////////////////////////////////////////////////////////////////////////////////
// Tasks  Notifications
//////////////////////////////////////////////////////////////////////////////////////////

exports.createTask = 
    functions
    .firestore
    .document('flat/{flat_id}/tasks/{id}')
    .onCreate((snapshot,context)=>{
        msgData = snapshot.data();
        
        admin.firestore().collection('user').where('flat_id' , '==' , context.params.flat_id).get().then((userSnapshots) => {
            var tokens = []
            var userName = "";
            if(userSnapshots.empty) {
                console.error("No User [DOCUMENT] /flat/" + context.params.flat_id + "/tasks/" + context.params.id);
            } else {
                for(var document of userSnapshots.docs) {
                    if(document.id==msgData.user_id) {
                        userName = document.data().name;
                    } else if(msgData.assignee.includes(document.id)) {
                        tokens.push(document.data().notification_token);
                    }
                }
                if(tokens.length==0) {
                    console.error("No Tokens [DOCUMENT] /flat/" + context.params.flat_id + "/tasks/" + context.params.id);
                } else {
                    var payload = {
                        "notification" : {
                            "title" : userName!="" 
                                        ? "New Task Created By " + userName 
                                        : "New Task",
                            "body" : msgData.title,
                            "sound" : "default"
                        },
                        "data" : {
                            "sendername" : userName,
                            "click_action": "FLUTTER_NOTIFICATION_CLICK",
                            "screen": "tasks",
                            "message": msgData.title
                        }
                    }
                    return admin.messaging().sendToDevice(tokens,payload).then((response) => {
                        console.log("Tasks notification pushed [TYPE] onCreate [DOCUMENT] /flat/" + context.params.flat_id + "/tasks/" + context.params.id);
                    }).catch((err) => {
                        console.error(err);
                    });
                }   
            }
        });
});

exports.updateTask = 
    functions
    .firestore
    .document('flat/{flat_id}/tasks/{id}')
    .onUpdate((snapshot,context)=>{
        msgData = snapshot.after.data();
        
        admin.firestore().collection('user').where('flat_id' , '==' , context.params.flat_id).get().then((userSnapshots) => {
            var tokens = []
            var userName = "";
            if(userSnapshots.empty) {
                console.error("No User [DOCUMENT] /flat/" + context.params.flat_id + "/tasks/" + context.params.id);
            } else {
                for(var document of userSnapshots.docs) {
                    if(document.id==msgData.user_id) {
                        userName = document.data().name;
                    } else if(msgData.assignee.includes(document.id)) {
                        tokens.push(document.data().notification_token);
                    }
                }
                if(tokens.length==0) {
                    console.error("No Tokens [DOCUMENT] /flat/" + context.params.flat_id + "/tasks/" + context.params.id);
                } else {
                    var payload = {
                        "notification" : {
                            "title" : userName!="" 
                                        ? "Task Updated By " + userName 
                                        : "Task Updated",
                            "body" : msgData.title,
                            "sound" : "default"
                        },
                        "data" : {
                            "sendername" : userName,
                            "click_action": "FLUTTER_NOTIFICATION_CLICK",
                            "screen": "tasks",
                            "message": msgData.title
                        }
                    }
                    return admin.messaging().sendToDevice(tokens,payload).then((response) => {
                        console.log("Tasks notification pushed [TYPE] onUpdate [DOCUMENT] /flat/" + context.params.flat_id + "/tasks/" + context.params.id);
                    }).catch((err) => {
                        console.error(err);
                    });
                }   
            }
        });
});

//////////////////////////////////////////////////////////////////////////////////////////
// Lists  Notifications
//////////////////////////////////////////////////////////////////////////////////////////

exports.createList = 
    functions
    .firestore
    .document('flat/{flat_id}/lists/{id}')
    .onCreate((snapshot,context)=>{
        msgData = snapshot.data();
        
        admin.firestore().collection('user').where('flat_id' , '==' , context.params.flat_id).get().then((userSnapshots) => {
            var tokens = []
            var userName = "";
            if(userSnapshots.empty) {
                console.error("No User [DOCUMENT] /flat/" + context.params.flat_id + "/lists/" + context.params.id);
            } else {
                for(var document of userSnapshots.docs) {
                    if(document.id==msgData.user_id) {
                        userName = document.data().name;
                    } else {
                        tokens.push(document.data().notification_token);
                    }
                }
                if(tokens.length==0) {
                    console.error("No Tokens [DOCUMENT] /flat/" + context.params.flat_id + "/lists/" + context.params.id);
                } else {
                    var payload = {
                        "notification" : {
                            "title" : userName!="" 
                                        ? "New list Created By " + userName 
                                        : "New list",
                            "body" : msgData.title,
                            "sound" : "default"
                        },
                        "data" : {
                            "sendername" : userName,
                            "click_action": "FLUTTER_NOTIFICATION_CLICK",
                            "screen": "lists",
                            "message": msgData.title
                        }
                    }
                    return admin.messaging().sendToDevice(tokens,payload).then((response) => {
                        console.log("List notification pushed [TYPE] onCreate [DOCUMENT] /flat/" + context.params.flat_id + "/lists/" + context.params.id);
                    }).catch((err) => {
                        console.error(err);
                    });
                }   
            }
        });
});


//////////////////////////////////////////////////////////////////////////////////////////
// flatContacts  Notifications
//////////////////////////////////////////////////////////////////////////////////////////

exports.createFlatContacts = 
    functions
    .firestore
    .document('flat/{flat_id}/flatContacts/{id}')
    .onCreate((snapshot,context)=>{
        msgData = snapshot.data();
        
        admin.firestore().collection('user').where('flat_id' , '==' , context.params.flat_id).get().then((userSnapshots) => {
            var tokens = []
            var userName = "";
            if(userSnapshots.empty) {
                console.error("No User [DOCUMENT] /flat/" + context.params.flat_id + "/flatContacts/" + context.params.id);
            } else {
                for(var document of userSnapshots.docs) {
                    if(document.id==msgData.user_id) {
                        userName = document.data().name;
                    } else {
                        tokens.push(document.data().notification_token);
                    }
                }
                if(tokens.length==0) {
                    console.error("No Tokens [DOCUMENT] /flat/" + context.params.flat_id + "/flatContacts/" + context.params.id);
                } else {
                    var payload = {
                        "notification" : {
                            "title" : userName!="" 
                                        ? "New Contact Created By " + userName 
                                        : "New Contact created",
                            "body" : msgData.name,
                            "sound" : "default"
                        },
                        "data" : {
                            "sendername" : userName,
                            "click_action": "FLUTTER_NOTIFICATION_CLICK",
                            "screen": "flatContacts",
                            "message": msgData.name
                        }
                    }
                    return admin.messaging().sendToDevice(tokens,payload).then((response) => {
                        console.log("List notification pushed [TYPE] onCreate [DOCUMENT] /flat/" + context.params.flat_id + "/flatContacts/" + context.params.id);
                    }).catch((err) => {
                        console.error(err);
                    });
                }   
            }
        });
});

//////////////////////////////////////////////////////////////////////////////////////////
// messageboard Notifications (landlord related)
//////////////////////////////////////////////////////////////////////////////////////////

exports.createMessageBoard = 
    functions
    .firestore
    .document('flat/{flat_id}/messageboard/{id}')
    .onCreate((snapshot,context)=>{
        msgData = snapshot.data();
        var userName = "";
        var tokens = []

        // notification to tenants
        admin.firestore().collection('user').where('flat_id' , '==' , context.params.flat_id).get().then((userSnapshots) => {
            if(userSnapshots.empty) {
                console.error("No User [DOCUMENT] /flat/" + context.params.flat_id + "/messageboard/" + context.params.id);
            } else {
                for(var document of userSnapshots.docs) {
                    if(document.id==msgData.user_id) {
                        userName = document.data().name;
                    } else {
                        tokens.push(document.data().notification_token);
                    }
                }
            }

            // notification to landlord
            admin.firestore().collection('flat').doc(context.params.flat_id).get().then((flatSnapshot) => {
                if(flatSnapshot.empty) {
                    console.error("No Flat [DOCUMENT] /flat/" + context.params.flat_id);
                } else {
                    landlordId = flatSnapshot.data().landlord_id;
                    admin.firestore().collection('landlord').doc(landlordId).get().then((landlordSnapshot) => {
                        if(landlordSnapshot.empty) {
                            console.error("No Landlord [DOCUMENT] /flat/" + context.params.flat_id + "/messageboard/" + context.params.id);
                        } else {
                            if(landlordSnapshot.id==msgData.user_id) {
                                userName = landlordSnapshot.data().name;
                            } else {
                                tokens.push(landlordSnapshot.data().notification_token);
                            }
                        }

                        if(tokens.length==0) {
                            console.error("No Tokens [DOCUMENT] /flat/" + context.params.flat_id + "/messageboard/" + context.params.id);
                        } else {
                            var payload = {
                                "notification" : {
                                    "title" : userName!="" 
                                                ? "New Message By " + userName 
                                                : "New Message in Message board",
                                    "body" : msgData.message,
                                    "sound" : "default"
                                },
                                "data" : {
                                    "sendername" : userName,
                                    "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                    "screen": "messageboard",
                                    "message": msgData.message
                                }
                            }
                            return admin.messaging().sendToDevice(tokens,payload).then((response) => {
                                console.log("messageboard notification pushed [TYPE] onCreate [DOCUMENT] /flat/" + context.params.flat_id + "/messageboard/" + context.params.id);
                            }).catch((err) => {
                                console.error(err);
                            });
                        }   
                    });
                }
            });
        });
});

//////////////////////////////////////////////////////////////////////////////////////////
// documentmanager Notifications (landlord related)
//////////////////////////////////////////////////////////////////////////////////////////

exports.createDocumentManager = 
    functions
    .firestore
    .document('flat/{flat_id}/documentmanager/{id}')
    .onCreate((snapshot,context)=>{
        msgData = snapshot.data();
        var userName = "";
        var tokens = []

        // notification to tenants
        admin.firestore().collection('user').where('flat_id' , '==' , context.params.flat_id).get().then((userSnapshots) => {
            if(userSnapshots.empty) {
                console.error("No User [DOCUMENT] /flat/" + context.params.flat_id + "/documentmanager/" + context.params.id);
            } else {
                for(var document of userSnapshots.docs) {
                    if(document.id==msgData.user_id) {
                        userName = document.data().name;
                    } else {
                        tokens.push(document.data().notification_token);
                    }
                }
            }

            // notification to landlord
            admin.firestore().collection('flat').doc(context.params.flat_id).get().then((flatSnapshot) => {
                if(flatSnapshot.empty) {
                    console.error("No Flat [DOCUMENT] /flat/" + context.params.flat_id);
                } else {
                    landlordId = flatSnapshot.data().landlord_id;
                    admin.firestore().collection('landlord').doc(landlordId).get().then((landlordSnapshot) => {
                        if(landlordSnapshot.empty) {
                            console.error("No Landlord [DOCUMENT] /flat/" + context.params.flat_id + "/documentmanager/" + context.params.id);
                        } else {
                            if(landlordSnapshot.id==msgData.user_id) {
                                userName = landlordSnapshot.data().name;
                            } else {
                                tokens.push(landlordSnapshot.data().notification_token);
                            }
                        }

                        if(tokens.length==0) {
                            console.error("No Tokens [DOCUMENT] /flat/" + context.params.flat_id + "/documentmanager/" + context.params.id);
                        } else {
                            var payload = {
                                "notification" : {
                                    "title" : userName!="" 
                                                ? "New Document uploaded By " + userName 
                                                : "New document in Document Manager",
                                    "body" : msgData.file_name,
                                    "sound" : "default"
                                },
                                "data" : {
                                    "sendername" : userName,
                                    "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                    "screen": "documentmanager",
                                    "message": msgData.file_name
                                }
                            }
                            return admin.messaging().sendToDevice(tokens,payload).then((response) => {
                                console.log("documentmanager notification pushed [TYPE] onCreate [DOCUMENT] /flat/" + context.params.flat_id + "/documentmanager/" + context.params.id);
                            }).catch((err) => {
                                console.error(err);
                            });
                        }   
                    });
                }                
            });
        });
});

//////////////////////////////////////////////////////////////////////////////////////////
// joinflat Notifications
//////////////////////////////////////////////////////////////////////////////////////////

exports.joinFlat = 
    functions
    .firestore
    .document('joinflat/{id}')
    .onCreate((snapshot,context)=>{
        msgData = snapshot.data();
        var tokens = []
        
        if(msgData.status == 0) {
            // join request to flat
            if(msgData.request_from_flat == 0) {
                admin.firestore().collection('user').where('flat_id' , '==' , msgData.flat_id).get().then((userSnapshots) => {
                    if(userSnapshots.empty) {
                        console.error("No User [DOCUMENT] /joinflat/" + context.params.id);
                    } else {
                        for(var document of userSnapshots.docs) {
                            tokens.push(document.data().notification_token);
                        }
                    }

                    if(tokens.length==0) {
                        console.error("No Tokens [DOCUMENT] /joinflat/" + context.params.id);
                    } else {
                        var payload = {
                            "notification" : {
                                "title" : "New Join Request",
                                "body" : msgData.request_from_flat == 0 ? "A user wants to join the flat" : "you have a join request from a flat",
                                "sound" : "default"
                            },
                            "data" : {
                                "sendername" : userName,
                                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                "screen": "joinflat",
                                "message": msgData.request_from_flat == 0 ? "A user wants to join the flat" : "you have a join request from a flat"
                            }
                        }
                        return admin.messaging().sendToDevice(tokens,payload).then((response) => {
                            console.log("joinflat notification pushed [TYPE] onCreate [DOCUMENT] /joinflat/" + context.params.id);
                        }).catch((err) => {
                            console.error(err);
                        });
                    }   
                });
            } else {
                // Join request to user
                admin.firestore().collection('user').doc(msgData.user_id).get().then((userSnapshot) => {
                    if(userSnapshot.empty) {
                        console.error("No User [DOCUMENT] /joinflat/" + context.params.id);
                    } else {
                        tokens.push(userSnapshot.data().notification_token);
                    }

                    if(tokens.length==0) {
                        console.error("No Tokens [DOCUMENT] /joinflat/" + context.params.id);
                    } else {
                        var payload = {
                            "notification" : {
                                "title" : "New Join Request",
                                "body" : msgData.request_from_flat == 0 ? "A user wants to join the flat" : "you have a join request from a flat",
                                "sound" : "default"
                            },
                            "data" : {
                                "sendername" : userName,
                                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                "screen": "joinflat",
                                "message": msgData.request_from_flat == 0 ? "A user wants to join the flat" : "you have a join request from a flat"
                            }
                        }
                        return admin.messaging().sendToDevice(tokens,payload).then((response) => {
                            console.log("joinflat notification pushed [TYPE] onCreate [DOCUMENT] /joinflat/" + context.params.id);
                        }).catch((err) => {
                            console.error(err);
                        });
                    }   
                });
            }
        }
});


//////////////////////////////////////////////////////////////////////////////////////////
// joinflat_landlord Notifications (landlord related)
//////////////////////////////////////////////////////////////////////////////////////////

exports.joinFlatLandlord = 
    functions
    .firestore
    .document('joinflat_landlord/{id}')
    .onCreate((snapshot,context)=>{
        msgData = snapshot.data();
        var tokens = []
        if(msgData.status == 0) {
            // join request to flat
            if(msgData.request_from_flat == 0) {
                admin.firestore().collection('user').where('flat_id' , '==' , msgData.flat_id).get().then((userSnapshots) => {
                    if(userSnapshots.empty) {
                        console.error("No User [DOCUMENT] /joinflat_landlord/" + context.params.id);
                    } else {
                        for(var document of userSnapshots.docs) {
                            tokens.push(document.data().notification_token);
                        }
                    }

                    if(tokens.length==0) {
                        console.error("No Tokens [DOCUMENT] /joinflat_landlord/" + context.params.id);
                    } else {
                        var payload = {
                            "notification" : {
                                "title" : "New Join Request",
                                "body" : msgData.request_from_flat == 0 ? "A landlord wants to join the flat" : "you have a join request from a flat",
                                "sound" : "default"
                            },
                            "data" : {
                                "sendername" : userName,
                                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                "screen": "joinflat_landlord",
                                "message": msgData.request_from_flat == 0 ? "A landlord wants to join the flat" : "you have a join request from a flat"
                            }
                        }
                        return admin.messaging().sendToDevice(tokens,payload).then((response) => {
                            console.log("joinflat_landlord notification pushed [TYPE] onCreate [DOCUMENT] /joinflat_landlord/" + context.params.id);
                        }).catch((err) => {
                            console.error(err);
                        });
                    } 
                });
            } else {
                // Join request to user
                admin.firestore().collection('landlord').doc(msgData.user_id).get().then((userSnapshot) => {
                    if(userSnapshot.empty) {
                        console.error("No User [DOCUMENT] /joinflat_landlord/" + context.params.id);
                    } else {
                        tokens.push(userSnapshot.data().notification_token);
                    }

                    if(tokens.length==0) {
                        console.error("No Tokens [DOCUMENT] /joinflat_landlord/" + context.params.id);
                    } else {
                        var payload = {
                            "notification" : {
                                "title" : "New Join Request",
                                "body" : msgData.request_from_flat == 0 ? "A landlord wants to join the flat" : "you have a join request from a flat",
                                "sound" : "default"
                            },
                            "data" : {
                                "sendername" : userName,
                                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                "screen": "joinflat_landlord",
                                "message": msgData.request_from_flat == 0 ? "A landlord wants to join the flat" : "you have a join request from a flat"
                            }
                        }
                        return admin.messaging().sendToDevice(tokens,payload).then((response) => {
                            console.log("joinflat_landlord notification pushed [TYPE] onCreate [DOCUMENT] /joinflat_landlord/" + context.params.id);
                        }).catch((err) => {
                            console.error(err);
                        });
                    } 
                });
            }  
        }
});

//////////////////////////////////////////////////////////////////////////////////////////
// Tasks  Notifications (landlord related) 
//////////////////////////////////////////////////////////////////////////////////////////

exports.createLandlordTask = 
    functions
    .firestore
    .document('flat/{flat_id}/tasks_landlord/{id}')
    .onCreate((snapshot,context)=>{
        msgData = snapshot.data();
        var tokens = []
        var userName = "";
        
        // get flat users notification token if task asssigned to them
        admin.firestore().collection('user').where('flat_id' , '==' , context.params.flat_id).get().then((userSnapshots) => {
            if(userSnapshots.empty) {
                console.error("No User [DOCUMENT] /flat/" + context.params.flat_id + "/tasks_" + msgData.landlord_id + "/" + context.params.id);
            } else {
                for(var document of userSnapshots.docs) {
                    if(document.id==msgData.user_id) {
                        userName = document.data().name;
                    } else if(msgData.assignee.includes(document.id)) {
                        tokens.push(document.data().notification_token);
                    }
                } 
            }

            // get landlord notification token if task asssigned to landlord
            if(msgData.assignee.includes(msgData.landlord_id) || msgData.landlord_id == msgData.user_id) {
                admin.firestore().collection('landlord').doc(msgData.landlord_id).get().then((userSnapshot) => {
                    if(userSnapshot.empty) {
                        console.error("No landlord for /flat/" + context.params.flat_id + "/tasks_" + msgData.landlord_id + "/" + context.params.id);
                    } else {
                        if(userSnapshot.id==msgData.user_id) {
                            userName = document.data().name;
                        } else {
                            tokens.push(userSnapshot.data().notification_token);
                        }                    
                    }

                    if(tokens.length==0) {
                        console.error("No Tokens [DOCUMENT] /flat/" + context.params.flat_id + "/tasks_" + msgData.landlord_id +  "/" + context.params.id);
                    } else {
                        var payload = {
                            "notification" : {
                                "title" : userName!="" 
                                            ? "New Task Created By " + userName 
                                            : "New Task",
                                "body" : msgData.title,
                                "sound" : "default"
                            },
                            "data" : {
                                "sendername" : userName,
                                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                "screen": "tasks_" + msgData.landlord_id,
                                "message": msgData.title
                            }
                        }
                        return admin.messaging().sendToDevice(tokens,payload).then((response) => {
                            console.log("Landlord-Tenant Tasks notification pushed [TYPE] onCreate [DOCUMENT] /flat/" + context.params.flat_id + "/tasks_" + msgData.landlord_id + "/" + context.params.id);
                        }).catch((err) => {
                            console.error(err);
                        });
                    }  
                });
            } else {
                if(tokens.length==0) {
                    console.error("No Tokens [DOCUMENT] /flat/" + context.params.flat_id + "/tasks_" + msgData.landlord_id +  "/" + context.params.id);
                } else {
                    var payload = {
                        "notification" : {
                            "title" : userName!="" 
                                        ? "New Task Created By " + userName 
                                        : "New Task",
                            "body" : msgData.title,
                            "sound" : "default"
                        },
                        "data" : {
                            "sendername" : userName,
                            "click_action": "FLUTTER_NOTIFICATION_CLICK",
                            "screen": "tasks_" + msgData.landlord_id,
                            "message": msgData.title
                        }
                    }
                    return admin.messaging().sendToDevice(tokens,payload).then((response) => {
                        console.log("Landlord-Tenant Tasks notification pushed [TYPE] onCreate [DOCUMENT] /flat/" + context.params.flat_id + "/tasks_" + msgData.landlord_id + "/" + context.params.id);
                    }).catch((err) => {
                        console.error(err);
                    });
                }  
            }
        });
});

exports.updateLandlordTask = 
    functions
    .firestore
    .document('flat/{flat_id}/tasks_landlord/{id}')
    .onUpdate((snapshot,context)=>{
        msgData = snapshot.after.data();
        var tokens = []
        var userName = "";
        
        // get flat users notification token if task asssigned to them
        admin.firestore().collection('user').where('flat_id' , '==' , context.params.flat_id).get().then((userSnapshots) => {
            if(userSnapshots.empty) {
                console.error("No User [DOCUMENT] /flat/" + context.params.flat_id + "/tasks_" + msgData.landlord_id + "/" + context.params.id);
            } else {
                for(var document of userSnapshots.docs) {
                    if(document.id==msgData.user_id) {
                        userName = document.data().name;
                    } else if(msgData.assignee.includes(document.id)) {
                        tokens.push(document.data().notification_token);
                    }
                } 
            }

            // get landlord notification token if task asssigned to landlord
            if(msgData.assignee.includes(msgData.landlord_id)) {
                admin.firestore().collection('landlord').doc(msgData.landlord_id).get().then((userSnapshot) => {
                    if(userSnapshot.empty) {
                        console.error("No landlord for /flat/" + context.params.flat_id + "/tasks_" + msgData.landlord_id + "/" + context.params.id);
                    } else {
                        tokens.push(userSnapshot.data().notification_token);
                    }

                    if(tokens.length==0) {
                        console.error("No Tokens [DOCUMENT] /flat/" + context.params.flat_id + "/tasks_" + msgData.landlord_id +  "/" + context.params.id);
                    } else {
                        var payload = {
                            "notification" : {
                                "title" : userName!="" 
                                            ? "Task Updated By " + userName 
                                            : "Update to Task",
                                "body" : msgData.title,
                                "sound" : "default"
                            },
                            "data" : {
                                "sendername" : userName,
                                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                "screen": "tasks_" + msgData.landlord_id,
                                "message": msgData.title
                            }
                        }
                        return admin.messaging().sendToDevice(tokens,payload).then((response) => {
                            console.log("Landlord-Tenant Tasks notification pushed [TYPE] onCreate [DOCUMENT] /flat/" + context.params.flat_id + "/tasks_" + msgData.landlord_id + "/" + context.params.id);
                        }).catch((err) => {
                            console.error(err);
                        });
                    } 
                });
            } else {
                if(tokens.length==0) {
                    console.error("No Tokens [DOCUMENT] /flat/" + context.params.flat_id + "/tasks_" + msgData.landlord_id +  "/" + context.params.id);
                } else {
                    var payload = {
                        "notification" : {
                            "title" : userName!="" 
                                        ? "Task Updated By " + userName 
                                        : "Update to Task",
                            "body" : msgData.title,
                            "sound" : "default"
                        },
                        "data" : {
                            "sendername" : userName,
                            "click_action": "FLUTTER_NOTIFICATION_CLICK",
                            "screen": "tasks_" + msgData.landlord_id,
                            "message": msgData.title
                        }
                    }
                    return admin.messaging().sendToDevice(tokens,payload).then((response) => {
                        console.log("Landlord-Tenant Tasks notification pushed [TYPE] onCreate [DOCUMENT] /flat/" + context.params.flat_id + "/tasks_" + msgData.landlord_id + "/" + context.params.id);
                    }).catch((err) => {
                        console.error(err);
                    });
                } 
            }
        }); 
});