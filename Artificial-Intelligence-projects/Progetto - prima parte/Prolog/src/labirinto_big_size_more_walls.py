import tkinter as tk
from tkinter import font
from PIL import Image, ImageTk
from pyswip import Prolog
from initialization import create_interface
import time

final_strategy_path = "src/final_strategy/"
base_strategy_path = "src/base_strategy/"
final_first_strategy_path = "src/final_strategy/first_strategy.pl"
base_first_strategy_path = "src/base_strategy/first_strategy.pl"
first_strategy_goal = "ricerca_iterative_deepening(Cammino, FinalVisited)"
final_second_strategy_path = "src/final_strategy/second_strategy.pl"
base_second_strategy_path = "src/base_strategy/second_strategy.pl"
second_strategy_goal = "ricerca_a_star(Cammino, FinalVisited)"

choice = create_interface()
choice_goal = ""

# Inizializza la sessione di Prolog
prolog = Prolog()

if(choice == "Opzione 1" or choice == "Opzione 2"):
    prolog.consult(base_strategy_path + "knowledge_big_size_more_walls.pl")
    if(choice == "Opzione 1"):
        prolog.consult(base_first_strategy_path)
        choice_goal = first_strategy_goal
    else:
        prolog.consult(base_second_strategy_path)
        choice_goal = second_strategy_goal

if(choice == "Opzione 3" or choice == "Opzione 4"):
    prolog.consult(final_strategy_path + "knowledge_big_size_more_walls.pl")
    prolog.consult(final_strategy_path + "applicable.pl")
    prolog.consult(final_strategy_path + "det_position.pl")
    prolog.consult(final_strategy_path + "transform.pl")
    prolog.consult(final_strategy_path + "utility.pl")
    if(choice == "Opzione 3"):
        prolog.consult(final_first_strategy_path)
        choice_goal = first_strategy_goal
    else:
        prolog.consult(final_second_strategy_path)
        choice_goal = second_strategy_goal

prolog.assertz(":-[knowledge_big_size_more_walls]")
prolog.assertz("size(11, 11)")

w = "wall"
h = "hammer"
hg = "hammer-gem"
dw = "destroyable-wall"
g = "gem"
p = "portal"
mp = "monster-position"
mt = "monster-trace"
pg = "path-gem"

# Posizione iniziale del mostro
posizione_mostro = [6, 7]

# Configurazione della finestra tkinter
root = tk.Tk()
root.title("Labirinto")

# Funzione per caricare immagini
def carica_immagine(file):
    img = Image.open(file)
    img = img.resize((79, 79), Image.ADAPTIVE)  # Ridimensiona a 79x79 per adattarsi meglio a 80x80 pixel
    return ImageTk.PhotoImage(img)

immagini = {
    w: carica_immagine("src/img/wall.png"),
    h: carica_immagine("src/img/hammer.png"),
    dw: carica_immagine("src/img/destroyable-wall.png"),
    g: carica_immagine("src/img/gem.png"),
    p: carica_immagine("src/img/portal.png"),
    mp: carica_immagine("src/img/monster-position.png"),
    " ": carica_immagine("src/img/empty-alternative.jpg"),
    hg: carica_immagine("src/img/hammer-gem.png"),
    mt: carica_immagine("src/img/monster-path.jpg"),
    pg: carica_immagine("src/img/path-gem.png")
}

if(choice == "Opzione 3" or choice == "Opzione 4"):
    labirinto = [
        [" ", " ", " ", h, " ", " ", " ", g, " ", " ", " ", " "],
        [dw, dw, w, " ", " ", " ", " ", " ", " ", " ", " ", " "],
        [dw, p, w, " ", " ", " ", " ", " ", " ", " ", " ", w],
        [dw, dw, w, " ", " ", " ", " ", " "," ", " ", " ", " "],
        [" ", " ", " ", " ", g, " ", h, " ", " ", " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", w, w, w, " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", w, mp, " ", " ", " ", " "],
        [" ", g, " ", " ", " ", " ", w, w, w, " ", " ", " "],
        [" ", " ", " ", " ", g, " ", " ", h, " "," ", " ", " "],
        [" ", " ", w, " ", " "," "," ", h," "," ", " ", " "],
        [" ", " ", " ", " ", " ", " ", " ", w, w, w, w, w],
        [" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", p]
    ]

    monster_trace = [
        [" ", " ", " ", h, " ", " ", " ", " ", " ", " ", " ", " "],
        [dw, dw, w, " ", " ", " ", " ", " ", " ", " ", " ", " "],
        [dw, p, w, " ", " ", " ", " ", " ", " ", " ", " ", w],
        [dw, dw, w, " ", " ", " ", " ", " "," ", " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", h, " ", " ", " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", w, w, w, " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", w, mp, " ", " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", w, w, w, " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", " ", h, " "," ", " ", " "],
        [" ", " ", w, " ", " ", " ", " ", h," "," ", " ", " "],
        [" ", " ", " ", " ", " ", " ", " ", w, w, w, w, w],
        [" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", p]
    ]
