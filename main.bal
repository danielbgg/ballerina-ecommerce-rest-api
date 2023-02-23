import ballerina/io;
import ballerina/sql;
import ballerina/http;
import ballerinax/mysql;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;
configurable decimal BASE_SHIPPING = ?;
configurable decimal BASE_TAX = ?;
configurable int SERVICE_PORT = ?;

public type Item record {|
    int id;
    string title;
    string description;
    string includes;
    string intended;
    string color;
    string material;
    string url;
    decimal price;
|};

public type Order record {|
    string userID;
    string cardName;
    string cardNumber;
    string cardDate;
    string cardCVV;
    OrderItem[] items;
|};

public type OrderItem record {|
    int id;
    int quantity;
|};

public type CartItemDescription record {|
    int id;
    string name;
    int quantity;
    decimal unit;
    decimal total;
|};

public type ReturnCart record {|
    decimal subtotal;
    decimal shipping;
    decimal tax;
    decimal total;
    CartItemDescription[] items;
|};

final mysql:Client dbClient = check new (
    host = HOST, user = USER, password = PASSWORD, port = PORT, database = DATABASE, connectionPool = ({maxOpenConnections: 3, maxConnectionLifeTime: 30})
);

function getCatalog() returns Item[]|error {
    io:println(`GET CATALOG`);
    sql:ParameterizedQuery query = `SELECT * FROM item`;
    stream<Item, error?> employeeStream = dbClient->query(query);

    Item[] res = [];
    check from Item employee in employeeStream
        do {
            res.push(employee);
        };
    return res;
}

service http:Service / on new http:Listener(SERVICE_PORT) {

    function init() {
        io:println(`REST API IS UP ON PORT ${SERVICE_PORT}`);
    }

    resource function post simulate(@http:Payload OrderItem[] payload) returns ReturnCart|error {
        return calculateOrder(payload);
    }

    resource function post place(@http:Payload Order payload) returns json|error {
        return postOrder(payload);
    }

    resource function post create(@http:Payload Item payload) returns json|error {
        return createItem(payload);
    }

    resource function put update/[int id](@http:Payload Item payload) returns json|error {
        return updateItem(id, payload);
    }

}

function calculateOrder(OrderItem[] userOrder) returns ReturnCart|error {
    io:println(`CALCULATE ORDER FOR: ${userOrder}`);
    Item[]|error catalog = getCatalog();
    if (catalog is error) {
        return catalog;
    }
    CartItemDescription[] descriptions = [];
    decimal subtotal = 0;
    foreach var currentOrder in userOrder {
        Item[] i = from Item item in catalog
            where item.id == currentOrder.id
            select item;
        subtotal = subtotal + (currentOrder.quantity * i[0].price);
        descriptions.push({
            id: i[0].id,
            name: i[0].title,
            quantity: currentOrder.quantity,
            unit: i[0].price,
            total: (currentOrder.quantity * i[0].price)
        });
    }

    decimal _shipping = BASE_SHIPPING;
    decimal _tax = subtotal * BASE_TAX;
    decimal _total = subtotal + _shipping + _tax;

    return {
        subtotal: subtotal,
        shipping: _shipping,
        tax: _tax,
        total: _total,
        items: descriptions
    };
}

function getInsertedID(int|string? lastInsertId) returns int|error {
    if lastInsertId is int {
        return lastInsertId;
    } else {
        return error("Error getting last inserted ID");
    }

}

function postOrder(Order userOrder) returns json|error {
    io:println(`POST ORDER FOR: ${userOrder}`);

    ReturnCart|error cart = calculateOrder(userOrder.items);
    if (cart is error) {
        return cart;
    }

    sql:ExecutionResult result1 = check dbClient->execute(`
        INSERT INTO orders (user_id, shipping, tax, card_name, card_number, card_date, card_cvv)
        VALUES (${userOrder.userID}, ${cart.shipping}, ${cart.tax}, ${userOrder.cardName}, ${userOrder.cardNumber}, ${userOrder.cardDate}, ${userOrder.cardCVV})`);

    int orderId = check getInsertedID(result1.lastInsertId);
    io:println(`ORDER ID ${orderId}`);

    foreach var currentItem in cart.items {
        sql:ExecutionResult result2 = check dbClient->execute(`
            INSERT INTO orders_item (order_id, item_id, quantity, price)
            VALUES (${orderId}, ${currentItem.id}, ${currentItem.quantity}, ${currentItem.total})`);
    }

    return {
        "id": orderId,
        "description": "Order created!"
    };
}

function createItem(Item userItem) returns json|error {
    io:println(`CREATE ITEM FOR: ${userItem}`);

    sql:ExecutionResult result1 = check dbClient->execute(`
        INSERT INTO item (title,description,includes,intended,color,material,url,price) 
        VALUES (${userItem.title}, ${userItem.description}, ${userItem.includes}, ${userItem.intended}, ${userItem.color}, ${userItem.material}, ${userItem.url}, ${userItem.price})`);

    int itemId = check getInsertedID(result1.lastInsertId);
    io:println(`ITEM ID ${itemId}`);

    return {
        "id": itemId,
        "description": "Item created!"
    };
}

function updateItem(int id, Item userItem) returns json|error {
    io:println(`UPDATE ITEM FOR: ${userItem}`);

    sql:ExecutionResult result1 = check dbClient->execute(`
        UPDATE item SET
            title = ${userItem.title}, 
            description = ${userItem.description},
            includes = ${userItem.includes},
            intended = ${userItem.intended},
            color = ${userItem.color},
            material = ${userItem.material},
            url = ${userItem.url},
            price = ${userItem.price}
        WHERE id = ${id}  
    `);

    int count = check getInsertedID(result1.affectedRowCount);
    io:println(`COUNT ${count}`);

    return {
        "id": id,
        "description": "Item updated!"
    };
}

function deleteItem(int id) returns json|error {
    io:println(`DELETE ITEM: ${id}`);
    sql:ExecutionResult result1 = check dbClient->execute(`DELETE FROM item where id = ${id}`);
    return {
        "id": id,
        "description": "Item deleted!"
    };
}

function unfollowItem(int itemID, string userID) returns json|error {
    io:println(`UNFOLLOW ITEM: ${itemID} FOR USER: ${userID}`);
    sql:ExecutionResult result1 = check dbClient->execute(`DELETE FROM follow where item_id = ${itemID} AND user_id = ${userID}`);
    return {
        "itemID": itemID,
        "userID": userID,
        "description": "Item unfollowed!"
    };
}

function followItem(int itemID, string userID) returns json|error {
    json ret = check unfollowItem(itemID, userID);
    io:println(`FOLLOW ITEM: ${itemID} FOR USER: ${userID}`);
    sql:ExecutionResult result1 = check dbClient->execute(`
        INSERT INTO follow (item_id, user_id) 
        VALUES (${itemID}, ${userID})`);
    return {
        "itemID": itemID,
        "userID": userID,
        "description": "Item followed!"
    };
}