'''
    Siyan
    CS5001
    Fall 2018
    November 28, 2018
'''

from asyncio import sleep
import score, turtle, random
import tkinter as tk
from tkinter import ttk
from board import Board
from PIL import Image, ImageTk
import customtkinter
import clips

env = clips.Environment()

env.load("player/control.clp")
env.load("player/cell.clp")
env.load("player/choose_move.clp")
    
env.reset()

# Define all the possible directions in which a player's move can flip 
# their adversary's tiles as constant (0 – the current row/column, 
# +1 – the next row/column, -1 – the previous row/column)
MOVE_DIRS = [(-1, -1), (-1, 0), (-1, +1),
             (0, -1),           (0, +1),
             (+1, -1), (+1, 0), (+1, +1)]

class Othello(Board):
    ''' Othello class.
        Attributes: current_player, an integer 0 or 1 to represent two 
                    different players (the user and the computer)
                    num_tiles, a list of integers for number of tiles each 
                    player has
                    n, an integer for nxn board
                    all other attributes inherited from class Board
        n (integer) is optional in the __init__ function
        current_player, num_tiles and all other inherited attributes 
        are not taken in the __init__

        Methods: initialize_board, make_move, flip_tiles, has_tile_to_flip, 
                 has_legal_move, get_legal_moves, is_legal_move, 
                 is_valid_coord, run, play, make_random_move, 
                 report_result, __str__ , __eq__ and all other methods 
                 inherited from class Board
    '''

    def __init__(self, n = 8):
        '''
            Initilizes the attributes. 
            Only takes one optional parameter; others have default values.
        '''
        Board.__init__(self, n)
        self.current_player = 0
        self.num_tiles = [2, 2]
        self.difficulty = None

    def initialize_board(self):
        ''' Method: initialize_board
            Parameters: self
            Returns: nothing
            Does: Draws the first 4 tiles in the middle of the board
                  (the size of the board must be at least 2x2).
        '''
        if self.n < 2:
            return

        coord1 = int(self.n / 2 - 1)
        coord2 = int(self.n / 2)
        initial_squares = [(coord1, coord2), (coord1, coord1),
                           (coord2, coord1), (coord2, coord2)]
        
        for i in range(len(initial_squares)):
            color = i % 2
            row = initial_squares[i][0]
            col = initial_squares[i][1]
            self.board[row][col] = color + 1
            self.draw_tile(initial_squares[i], color)
        
    def make_move(self):
        ''' Method: make_move
            Parameters: self
            Returns: nothing
            Does: Draws a tile for the player's next legal move on the 
                  board and flips the adversary's tiles. Also, updates the 
                  state of the board (1 for black tiles and 2 for white 
                  tiles), and increases the number of tiles of the current 
                  player by 1.
        '''
        if self.is_legal_move(self.move):
            #mossa legale
            #print("mossa legale", self.move)
            self.board[self.move[0]][self.move[1]] = self.current_player + 1
            self.num_tiles[self.current_player] += 1
            self.draw_tile(self.move, self.current_player)
            self.flip_tiles()
            
    def flip_tiles(self):
        ''' Method: flip_tiles
            Parameters: self
            Returns: nothing
            Does: Flips the adversary's tiles for current move. Also, 
                  updates the state of the board (1 for black tiles and 
                  2 for white tiles), increases the number of tiles of 
                  the current player by 1, and decreases the number of 
                  tiles of the adversary by 1.
        '''
        curr_tile = self.current_player + 1 
        for direction in MOVE_DIRS:
            if self.has_tile_to_flip(self.move, direction):
                i = 1
                while True:
                    row = self.move[0] + direction[0] * i
                    col = self.move[1] + direction[1] * i
                    if self.board[row][col] == curr_tile:
                        break
                    else:
                        self.board[row][col] = curr_tile
                        self.num_tiles[self.current_player] += 1
                        self.num_tiles[(self.current_player + 1) % 2] -= 1
                        self.draw_tile((row, col), self.current_player)
                        i += 1

    def has_tile_to_flip(self, move, direction):
        ''' Method: has_tile_to_flip
            Parameters: self, move (tuple), direction (tuple)
            Returns: boolean 
                     (True if there is any tile to flip, False otherwise)
            Does: Checks whether the player has any adversary's tile to flip
                  with the move they make.

                  About input: move is the (row, col) coordinate of where the 
                  player makes a move; direction is the direction in which the 
                  adversary's tile is to be flipped (direction is any tuple 
                  defined in MOVE_DIRS).
        '''
        i = 1
        if self.current_player in (0, 1) and \
           self.is_valid_coord(move[0], move[1]):
            curr_tile = self.current_player + 1
            while True:
                row = move[0] + direction[0] * i
                col = move[1] + direction[1] * i
                if not self.is_valid_coord(row, col) or \
                    self.board[row][col] == 0:
                    return False
                elif self.board[row][col] == curr_tile:
                    break
                else:
                    i += 1
        return i > 1

    def has_legal_move(self):
        ''' Method: has_legal_move
            Parameters: self
            Returns: boolean 
                     (True if the player has legal move, False otherwise)
            Does: Checks whether the current player has any legal move 
                  to make.
        '''
        for row in range(self.n):
            for col in range(self.n):
                move = (row, col)
                if self.is_legal_move(move):
                    return True
        return False
    
    def get_legal_moves(self):
        ''' Method: get_legal_moves
            Parameters: self
            Returns: a list of legal moves that can be made
            Does: Finds all the legal moves the current player can make.
                  Every move is a tuple of coordinates (row, col).
        '''
        moves = []
        for row in range(self.n):
            for col in range(self.n):
                move = (row, col)
                if self.is_legal_move(move):
                    moves.append(move)
        return moves

    def is_legal_move(self, move):
        ''' Method: is_legal_move
            Parameters: self, move (tuple)
            Returns: boolean (True if move is legal, False otherwise)
            Does: Checks whether the player's move is legal.

                  About input: move is a tuple of coordinates (row, col).
        '''
        #print( move, (move != () and self.is_valid_coord(move[0], move[1]) \
         #  and self.board[move[0]][move[1]] == 0))
        if move != () and self.is_valid_coord(move[0], move[1]) \
           and self.board[move[0]][move[1]] == 0:
            for direction in MOVE_DIRS:
                if self.has_tile_to_flip(move, direction):
                    #print("has tile to flip")
                    return True
        return False

    def is_valid_coord(self, row, col):
        ''' Method: is_valid_coord
            Parameters: self, row (integer), col (integer)
            Returns: boolean (True if row and col is valid, False otherwise)
            Does: Checks whether the given coordinate (row, col) is valid.
                  A valid coordinate must be in the range of the board.
        '''
        if 0 <= row < self.n and 0 <= col < self.n:
            return True
        return False

    def run(self):
        ''' Method: run
            Parameters: self
            Returns: nothing
            Does: Starts the game, sets the user to be the first player,
                  and then alternate back and forth between the user and 
                  the computer until the game is over.
        '''
        if self.current_player not in (0, 1):
            print('Error: unknown player. Quit...')
            return
        
        if self.difficulty is None:
            self.draw_difficulty_banner()
        else:
            self.current_player = 0
            print('Your turn.')
            turtle.onscreenclick(self.play)
            turtle.mainloop()
  
    def reviseClipsBoard(self):
        #env.reset()
        game_difficulty = env.find_template('game-difficulty')
        game_difficulty.assert_fact(difficulty=clips.Symbol(self.difficulty))
        diff = game_difficulty.facts()
        for d in diff:
            [difficulty] = [*d]
            #print(difficulty)  
        time = env.find_template("time")
        times=time.facts()
        
        t = next(times)
        [step] = [*t]
        s=step[1]+1
       
        t.retract()
        time.assert_fact(step = s)
        #print("----------NEW STEP %d----------", s)
        
        cell = env.find_template('cell')
        for i in range(len(self.board)):
            line = self.board[i]
            for j in range(len(line)):
                if(self.board[i][j]==0):
                    cell.assert_fact(step=s, row = i, col =j, nearCorner=1, content=clips.Symbol('empty'), type=clips.Symbol('empty'))
                elif(self.board[i][j]==1):
                    cell.assert_fact(step=s, row = i, col =j, nearCorner=1, content=clips.Symbol('black'), type=clips.Symbol('empty'))
                else:
                    cell.assert_fact(step=s, row = i, col =j, nearCorner=1, content=clips.Symbol('white'), type=clips.Symbol('empty'))
        cells = cell.facts()      

    def play(self, x, y):
        ''' Method: play
            Parameters: self, x (float), y (float)
            Returns: nothing
            Does: Plays alternately between the user's turn and the computer's
                  turn. The user plays the first turn. For the user's turn, 
                  gets the user's move by their click on the screen, and makes 
                  the move if it is legal; otherwise, waits indefinitely for a 
                  legal move to make. For the computer's turn, just makes a 
                  random legal move. If one of the two players (user/computer)
                  does not have a legal move, switches to another player's 
                  turn. When both of them have no more legal moves or the 
                  board is full, reports the result, saves the user's score 
                  and ends the game.

                  About the input: (x, y) are the coordinates of where 
                  the user clicks.
        '''
        # Play the user's turn
        if self.has_legal_move():
            self.get_coord(x, y)
            if self.is_legal_move(self.move):
                turtle.onscreenclick(None)
                self.make_move()
            else:
                return

        def bestMove(move_1, move_2):
            if move_1[2] <= move_2[2]:
                return move_1
            else:
                return move_2
        # Play the computer's turn
        while True:
            time = env.find_template("time")    
            times=time.facts()
            
            for t in times:
              [step] = [*t] #step
              #print(step)
              
              break
            s=step[1]
            #print(step)
            
            self.current_player = 1
            if self.has_legal_move():
                print('Computer\'s turn.')
                #self.make_random_move()
                self.reviseClipsBoard()  
                env.run()    
                template = env.find_template('move')   
                moves = template.facts()
                noMove = True
                self.move = (0, 0,  10000.0 )
                i = 0
                for m in moves:
                   [step, ro, co, cost] = [*m]
                   i = i + 1
                   self.temp = bestMove(self.move, (int(ro[1]), int(co[1]), float(cost[1])))
                   if self.is_legal_move(self.temp):
                       #print("is legal")
                       self.move = self.temp
                       noMove = False
                      
                #print("###### fuori dal for ######")
                if (noMove):
                    #print("nessuna mossa")
                    return
                else:
                    #print("c'è una mossa")
                    turtle.onscreenclick(None)
                    self.make_move()
                
                self.current_player = 0
                if self.has_legal_move(): 
                    print("il player ha mosse legali")
                    break
                else:
                    print("il player non ha mosse legali")
            else:
                break
        
        # Switch back to the user's turn
        self.current_player = 0

        # Check whether the game is over
        if not self.has_legal_move() or sum(self.num_tiles) == self.n ** 2:
            turtle.onscreenclick(None)
            print('-----------')
            self.report_result()
            name = input('Enter your name for posterity\n')
            if not score.update_scores(name, self.num_tiles[0]):
                print('Your score has not been saved.')
            print('Thanks for playing Othello!')
            close = input('Close the game screen? Y/N\n')
            if close == 'Y':
                turtle.bye()
            elif close != 'N':
                print('Quit in 3s...')
                turtle.ontimer(turtle.bye, 3000)
        else:
            print('Your turn.')
            turtle.onscreenclick(self.play)
        
    def make_random_move(self):
        ''' Method: make_random_move
            Parameters: self
            Returns: nothing
            Does: Makes a random legal move on the board.
        '''
        moves = self.get_legal_moves()
        if moves:
            self.move = random.choice(moves)
            self.make_move()

    def report_result(self):
        ''' Method: report_result
            Parameters: self
            Returns: nothing
            Does: Announces the winner and reports the final number of
                  tiles each play has.
        '''
        print('GAME OVER!!')
        if self.num_tiles[0] > self.num_tiles[1]:
            print('YOU WIN!!',
                  'You have %d tiles, but the computer only has %d!' 
                  % (self.num_tiles[0], self.num_tiles[1]))
        elif self.num_tiles[0] < self.num_tiles[1]:
            print('YOU LOSE...',
                  'The computer has %d tiles, but you only have %d :(' 
                  % (self.num_tiles[1], self.num_tiles[0]))
        else:
            print("IT'S A TIE!! There are %d of each!" % self.num_tiles[0])
    
    def __str__(self):
        ''' 
            Returns a printable version of the current status of the 
            game to print.
        '''
        player_str = 'Current player: ' + str(self.current_player + 1) + '\n'
        num_tiles_str = '# of black tiles -- 1: ' + str(self.num_tiles[0]) + \
                        '\n' + '# of white tiles -- 2: ' + \
                        str(self.num_tiles[1]) + '\n'
        board_str = Board.__str__(self)
        printable_str = player_str + num_tiles_str + board_str

        return printable_str

    def __eq__(self, other):
        '''
            Compares two instances. 
            Returns True if they have both the same board attribute and 
            current player, False otherwise.
        '''
        return Board.__eq__(self, other) and self.current_player == \
        other.current_player
        
    def draw_difficulty_banner(self):
        ''' Function: draw_difficulty_banner
            Parameters: self
            Returns: nothing
            Does: Draws dialog windows where the player can choose the difficulty level. The dialog window must be over the board and the board isn't usable
        '''
        customtkinter.set_appearance_mode("dark")  # Modes: system (default), light, dark
        customtkinter.set_default_color_theme("dark-blue")  # Themes: blue (default), dark-blue, green

        self.root = customtkinter.CTk()
        self.root.title("Choose Difficulty Level")
        self.root.geometry("400x400")

        #set text color orange
        label = customtkinter.CTkLabel(self.root, text="Select Difficulty",  font=("Helvetica", 24))
        label.pack(pady=40)

        self.difficulty = tk.StringVar(value="Easy")

        easy_rb = customtkinter.CTkRadioButton(self.root, text="Easy", variable=self.difficulty, value="easy",                          	
                                                                                                    #width=50,
                                                                                                    #height=50,
                                                                                                    radiobutton_width=20,
                                                                                                    radiobutton_height=20,
                                                                                                    corner_radius=3,
                                                                                                    border_width_unchecked = 2,
                                                                                                    border_width_checked=3,
                                                                                                    border_color="white",
                                                                                                    hover_color="lightblue",
                                                                                                    fg_color="blue",
                                                                                                    hover=True,
                                                                                                    text_color="white",
                                                                                                    font=("Helvetica", 18),
                                                                                                    state="normal",
                                                                                                    text_color_disabled="blue")
        easy_rb.pack(anchor=tk.W, padx=20, pady=10)

        hard_rb = customtkinter.CTkRadioButton(self.root, text="Hard", variable=self.difficulty, value="hard",
                                                                                                    #width=50,
                                                                                                    #height=50,
                                                                                                    radiobutton_width=20,
                                                                                                    radiobutton_height=20,
                                                                                                    corner_radius=3,
                                                                                                    border_width_unchecked = 2,
                                                                                                    border_width_checked=3,
                                                                                                    border_color="white",
                                                                                                    hover_color="lightblue",
                                                                                                    fg_color="blue",
                                                                                                    hover=True,
                                                                                                    text_color="white",
                                                                                                    font=("Helvetica", 18),
                                                                                                    state="normal",
                                                                                                    text_color_disabled="blue")
        hard_rb.pack(anchor=tk.W, padx=20, pady=10)
        
        vhard_rb = customtkinter.CTkRadioButton(self.root, text="Very Hard", variable=self.difficulty, value="vhard",
                                                                                            #width=50,
                                                                                            #height=50,
                                                                                            radiobutton_width=20,
                                                                                            radiobutton_height=20,
                                                                                            corner_radius=3,
                                                                                            border_width_unchecked = 2,
                                                                                            border_width_checked=3,
                                                                                            border_color="white",
                                                                                            hover_color="lightblue",
                                                                                            fg_color="blue",
                                                                                            hover=True,
                                                                                            text_color="white",
                                                                                            font=("Helvetica", 18),
                                                                                            state="normal",
                                                                                            text_color_disabled="blue")
        vhard_rb.pack(anchor=tk.W, padx=20, pady=10)

        start_button = customtkinter.CTkButton(self.root, border_color= "black", border_width=3, text="Start Game", command=self.start_game, font=("Helvetica", 22))
        start_button.pack(pady=20)

        self.root.mainloop()
        
    def start_game(self):
        
        #close the dialog window
        self.root.destroy()
        self.difficulty = self.difficulty.get()
        print(f"Selected Difficulty: {self.difficulty}")
        
        self.draw_board()
        self.initialize_board()
        # Starts playing the game
        # The user makes a move by clicking one of the squares on the board
        # The computer makes a random legal move every time
        # Game is over when there are no more lagal moves or the board is full
        self.run()
        