elif(choice == "Opzione 1" or choice == "Opzione 2"):
    labirinto = [
        [" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "],
        [" ", p, w, " ", " ", " ", " ", " ", " ", " ", " ", w],
        [" ", " ", " ", " ", " ", " ", " ", " "," ", " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", w, w, w, " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", w, mp, " ", " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", w, w, w, " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", " ", " ", " "," ", " ", " "],
        [" ", " ", w, " ", " "," "," ", " "," "," ", " ", " "],
        [" ", " ", " ", " ", " ", " ", " ", w, w, w, w, w],
        [" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", p]
    ]

    monster_trace = [
        [" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "],
        [" ", p, w, " ", " ", " ", " ", " ", " ", " ", " ", w],
        [" ", " ", " ", " ", " ", " ", " ", " "," ", " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", w, w, w, " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", w, mp, " ", " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", w, w, w, " ", " ", " "],
        [" ", " ", " ", " ", " ", " ", " ", " ", " "," ", " ", " "],
        [" ", " ", w, " ", " "," "," ", " "," "," ", " ", " "],
        [" ", " ", " ", " ", " ", " ", " ", w, w, w, w, w],
        [" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", p]
    ]


canvas_items = []

# Funzione per disegnare il labirinto
def disegna_labirinto(canvas, labirinto):
    canvas_items.clear()
    for riga in range(len(labirinto)):
        canvas_items_row = []
        for colonna in range(len(labirinto[riga])):
            x0 = colonna * 80
            y0 = riga * 80
            item = canvas.create_image(x0, y0, anchor=tk.NW, image=immagini[" "])
            item = canvas.create_image(x0, y0, anchor=tk.NW, image=immagini[labirinto[riga][colonna]])
            canvas_items_row.append(item)
        canvas_items.append(canvas_items_row)

def get_first_solution(prolog, query):
    first_result = []
    # Esegui la query
    result_generator = prolog.query(query)
    # Estrai solo il primo risultato
    first_result = next(result_generator, None)
    return first_result

# Funzione per aggiornare il labirinto con la direzione del movimento
def aggiorna_labirinto(labirinto, direction, final_visited, gem_states):
    x, y = posizione_mostro[0], posizione_mostro[1]
    monster_trace[x][y] = mt

    print(final_visited)

    def muovi_mostro_e_gemme(i):
        x1 = 0 
        x2 = 0 
        y1 = 0 
        y2 = 0
        if(i == 0):
            disegna_labirinto(canvas=canvas, labirinto=labirinto) 
        else:
            if i >= len(final_visited):
                # Evidenziare il percorso del mostro
                if(choice == "Opzione 3" or choice == "Opzione 4"):
                    for gem in gem_states[i-1]:
                        final_gem_x, final_gem_y = generate_coordinate_from_pos(gem)
                        if(monster_trace[final_gem_x][final_gem_y] == mt):
                            monster_trace[final_gem_x][final_gem_y] = pg
                        else:
                            monster_trace[final_gem_x][final_gem_y] = g
                disegna_labirinto(canvas=canvas, labirinto=monster_trace)
                button.config(state=tk.NORMAL)  
                return
            
            dir = direction[i-1]
            from_visited_x, from_visited_y = generate_coordinate_from_pos(final_visited[i-1])
            to_visited_x, to_visited_y = generate_coordinate_from_pos(final_visited[i])
            
            # Ottieni le coordinate delle celle da visitare
            x1, y1 = from_visited_x, from_visited_y
            x2, y2 = to_visited_x, to_visited_y

            coordinates = bresenham(x1, y1, x2, y2)
            
            # Definisci i movimenti per ciascuna direzione
            if dir == 'nord':
                if(len(coordinates) > 0):
                    for x, y in coordinates:
                        monster_trace[x][y] = mt
                        canvas.itemconfig(canvas_items[x][y], image=immagini[" "])
                monster_trace[x2][y2] = mp
                canvas.itemconfig(canvas_items[x2][y2], image=immagini[mp])
            elif dir == 'sud':
                if(len(coordinates) > 0):
                    for x, y in coordinates:
                        monster_trace[x][y] = mt
                        canvas.itemconfig(canvas_items[x][y], image=immagini[" "])
                monster_trace[x2][y2] = mp
                canvas.itemconfig(canvas_items[x2][y2], image=immagini[mp])
            elif dir == 'ovest':
                if(len(coordinates) > 0):
                    for x, y in coordinates:
                        monster_trace[x][y] = mt
                        canvas.itemconfig(canvas_items[x][y], image=immagini[" "])
                monster_trace[x2][y2] = mp
                canvas.itemconfig(canvas_items[x2][y2], image=immagini[mp])
            elif dir == 'est':
                if(len(coordinates) > 0):
                    for x, y in coordinates:
                        monster_trace[x][y] = mt
                        canvas.itemconfig(canvas_items[x][y], image=immagini[" "])
                monster_trace[x2][y2] = mp
                canvas.itemconfig(canvas_items[x2][y2], image=immagini[mp])

            if(choice == "Opzione 3" or choice == "Opzione 4"):
                for gem in gem_states[i-1]:
                    old_x, old_y = generate_coordinate_from_pos(gem)
                    obstacle_detector_flag = len(obstacle_detector([(old_x, old_y)], targets={h})) > 0 
                    if(obstacle_detector_flag and monster_trace[old_x][old_y] == h):
                        canvas.itemconfig(canvas_items[old_x][old_y], image=immagini[h])
                    else:
                        if(monster_trace[old_x][old_y] == mp):
                            canvas.itemconfig(canvas_items[old_x][old_y], image=immagini[mp])
                        else:
                            canvas.itemconfig(canvas_items[old_x][old_y], image=immagini[" "])
                
                for gem in gem_states[i]:
                    new_x, new_y = generate_coordinate_from_pos(gem)
                    obstacle_detector_flag = len(obstacle_detector([(new_x, new_y)], targets={h})) > 0 
                    if(obstacle_detector_flag and monster_trace[new_x][new_y] == h):
                        canvas.itemconfig(canvas_items[new_x][new_y], image=immagini[hg])
                    else:
                        canvas.itemconfig(canvas_items[new_x][new_y], image=immagini[g])

        root.after(1500, muovi_mostro_e_gemme, i + 1)
        
        # Aggiorna la posizione del mostro
        posizione_mostro[0], posizione_mostro[1] = x2, y2
    
    muovi_mostro_e_gemme(0)

