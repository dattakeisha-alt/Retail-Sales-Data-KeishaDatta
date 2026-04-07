CREATE TABLE customers (
    customer_id TEXT PRIMARY KEY,
    customer_name TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    region TEXT NOT NULL,
    segment TEXT NOT NULL,
    loyalty_tier TEXT NOT NULL
);

CREATE TABLE products (
    product_id TEXT PRIMARY KEY,
    category TEXT NOT NULL,
    subcategory TEXT NOT NULL,
    product_name TEXT NOT NULL,
    list_price REAL NOT NULL
);

CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT NOT NULL,
    order_date TEXT NOT NULL,
    sales_channel TEXT NOT NULL,
    payment_method TEXT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price REAL NOT NULL,
    sales_amount REAL NOT NULL,
    profit_amount REAL NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
