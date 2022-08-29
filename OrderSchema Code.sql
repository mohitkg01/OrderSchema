#----------------------------------------------------------------------------------------------
# 1. Write a query to display the product details
# (product_class_code, product_id, product_desc, product_price) 
# as per the following criteria and sort them descending order of category: i) 
# If the category is 2050, increase the price by 2000 ii) If the category is 2051, increase the price by 500 iii)
# If the category is 2052, increase the price by 600
# Hint: Use CASE statement, no permanent change in table required. (60 rows)[NOTE:PRODUCT TABLE]
#----------------------------------------------------------------------------------------------------

SELECT 
 product_class_code,
    product_price,
    (CASE
        WHEN product_class_code = 2050 THEN (product_price + 2000)
        WHEN product_class_code = 2051 THEN (product_price + 500)
        WHEN product_class_code = 2052 THEN (product_price + 600)
        ELSE product_price
    END) AS new_price
FROM
    product
ORDER BY product_class_code DESC;
#-----------------------------------------------------------------------------------------
#2. Write a query to display 
#(product_class_desc, product_id, product_desc, product_quantity_avail ) and
# Show inventory status of products as below as per their available quantity:
# a. For Electronics and Computer categories, 
#if available quantity is <= 10, show 'Low stock',
# 11 <= qty <= 30, show 'In stock', >= 31, show 'Enough stock'
#b. For Stationery and Clothes categories, if qty <= 20, show 'Low stock', 
#21 <= qty <= 80, show 'In stock', >=81, show 'Enough stock' 
#c. Rest of the categories, if qty <= 15 – 'Low Stock',
# 16 <= qty <= 50 – 'In Stock', >= 51 – 'Enough stock' For all categories, 
#if available quantity is 0, show 'Out of stock'.
# Hint: Use case statement. (60 ROWS)[NOTE : TABLES TO BE USED – product, product_class]
#-----------------------------------------------------------------------------------------------------------------

SELECT 
    pc.product_class_desc,
    pd.product_id,
    pd.product_desc,
    pd.product_quantity_avail,
   ( CASE
        WHEN pd.product_quantity_avail = 0 THEN 'Out of stock'
        WHEN
            pc.product_class_desc IN ('Electronics' , 'Computer')
        THEN
            CASE
                WHEN pd.product_quantity_avail <= 10 THEN 'Low stock'
                WHEN pd.product_quantity_avail BETWEEN 11 AND 30 THEN 'In stock'
                ELSE 'Enough stock'
            END
        WHEN
            pc.product_class_desc IN ('Stationery' , 'Clothes')
        THEN
            CASE
                WHEN pd.product_quantity_avail <= 20 THEN 'Low stock'
                WHEN pd.product_quantity_avail BETWEEN 21 AND 80 THEN 'In stock'
                ELSE 'Enough stock'
            END
        WHEN pd.product_quantity_avail <= 15 THEN 'Low stock'
        WHEN pd.product_quantity_avail BETWEEN 16 AND 50 THEN 'In stock'
        ELSE 'Enough stock'
    END) as quantity_status
FROM
    product AS pd
        JOIN
    product_class AS pc ON pd.product_class_code = pc.product_class_code
    group by pd.product_desc order by pd.product_id asc;

#--------------------------------------------------------------------------------------
#3Write a query to Show the count of cities in all countries other than USA & MALAYSIA,
# with more than 1 city, in the descending order of CITIES.
#(2 rows)[NOTE :ADDRESS TABLE] 
#-----------------------------------------------------------------------------------------

SELECT 
    country, COUNT(city) counts
FROM
    address
WHERE
    country NOT IN ('usa' , 'malaysia')
GROUP BY country
HAVING COUNT(city) > 1
ORDER BY city DESC;

#----------------------------------------------------------------------
#4. Write a query to display the customer_id,customer full name ,
#city,pincode,and order details 
#(order id, product class desc, product desc, subtotal(product_quantity * product_price))
#for orders shipped to cities whose pin codes do not have any 0s in them.
#Sort the output on customer name, order date and subtotal.
#(52 ROWS) [NOTE : TABLE TO BE USED - online_customer, address,
#order_header, order_items, product, product_class] 
#------------------------------------------------------------------------------------- 
 SELECT 
    oc.customer_id,
    CONCAT(oc.customer_fname,' ',oc.customer_lname) AS customer_full_name,
    ad.city,
    ad.pincode,
    oh.order_id,
    pc.product_class_desc,
    pd.product_desc,
    (oi.product_quantity * pd.product_price) AS subtotal
FROM
    product_class AS pc
         JOIN
    product AS pd ON pc.product_class_code = pd.product_class_code
         JOIN
    order_items AS oi ON pd.product_id = oi.product_id
         JOIN
    order_header AS oh ON oi.order_id = oh.order_id
         JOIN
    online_customer AS oc ON oh.customer_id = oc.customer_id
         JOIN
    address AS ad ON oc.address_id = ad.address_id
WHERE
    ad.pincode NOT LIKE '%0%'
ORDER BY oc.customer_fname , subtotal;
#----------------------------------------------------------------------
#5. Write a Query to display product id,product description,
#totalquantity(sum(product quantity) for a given item whose 
#product id is 201 and which item has been bought along with it maximum no.
# of times. Display only one record which has the maximum value for total quantity in this scenario.
#(USE SUB-QUERY)(1 ROW)[NOTE : ORDER_ITEMS TABLE,PRODUCT TABLE] 
#--------------------------------------------------------------------------------------

