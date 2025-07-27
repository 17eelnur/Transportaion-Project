import mysql.connector
from mysql.connector import Error
import connection as conn

# Add a user using the stored procedure
def add_user():
    username = input("Enter username: ")
    email = input("Enter email: ")
    password = input("Enter your password: ")
    cursor = conn.cursor

    try:
        print(f"Attempting to add user '{username}'...")
        cursor.callproc('addOneUser', [username, email, password])
        for result in conn.cursor.stored_results():
            message = result.fetchall()
            print(message[0])
        conn.connection.commit()
    except Error as e:
        print(f"Error occurred: {e}")

# Delete a user using the stored procedure
def delete_user(username: str) -> None:
    try:
        conn.cursor.callproc('DeleteOneUser', [username])
        for result in conn.cursor.stored_results():
            message = result.fetchall()
            print(message[0])
        conn.connection.commit()
    except conn.mysql.connector.Error as err:
        print(f"Error: {err}")


# Add a ship using the stored procedure
def add_ship(name: str, color: str, country: str) -> None:
    try:
        conn.cursor.callproc('addShip', [name, color, country])
        for result in conn.cursor.stored_results():
            message = result.fetchall()
            print(message[0])
        conn.connection.commit()
    except conn.mysql.connector.Error as err:
        print(f"Error: {err}")


# Delete a ship using the stored procedure
def delete_ship(name: str) -> None:
    try:
        conn.cursor.callproc('deleteShip', [name])
        for result in conn.cursor.stored_results():
            message = result.fetchall()
            print(message[0])
        conn.connection.commit()
    except conn.mysql.connector.Error as err:
        print(f"Error: {err}")


# Display all users using the stored procedure
def display_users():
    cursor = conn.cursor
    try:
        cursor.callproc('selectAllUsers')
        for result in cursor.stored_results():
            users = result.fetchall()
            if users:
                print("Users:")
                for user in users:
                    print(user)
            else:
                print("No users found.")
    except mysql.connector.Error as e:
        print(f"Error: {e}")

# Display all ships using the stored procedure
def display_ships() -> None:
    try:
        conn.cursor.callproc('selectAllShips')
        for result in conn.cursor.stored_results():
            ships = result.fetchall()
            if ships:
                print("Ships:")
                for ship in ships:
                    print(ship)
            else:
                print("No ships found.")
    except conn.mysql.connector.Error as err:
        print(f"Error: {err}")



# Main menu
def main():
    if conn:
        while True:
            print("\n--- Shipping Database Management ---")
            print("1. Add User")
            print("2. Delete User")
            print("3. Display Users")
            print("4. Add Ship")
            print("5. Delete Ship")
            print("6. Display Ships")
            print("7. Exit")
            choice = input("Enter your choice: ")
            
            if choice == "1":
                print("We are here!")
                add_user()
            elif choice == "2":
                username=input("username:")
                delete_user(username)
            elif choice == "3":
                display_users()
            elif choice == "4":
                name=input("name:")
                color=input("color:")
                country=input("country:")
                add_ship(name, color,country)
            elif choice == "5":
                name=input("shipname:")
                delete_ship(name)
            elif choice == "6":
                display_ships()
            elif choice == "7":
                print("Exiting... Goodbye!")
                break
            else:
                print("Invalid choice. Please try again.")

# Run the main function
if __name__ == "__main__":
    main()
