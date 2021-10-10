import random

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
                print(kolik_ohrozuji([["A","B"] * 6,[],[],[],[],["A"],["A"],[],["B"],[],[],[],[],[],[]],"A","B")kolik_ohrozuji([["A","B"] * 6,[],[],[],[],["A"],["A"],[],["B"],[],[],[],[],[],[]],"A","B"))
                sance_ze_vyhodim.append(prob)
    
    return sance_ze_vyhodim

def vyhodnotit_stav(stav,MOJE_KAMENY,ai_params):
    NEPRITEL_KAMENY = {"A":"B","B":"A"}[MOJE_KAMENY] # Pokud je to A, vrat B. Pokud je to B, vrat A.

    nepritel_odevzdane = stav[-1].count(NEPRITEL_KAMENY)
    moje_odevzdane = stav[-1].count(MOJE_KAMENY)

    # Cim bliz je k 1, tim lip se mi dari.
    koeficient_uspechu = min(moje_odevzdane/nepritel_odevzdane,1)

    # Pokud se mi dari, nechci prijit o kameny, a chci bit bliz k cili.
    # Pokud se mi nedari, chci spis ohrozovat nepritele.
