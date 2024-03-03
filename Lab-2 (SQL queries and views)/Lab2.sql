/*Lab 2, Sachini Bambaranda (bamba063) and Umamaheswarababu Maddela (umama339)*/
SOURCE company_schema.sql;
SOURCE company_data.sql;

drop view IF EXISTS items_view;
drop table IF EXISTS jbitems;
drop table IF EXISTS jbnew_item;
drop view IF EXISTS jbsale_supply;
drop view  IF EXISTS total_debit_cost_join_view;
drop view  IF EXISTS total_debit_cost_view;

/*Question 1: List all employees, i.e., all tuples in the jbemployee relation."*/
 select name from jbemployee ;

/*
+--------------------+
| name               |
+--------------------+
| Ross, Stanley      |
| Ross, Stuart       |
| Edwards, Peter     |
| Thompson, Bob      |
| Smythe, Carol      |
| Hayes, Evelyn      |
| Evans, Michael     |
| Raveen, Lemont     |
| James, Mary        |
| Williams, Judy     |
| Thomas, Tom        |
| Jones, Tim         |
| Bullock, J.D.      |
| Collins, Joanne    |
| Brunet, Paul C.    |
| Schmidt, Herman    |
| Iwano, Masahiro    |
| Smith, Paul        |
| Onstad, Richard    |
| Zugnoni, Arthur A. |
| Choy, Wanda        |
| Wallace, Maggie J. |
| Bailey, Chas M.    |
| Bono, Sonny        |
| Schwarz, Jason B.  |
+--------------------+
25 rows in set (0.0276 sec)
*/

/*Question 2: List the name of all departments in alphabetical order. Note: by “name” 
we mean the name attribute in the jbdept relation.
*/
select name from jbdept  order by name asc ;

/*
+------------------+
| name             |
+------------------+
| Bargain          |
| Book             |
| Candy            |
| Children's       |
| Children's       |
| Furniture        |
| Giftwrap         |
| Jewelry          |
| Junior Miss      |
| Junior's         |
| Linens           |
| Major Appliances |
| Men's            |
| Sportswear       |
| Stationary       |
| Toys             |
| Women's          |
| Women's          |
| Women's          |
+------------------+
19 rows in set (0.0142 sec)
*/

/*Question 3: What parts are not in store? Note that such parts have the value 0 (zero)
for the qoh attribute (qoh = quantity on hand).*/
select name from jbparts where qoh=0;

/*
+-------------------+
| name              |
+-------------------+
| card reader       |
| card punch        |
| paper tape reader |
| paper tape punch  |
+-------------------+
4 rows in set (0.0137 sec)
*/

/*Question 4: List all employees who have a salary between 9000 (included) and 
10000 (included)?*/
select name from jbemployee where salary between 9000 and 10000;

/*
+----------------+
| name           |
+----------------+
| Edwards, Peter |
| Smythe, Carol  |
| Williams, Judy |
| Thomas, Tom    |
+----------------+
4 rows in set (0.0269 sec)
*/

/*Question 5: List all employees together with the age they had when they started 
working? Hint: use the startyear attribute and calculate the age in the 
SELECT clause.*/
 select name, (startyear - birthyear) as age from jbemployee ;

/*
+--------------------+-----+
| name               | age |
+--------------------+-----+
| Ross, Stanley      |  18 |
| Ross, Stuart       |   1 |
| Edwards, Peter     |  30 |
| Thompson, Bob      |  40 |
| Smythe, Carol      |  38 |
| Hayes, Evelyn      |  32 |
| Evans, Michael     |  22 |
| Raveen, Lemont     |  24 |
| James, Mary        |  49 |
| Williams, Judy     |  34 |
| Thomas, Tom        |  21 |
| Jones, Tim         |  20 |
| Bullock, J.D.      |   0 |
| Collins, Joanne    |  21 |
| Brunet, Paul C.    |  21 |
| Schmidt, Herman    |  20 |
| Iwano, Masahiro    |  26 |
| Smith, Paul        |  21 |
| Onstad, Richard    |  19 |
| Zugnoni, Arthur A. |  21 |
| Choy, Wanda        |  23 |
| Wallace, Maggie J. |  19 |
| Bailey, Chas M.    |  19 |
| Bono, Sonny        |  24 |
| Schwarz, Jason B.  |  15 |
+--------------------+-----+
25 rows in set (0.0136 sec)
*/

/*Question 6: List all employees who have a last name ending with “son”*/
select name from jbemployee where name like '%son,%';

/*
+---------------+
| name          |
+---------------+
| Thompson, Bob |
+---------------+
1 row in set (0.00 sec)
*/

/*Question 7: Which items (note items, not parts) have been delivered by a supplier 
called Fisher-Price? Formulate this query by using a subquery in the 
WHERE clause.*/
select name from jbitem where supplier=(select id from jbsupplier where name ='Fisher-Price') ;

