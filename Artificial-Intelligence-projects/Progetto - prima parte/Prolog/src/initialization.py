import tkinter as tk
from tkinter import font

def create_interface():
    # Callback function to handle button clicks
    def on_button_click(choice):
        result.set(choice)
        root.destroy()

    # Create the main window
    root = tk.Tk()
    root.title("Scelta della strategia da utilizzare per risolvere il labirinto")
    root.geometry("500x400")
    root.configure(bg="#f0f0f0")

    # Create a StringVar to store the result
    result = tk.StringVar()

    # Define a custom font
    custom_font = font.Font(family="Helvetica", size=14, weight="bold")

    # Button configuration
    button_config = {
        "font": custom_font,
        "bg": "green",
        "fg": "white",
        "activebackground": "#45a049",
        "width": 20,
        "height": 2
    }

    # Create buttons with different options
    button1 = tk.Button(root, text="Base first strategy", command=lambda: on_button_click("Opzione 1"), **button_config)
    button2 = tk.Button(root, text="Base second strategy", command=lambda: on_button_click("Opzione 2"), **button_config)
    button3 = tk.Button(root, text="Final first strategy", command=lambda: on_button_click("Opzione 3"), **button_config)
    button4 = tk.Button(root, text="Final second strategy", command=lambda: on_button_click("Opzione 4"), **button_config)

    # Configure the grid layout to center the buttons
    root.grid_rowconfigure(0, weight=1)
    root.grid_rowconfigure(5, weight=1)
    root.grid_columnconfigure(0, weight=1)
    root.grid_columnconfigure(2, weight=1)

    # Place buttons in the window using grid layout
    button1.grid(row=1, column=1, pady=10, padx=20)
    button2.grid(row=2, column=1, pady=10, padx=20)
    button3.grid(row=3, column=1, pady=10, padx=20)
    button4.grid(row=4, column=1, pady=10, padx=20)

    # Start the Tkinter main loop
    root.mainloop()

    # Return the selected result
    print(result.get())
    return result.get()
