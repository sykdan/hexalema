import random
import copy

#                      1 1 1 1 1
#  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4
# [-,-,-,-,_,*,_,_,_,*,_,-,-,-,-]
#
# - je privat
# * je kvocna
# _ je spolecny
#
# Kameny necht jsou oznaceny A a B.

sance_na_hozeni = {
    0: 1/2**5,
    1: 5/2**5,
    2: 5/2**4,
    3: 5/2**4,
    4: 5/2**5,
    5: 1/2**5
}

def hod_kostkama():
    return sum([random.randint(0,1),random.randint(0,1),random.randint(0,1),random.randint(0,1),random.randint(0,1)])

def kolik_ohrozuji(stav,MOJE_KAMENY,NEPRITEL_KAMENY):
    mnou_obsazene = []
    for i in range(len(stav)):
        if MOJE_KAMENY in stav[i]:
            mnou_obsazene.append(i)
    
    sance_ze_vyhodim = []
    for ja in mnou_obsazene:
        moznosti = range(ja+1,ja+6)
        for moznost in moznosti:
            if moznost in [5,9]: continue # Pokud by kamen skoncil na kvocne, urcite neohrozuje souperuv kamen
            if moznost < 4 or moznost > 10: continue # Pokud by kamen skoncil v soukrome casti, urcite neohrozuje souperuv kamen

            if NEPRITEL_KAMENY in stav[moznost]:
                prob = sance_na_hozeni[moznost-ja]
                sance_ze_vyhodim.append(prob)
    
    return sum(sance_ze_vyhodim)

def kolik_me_ohrozuje(stav,MOJE_KAMENY,NEPRITEL_KAMENY):
    nepritelem_obsazene = []
    for i in range(len(stav)):
        if NEPRITEL_KAMENY in stav[i]:
            nepritelem_obsazene.append(i)
    
    sance_ze_me_vyhodi = []
    for on in nepritelem_obsazene:
        moznosti = range(on+1,on+6)
        for moznost in moznosti:
            if moznost in [5,9]: continue # Pokud by kamen skoncil na kvocne, urcite neohrozuje muj kamen
            if moznost < 4 or moznost > 10: continue # Pokud by kamen skoncil v soukrome casti, urcite neohrozuje muj kamen

            if MOJE_KAMENY in stav[moznost]:
                prob = sance_na_hozeni[moznost-on]
                sance_ze_me_vyhodi.append(prob)
    
    return sum(sance_ze_me_vyhodi)

def vyhodnotit_stav(stav,MOJE_KAMENY,ai_params):
    NEPRITEL_KAMENY = {"A":"B","B":"A"}[MOJE_KAMENY] # Pokud je to A, vrat B. Pokud je to B, vrat A.

    nepritel_odevzdane = stav[-1].count(NEPRITEL_KAMENY)
    moje_odevzdane = stav[-1].count(MOJE_KAMENY)

    # Cim bliz je k 1, tim lip se mi dari.
    koeficient_uspechu = min((moje_odevzdane+1)/(nepritel_odevzdane+1),1)

    # Pokud se mi dari, nechci prijit o kameny, a chci bit bliz k cili.
    # Pokud se mi nedari, chci spis ohrozovat nepritele.

    vliv = kolik_ohrozuji(stav,MOJE_KAMENY,NEPRITEL_KAMENY)
    hrozby = kolik_me_ohrozuje(stav,MOJE_KAMENY,NEPRITEL_KAMENY)
    kvocna = stav[5].count(MOJE_KAMENY) + stav[9].count(MOJE_KAMENY)
    zabezpecene_kameny = sum([stav[i].count(MOJE_KAMENY) for i in range(11,14)])

    return 0

def muzu_tahnout(stav,od,o_kolik,MOJE_KAMENY):
    NEPRITEL_KAMENY = {"A":"B","B":"A"}[MOJE_KAMENY]
    if od + o_kolik > 14: return False # Pokud bych skoncil mimo herni desku, tak nemuzu
    if od + o_kolik == 14: return 2 # Vyvadet muzu vzdy
    if len(stav[od+o_kolik]) == 0: return 3 # Pokud na poli nic neni, tak muzu
    if len(stav[od+o_kolik]) == 1:
        if stav[od+o_kolik][0] == MOJE_KAMENY: return False # Pokud bych si stoupl na svuj vlastni kamen, tak ne
        elif od+o_kolik in [5,9]: return False # Kamen na kvocne nemuzu vyhodit
        elif od+o_kolik > 3 and od+o_kolik < 11: return 1 # Vyhozeni kamene
        else: return 3 # Pokud na poli nic neni, tak muzu
    

def hra(ai_params):
    turn = random.choice(["A","B"])
    gameBoard = [["A","B"] * 7,[],[],[],[],[],[],[],[],[],[],[],[],[],[]]
    done = False
    winner = ""
    while not done:
        k = hod_kostkama() # Napred hodim kostkou...
        if k == 0: # Ztrata tahu.
            turn = {"A":"B","B":"A"}[turn]
            continue

        moje_pole = [] # Kde vsude mam kameny?
        for i in range(len(gameBoard)):
            if turn in gameBoard[i]:
                moje_pole.append(i)

        mozne_tahy = [(pole,muzu_tahnout(gameBoard,pole,k,turn)) for pole in moje_pole]
        mozne_tahy = [tah for tah in mozne_tahy if tah[1]]

        if len(mozne_tahy) == 0: # Ztrata tahu.
            turn = {"A":"B","B":"A"}[turn]
            continue

        puvodni_stav = vyhodnotit_stav(gameBoard,turn,ai_params[turn])
        nejlepsi_skore = -999999
        nejlepsi_tah = None
        for tah in mozne_tahy:
            tempGameBoard = copy.deepcopy(gameBoard)
            pole = tah[0]
            typ = tah[1]
            odkud = tempGameBoard[pole]
            kam = tempGameBoard[pole+k]
            if typ == 1: # Pokud dochazi k vyhazovani...
                tempGameBoard[0].append(kam.pop(0)) # Kamen na destinaci vrat na zacatek
                odkud.remove(turn) # Seber jeden muj kamen
                kam.append(turn) # Pridej tam jeden muj kamen
            else:
                odkud.remove(turn) # Seber jeden muj kamen
                kam.append(turn) # Pridej tam jeden muj kamen

            s = vyhodnotit_stav(tempGameBoard,turn,ai_params[turn]) - puvodni_stav
            if s > nejlepsi_skore:
                nejlepsi_skore = s
                nejlepsi_tah = tah

        pole = nejlepsi_tah[0]
        typ = nejlepsi_tah[1]
        odkud = gameBoard[pole] # Pozice ze ktere tahnu
        kam = gameBoard[pole+k]
        if typ == 1: # Pokud dochazi k vyhazovani...
            gameBoard[0].append(kam.pop(0)) # Kamen na destinaci vrat na zacatek
            odkud.remove(turn) # Seber jeden muj kamen
            kam.append(turn) # Pridej tam jeden muj kamen
        else:
            odkud.remove(turn) # Seber jeden muj kamen
            kam.append(turn) # Pridej tam jeden muj kamen

        if pole+k in [5,9]:
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
    for i in range(10):
        h.append(hra({"A":a_params,"B":b_params}))
    print("A vyhral {} her.".format(h.count("A")))
    print("B vyhral {} her.".format(h.count("B")))


test([],[])
