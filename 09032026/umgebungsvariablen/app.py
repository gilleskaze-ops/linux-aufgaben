import os

app_name = os.environ.get("APP_NAME", "DefaultApp")
greeting = os.environ.get("GREETING_MESSAGE", "Hello World!")
db_url = os.environ.get("DATABASE_URL", "Not Available")


print(f"App: {app_name}")
print(f"Nachricht: {greeting}")
print(f"Datenbank: {db_url}")