/*
+-----------------+
| name            |
+-----------------+
| Maze            |
| The 'Feel' Book |
| Squeeze Ball    |
+-----------------+
3 rows in set (0.0332 sec)
*/

/*Question 8: Formulate the same query as above, but without a subquery.*/
select i.name from jbitem i, jbsupplier s where i.supplier = s.id and s.name='Fisher-Price';

/*
+-----------------+
| name            |
+-----------------+
| Maze            |
| The 'Feel' Book |
| Squeeze Ball    |
+-----------------+
3 rows in set (0.0148 sec)
*/

/*Question 9: List all cities that have suppliers located in them. Formulate this query 
using a subquery in the WHERE clause.
*/
select name from jbcity where id in(select city from jbsupplier);

/*
+----------------+
| name           |
+----------------+
| Amherst        |
| Boston         |
| New York       |
| White Plains   |
| Hickville      |
| Atlanta        |
| Madison        |
| Paxton         |
| Dallas         |
| Denver         |
| Salt Lake City |
| Los Angeles    |
| San Diego      |
| San Francisco  |
| Seattle        |
+----------------+
15 rows in set (0.0125 sec)
*/

/*Question 10: What is the name and the color of the parts that are heavier than a card 
reader? Formulate this query using a subquery in the WHERE clause. 
(The query must not contain the weight of the card reader as a constant;
instead, the weight has to be retrieved within the query.)*/
select name, color from jbparts where weight>(select weight from jbparts where name='card reader');

/*
+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+
4 rows in set (0.0138 sec)
*/

/*Question 11: Formulate the same query as above, but without a subquery. Again, the 
query must not contain the weight of the card reader as a constant.
*/
select p1.name, p1.color from jbparts p1, jbparts p2 where p2.name='card reader' and p1.weight>p2.weight;

/*
+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+
4 rows in set (0.0133 sec)
*/

/*Question 12: What is the average weight of all black parts?
*/
select avg(weight) as average from jbparts where color='black';

/*
+----------+
| average  |
+----------+
| 347.2500 |
+----------+
1 row in set (0.0130 sec)
*/

/*Question 13: For every supplier in Massachusetts (“Mass”), retrieve the name and the
total weight of all parts that the supplier has delivered? Do not forget to 
take the quantity of delivered parts into account. Note that one row 
should be returned for each supplier.
*/
select s.name, sum(supply.quan*p.weight) as Total_Weight from jbsupplier as s, jbcity as c, jbsupply as supply, jbparts as p where s.city = c.id and c.state='Mass' and s.id = supply.supplier and p.id=supply.part group by s.name;

/*
+--------------+--------------+
| name         | Total_Weight |
+--------------+--------------+
| DEC          |         3120 |
| Fisher-Price |      1135000 |
+--------------+--------------+
2 rows in set (0.0182 sec)
*/

/*Question 14: Create a new relation with the same attributes as the jbitems relation by 
using the CREATE TABLE command where you define every attribute 
explicitly (i.e., not as a copy of another table). Then, populate this new 
relation with all items that cost less than the average price for all items. 
Remember to define the primary key and foreign keys in your table!*/
CREATE TABLE jbitems (id INT, name VARCHAR(20), dept INT NOT NULL,price INT, qoh INT UNSIGNED, supplier INT NOT NULL, CONSTRAINT pk_items PRIMARY KEY(id), CONSTRAINT fk_items_dept FOREIGN KEY (dept) REFERENCES jbdept(id), CONSTRAINT fk_items_supplier FOREIGN KEY (supplier) REFERENCES jbsupplier(id)) ENGINE=InnoDB;
/*
Query OK, 0 rows affected, 1 warning (0.0380 sec)
*/
INSERT INTO jbitems select * from jbitem where price < (select avg(price) from jbitem);
/*
Query OK, 14 rows affected (0.0258 sec)
*/
select * from jbitems;
/*
+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  11 | Wash Cloth      |    1 |    75 |  575 |      213 |
|  19 | Bellbottoms     |   43 |   450 |  600 |       33 |
|  21 | ABC Blocks      |    1 |   198 |  405 |      125 |
|  23 | 1 lb Box        |   10 |   215 |  100 |       42 |
|  25 | 2 lb Box, Mix   |   10 |   450 |   75 |       42 |
|  26 | Earrings        |   14 |  1000 |   20 |      199 |
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 106 | Clock Book      |   49 |   198 |  150 |      125 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 118 | Towels, Bath    |   26 |   250 | 1000 |      213 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
| 120 | Twin Sheet      |   26 |   800 |  750 |      213 |
| 165 | Jean            |   65 |   825 |  500 |       33 |
| 258 | Shirt           |   58 |   650 | 1200 |       33 |
+-----+-----------------+------+-------+------+----------+
14 rows in set (0.0141 sec)
*/