SELECT 
    pd.product_id,
    pd.product_desc,
    SUM(oi.product_quantity) AS total_quantity,
    MAX(oi.product_quantity)
FROM
    product AS pd
        JOIN
    order_items AS oi ON pd.product_id = oi.product_id
WHERE
    pd.product_id = 201;
#------------------------------------------------------------------------------------
#6. Write a query to display the customer_id,customer name, email and order details
#(order id, product desc,product qty, subtotal(product_quantity * product_price))
#for all customers even if they have not ordered any item.(225 ROWS)
#[NOTE : TABLE TO BE USED - online_customer, order_header, order_items, product]
#--------------------------------------------------------------------------------
 
 SELECT 
    oc.customer_id,
    CONCAT(oc.customer_fname, ' ', customer_lname) AS customer_name,
    oc.customer_email,
    oh.order_id,
    pd.product_desc,
    oi.product_quantity,
    oi.product_quantity * pd.product_price
FROM
    online_customer AS oc
        LEFT JOIN
    order_header AS oh ON oc.customer_id = oh.customer_id
        LEFT JOIN
    order_items AS oi ON oh.order_id = oi.order_id
        LEFT JOIN
    product AS pd ON oi.product_id = pd.product_id;
 
#----------------------------------------------------------------------
#7. Write a query to display carton id ,(len*width*height)
# as carton_vol and identify the optimum carton
# (carton with the least volume whose volume is greater than the 
#total volume of all items(len * width * height * product_quantity)) 
#for a given order whose order id is 10006 , Assume all items of an order
# are packed into one single carton (box) .(1 ROW)[NOTE : CARTON TABLE] 
#--------------------------------------------------------------------------
SELECT 
    c.carton_id, (c.len * c.width * c.height) AS carton_vol
FROM
    carton AS c
WHERE
    (c.len * c.width * c.height) > (SELECT 
            SUM(pd.len * pd.width * pd.height * oi.product_quantity)
        FROM
            order_items AS oi 
                JOIN
            product AS pd ON oi.product_id = pd.product_id
        WHERE
            oi.order_id = 10006)
ORDER BY carton_vol
LIMIT 1;
#---------------------------------------------------------------------------------------
#8. Write a query to display details (customer id,customer fullname,order id,product quantity)
# of customers who bought more than ten (i.e. total order qty) 
#products with credit card or net banking as the mode of 
#payment per shipped order. (6 ROWS) 
#[NOTE: TABLES TO BE USED - online_customer, order_header, order_items,]
#------------------------------------------------------------------------------------------------
SELECT 
    oc.customer_id,
    CONCAT(customer_fname, ' ', customer_lname) AS fullname,
    oh.order_id,
    SUM(oi.product_quantity) AS total_order_qty,
    oh.payment_mode
FROM
    online_customer AS oc
        JOIN
    order_header AS oh ON oc.customer_id = oh.customer_id
        JOIN
    order_items AS oi ON oh.order_id = oi.order_id
WHERE
    oh.order_status = 'shipped'
        AND (payment_mode = 'credit card'
        OR payment_mode = 'net banking')
GROUP BY oh.order_id
HAVING total_order_qty > 10;
#-------------------------------------------------------
#9.Write a query to display the order_id,customer_id and 
#customer fullname starting with “A” along with (product quantity)
# as total quantity of products shipped for order ids > 10030 (5 Rows)
# [NOTE: TABLES to be used-online_customer,Order_header, order_items]
#----------------------------------------------------------------
SELECT 
    oh.order_id,
    oh.customer_id,
    CONCAT(oc.customer_fname,
            ' ',
            oc.customer_lname) AS fullname,
    oi.product_quantity
FROM
    online_customer AS oc
        JOIN
    order_header AS oh ON oc.customer_id = oh.customer_id
        JOIN
    order_items AS oi ON oh.order_id = oi.order_id
WHERE
    order_status = 'shipped'
        AND oc.customer_fname LIKE 'A%'
        AND oh.order_id > 10030
GROUP BY 1 , 2;

#-----------------------------------------------------------------------------
# 10. Write a query to display product class description, total quantity(sum(product_quantity),
#Total value (product_quantity * product price) and show which class of products have been shipped highest
#(Quantity) to countries outside India other than USA? Also show the total value of those items.
# (1 ROWS)[NOTE:PRODUCT TABLE,ADDRESS TABLE,ONLINE_CUSTOMER TABLE,
#ORDER_HEADER TABLE,ORDER_ITEMS TABLE,PRODUCT_CLASS TABLE]
#-------------------------------------------------------------------------------
SELECT 
    pc.product_class_desc,
    SUM(oi.product_quantity) AS total_order_quantity,
    (oi.product_quantity * pd.product_price) AS Total_value,
    MAX(oi.product_quantity) AS quantity,
    pd.product_quantity_avail
FROM
    product_class AS pc
        JOIN
    product AS pd ON pc.product_class_code = pd.product_class_code
        JOIN
    order_items AS oi ON pd.product_id = oi.product_id
        JOIN
    order_header AS oh ON oi.order_id = oh.order_id
        JOIN
    online_customer AS oc ON oh.customer_id = oc.customer_id
        JOIN
    address AS ad ON oc.address_id = ad.address_id
WHERE
    oh.order_status = 'shipped'
        AND ad.country NOT IN ('India' , 'Usa');


