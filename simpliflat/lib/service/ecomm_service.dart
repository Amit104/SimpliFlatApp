




class EcommService {
  static Map getData() {
    var data = {};
    var amazonData = [];

    amazonData.add({'productName':'Oranges','price':'Rs. 100', 'quantity':'1 kg', 'rating':'4', 'imageLocation':'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSkNM0bfjR-T3bjQqHs9xwJxtI5Mn4pR5awHiXPo_vEJTh5hfHO&usqp=CAU'});
    amazonData.add({'productName':'Bananas','price':'Rs. 10', 'quantity':'1 kg', 'rating':'3', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Bananas_white_background_DS.jpg/220px-Bananas_white_background_DS.jpg'});
    amazonData.add({'productName':'Apples','price':'Rs. 200', 'quantity':'2 kg', 'rating':'5', 'imageLocation': 'https://upload.wikimedia.org/wikipedia/commons/1/15/Red_Apple.jpg'});
    amazonData.add({'productName':'Watermelon','price':'Rs. 50', 'quantity':'1 kg', 'rating':'1', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Watermelon_cross_BNC.jpg/220px-Watermelon_cross_BNC.jpg'});
    amazonData.add({'productName':'Grapes','price':'Rs. 80', 'quantity':'1 kg', 'rating':'2', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/b/bb/Table_grapes_on_white.jpg'});
    amazonData.add({'productName':'Grapes','price':'Rs. 80', 'quantity':'1 kg', 'rating':'2', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/b/bb/Table_grapes_on_white.jpg'});
    amazonData.add({'productName':'Grapes','price':'Rs. 80', 'quantity':'1 kg', 'rating':'2', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/b/bb/Table_grapes_on_white.jpg'});
    amazonData.add({'productName':'Grapes','price':'Rs. 80', 'quantity':'1 kg', 'rating':'2', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/b/bb/Table_grapes_on_white.jpg'});
    amazonData.add({'productName':'Grapes are my favorite fruit','price':'Rs. 80', 'quantity':'1 kg', 'rating':'2', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/b/bb/Table_grapes_on_white.jpg'});


    data['Amazon'] = amazonData;


    var grofersData = [];

    grofersData.add({'productName':'Kiwi','price':'Rs. 100', 'quantity':'1.5 kg', 'rating':'4', 'imageLocation':'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSkNM0bfjR-T3bjQqHs9xwJxtI5Mn4pR5awHiXPo_vEJTh5hfHO&usqp=CAU'});
    grofersData.add({'productName':'Mango','price':'Rs. 1000', 'quantity':'1 kg', 'rating':'3', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Bananas_white_background_DS.jpg/220px-Bananas_white_background_DS.jpg'});
    grofersData.add({'productName':'Cherry','price':'Rs. 100', 'quantity':'3 kg', 'rating':'', 'imageLocation': 'https://upload.wikimedia.org/wikipedia/commons/1/15/Red_Apple.jpg'});
    grofersData.add({'productName':'Plum','price':'Rs. 150', 'quantity':'1 kg', 'rating':'1', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Watermelon_cross_BNC.jpg/220px-Watermelon_cross_BNC.jpg'});
    grofersData.add({'productName':'Peach','price':'Rs. 180', 'quantity':'1 kg', 'rating':'2', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/b/bb/Table_grapes_on_white.jpg'});
    grofersData.add({'productName':'Pear','price':'Rs. 280', 'quantity':'3 kg', 'rating':'', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/b/bb/Table_grapes_on_white.jpg'});
    grofersData.add({'productName':'Grapes','price':'Rs. 380', 'quantity':'1 kg', 'rating':'2', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/b/bb/Table_grapes_on_white.jpg'});
    grofersData.add({'productName':'Peach','price':'Rs. 180', 'quantity':'2 kg', 'rating':'2', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/b/bb/Table_grapes_on_white.jpg'});
    grofersData.add({'productName':'Cherries are my favorite fruit','price':'Rs. 80', 'quantity':'1 kg', 'rating':'2', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/b/bb/Table_grapes_on_white.jpg'});


    data['Grofers'] = grofersData;


    var bigBasket = [];

    bigBasket.add({'productName':'Kiwi','price':'Rs. 100', 'quantity':'1.5 kg', 'rating':'4', 'imageLocation':'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSkNM0bfjR-T3bjQqHs9xwJxtI5Mn4pR5awHiXPo_vEJTh5hfHO&usqp=CAU'});
    bigBasket.add({'productName':'Mango','price':'Rs. 1000', 'quantity':'1 kg', 'rating':'3', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Bananas_white_background_DS.jpg/220px-Bananas_white_background_DS.jpg'});
    bigBasket.add({'productName':'Cherry','price':'Rs. 100', 'quantity':'3 kg', 'rating':'', 'imageLocation': 'https://upload.wikimedia.org/wikipedia/commons/1/15/Red_Apple.jpg'});
    bigBasket.add({'productName':'Plum','price':'Rs. 150', 'quantity':'1 kg', 'rating':'1', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Watermelon_cross_BNC.jpg/220px-Watermelon_cross_BNC.jpg'});
    bigBasket.add({'productName':'Peach','price':'Rs. 180', 'quantity':'1 kg', 'rating':'2', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/b/bb/Table_grapes_on_white.jpg'});
    bigBasket.add({'productName':'Pear','price':'Rs. 280', 'quantity':'3 kg', 'rating':'', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/b/bb/Table_grapes_on_white.jpg'});
    bigBasket.add({'productName':'Grapes','price':'Rs. 380', 'quantity':'1 kg', 'rating':'2', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/b/bb/Table_grapes_on_white.jpg'});
    bigBasket.add({'productName':'Peach','price':'Rs. 180', 'quantity':'2 kg', 'rating':'2', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/b/bb/Table_grapes_on_white.jpg'});
    bigBasket.add({'productName':'Cherries are my favorite fruit','price':'Rs. 80', 'quantity':'1 kg', 'rating':'2', 'imageLocation':'https://upload.wikimedia.org/wikipedia/commons/b/bb/Table_grapes_on_white.jpg'});


    data['BigBasket'] = bigBasket;

    return data;
  }

  static List getEcomms() {
    return ['Amazon', 'Grofers', 'BigBasket'];
  }
  
}