def bresenham(x1, y1, x2, y2):
    # Lista delle coordinate intermedie
    coordinates = []
    # Calcolo delle differenze e dei passi
    dx = abs(x2 - x1)
    dy = abs(y2 - y1)
    sx = 1 if x1 < x2 else -1
    sy = 1 if y1 < y2 else -1
    err = dx - dy
    while True:
        # Aggiungi la coordinata corrente alla lista
        coordinates.append((x1, y1))
        # Se siamo arrivati al punto finale, termina il ciclo
        if x1 == x2 and y1 == y2:
            break
        e2 = 2 * err
        if e2 > -dy:
            err -= dy
            x1 += sx
        if e2 < dx:
            err += dx
            y1 += sy
    return coordinates

def obstacle_detector(coordinates, targets):
    obstacle_positions = []
    for x, y in coordinates:
        if labirinto[x][y] in targets:
            obstacle_positions.append((x, y))
    return obstacle_positions

def extract_monster_position(final_visited):
    monster_positions = []
    for pos in final_visited:
        mpos = pos[0]
        monster_positions.append(mpos)
    return monster_positions

def generate_coordinate_from_pos(position):
    # Form the string 'pos(monster_position, x, y)' in position extract the cordinate
    x = position.split(',')[1]
    y = position.split(',')[2][:-1]
    return int(x), int(y)

def extract_gem_states(visited):
    gemstates = []
    for pos in visited:
        #add to gemstates elment from pos[1] to the end
        gemstates.append(pos[1:])
    return gemstates
       
# Funzione per risolvere il labirinto con Prolog
def risolvi_labirinto():
    # Button cant't clicked
    button.config(state=tk.DISABLED)

    # Reset del percorso del mostro 
    for x in range(len(monster_trace)):
        for y in range(len(monster_trace[x])):
            if(labirinto[x][y] == g):
                monster_trace[x][y] = " "
            else:
                monster_trace[x][y] = labirinto[x][y]
                if(labirinto[x][y] == mp):
                    posizione_mostro[0] = x
                    posizione_mostro[1] = y

    disegna_labirinto(canvas, labirinto)
    
    start_time = time.time()
    first_result = get_first_solution(prolog, choice_goal)
    end_time = time.time()
    #round to 2 decimal places
    execution_time = round(end_time - start_time, 2)
  
    
    final_visited = first_result['FinalVisited']
    if(choice == "Opzione 3" or choice == "Opzione 4"):
        final_visited = extract_monster_position(first_result['FinalVisited'])
    Gemstates = extract_gem_states(first_result['FinalVisited'])
    
    if first_result:
        aggiorna_labirinto(labirinto, first_result['Cammino'], final_visited[::-1], Gemstates[::-1])
        print("Soluzione trovata:", first_result['Cammino'])
    else:
        print("Nessuna soluzione trovata")
        # Button can be clicked
        button.config(state=tk.NORMAL)
    print("Execution time: ", execution_time, " seconds")

# Configurazione del canvas
canvas = tk.Canvas(root, width=960, height=960)  # Dimensione del canvas aumentata
canvas.pack()

# Disegna il labirinto
disegna_labirinto(canvas, labirinto)

button_font = font.Font(family='Minecraft', size=14, weight='bold')
button = tk.Button(root, text="Risolvi Labirinto", command=risolvi_labirinto,
                   font=button_font, bg='green', fg='white', padx=10, pady=5,
                   borderwidth=5, relief=tk.RAISED)
button.pack(pady=20)

# Avvia la finestra
root.mainloop()