/*Question 15: Create a view that contains the items that cost less than the average 
price for items*/
create view items_view as select * from jbitems;

/*
Query OK, 0 rows affected (0.0690 sec)
*/
select * from items_view;
/*
+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  11 | Wash Cloth      |    1 |    75 |  575 |      213 |
|  19 | Bellbottoms     |   43 |   450 |  600 |       33 |
|  21 | ABC Blocks      |    1 |   198 |  405 |      125 |
|  23 | 1 lb Box        |   10 |   215 |  100 |       42 |
|  25 | 2 lb Box, Mix   |   10 |   450 |   75 |       42 |
|  26 | Earrings        |   14 |  1000 |   20 |      199 |
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 106 | Clock Book      |   49 |   198 |  150 |      125 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 118 | Towels, Bath    |   26 |   250 | 1000 |      213 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
| 120 | Twin Sheet      |   26 |   800 |  750 |      213 |
| 165 | Jean            |   65 |   825 |  500 |       33 |
| 258 | Shirt           |   58 |   650 | 1200 |       33 |
+-----+-----------------+------+-------+------+----------+
14 rows in set (0.0134 sec)
*/

/*Question 16: What is the difference between a table and a view? One is static and the
other is dynamic. Which is which and what do we mean by static 
respectively dynamic?*/

/*
A table is physical storage structure of data while a view is a virtual representation of data based on a query.
Table is static which means data remains unchanged until explicitly modified or deleted.
View is dynamic which means they automatically updates when related objacts are changed.
*/

/*Question 17: Create a view that calculates the total cost of each debit, by considering 
price and quantity of each bought item. (To be used for charging 
customer accounts). The view should contain the sale identifier (debit) 
and the total cost. In the query that defines the view, capture the join 
condition in the WHERE clause (i.e., do not capture the join in the 
FROM clause by using keywords inner join, right join or left join).*/
create view total_debit_cost_view as select s.debit, SUM(s.quantity * i.price) as total_cost from jbsale as s, jbitem as i where s.item = i.id group by s.debit;

/*
Query OK, 0 rows affected (0.0173 sec)
*/

select * from total_debit_cost_view;

/*
+--------+------------+
| debit  | total_cost |
+--------+------------+
| 100581 |       2050 |
| 100582 |       1000 |
| 100586 |      13446 |
| 100592 |        650 |
| 100593 |        430 |
| 100594 |       3295 |
+--------+------------+
6 rows in set (0.0157 sec)
*/

/*Question 18: Do the same as in the previous point, but now capture the join conditions
in the FROM clause by using only left, right or inner joins. Hence, the 
WHERE clause must not contain any join condition in this case. Motivate
why you use type of join you do (left, right or inner), and why this is the 
correct one (in contrast to the other types of joins).*/
create view total_debit_cost_join_view as select s.debit, SUM(s.quantity * i.price) as total_cost from jbsale as s inner join jbitem as i on s.item = i.id group by s.debit;

/*
Query OK, 0 rows affected (0.0168 sec)
*/

select * from total_debit_cost_join_view;

/*
+--------+------------+
| debit  | total_cost |
+--------+------------+
| 100581 |       2050 |
| 100582 |       1000 |
| 100586 |      13446 |
| 100592 |        650 |
| 100593 |        430 |
| 100594 |       3295 |
+--------+------------+
6 rows in set (0.0143 sec)
*/

/*Question 19 a: Remove all suppliers in Los Angeles from the jbsupplier table. This 
will not work right away. Instead, you will receive an error with error 
code 23000 which you will have to solve by deleting some other
related tuples. However, do not delete more tuples from other tables 
than necessary, and do not change the structure of the tables (i.e., 
do not remove foreign keys). Also, you are only allowed to use “Los 
Angeles” as a constant in your queries, not “199” or “900”."*/

-- Trying to remove from jbsupplier
-- delete from jbsupplier where city in (select id from jbcity where name ='Los Angeles');
-- ERROR: 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails (`bamba063`.`jbitem`, CONSTRAINT `fk_item_supplier` FOREIGN KEY (`supplier`) REFERENCES `jbsupplier` (`id`))
-- Have to remove data from jbitem, jbitems

-- Trying to remove relevant data from jbitem
-- delete from jbitem where supplier in (select id from jbsupplier where city in (select id from jbcity where name = 'Los Angeles'));
-- ERROR: 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails (`bamba063`.`jbsale`, CONSTRAINT `fk_sale_item` FOREIGN KEY (`item`) REFERENCES `jbitem` (`id`))
-- Have to remove data from jbsale

