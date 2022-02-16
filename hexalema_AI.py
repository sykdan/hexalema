import random
import copy

#                      1 1 1 1 1
#  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4
# [-,-,-,-,_,*,_,_,_,*,_,-,-,-,-]
#
# - is enter/exit
# * is a crystal
# _ is joint space
#
# Stones shall be referred to as A and B.

chance_of_rolling = {
    0: 1/2**5,
    1: 5/2**5,
    2: 5/2**4,
    3: 5/2**4,
    4: 5/2**5,
    5: 1/2**5
}

def roll_dice():
    return sum([random.randint(0,1),random.randint(0,1),random.randint(0,1),random.randint(0,1),random.randint(0,1)])

def how_many_i_threaten(state,MY_STONES,ENEMY_STONES):
    occupied_by_me = []
    for i in range(len(state)):
        if MY_STONES in state[i]:
            occupied_by_me.append(i)
    
    chance_that_i_reset_a_stone = []
    for me in occupied_by_me:
        options = range(me+1,me+6)
        for option in options:
            if option in [5,9]: continue # We can't reset stones that are on crystals, so if one of the moves involves landing on a crystal space,
                                         # then it's definitely not a threat to the enemy
            if option < 4 or option > 10: continue # If the move involves landing on a entry/exit space, it can't be threatening an enemy's stone

            if ENEMY_STONES in state[option]:
                prob = chance_of_rolling[option-me]
                chance_that_i_reset_a_stone.append(prob)
    
    return sum(chance_that_i_reset_a_stone)

def how_many_threaten_me(state,MY_STONES,ENEMY_STONES):
    occupied_by_enemy = []
    for i in range(len(state)):
        if ENEMY_STONES in state[i]:
            occupied_by_enemy.append(i)
    
    chance_that_enemy_resets_my_stone = []
    for on in occupied_by_enemy:
        options = range(on+1,on+6)
        for option in options:
            if option in [5,9]: continue # We can't reset stones that are on crystals, so if one of the moves involves landing on a crystal space,
                                         # it's definitely not a threat to me
            if option < 4 or option > 10: continue # If the move involves landing on a entry/exit space, it can't be threatening my stones

            if MY_STONES in state[option]:
                prob = chance_of_rolling[option-on]
                chance_that_enemy_resets_my_stone.append(prob)
    
    return sum(chance_that_enemy_resets_my_stone)

def evaluate_state(state,MY_STONES,ai_params):
    ENEMY_STONES = {"A":"B","B":"A"}[MY_STONES] # Invert A to B and vice versa

    enemy_exited_stones = state[-1].count(ENEMY_STONES)
    my_exited_stones = state[-1].count(MY_STONES)

    # The closer it is to 1 the better I am doing
    success_coefficient = min((my_exited_stones+1)/(enemy_exited_stones+1),1)

    # If I'm doing well, I want to get closer to the exiting spaces, and I don't want to lose my stones
    # If I'm NOT doing well, I want to threaten my enemy 

    threat = 1

    influence = how_many_i_threaten(state,MY_STONES,ENEMY_STONES) / ([1,threat,1][ai_params[1]]) # positive 
    threats = how_many_threaten_me(state,MY_STONES,ENEMY_STONES) / ([threat,1,1][ai_params[1]]) # negative
    crystals_occupied = state[5].count(MY_STONES) + state[9].count(MY_STONES) # positive
    safe_stones = sum([state[i].count(MY_STONES) for i in range(11,14)]) # positive

    return (influence - threats) + (crystals_occupied * ai_params[0]) + safe_stones

def can_i_make_a_move(state,from_where,how_many_spaces,MY_STONES):
    ENEMY_STONES = {"A":"B","B":"A"}[MY_STONES]
    if from_where + how_many_spaces > 14: return False # If I end outside of the board (overshoot) then I can't make the move
    if from_where + how_many_spaces == 14: return 2 # I can always exit a piece
    if len(state[from_where+how_many_spaces]) == 0: return 3 # If there's nothing on the board, move is legal
    if len(state[from_where+how_many_spaces]) == 1:
        if state[from_where+how_many_spaces][0] == MY_STONES: return False # If I land on my own stone the move is not legal
        elif from_where+how_many_spaces in [5,9]: return False # I can't reset a stone on a crystal
        elif from_where+how_many_spaces > 3 and from_where+how_many_spaces < 11: return 1 # 1 means a stone reset
        else: return 3 # If the space is clean, move is legal
                       # This is here because the game only has one array for the entire board
                       # If, say, the stone lands on the first space of the entire board, but the enemy
                       # has a stone on the first space of the board too, the space counts as "occupied"
                       # even though the board is split in two paths physically

                       # This is so I don't have to deal with weird data structures   

def game_simulation(ai_params):
    # Prerequisites...
    turn = random.choice(["A","B"])
    gameBoard = [["A","B"] * 7,[],[],[],[],[],[],[],[],[],[],[],[],[],[]]
    done = False
    winner = ""

    # Game loop
    while not done:
        k = roll_dice() # Roll dice first...
        if k == 0: # Turn lost.
            turn = {"A":"B","B":"A"}[turn]
            continue

        # What positions are my stones in?
        my_spaces = []
        for i in range(len(gameBoard)):
            if turn in gameBoard[i]:
                my_spaces.append(i)

        possible_moves = [(space,can_i_make_a_move(gameBoard,space,k,turn)) for space in my_spaces]
        possible_moves = [move for move in possible_moves if move[1]]

        if len(possible_moves) == 0: # Turn lost.
            turn = {"A":"B","B":"A"}[turn]
            continue

        original_state = evaluate_state(gameBoard,turn,ai_params[turn])
        best_score = -999999
        best_move = None
        for move in possible_moves:
            # Make a copy of the board, this is for separating the game field from the calculation
            tempGameBoard = copy.deepcopy(gameBoard)
            space = move[0]
            _type = move[1]
            from_where = tempGameBoard[space]
            to_where = tempGameBoard[space+k]
            if _type == 1: # Type = 1 if there is resetting involved
                tempGameBoard[0].append(to_where.pop(0)) # Return the stone in the destination to the beginning
                from_where.remove(turn) # Remove one stone of mine from the index
                to_where.append(turn) # Add one stone of mine to that index
            else:
                from_where.remove(turn) # Remove one stone of mine from the index
                to_where.append(turn) # Add one stone of mine to that index

            s = evaluate_state(tempGameBoard,turn,ai_params[turn]) - original_state
            if s > best_score:
                best_score = s
                best_move = move

        space = best_move[0]
        _type = best_move[1]
        from_where = gameBoard[space] # Position I move from
        to_where = gameBoard[space+k]
        if _type == 1: # If there is resetting involved...
            gameBoard[0].append(to_where.pop(0)) # Return the stone in the destination to the beginning
            from_where.remove(turn) # Remove one stone of mine from the index
            to_where.append(turn) # Add one stone of mine to that index
        else:
            from_where.remove(turn) # Remove one stone of mine from the index
            to_where.append(turn) # Add one stone of mine to that index

        if space+k in [5,9]:
            turn = {"A":"B","B":"A"}[turn]
        turn = {"A":"B","B":"A"}[turn]

        if gameBoard[-1].count("A") == 7:
            done = True
            winner = "A"
        elif gameBoard[-1].count("B") == 7:
            done = True
            winner = "B"

    return winner

def test(a_params,b_params):
    h = []
    for i in range(100):
        h.append(game_simulation({"A":a_params,"B":b_params}))
    print("A won {} simulated games.".format(h.count("A")))
    print("B won {} simulated games.".format(h.count("B")))


test(
    (3,1),
    (3,2)
)
