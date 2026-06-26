import pyautogui
import time

def send_whatsapp_spam(message, repetitions, delay=0.1):
    print(f"Bereite vor, '{message}' {repetitions} Mal zu senden.")
    print("Bitte stelle sicher, dass dein WhatsApp-Chatfenster geöffnet und aktiv ist.")
    print("Du hast 5 Sekunden Zeit, um zum Chatfenster zu wechseln...")
    time.sleep(5) # Gib dem Benutzer Zeit, zum WhatsApp-Fenster zu wechseln

    for i in range(repetitions):
        pyautogui.typewrite(message)
        pyautogui.press('enter')
        time.sleep(delay)
        print(f"Nachricht {i+1}/{repetitions} gesendet.")

if __name__ == "__main__":
    spam_message = input("Gib die Nachricht ein, die du senden möchtest: ")
    num_repetitions = int(input("Gib die Anzahl der Wiederholungen ein: "))
    send_whatsapp_spam(spam_message, num_repetitions)

