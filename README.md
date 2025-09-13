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
   - Diagram bol vytvorený na platforme [dbdiagram.io](https://dbdiagram.io/). Do repozitára vložím aj kód ([`oltp.sql`]()) a pridám screenshot schémy dole.

<img width="2207" height="842" alt="image" src="https://github.com/user-attachments/assets/3f88e05a-80d1-4fa2-863c-8545bc559c6a" />


#### 2. Definujte dimenzie a faktové tabuľky pre analytické potreby:
- Navrhnite dátový model (napr. **star schéma** alebo **snowflake schéma**), ktorý bude slúžiť na analýzu predajov podľa času, produktov, kategórií a regiónov  

#### Riešenie

1. **Voľba schémy**
   - Použila som **snowflake** namiesto hviezdy, pretože kategórie produktov majú hierarchiu (podkategórie → kategória → sekcia).  
Samostatná tabuľka `DimCategory` so vzťahom parent→child umožňuje čistejšie analyzovať predaje na rôznych úrovniach kategórií a znižuje duplicitu dát.

3. **Definovanie faktov**
   - Model obsahuje **dve rôzne udalosti**, preto sú vytvorené dve faktové tabuľky s rôznym zrnom:  
   - **`FactSales`** – uchováva predaje na úrovni položky objednávky (koľko kusov, aká cena). Zrno je nastavené takto, aby bolo možné presne analyzovať podľa produktu a kategórie.  
   - **`FactTransactions`** – uchováva platobné transakcie (suma, spôsob platby). Je oddelená, pretože platba a predaj nemusia byť vždy 1:1 (napr. pokusy o platbu, refundy alebo kombinácia viacerých metód).

3. **Definovanie dimenzií**
   - **`DimDate`** – umožňuje analýzu v čase (dni, mesiace, roky).  
   - **`DimProduct`** – uchováva informácie o produkte.  
   - **`DimCategory`** – reprezentuje hierarchiu kategórií.  
   - **`DimCustomer`** – údaje o zákazníkovi, potrebné na spojenie s regiónom.  
   - **`DimRegion`** – uchováva región a krajinu, pre analýzy podľa lokality.  
   - **`DimPaymentMethod`** – porovnanie a analýza spôsobov platieb.  

4. **Spôsob analýzy**
   - Podľa **času** – cez `DimDate`.  
   - Podľa **produktov a kategórií** – `FactSales` prepojený s `DimProduct` a `DimCategory`.  
   - Podľa **regiónov** – `FactSales` alebo `FactTransactions` cez `DimRegion` (region_key je priamo vo faktoch pre rýchlejšie dotazy).  
   - Podľa **spôsobov platieb** – `FactTransactions` cez `DimPaymentMethod`.

5. **Snowflake Schema in DWH**
   - Schema bola vytvorena tiež na platforme [dbdiagram.io](https://dbdiagram.io/). Do repozitára vložím aj kód ([`dwh.sql`]()) a pridám screenshot schémy dole.

<img width="2124" height="902" alt="image" src="https://github.com/user-attachments/assets/7a3937b5-3f10-4a46-a070-d57e8cf17105" />

#### 3. Identifikujte primárne a cudzie kľúče

#### Riešenie

- Každá dimenzia má vlastný **surrogátny kľúč** (`*_key`) ako primárny kľúč (PK).  
  - `DimDate.date_key`, `DimProduct.product_key`, `DimCategory.category_key`, `DimCustomer.customer_key`, `DimRegion.region_key`, `DimPaymentMethod.payment_method_key`.  

- Faktové tabuľky obsahujú **cudzie kľúče (FK)** na tieto dimenzie:  
  - `FactSales`: `order_date_key → DimDate`, `customer_key → DimCustomer`, `product_key → DimProduct`, `region_key → DimRegion`.  
  - `FactTransactions`: `txn_date_key → DimDate`, `customer_key → DimCustomer`, `region_key → DimRegion`, `payment_method_key → DimPaymentMethod`.  

- Okrem toho fakty obsahujú aj **biznis kľúče** (`*_id_bk`) ako atribúty na trasovanie do OLTP systému,  
  ale nie sú použité ako PK/FK. Týmto prístupom sú OLTP identifikátory oddelené od DWH a je umožnená správa historických zmien (napr. SCD).


#### 4. Pripravte SQL skript na definovanie tabuliek podľa vášho návrhu:

#### Riešenie

   - **`oltp.sql`** – operatívna (transakčná) schéma systému e-commerce. Obsahuje tabuľky pre produkty, kategórie, zákazníkov, objednávky, položky objednávok a transakcie. Táto časť predstavuje **source-of-truth** pre všetky obchodné dáta.

   - **`dwh.sql`** – analytický dátový sklad (DWH) navrhnutý vo forme **snowflake**. Obsahuje faktové tabuľky (`FactSales`, `FactTransactions`) a dimenzie (`DimDate`, `DimProduct`, `DimCategory`, `DimCustomer`, `DimRegion`, `DimPaymentMethod`). Tento model je optimalizovaný pre reporting a umožňuje analýzu predajov podľa času, produktov, kategórií a regiónov.

### Dodatočná otázka na diskusiu
- Ako by ste riešili **historické zmeny** (napr. zmena ceny produktu, adresa zákazníka)?

História zmien (napríklad cena produktu alebo adresa zákazníka) sa vo firmách rieši tak, aby sme vedeli pozrieť na dáta tak, ako vyzerali v minulosti. Najčastejšie sa používa SCD Type 2, kde sa pri zmene nevymení pôvodný riadok, ale pridá sa nový s dátumom platnosti. Takto sa dá správne zistiť, aká cena alebo aký región platili v čase objednávky a fakty sa napoja na túto verziu dimenzie. Je to dôležité, pretože pri reportoch za minulý rok nechceme vidieť dnešné ceny alebo adresy.

V praxi to znamená, že vo FactSales sa vždy ukladá aj reálna cena z objednávky a v dimenziách sa držia historické údaje, ako napríklad kategória alebo región zákazníka. Menšie úpravy, ktoré nie sú dôležité (napr. oprava mena), sa dajú riešiť jednoduchým prepísaním (SCD Type 1). Ale pri produktoch a zákazníkoch sa bežne používa SCD2, aby reporty ukazovali presný stav v čase predaja.

---

## 2. Analytická úloha

Vašou úlohou bude spracovať vzorové tabuľky z prostredia e-commerce, dopočítať požadované metriky a vizualizovať ich.  

### Poskytnuté zdrojové tabuľky
- **`sales_order`** – zoznam 30 000 objednávok z roku 2024,  
- **`sales_order_item`** – položky, ktoré sa nachádzajú vo vybraných objednávkach.  

### Použité nástroje
- **ETL nástroj:** [Keboola](https://help.keboola.com/) – nahratie a transformácia dát (SQL / Python),  
- **BI nástroj:** vami zvolený (bezplatný účet), určený na vizualizáciu výsledkov.  

### 2.1. Doplniť názov mesta k objednávke
- V dátach chýba názov mesta, k dispozícii je iba PSČ.  
- Doplniť názov mesta k objednávkam (napr. pomocou externej knižnice alebo datasetu).  
- Vizualizovať:  
  - **TOP 20 miest** vo forme tabuľky podľa metriky **AOV (Average Order Value)**,  
  - **mapu** s počtom vytvorených objednávok z jednotlivých miest.  

### 2.2. Nová kamenná predajňa
- GymBeam má aktuálne predajne v **Košiciach, Budapešti a Prahe**.  
- Na základe vzorky dát (prípadne doplnkových datasetov) určiť vhodnú lokalitu pre **novú predajňu**.  
- Vysvetliť dôvody výberu mesta.  
- Výstup nie je nutné vizualizovať v BI nástroji.  


### 2.3. Vypočítať priemernú mesačnú maržu produktu
- Vypočítať **priemernú mesačnú maržu** pre každý produkt.  
- Vizualizovať vývoj marže v čase s možnosťou filtrovať konkrétny produkt.  

### 2.4. Vypočítať najpredávanejšie dvojice produktov
- Identifikovať **najčastejšie predávané dvojice produktov** v rámci jednej objednávky.  
- Do dvojíc nezapočítavať produkty pridané ako darček.  
- Poskytnúť zoznam **TOP 10 dvojíc** spolu s percentuálnym podielom objednávok, kde sa tieto dvojice vyskytli.  
- Vizualizácia v BI nie je nutná.  


