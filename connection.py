import mysql.connector
connection = mysql.connector.connect(host='localhost', user='root', password='17eelnur', database='senja')
cursor = connection.cursor(dictionary=True)

# import mysql.connector
# print("MySQL Connector imported successfully!")