-- 
-- Removing relevant data from jbsale
delete from jbsale where item in (select id from jbitem where supplier in(select id from jbsupplier where city in (select id from jbcity where name = 'Los Angeles')));
/*
Query OK, 8 rows affected (0.0233 sec)
*/

-- Removing relevant data from jbitem
delete from jbitem where supplier in (select id from jbsupplier where city in (select id from jbcity where name = 'Los Angeles'));
/*
Query OK, 2 rows affected (0.0172 sec)
*/

-- Removing relevant data from jbitems
delete from jbitems where supplier in (select id from jbsupplier where city in (select id from jbcity where name = 'Los Angeles'));
/*
Query OK, 1 row affected (0.0251 sec)
*/

-- Finally remiving suppliers from Los Angeles
delete from jbsupplier where city in (select id from jbcity where name ='Los Angeles');
/*
Query OK, 1 row affected (0.0186 sec)
*/

-- select data from jbsupplier and jbcity to see if removing is successfull
select s.id, s.name, c.name from jbsupplier as s join jbcity as c on s.city=c.id;

/*
+-----+--------------+----------------+
| id  | name         | name           |
+-----+--------------+----------------+
|   5 | Amdahl       | San Diego      |
|  15 | White Stag   | White Plains   |
|  20 | Wormley      | Hickville      |
|  33 | Levi-Strauss | San Francisco  |
|  42 | Whitman's    | Denver         |
|  62 | Data General | Atlanta        |
|  67 | Edger        | Salt Lake City |
|  89 | Fisher-Price | Boston         |
| 122 | White Paper  | Seattle        |
| 125 | Playskool    | Dallas         |
| 213 | Cannon       | Atlanta        |
| 241 | IBM          | New York       |
| 440 | Spooley      | Paxton         |
| 475 | DEC          | Amherst        |
| 999 | A E Neumann  | Madison        |
+-----+--------------+----------------+
15 rows in set (0.0286 sec)
*/


/*Question 19 b: Explain what you did and why.*/

/*
when we tried to remove the relevant supplier first we got the error "fk constraint 'fk_item_supplier' fails". 
Then we attended on this and try to remove records related to this supplier in jbitem and got the error "fk constraint 'fk_sale_item' fails". 
Then we removed related records from jbsale relation. it was successful.
After that we removed related records from both relations jbitem and jbitems as they are similar. It was also successful.
Finally we were successfull in removing the supplier from supplier table.

*/

/*Question 20:  An employee has tried to find out which suppliers have delivered items 
that have been sold. To this end, the employee has created a view and 
a query that lists the number of items sold from a supplier.
mysql> CREATE VIEW jbsale_supply(supplier, item, quantity) AS
-> SELECT jbsupplier.name, jbitem.name, jbsale.quantity 
-> FROM jbsupplier, jbitem, jbsale
-> WHERE jbsupplier.id = jbitem.supplier 
-> AND jbsale.item = jbitem.id;
Query OK, 0 rows affected (0.01 sec)
mysql> SELECT supplier, sum(quantity) AS sum FROM jbsale_supply
-> GROUP BY supplier;
+--------------+---------------+
| supplier     | sum(quantity) |
+--------------+---------------+
| Cannon       |             6 |
| Levi-Strauss |             1 |
| Playskool    |             2 |
| White Stag   |             4 |
| Whitman's    |             2 |
+--------------+---------------+
5 rows in set (0.00 sec)
Now, the employee also wants to include the suppliers that have 
delivered some items, although for whom no items have been sold so 
far. In other words, he wants to list all suppliers that have supplied any 
item, as well as the number of these items that have been sold. Help 
him! Drop and redefine the jbsale_supply view to also consider suppliers
that have delivered items that have never been sold.
Hint: Notice that the above definition of jbsale_supply uses an (implicit) 
inner join that removes suppliers that have not had any of their delivered
items sold*/
CREATE VIEW jbsale_supply AS SELECT jbsupplier.name AS supplier, jbitem.name AS item, SUM(IFNULL(jbsale.quantity, 0)) AS quantity_sold FROM jbsupplier JOIN  jbitem ON jbsupplier.id = jbitem.supplier LEFT JOIN jbsale ON jbsale.item = jbitem.id GROUP BY jbsupplier.name, jbitem.name;

/*
Query OK, 0 rows affected (0.0169 sec)
*/

SELECT supplier, sum(quantity_sold) AS sum FROM jbsale_supply GROUP BY supplier;

/*
+--------------+-----+
| supplier     | sum |
+--------------+-----+
| Cannon       |   6 |
| Fisher-Price |   0 |
| Koret        |   0 |
| Levi-Strauss |   1 |
| Playskool    |   2 |
| White Stag   |   4 |
| Whitman's    |   2 |
+--------------+-----+
7 rows in set (0.0151 sec)
*/

