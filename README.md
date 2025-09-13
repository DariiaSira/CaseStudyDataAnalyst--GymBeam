# Case Study - Medior Data Analyst in GymBeam

## 1. Návrh dátového modelu pre e-commerce platformu

Predstavte si, že pracujete pre e-commerce spoločnosť, ktorá predáva produkty online. Vašou úlohou je navrhnúť optimálny dátový model, ktorý bude podporovať:  
1. Správu produktov a ich kategórií  
2. Zákaznícke objednávky  
3. Históriu transakcií  
4. Analýzu predajov podľa rôznych dimenzií (napr. čas, produkt, kategória, región)  

---

### Zadanie

#### 1. Navrhnite dátový model vo forme ER diagramu (Entity-Relationship diagram), ktorý pokryje nasledovné požiadavky:
- **Produkty**: ID, názov, cena, opis, dostupnosť, kategória  
- **Kategórie**: ID kategórie, názov kategórie, nadradená kategória (hierarchia kategórií)  
- **Zákazníci**: ID zákazníka, meno, email, adresa (vrátane regiónu), dátum registrácie  
- **Objednávky**: ID objednávky, zákazník, dátum objednávky, stav objednávky, položky objednávky  
- **Položky objednávky**: ID položky, produkt, množstvo, cena za jednotku  
- **Transakcie**: ID transakcie, objednávka, dátum, spôsob platby, suma

#### Riešenie

1. **Identifikovať entity**  
   - Produkty, Kategórie, Zákazníci, Objednávky, Položky objednávky, Transakcie  
   - pomocná: Regióny (pre adresy a analytiku)

2. **Určiť kľúčové atribúty**  
   - ID, názvy, dátumy, sumy, väzby na súvisiace tabuľky

3. **Definovať vzťahy a kardinality**  
   - Kategórie (self-FK) → hierarchia „1:N“ -- Jedna kategória môže mať viac podkategórií. Self-referencia umožňuje stromovú štruktúru.  
   - Kategórie ↔ Produkty → 1:N  -- Každý produkt patrí práve do jednej kategórie, ale jedna kategória môže obsahovať mnoho produktov. 
   - Regióny ↔ Zákazníci → 1:N  -- Zákazník sa nachádza v jednom regióne, ale v regióne môže byť veľa zákazníkov.  
   - Zákazníci ↔ Objednávky → 1:N  -- Každý zákazník môže vytvoriť viacero objednávok, ale objednávka patrí iba jednému zákazníkovi.  
   - Objednávky ↔ Položky objednávky → 1:N  -- Objednávka sa skladá z viacerých položiek, ale každá položka je naviazaná na jednu objednávku.
   - Produkty ↔ Položky objednávky → 1:N  -- Jeden produkt sa môže objaviť vo viacerých položkách (v rôznych objednávkach), ale položka vždy obsahuje iba jeden produkt.  
   - Objednávky ↔ Transakcie → 1:N  -- Objednávka môže mať jednu alebo viac transakcií (napr. ak zákazník zaplatí na viac častí), ale transakcia patrí len k jednej objednávke. Prípady: čiastočná platba (split payment), opakovaný pokus o platbu, doplatok/refund. V jednoduchých e-shopoch je to väčšinou 1:1, ale model je navrhnutý flexibilne.  

4. **Nastaviť PK/FK**  
   - PK: všetky ID  
   - FK: väzby podľa kategórií, regiónov, zákazníkov, objednávok a produktov  

5. **ER diagram**
   - Diagram bol vytvorený na platforme [dbdiagram.io](https://dbdiagram.io/). Do repozitára vložím aj kód (`schema.dbml`) a pridám screenshot schémy dole.
     <img width="1854" height="919" alt="image" src="https://github.com/user-attachments/assets/a811076c-1213-4cea-8b8f-7671a17e4e30" />

#### 2. Definujte dimenzie a faktové tabuľky pre analytické potreby:
- Navrhnite dátový model (napr. **star schéma** alebo **snowflake schéma**), ktorý bude slúžiť na analýzu predajov podľa času, produktov, kategórií a regiónov  

#### 3. Identifikujte:
- Primárne a cudzie kľúče  

#### 4. Pripravte SQL schému:
- Vytvorte SQL skript na definovanie tabuliek podľa vášho návrhu  

---

### Dodatočná otázka na diskusiu
- Ako by ste riešili **historické zmeny** (napr. zmena ceny produktu, adresa zákazníka)?  
